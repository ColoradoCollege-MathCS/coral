import QtCore
import QtQuick 
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts 
//import Qt.labs.platform


//import QtGraphicalEffects 1.15
//import AppStyle 1.0



ApplicationWindow {
    width: 800
    height: 600
    visible: true

function refreshMask() {
    overlay.source = "images/mask2.png"
    overlay.source = "images/mask.png"
}

///
 menuBar: MenuBar {
        Menu {
            title: qsTr("&File")
            Action { text: qsTr("&New...") }
            Action { text: qsTr("&Open...") }
            Action { text: qsTr("&Save") }
            Action { text: qsTr("Save &As...") }
            MenuSeparator { }
            Action { text: qsTr("&Quit") }
        }
        Menu {
            title: qsTr("&Edit")
            Action { text: qsTr("Cu&t") }
            Action { text: qsTr("&Copy") }
            Action { text: qsTr("&Paste") }
        }
        Menu {
            title: qsTr("&Help")
            Action { text: qsTr("&About") }
        }
        Menu {
            title: qsTr("&Tools")
            Action {
                text: qsTr("Random Rectangle")
                onTriggered: tbox.randomRectangle(), refreshMask()
            }
            Action {
                text: qsTr("Get AI Predictions")
                onTriggered: tbox.getPrediction(), refreshMask()
            }
        }
    }





//row tool bar
    header: ToolBar {
        
        RowLayout {
            anchors.fill: parent
            
            ToolButton {
                text: qsTr("Choose Image")
    
                onClicked: fileDialog.open()
                Layout.alignment: Qt.AlignLeft

            }
                   

            Image {

                    id:saveIconButton
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50
                    source: "save.png"
                
                    MouseArea {
                        anchors.fill: parent
                        
                        onClicked: {
                        console.info("image clicked!")
                    }
                    
                }
            }
            Slider {
                id: opacitySlider
                from: 0.0
                to: 1.0
                stepSize: .01
                value: .75
                onMoved: overlay.opacity = value
                visible: true
                height: 10
                width: 100
            }
    
         


    FileDialog {
        id: fileDialog
        currentFolder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
        onAccepted: image.source = selectedFile, tbox.initLabels(selectedFile), refreshMask()
    }


    StackView {
        id: stack
        anchors.fill: parent
    }


        }

   

    }

    //file image
    Image {
        id: image
        anchors.fill: parent

        Layout.preferredWidth: 100
        Layout.preferredHeight: 100
    
        fillMode: Image.PreserveAspectFit

        Image {
            id: overlay
            anchors.fill: parent
            x: 0
            y: 0
            Layout.preferredWidth: 100
            Layout.preferredHeight: 100
            fillMode: Image.PreserveAspectFit
            smooth: true
            visible: true
            opacity: opacitySlider.value
            cache: false
        }
    }

//////////
   ToolBar {
        ColumnLayout {
                    anchors.fill: parent
                    
                    Image {

                    id:magicWandIcon
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50
                    source: "magicwand.png"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                        console.info("image clicked!")
                    }

                }
            }

            Image {
                    id:paintbrushIcon
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50
                    source: "paintbrush.png"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                        console.info("image clicked!")
                    }

                }
            }
            Image {
                    id:circleSelectIcon
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50
                    source: "circleselect.png"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                        console.info("image clicked!")
                    }

                }
            }
            Image {
                    id:squareSelectIcon
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50
                    source: "squareselect.png"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                        console.info("image clicked!")
                    }

                }
            }
       

        }
 }
/*
    GridView {
            id: gallery

            anchors.fill: parent

            clip: true

            model: folderListModel

            delegate: fileDialog.delegateComponent

            cellWidth: parent.width / 4
            cellHeight: parent.width / 4
        }


*/

}