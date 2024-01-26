import QtCore
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
//import Qt.labs.platform

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Two Overlaid Images")

    function refreshMask() {
        overlay.source= "test_images/mask2.png"
        overlay.source= "test_images/mask.png"
    }

    ColumnLayout {
        MenuBar {
            id: menuBar
            Menu {
                id: fileMenu
                title: qsTr("File")
                MenuItem {
                    text: qsTr("Open Image")
                    onTriggered: singleFileDialog.open()
                }
            }

            Menu {
                id: toolsMenu
                title: qsTr("Tools")
                MenuItem {
                    text: qsTr("Random Rectangle")
                    onTriggered: tbox.randomRectangle(), refreshMask()
                }
                MenuItem {
                    text: qsTr("Get AI Predictions")
                    onTriggered: tbox.getPrediction(), refreshMask()
                }
            }
        }

        Slider {
            id: opacity_slider
            from: 0.0
            to: 1.0
            stepSize: .01
            value: .75
            onMoved: overlay.opacity = value
            visible: true
            height: 10
            width: 100
        }
        Rectangle {
            height: 500
            width: 500
            Image {
                id: base
                source: "test_images/rosvol2-cover.jpg"
                sourceSize.width: 500
                sourceSize.height: 500
                height: 500
                width: 500
                smooth: true
                visible: true
                fillMode: Image.PreserveAspectFit
                Image {
                    id: overlay
                    source: "test_images/mask.png"
                    x: 0
                    y: 0
                    sourceSize.width: 500
                    sourceSize.height: 500
                    height: 500
                    width: 500
                    smooth: true
                    visible: true
                    opacity: opacity_slider.value
                    cache: false
                    fillMode: Image.PreserveAspectFit
                }

                FileDialog {
                    id: singleFileDialog
                    onAccepted: base.source = selectedFile, tbox.initLabels(selectedFile), refreshMask()
                }
            }
        }
    }
}
