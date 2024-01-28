import QtCore
import QtQuick 
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts 
import Qt.labs.folderlistmodel
//import Qt.labs.platform

//from PyQt5.QtCore import pyqtSlot

//import QtGraphicalEffects 1.15
//import AppStyle 1.0


ApplicationWindow {
    width: 800
    height: 600
    visible: true


//change main image function
function changeImage(filename){
        image.source = filename;
        
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
    }





//row tool bar
    header: ToolBar {
        
        RowLayout {
            anchors.fill: parent


            
            ToolButton {
                text: qsTr("Choose Image")
    
                onClicked: {
                    fileDialog.open()
                }
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

            ToolButton {
                text: qsTr("Crop")

                onClicked: {
                   //@pyqtSlot
                   //print("yuh")
                }
            }
    
         


    FileDialog {
        id: fileDialog
        currentFolder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
        onAccepted: image.source = selectedFile
    }


    StackView {
        id: stack
        //anchors.fill: parent
    }


        }

   

    }

    

////////// Tool bar stuff
   ToolBar {
        ColumnLayout {
            id: toolbaryuh
            anchors.fill: parent
                    
            width: parent.width/8

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


//random rectangle for now to push image away from tool bar margin for image
Rectangle{
    id: yuh
    width: parent.width/8
}

//file image
Image {
    id: image
        anchors.left: yuh.right

        width: parent.height - parent.width/8
        height: parent.height - 50
    
        fillMode: Image.PreserveAspectFit
}



//Gallery stuff
Rectangle{
    width: parent.width/8
    height: parent.height
    anchors.left: image.right

    ListView {
            id: gallery


            width: parent.width; height: parent.height

            flickableDirection: Flickable.VerticalFlick

            FolderListModel {
                id: folderModel

                folder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]

                nameFilters: ["*.jpg"]
            }

            model: folderModel

            Component {
                id: fileDelegate
                Image{
                    source: StandardPaths.standardLocations(StandardPaths.PicturesLocation) + "/" + fileName

                    width: gallery.width
                    height: width * (2/3)


                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            changeImage(StandardPaths.standardLocations(StandardPaths.PicturesLocation) + "/" + fileName)
                            //FileDialog.close()
                            //FileDialog.open()
                        }

                    }
                }
            }

            //model: ListTest {}
            delegate: fileDelegate
    }
}


}

