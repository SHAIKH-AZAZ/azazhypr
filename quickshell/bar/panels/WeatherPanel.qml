import QtQuick
import QtQuick.Layouts
import "../components"
import "../services"

// Weather panel: place + update time, current conditions, hourly / today / weekly strip,
// 7-day list with temperature bars, air quality and sunrise/sunset. Data: services/Forecast.qml.
ColumnLayout {
    id: c
    signal close()
    spacing: 10

    property int tab: 0             // 0 hourly, 1 today (3 h steps), 2 weekly
    readonly property real cardW: 64
    property bool editing: false

    readonly property var cur: Forecast.cur
    readonly property var days: Forecast.days()
    readonly property var strip: {
        void Forecast.fetched;
        if (tab === 0) return Forecast.hours(0, 24, 1);
        if (tab === 1) return Forecast.todaySlots();
        return days.map(d => ({ label: d.name, temp: d.hi, code: d.code, day: true }));
    }
    readonly property real wkMin: { let m = 99; for (const d of days) m = Math.min(m, d.lo); return m }
    readonly property real wkMax: { let m = -99; for (const d of days) m = Math.max(m, d.hi); return m }

    Component.onCompleted: if (Date.now() - Forecast.fetched > 10 * 60000) Forecast.refresh()

    component Pill: Rectangle {
        property string text
        property bool on: false
        signal clicked
        implicitWidth: lbl.implicitWidth + 28; implicitHeight: 30
        radius: 15
        color: on ? Theme.blue : Qt.alpha(Theme.subtle, pma.containsMouse ? 0.8 : 0.45)
        Txt { id: lbl; anchors.centerIn: parent; text: parent.text; color: parent.on ? Theme.bg : Theme.fg; font { pixelSize: 12; bold: parent.on } }
        MouseArea { id: pma; anchors.fill: parent; hoverEnabled: true; onClicked: parent.clicked() }
    }

    // ================= header =================
    RowLayout {
        Layout.fillWidth: true
        spacing: 10
        Txt { icon: true; text: "location_on"; color: Theme.blue; font.pixelSize: 22 }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Txt { Layout.fillWidth: true; text: Forecast.place || "Weather"; font { pixelSize: 17; bold: true } }
            Txt { text: Forecast.ago(); color: Theme.muted; font.pixelSize: 11 }
        }
        Rectangle {
            implicitWidth: 30; implicitHeight: 30; radius: 8
            color: refMa.containsMouse ? Qt.alpha(Theme.fg, 0.12) : Qt.alpha(Theme.subtle, 0.4)
            border { width: 1; color: Theme.subtle }
            Txt {
                anchors.centerIn: parent
                icon: true
                text: "refresh"
                color: Forecast.loading ? Theme.blue : Theme.fg
                RotationAnimator on rotation { running: Forecast.loading; from: 0; to: 360; duration: 900; loops: Animation.Infinite }
            }
            MouseArea { id: refMa; anchors.fill: parent; hoverEnabled: true; onClicked: Forecast.refresh() }
        }
        Rectangle {
            implicitWidth: 30; implicitHeight: 30; radius: 8
            color: c.editing || locMa.containsMouse ? Qt.alpha(Theme.fg, 0.12) : Qt.alpha(Theme.subtle, 0.4)
            border { width: 1; color: c.editing ? Theme.blue : Theme.subtle }
            Txt { icon: true; anchors.centerIn: parent; text: "more_vert"; color: c.editing ? Theme.blue : Theme.fg }
            MouseArea { id: locMa; anchors.fill: parent; hoverEnabled: true; onClicked: c.editing = !c.editing }
        }
    }

    // ---- change location: type, pick a suggestion (saved as your location until you change it) ----
    property int hi: -1                     // highlighted suggestion
    function pick(sg) {
        const lbl = [sg.name, sg.admin1, sg.country].filter(x => x).join(", ");
        Forecast.setLocation(sg.lat.toFixed(4) + "," + sg.lon.toFixed(4), lbl);
        editing = false;
    }
    ColumnLayout {
        Layout.fillWidth: true
        visible: c.editing
        spacing: 4

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 40
            radius: 10
            color: Qt.alpha(Theme.subtle, 0.4)
            border { width: 1; color: loc.activeFocus ? Theme.blue : Theme.subtle }
            TextInput {
                id: loc
                anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.fg
                selectionColor: Theme.blue
                selectedTextColor: Theme.bg
                clip: true
                text: Forecast.label || Forecast.location
                font { family: Theme.font; pixelSize: 13 }
                onTextEdited: { c.hi = -1; sugTimer.restart() }
                onAccepted: {
                    const l = Forecast.suggestions;
                    if (c.hi >= 0 && c.hi < l.length) c.pick(l[c.hi]);
                    else if (l.length > 0 && text.trim() !== "") c.pick(l[0]);   // Enter on a typed name = best match
                    else { Forecast.setLocation(text, ""); c.editing = false }
                }
                Keys.onPressed: e => {
                    const n = Forecast.suggestions.length;
                    if (e.key === Qt.Key_Down && n) { c.hi = (c.hi + 1) % n; e.accepted = true }
                    else if (e.key === Qt.Key_Up && n) { c.hi = (c.hi - 1 + n) % n; e.accepted = true }
                    else if (e.key === Qt.Key_Escape) { c.editing = false; e.accepted = true }
                }
                Component.onCompleted: if (c.editing) { forceActiveFocus(); selectAll() }
                onVisibleChanged: if (visible) { forceActiveFocus(); selectAll() }
            }
            Txt {
                anchors { fill: parent; leftMargin: 12 }
                verticalAlignment: Text.AlignVCenter
                visible: loc.text === "" && !loc.activeFocus
                text: "Search a city, e.g. Ahmedabad"
                color: Theme.muted
                font.pixelSize: 12
            }
            Timer { id: sugTimer; interval: 280; onTriggered: Forecast.suggest(loc.text) }
        }

        // suggestions
        Repeater {
            model: Forecast.suggestions
            Rectangle {
                required property var modelData
                required property int index
                Layout.fillWidth: true
                implicitHeight: 38
                radius: 8
                color: index === c.hi || smaMa.containsMouse ? Qt.alpha(Theme.blue, 0.2) : Qt.alpha(Theme.subtle, 0.35)
                RowLayout {
                    anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                    spacing: 8
                    Txt { icon: true; text: "location_on"; color: Theme.muted }
                    Txt { text: modelData.name; font { pixelSize: 13; bold: true } }
                    Txt {
                        Layout.fillWidth: true
                        text: [modelData.admin1, modelData.country].filter(x => x).join(", ")
                        color: Theme.muted
                        font.pixelSize: 12
                    }
                }
                MouseArea { id: smaMa; anchors.fill: parent; hoverEnabled: true; onClicked: c.pick(modelData) }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Txt {
                Layout.fillWidth: true
                text: Forecast.location === "" ? "Using a guess from your IP address" : "Saved as your location, kept across restarts"
                color: Theme.muted
                font.pixelSize: 11
            }
            Txt {
                visible: Forecast.location !== ""
                text: "Use IP guess"
                color: ipMa.containsMouse ? Theme.blue : Theme.muted
                font.pixelSize: 11
                MouseArea { id: ipMa; anchors { fill: parent; margins: -4 } hoverEnabled: true; onClicked: { Forecast.setLocation("", ""); c.editing = false } }
            }
        }
    }

    // ================= current =================
    RowLayout {
        Layout.fillWidth: true
        spacing: 14
        visible: c.cur !== null

        Txt { icon: true; text: c.cur ? Forecast.icon(c.cur.weather_code, c.cur.is_day === 1) : ""; font.pixelSize: 62 }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Row {
                spacing: 2
                Txt { text: c.cur ? Math.round(c.cur.temperature_2m) : "--"; font { pixelSize: 46; bold: true } }
                Txt { anchors.top: parent.top; anchors.topMargin: 8; text: "°C"; color: Theme.muted; font.pixelSize: 18 }
            }
            Txt { text: c.cur ? Forecast.desc(c.cur.weather_code) : ""; font { pixelSize: 15 } }
            Txt { text: c.cur ? "Feels like " + Math.round(c.cur.apparent_temperature) + "°C" : ""; color: Theme.muted; font.pixelSize: 12 }
        }
        Rectangle { Layout.fillHeight: true; width: 1; color: Theme.subtle }
        ColumnLayout {
            Layout.preferredWidth: 160
            spacing: 7
            Repeater {
                model: c.cur ? [
                    { e: "water_drop", k: "Humidity", v: c.cur.relative_humidity_2m + "%" },
                    { e: "air", k: "Wind", v: Math.round(c.cur.wind_speed_10m) + " km/h " + Forecast.compass(c.cur.wind_direction_10m) },
                    { e: "speed", k: "Pressure", v: Math.round(c.cur.pressure_msl) + " hPa" },
                    { e: "visibility", k: "Visibility", v: (c.cur.visibility / 1000).toFixed(c.cur.visibility >= 10000 ? 0 : 1) + " km" }
                ] : []
                RowLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 7
                    Txt { icon: true; text: modelData.e; font.pixelSize: 15; color: Theme.muted }
                    Txt { Layout.fillWidth: true; text: modelData.k; color: Theme.muted; font.pixelSize: 12 }
                    Txt { text: modelData.v; font { pixelSize: 12; bold: true } }
                }
            }
        }
    }
    Txt {
        Layout.fillWidth: true
        visible: c.cur === null
        horizontalAlignment: Text.AlignHCenter
        text: Forecast.failed ? "Could not reach the weather service. Check the connection, then refresh." : "Loading…"
        color: Theme.muted
        topPadding: 30; bottomPadding: 30
    }

    // ================= strip: hourly / today / weekly =================
    Rectangle {
        Layout.fillWidth: true
        visible: c.cur !== null
        implicitHeight: stripCol.implicitHeight + 20
        radius: 12
        color: Qt.alpha(Theme.subtle, 0.3)
        border { width: 1; color: Theme.subtle }

        ColumnLayout {
            id: stripCol
            anchors { fill: parent; margins: 10 }
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Pill { text: "Hourly"; on: c.tab === 0; onClicked: { c.tab = 0; strip.contentX = 0 } }
                Pill { text: "Today"; on: c.tab === 1; onClicked: { c.tab = 1; strip.contentX = 0 } }
                Pill { text: "Weekly"; on: c.tab === 2; onClicked: { c.tab = 2; strip.contentX = 0 } }
                Item { Layout.fillWidth: true }
                Rectangle {
                    visible: strip.contentWidth > strip.width + 1
                    implicitWidth: 30; implicitHeight: 30; radius: 15
                    color: Qt.alpha(Theme.subtle, nxMa.containsMouse ? 0.9 : 0.5)
                    Txt { icon: true; anchors.centerIn: parent; text: strip.atXEnd ? "chevron_left" : "chevron_right" }
                    MouseArea {
                        id: nxMa
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: { strip.scrollTo(strip.atXEnd ? 0 : strip.contentX + strip.width * 0.9) }
                    }
                }
            }
            // horizontal strip: wheel / drag / arrow button scroll it
            Flickable {
                id: strip
                Layout.fillWidth: true
                implicitHeight: 84
                contentWidth: row.implicitWidth
                contentHeight: height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                flickableDirection: Flickable.HorizontalFlick
                readonly property bool atXEnd: contentX >= contentWidth - width - 1

                function scrollTo(x) {
                    scrollAnim.to = Math.max(0, Math.min(contentWidth - width, x));
                    scrollAnim.restart();
                }
                NumberAnimation { id: scrollAnim; target: strip; property: "contentX"; duration: 250; easing.type: Easing.OutCubic }

                // wheel -> horizontal scroll (the strip has no vertical content)
                WheelHandler {
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    onWheel: e => strip.scrollTo(strip.contentX - (e.angleDelta.y + e.angleDelta.x) * 0.7)
                }

                Row {
                    id: row
                    spacing: 6
                    Repeater {
                        model: c.strip
                        Rectangle {
                            required property var modelData
                            required property int index
                            width: c.tab === 2 ? (strip.width - 6 * 6) / 7 : c.cardW
                            height: 84
                            radius: 10
                            readonly property bool first: index === 0 && c.tab === 0
                            color: first ? Qt.alpha(Theme.blue, 0.16) : Qt.alpha(Theme.subtle, 0.35)
                            border { width: first ? 1 : 0; color: Theme.blue }
                            Column {
                                anchors.centerIn: parent
                                spacing: 5
                                Txt { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.label; color: Theme.muted; font.pixelSize: 11 }
                                Txt { icon: true; anchors.horizontalCenter: parent.horizontalCenter; text: Forecast.icon(modelData.code, modelData.day); font.pixelSize: 24 }
                                Txt { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.temp + "\u00b0"; font { pixelSize: 15; bold: true } }
                            }
                        }
                    }
                }
            }
        }
    }

    // ================= 7-day list =================
    Rectangle {
        Layout.fillWidth: true
        visible: c.cur !== null && c.days.length > 0
        implicitHeight: dayCol.implicitHeight + 12
        radius: 12
        color: Qt.alpha(Theme.subtle, 0.3)
        border { width: 1; color: Theme.subtle }

        ColumnLayout {
            id: dayCol
            anchors { fill: parent; margins: 6 }
            spacing: 0
            Repeater {
                model: c.days.slice(0, 7)
                ColumnLayout {
                    required property var modelData
                    required property int index
                    Layout.fillWidth: true
                    spacing: 0
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        Layout.leftMargin: 6; Layout.rightMargin: 6
                        spacing: 8
                        Txt { Layout.preferredWidth: 46; text: modelData.name; font { pixelSize: 13; bold: index === 0 } }
                        Txt { icon: true; text: Forecast.icon(modelData.code, true); font.pixelSize: 19 }
                        Txt { Layout.fillWidth: true; text: Forecast.desc(modelData.code); color: Theme.muted; font.pixelSize: 12 }
                        Txt { Layout.preferredWidth: 30; horizontalAlignment: Text.AlignRight; text: modelData.hi + "°"; font { pixelSize: 13; bold: true } }
                        Txt { Layout.preferredWidth: 30; horizontalAlignment: Text.AlignRight; text: modelData.lo + "°"; color: Theme.muted; font.pixelSize: 13 }
                        Rectangle {   // where this day sits inside the week's range
                            Layout.preferredWidth: 84; height: 5; radius: 2.5
                            color: Qt.alpha(Theme.bg, 0.7)
                            Rectangle {
                                readonly property real span: Math.max(1, c.wkMax - c.wkMin)
                                x: parent.width * (modelData.lo - c.wkMin) / span
                                width: Math.max(8, parent.width * (modelData.hi - modelData.lo) / span)
                                height: parent.height; radius: parent.radius
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0; color: modelData.hi >= 33 ? Theme.orange : modelData.hi >= 27 ? Theme.yellow : Theme.blue }
                                    GradientStop { position: 1; color: modelData.hi >= 33 ? Theme.red : modelData.hi >= 27 ? Theme.orange : Theme.accent }
                                }
                            }
                        }
                    }
                    Rectangle { Layout.fillWidth: true; Layout.leftMargin: 6; Layout.rightMargin: 6; height: 1; color: Qt.alpha(Theme.subtle, 0.7); visible: index < c.days.length - 1 && index < 6 }
                }
            }
        }
    }

    // ================= air quality + sun =================
    RowLayout {
        Layout.fillWidth: true
        visible: c.cur !== null
        spacing: 10

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredWidth: 5
            implicitHeight: 84
            radius: 12
            color: Qt.alpha(Theme.subtle, 0.3)
            border { width: 1; color: Theme.subtle }
            readonly property var v: Forecast.aqi
            ColumnLayout {
                anchors { fill: parent; margins: 10 }
                spacing: 4
                Txt { text: "🍃  Air Quality Index"; color: Theme.muted; font.pixelSize: 11 }
                RowLayout {
                    spacing: 8
                    Txt { text: parent.parent.parent.v !== null ? Math.round(parent.parent.parent.v) : "--"; font { pixelSize: 24; bold: true } }
                    Rectangle {
                        visible: parent.parent.parent.v !== null
                        implicitWidth: aqiTxt.implicitWidth + 16; implicitHeight: 22; radius: 11
                        color: Forecast.aqiColor(parent.parent.parent.v ?? 0)
                        Txt { id: aqiTxt; anchors.centerIn: parent; text: Forecast.aqiLabel(parent.parent.parent.parent.v ?? 0); color: Theme.bg; font { pixelSize: 11; bold: true } }
                    }
                }
                Item {
                    Layout.fillWidth: true
                    height: 8
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width; height: 5; radius: 2.5
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0; color: Theme.green }
                            GradientStop { position: 0.2; color: Theme.yellow }
                            GradientStop { position: 0.45; color: Theme.orange }
                            GradientStop { position: 0.7; color: Theme.red }
                            GradientStop { position: 1; color: Theme.purple }
                        }
                    }
                    Rectangle {
                        visible: parent.parent.parent.v !== null
                        anchors.verticalCenter: parent.verticalCenter
                        x: Math.max(0, Math.min(parent.width - width, parent.width * Math.min(1, (parent.parent.parent.v ?? 0) / 300) - width / 2))
                        width: 9; height: 9; radius: 4.5
                        color: Theme.fg
                        border { width: 2; color: Theme.bg }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredWidth: 5
            implicitHeight: 84
            radius: 12
            color: Qt.alpha(Theme.subtle, 0.3)
            border { width: 1; color: Theme.subtle }
            RowLayout {
                anchors { fill: parent; margins: 10 }
                spacing: 4
                Repeater {
                    model: c.days.length ? [
                        { e: "wb_twilight", k: "Sunrise", v: Forecast.clock(c.days[0].sunrise) },
                        { e: "bedtime", k: "Sunset", v: Forecast.clock(c.days[0].sunset) }
                    ] : []
                    RowLayout {
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: 6
                        Txt { icon: true; text: modelData.e; font.pixelSize: 22 }
                        ColumnLayout {
                            spacing: 0
                            Txt { text: modelData.k; color: Theme.muted; font.pixelSize: 11 }
                            Txt { text: modelData.v; font { pixelSize: 12; bold: true } }
                        }
                    }
                }
            }
        }
    }
}
