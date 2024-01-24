import QtCore
import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Two Overlaid Images")
    ColumnLayout {

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

        Image {
            id: cover
            source: "test_images/rosvol2-cover.jpg"
            width: 500
            height: 500
            smooth: true
            visible: true
            Image {
                id: overlay
                source: "test_images/mask.png"
                width: 500
                height: 500 
                x: 0
                y: 0
                smooth: true
                visible: true
                opacity: opacity_slider.value
            }
        }
    }
}
