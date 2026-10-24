import QtQuick
import "../services"
import "../theme"

// Weather in detail, opened from the Overview tab: the place, now and today's
// details, then the next hours. The place can be searched by city name or
// found again from the IP address. While searching, the island holds open so
// the field keeps the keyboard.
Item {
    id: root

    signal back()

    property bool searching: false
    property int highlighted: 0         // search result Enter picks

    function openSearch() {
        if (searching)
            return;
        searching = true;
        IslandState.holdOpen();
        field.input.text = "";
        field.input.forceActiveFocus();
    }

    function closeSearch() {
        if (!searching)
            return;
        searching = false;
        IslandState.release();
        Weather.search("");
    }

    function pick(place) {
        Weather.choose(place);
        closeSearch();
    }

    Component.onDestruction: {
        if (searching)
            IslandState.release();
    }

    Connections {
        target: Weather
        function onPlacesChanged() { root.highlighted = 0; }
    }

    // A caption over a value.
    component Detail: Column {
        property string label: ""
        property string value: ""

        spacing: 1

        Label {
            text: parent.label
            color: Theme.textTertiary
            font.pixelSize: Theme.fontCaption
        }
        Label {
            text: parent.value
            font.pixelSize: Theme.fontSmall + 1
            font.weight: Font.DemiBold
        }
    }

    // Header: back, then the place with last update, search, refresh and
    // locate, or the search field.
    Item {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 28

        IslandButton {
            id: backButton
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            icon: "chevronLeft"
            iconSize: 16
            color: Theme.textSecondary
            onClicked: root.searching ? root.closeSearch() : root.back()
        }

        Field {
            id: field
            anchors.left: backButton.right
            anchors.leftMargin: 4
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: root.searching
            placeholder: "Search for a city"
            input.onTextChanged: debounce.restart()
            input.onAccepted: {
                if (Weather.places.length > 0)
                    root.pick(Weather.places[root.highlighted]);
            }
            input.Keys.onEscapePressed: root.closeSearch()
            input.Keys.onDownPressed: root.highlighted = Math.min(root.highlighted + 1, Weather.places.length - 1)
            input.Keys.onUpPressed: root.highlighted = Math.max(root.highlighted - 1, 0)
        }
        Timer {
            id: debounce
            interval: 300
            onTriggered: Weather.search(field.input.text)
        }

        Item {
            anchors.left: backButton.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            visible: !root.searching

            Icon {
                id: pin
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                name: "location"
                size: 13
                color: Theme.textSecondary
            }
            Label {
                id: placeLabel
                anchors.left: pin.right
                anchors.leftMargin: 6
                anchors.right: actions.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: Weather.place
                font.pixelSize: Theme.fontBody + 1
                font.weight: Font.DemiBold
                elide: Text.ElideRight

                MouseArea {
                    width: Math.min(parent.width, parent.implicitWidth)
                    height: parent.height
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.openSearch()
                }
            }

            Row {
                id: actions
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Weather.locating ? "Locating…"
                        : Weather.locateFailed ? "Couldn't set place"
                        : Weather.now ? "Updated " + Qt.formatTime(Weather.updated, "hh:mm")
                        : ""
                    color: Weather.locateFailed ? Theme.red : Theme.textTertiary
                    font.pixelSize: Theme.fontCaption + 1
                }
                IslandButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "search"
                    iconSize: 14
                    color: Theme.textSecondary
                    onClicked: root.openSearch()
                }
                IslandButton {
                    id: refreshButton
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "refresh"
                    iconSize: 14
                    color: Theme.textSecondary
                    onClicked: Weather.refresh()

                    RotationAnimation on rotation {
                        running: Weather.fetching
                        from: 0
                        to: 360
                        duration: 900
                        loops: Animation.Infinite
                        onRunningChanged: if (!running) refreshButton.rotation = 0
                    }
                }
                IslandButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "location"
                    iconSize: 14
                    color: Weather.locating ? Theme.blue : Theme.textSecondary
                    onClicked: Weather.locate()
                }
            }
        }
    }

    // The weather, swapped for search results while searching.
    Swappable {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        shown: !root.searching

        Label {
            anchors.centerIn: parent
            visible: !Weather.now
            text: Weather.condition === "Unavailable" ? "Weather unavailable" : "Loading weather…"
            color: Theme.textTertiary
        }

        // Now: icon, temperature, condition and today's range, details beside.
        Item {
            id: nowRow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 8
            height: 62
            visible: !!Weather.now

            Icon {
                id: bigIcon
                anchors.left: parent.left
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                name: Weather.icon
                size: 42
                color: Weather.icon === "weatherClear" ? Theme.yellow : Theme.cyan
            }
            Label {
                id: bigTemperature
                anchors.left: bigIcon.right
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: Weather.now ? Weather.now.temperature + "°" : ""
                font.pixelSize: Theme.fontDisplay
                font.weight: Font.DemiBold
            }
            Column {
                anchors.left: bigTemperature.right
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Label {
                    text: Weather.condition
                    font.pixelSize: Theme.fontBody
                    font.weight: Font.DemiBold
                }
                Label {
                    text: Weather.today ? "H " + Weather.today.high + "°  L " + Weather.today.low + "°" : ""
                    color: Theme.textSecondary
                    font.pixelSize: Theme.fontSmall + 1
                }
            }

            Grid {
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                columns: 3
                columnSpacing: 22
                rowSpacing: 6

                Detail { label: "Feels like"; value: Weather.now ? Weather.now.feelsLike + "°" : "" }
                Detail { label: "Humidity"; value: Weather.now ? Weather.now.humidity + "%" : "" }
                Detail { label: "Wind"; value: Weather.now ? Weather.now.wind + " km/h" : "" }
                Detail { label: "UV index"; value: Weather.today ? String(Weather.today.uv) : "" }
                Detail { label: "Sunrise"; value: Weather.today ? Weather.today.sunrise : "" }
                Detail { label: "Sunset"; value: Weather.today ? Weather.today.sunset : "" }
            }
        }

        // The next hours: time, sky, temperature and chance of rain.
        Rectangle {
            id: hourly
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: nowRow.bottom
            anchors.topMargin: 10
            anchors.bottom: parent.bottom
            radius: 14
            color: Theme.surface
            visible: Weather.hours.length > 0

            Row {
                anchors.fill: parent

                Repeater {
                    model: Weather.hours

                    Item {
                        required property var modelData

                        width: hourly.width / Weather.hours.length
                        height: hourly.height

                        Column {
                            anchors.centerIn: parent
                            spacing: 3

                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.time
                                color: Theme.textSecondary
                                font.pixelSize: Theme.fontCaption + 1
                            }
                            Icon {
                                anchors.horizontalCenter: parent.horizontalCenter
                                name: modelData.icon
                                size: 18
                                color: modelData.icon === "weatherClear" ? Theme.yellow : Theme.text
                            }
                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.temperature + "°"
                                font.pixelSize: Theme.fontSmall + 1
                                font.weight: Font.DemiBold
                            }
                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                // Kept in the layout so the columns line up.
                                opacity: modelData.rain > 0 ? 1 : 0
                                text: modelData.rain + "%"
                                color: Theme.cyan
                                font.pixelSize: Theme.fontCaption
                            }
                        }
                    }
                }
            }
        }
    }

    // Search results: click one, or move with the arrows and press Enter.
    Swappable {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.topMargin: 6
        anchors.bottom: parent.bottom
        shown: root.searching

        Label {
            anchors.centerIn: parent
            visible: Weather.places.length === 0
            text: Weather.searchFailed ? "Search failed, check the connection"
                : Weather.query.length < 2 ? "Type a city name"
                : Weather.searchBusy || debounce.running ? "Searching…"
                : "No places found"
            color: Weather.searchFailed ? Theme.red : Theme.textTertiary
        }

        ListView {
            anchors.fill: parent
            clip: true
            spacing: 2
            boundsBehavior: Flickable.StopAtBounds
            model: Weather.places
            currentIndex: root.highlighted
            onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

            delegate: Item {
                id: result

                required property var modelData
                required property int index

                width: ListView.view.width
                height: 32

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: result.index === root.highlighted || resultHover.hovered ? Theme.surface : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.fadeDuration } }
                }
                HoverHandler {
                    id: resultHover
                    onHoveredChanged: if (hovered) root.highlighted = result.index
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.pick(result.modelData)
                }

                Icon {
                    id: resultPin
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    name: "location"
                    size: 13
                    color: result.index === root.highlighted ? Theme.blue : Theme.textTertiary
                }
                Label {
                    id: resultName
                    anchors.left: resultPin.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: result.modelData.name
                    font.pixelSize: Theme.fontSmall + 1
                    font.weight: Font.Medium
                }
                Label {
                    anchors.left: resultName.right
                    anchors.leftMargin: 8
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: result.modelData.detail
                    color: Theme.textTertiary
                    font.pixelSize: Theme.fontCaption + 1
                    elide: Text.ElideRight
                }
            }
        }
    }
}
