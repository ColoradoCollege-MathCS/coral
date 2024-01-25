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
    
         


    FileDialog {
        id: fileDialog
        currentFolder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
        onAccepted: image.source = selectedFile
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