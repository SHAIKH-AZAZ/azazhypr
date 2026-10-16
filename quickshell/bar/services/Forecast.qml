pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Forecast bundle for the weather panel: scripts/weather.sh (wttr.in for the place, Open-Meteo for
// forecast + air quality). Location: Config.weatherLocation, overridden by what you save in the
// panel (~/.local/share/quickshell-bar/weather.json). "" = guessed from your IP.
Singleton {
    id: root

    readonly property string dir: Quickshell.env("HOME") + "/.local/share/quickshell-bar"
    property string location: Config.weatherLocation
    property string label: ""               // display name of a picked suggestion (location is then "lat,lon")
    property var suggestions: []            // [{ name, admin1, country, lat, lon }] for the typed text
    property var data: null
    property double fetched: 0
    property bool loading: false
    property bool failed: false
    property int tick: 0                    // bumps each minute so "updated 5 min ago" stays fresh

    readonly property var cur: data?.f?.current ?? null
    readonly property string place: data?.place ?? ""
    readonly property var aqi: data?.aqi ?? null

    property bool again: false              // a refresh was requested while one was running
    function refresh() {
        if (loading) { again = true; return }
        loading = true;
        proc.running = true;
    }
    function setLocation(s, lbl) {
        location = s.trim();
        label = lbl ?? "";
        suggestions = [];
        save();
        fetched = 0;
        data = null;
        refresh();
    }
    function save() { file.setText(JSON.stringify({ location: location, label: label })) }
    // Open-Meteo geocoding: places matching what you type
    function suggest(q) {
        const t = q.trim();
        sug.running = false;
        if (t.length < 2) { suggestions = []; return }
        sug.query = t;
        sug.running = true;
    }

    // ---- helpers for the panel ----
    function ago() {
        void tick;
        if (!fetched) return failed ? "Could not load weather" : "Loading…";
        const m = Math.floor((Date.now() - fetched) / 60000);
        return m < 1 ? "Updated just now" : m < 60 ? "Updated " + m + " min ago" : "Updated " + Math.floor(m / 60) + " h ago";
    }
    // WMO weather code -> text
    function desc(code) {
        if (code === 0) return "Clear sky";
        if (code === 1) return "Mainly clear";
        if (code === 2) return "Partly cloudy";
        if (code === 3) return "Overcast";
        if (code === 45 || code === 48) return "Fog";
        if (code >= 51 && code <= 55) return code === 51 ? "Light drizzle" : "Drizzle";
        if (code === 56 || code === 57) return "Freezing drizzle";
        if (code === 61) return "Light rain";
        if (code === 63) return "Rain";
        if (code === 65) return "Heavy rain";
        if (code === 66 || code === 67) return "Freezing rain";
        if (code === 71) return "Light snow";
        if (code === 73) return "Snow";
        if (code === 75 || code === 77) return "Heavy snow";
        if (code >= 80 && code <= 82) return code === 80 ? "Light showers" : "Showers";
        if (code === 85 || code === 86) return "Snow showers";
        if (code === 95) return "Thunderstorm";
        if (code >= 96) return "Thunderstorm, hail";
        return "Unknown";
    }
    // Material Symbols name for a WMO weather code
    function icon(code, day) {
        const d = day !== false;
        if (code === 0 || code === 1) return d ? "sunny" : "bedtime";
        if (code === 2) return d ? "partly_cloudy_day" : "partly_cloudy_night";
        if (code === 3) return "cloud";
        if (code === 45 || code === 48) return "foggy";
        if (code >= 51 && code <= 57) return "rainy";
        if (code >= 61 && code <= 67) return "rainy";
        if (code >= 71 && code <= 77) return "weather_snowy";
        if (code >= 80 && code <= 82) return "rainy";
        if (code === 85 || code === 86) return "weather_snowy";
        if (code >= 95) return "thunderstorm";
        return "device_thermostat";
    }
    function compass(deg) {
        return ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"][Math.round(deg / 22.5) % 16];
    }
    function aqiLabel(v) {
        return v <= 50 ? "Good" : v <= 100 ? "Moderate" : v <= 150 ? "Sensitive" : v <= 200 ? "Unhealthy" : v <= 300 ? "Very bad" : "Hazardous";
    }
    function aqiColor(v) {
        return v <= 50 ? Theme.green : v <= 100 ? Theme.yellow : v <= 150 ? Theme.orange : v <= 200 ? Theme.red : Theme.purple;
    }

    // hourly slots from now: [{ label, temp, code, day }]
    function hours(from, count, step) {
        void data;
        const h = data?.f?.hourly;
        if (!h || !cur) return [];
        const base = h.time.indexOf(cur.time.slice(0, 13) + ":00");
        const out = [];
        for (let i = 0; i < count; i++) {
            const k = base + from + i * step;
            if (k < 0 || k >= h.time.length) break;
            out.push({
                label: (from + i * step === 0) ? "Now" : Qt.formatDateTime(new Date(h.time[k]), "h AP"),
                temp: Math.round(h.temperature_2m[k]),
                code: h.weather_code[k],
                day: h.is_day[k] === 1
            });
        }
        return out;
    }
    // today's remaining day in 3 h steps starting at the next multiple of 3, from midnight if earlier
    function todaySlots() {
        const h = data?.f?.hourly;
        if (!h || !cur) return [];
        const day = cur.time.slice(0, 10);
        const out = [];
        for (let k = 0; k < h.time.length && out.length < 8; k++) {
            if (h.time[k].slice(0, 10) !== day) continue;
            const hr = +h.time[k].slice(11, 13);
            if (hr % 3 !== 0) continue;
            out.push({ label: Qt.formatDateTime(new Date(h.time[k]), "h AP"), temp: Math.round(h.temperature_2m[k]), code: h.weather_code[k], day: h.is_day[k] === 1 });
        }
        return out;
    }
    function days() {
        void data;
        const d = data?.f?.daily;
        if (!d) return [];
        return d.time.map((t, i) => ({
            name: i === 0 ? "Today" : Qt.formatDate(new Date(t + "T12:00:00"), "ddd"),
            code: d.weather_code[i],
            hi: Math.round(d.temperature_2m_max[i]),
            lo: Math.round(d.temperature_2m_min[i]),
            sunrise: d.sunrise[i],
            sunset: d.sunset[i]
        }));
    }
    function clock(iso) { return iso ? Qt.formatDateTime(new Date(iso), "h:mm AP") : "--" }

    Process {
        id: proc
        command: ["sh", Quickshell.shellPath("scripts/weather.sh"), root.location, root.label]
        stdout: StdioCollector {
            onStreamFinished: {
                root.loading = false;
                if (root.again) { root.again = false; root.refresh(); return }   // location changed meanwhile
                try {
                    root.data = JSON.parse(text);
                    root.fetched = Date.now();
                    root.failed = false;
                } catch (e) { root.failed = true }
            }
        }
    }
    Process {
        id: sug
        property string query: ""
        command: ["sh", "-c", 'curl -fsS --max-time 5 -G "https://geocoding-api.open-meteo.com/v1/search" --data-urlencode "name=$1" -d count=6 -d language=en -d format=json 2>/dev/null | jq -c "[.results[]? | {name, admin1, country, lat: .latitude, lon: .longitude}]"', "sh", query]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.suggestions = JSON.parse(text) } catch (e) { root.suggestions = [] }
            }
        }
    }
    Timer { interval: 60000; running: true; repeat: true; onTriggered: root.tick++ }
    Timer { interval: Config.slowPollMs; running: Config.showWeather; repeat: true; onTriggered: root.refresh() }
    // first fetch waits for the saved location, otherwise it would start with the IP guess and show
    // the wrong place until the next refresh. A short timer covers a missing / unreadable file.
    Timer { interval: 1500; running: true; onTriggered: if (root.fetched === 0 && !root.loading) root.refresh() }

    Process { running: true; command: ["mkdir", "-p", root.dir] }
    FileView {
        id: file
        path: root.dir + "/weather.json"
        printErrors: false
        onLoaded: {
            try {
                const o = JSON.parse(text());
                if (typeof o.location === "string") root.location = o.location;
                root.label = o.label ?? "";
            } catch (e) {}
            root.refresh();
        }
        onLoadFailed: root.refresh()
    }
}
