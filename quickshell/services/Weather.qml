pragma Singleton

import QtQuick
import Quickshell.Io

// Weather from Open-Meteo: now, today's range and the next few hours. Enabled
// once weatherLatitude or weatherLongitude is set in the config. Coordinates
// are sent to Open-Meteo. The place is saved to the config by locate(), from
// the IP address (sent to ipinfo.io), or by choose(), from a city search
// (the text is sent to Open-Meteo's geocoding).
QtObject {
    id: root

    readonly property real latitude: Settings.weatherLatitude
    readonly property real longitude: Settings.weatherLongitude
    readonly property bool enabled: latitude !== 0 || longitude !== 0
    readonly property string url: "https://api.open-meteo.com/v1/forecast?latitude=" + latitude + "&longitude=" + longitude
        + "&current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code,is_day"
        + "&hourly=temperature_2m,weather_code,is_day,precipitation_probability"
        + "&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max"
        + "&timezone=auto&forecast_days=2"

    // The configured place name, or the coordinates.
    readonly property string place: Settings.weatherLocation
        || Math.abs(latitude).toFixed(2) + "°" + (latitude < 0 ? "S" : "N") + ", "
            + Math.abs(longitude).toFixed(2) + "°" + (longitude < 0 ? "W" : "E")

    property string temperature: ""     // "31°C"
    property string condition: ""
    property string icon: "cloud"
    property var now: null              // temperature, feelsLike, humidity, wind
    property var today: null            // high, low, uv, sunrise, sunset
    property var hours: []              // time, temperature, icon, rain
    property date updated
    readonly property bool fetching: fetcher.running

    property bool locating: false       // finding or saving the place
    property bool locateFailed: false

    property var places: []             // search results: name, region, detail, latitude, longitude
    property bool searchFailed: false
    readonly property bool searchBusy: searcher.running
    property string query: ""
    property string searchedQuery: ""

    onUrlChanged: refresh()

    function refresh() {
        if (!enabled || fetcher.running)
            return;
        fetcher.command = ["curl", "-sf", "--max-time", "10", url];
        fetcher.running = true;
    }

    function locate() {
        if (locating)
            return;
        locating = true;
        locateFailed = false;
        locator.running = true;
    }

    function choose(place) {
        if (locating)
            return;
        locating = true;
        locateFailed = false;
        save(place.latitude, place.longitude, place.region && place.region !== place.name ? place.name + ", " + place.region : place.name);
    }

    function search(text) {
        query = text.trim();
        searchFailed = false;
        if (query.length < 2)
            places = [];
        else if (!searcher.running)
            runSearch();
    }

    function runSearch() {
        searchedQuery = query;
        searcher.command = ["curl", "-sfG", "--max-time", "10", "--data-urlencode", "name=" + query,
            "--data", "count=6&language=en&format=json", "https://geocoding-api.open-meteo.com/v1/search"];
        searcher.running = true;
    }

    function fail() {
        locating = false;
        locateFailed = true;
    }

    property Process locator: Process {
        command: ["curl", "-sf", "--max-time", "10", "https://ipinfo.io/json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const ip = JSON.parse(this.text);
                    const [lat, lon] = ip.loc.split(",").map(Number);
                    if (isNaN(lat) || isNaN(lon))
                        throw "no coordinates";
                    root.save(lat, lon, [ip.city, ip.region].filter(Boolean).join(", "));
                } catch (error) {
                    root.fail();
                }
            }
        }
        onExited: code => {
            if (code !== 0)
                root.fail();
        }
    }

    function save(lat, lon, name) {
        saver.command = ["sh", "-c", saver.script, "sh", Settings.path, String(lat), String(lon), name];
        saver.running = true;
    }

    // Merges the three keys into the config in place; an unreadable config is
    // left untouched. Values arrive as arguments, never as shell text.
    property Process saver: Process {
        readonly property string script: "f=$1; mkdir -p \"$(dirname \"$f\")\"; [ -s \"$f\" ] || echo '{}' > \"$f\"; "
            + "jq --argjson lat \"$2\" --argjson lon \"$3\" --arg name \"$4\" "
            + "'.weatherLatitude = $lat | .weatherLongitude = $lon | .weatherLocation = $name' \"$f\" > \"$f.tmp\" "
            + "&& cat \"$f.tmp\" > \"$f\"; s=$?; rm -f \"$f.tmp\"; exit $s"
        onExited: code => {
            root.locating = false;
            root.locateFailed = code !== 0;
        }
    }

    property Process searcher: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.query.length < 2)
                    return;
                try {
                    root.places = (JSON.parse(this.text).results || []).map(place => ({
                        name: place.name,
                        region: place.admin1 || "",
                        detail: [place.admin1, place.country].filter(Boolean).join(", "),
                        latitude: place.latitude,
                        longitude: place.longitude
                    }));
                } catch (error) {
                    root.places = [];
                    root.searchFailed = true;
                }
            }
        }
        // Text typed while a search ran is searched next.
        onExited: {
            if (root.query !== root.searchedQuery && root.query.length >= 2)
                root.runSearch();
        }
    }

    // WMO weather codes.
    function describe(code) {
        if (code === 0) return "Clear";
        if (code === 1) return "Mostly clear";
        if (code === 2) return "Partly cloudy";
        if (code === 3) return "Overcast";
        if (code <= 48) return "Fog";
        if (code <= 57) return "Drizzle";
        if (code <= 67) return "Rain";
        if (code <= 77) return "Snow";
        if (code <= 82) return "Showers";
        if (code <= 86) return "Snow showers";
        if (code <= 99) return "Thunderstorm";
        return "";
    }

    function iconFor(code, day) {
        if (code <= 1) return day ? "weatherClear" : "weatherNight";
        if (code === 2) return day ? "weatherFewClouds" : "weatherFewCloudsNight";
        if (code === 3) return "weatherOvercast";
        if (code <= 48) return "weatherFog";
        if (code <= 67 || (code >= 80 && code <= 82)) return "weatherShowers";
        if (code <= 86) return "weatherSnow";
        return "weatherStorm";
    }

    property Process fetcher: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(this.text);
                    const c = data.current;
                    const d = data.daily;
                    const h = data.hourly;
                    const day = c.is_day === 1;

                    root.now = {
                        temperature: Math.round(c.temperature_2m),
                        feelsLike: Math.round(c.apparent_temperature),
                        humidity: c.relative_humidity_2m,
                        wind: Math.round(c.wind_speed_10m)
                    };
                    root.today = {
                        high: Math.round(d.temperature_2m_max[0]),
                        low: Math.round(d.temperature_2m_min[0]),
                        uv: Math.round(d.uv_index_max[0]),
                        sunrise: Qt.formatDateTime(new Date(d.sunrise[0]), "h:mm AP"),
                        sunset: Qt.formatDateTime(new Date(d.sunset[0]), "h:mm AP")
                    };
                    // Times are local and share a format, so they compare as text.
                    const start = h.time.findIndex(time => time > c.time);
                    root.hours = start < 0 ? [] : h.time.slice(start, start + 6).map((time, i) => ({
                        time: Qt.formatDateTime(new Date(time), "h AP"),
                        temperature: Math.round(h.temperature_2m[start + i]),
                        icon: root.iconFor(h.weather_code[start + i], h.is_day[start + i] === 1),
                        rain: h.precipitation_probability[start + i]
                    }));
                    root.temperature = root.now.temperature + "°C";
                    root.condition = root.describe(c.weather_code);
                    root.icon = root.iconFor(c.weather_code, day);
                    root.updated = new Date();
                } catch (error) {
                    console.warn("latto: weather unavailable: " + error);
                    if (root.temperature === "")
                        root.condition = "Unavailable";
                }
            }
        }
    }

    property Timer timer: Timer {
        interval: 900000
        running: root.enabled
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
