/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQml.Models
import QtQuick.Controls
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlightDisplay

ToolStripActionList {
    id: _root

    property bool trackingEnabled: false
    property string trackingType: "people"
    property var trackingSocket

    signal displayPreFlightChecklist

    model: [
        ToolStripAction {
            property bool _is3DViewOpen: viewer3DWindow.isOpen
            property bool _viewer3DEnabled: QGroundControl.settingsManager.viewer3DSettings.enabled.rawValue

            id: view3DIcon
            visible: _viewer3DEnabled
            text: qsTr("3D View")
            iconSource: "/qml/QGroundControl/Viewer3D/City3DMapIcon.svg"
            onTriggered: {
                if (!_is3DViewOpen) {
                    viewer3DWindow.open()
                } else {
                    viewer3DWindow.close()
                }
            }
            on_Is3DViewOpenChanged: {
                if (_is3DViewOpen) {
                    view3DIcon.iconSource = "/qmlimages/PaperPlane.svg"
                    text = qsTr("Fly")
                } else {
                    iconSource = "/qml/QGroundControl/Viewer3D/City3DMapIcon.svg"
                    text = qsTr("3D View")
                }
            }
        },

        ToolStripAction {
            id: customTestAction
            text: qsTr("ТЕСТ")
            iconSource: "/qmlimages/PaperPlane.svg"
            onTriggered: {
                console.log("✅ ТЕСТ-кнопка спрацювала")
            }
        },

        ToolStripAction {
            id: trackingToggle
            text: trackingEnabled ? qsTr("Tracking: ON") : qsTr("Tracking: OFF")
            iconSource: "qrc:/qmlimages/target-icon.svg"
            onTriggered: {
                trackingEnabled = !trackingEnabled
                console.log("🧠 Трекінг вмикнено:", trackingEnabled)
                if (trackingSocket) {
                    trackingSocket.sendTextMessage(JSON.stringify({
                        type: "tracking_toggle",
                        enabled: trackingEnabled
                    }))
                }
            }
        },

        ToolStripAction {
            id: trackingTarget
            text: qsTr("ТЕСТ")
            iconSource: "/qmlimages/PaperPlane.svg"
            onTriggered: {
                trackingTargetPopup.visible = true
            }
        },

        Popup {
            id: trackingTargetPopup
            modal: true
            focus: true
            width: 200
            height: 220
            anchors.centerIn: parent
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            Rectangle {
                anchors.fill: parent
                color: "#2e2e2e"
                radius: 6

                Column {
                    spacing: 10
                    anchors.centerIn: parent

                    Repeater {
                        model: ["People", "Cars", "Drones", "Aircraft"]
                        delegate: Button {
                            width: 160
                            text: modelData
                            onClicked: {
                                trackingType = modelData.toLowerCase()
                                trackingTargetPopup.close()
                                console.log("🎯 Вибрано тип:", trackingType)
                                if (trackingSocket) {
                                    trackingSocket.sendTextMessage(JSON.stringify({
                                        type: "tracking_type",
                                        value: trackingType
                                    }))
                                }
                            }
                        }
                    }
                }
            }
        },

        PreFlightCheckListShowAction { onTriggered: displayPreFlightChecklist() },
        GuidedActionTakeoff { },
        GuidedActionLand { },
        GuidedActionRTL { },
        GuidedActionPause { },
        FlyViewAdditionalActionsButton { },
        GuidedActionGripper { }
    ]
}
