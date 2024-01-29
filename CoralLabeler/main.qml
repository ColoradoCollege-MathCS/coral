import QtCore
import QtQuick 
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts 
import Qt.labs.folderlistmodel


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


            ToolButton {
                text: qsTr("Choose Folder")

                onClicked: {
                   folderDialog.open()
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
            id: toolbaryuh
                    
            width: parent.width/8
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


    //Gallery stuff
    Rectangle{
        id:allGallery
        width: parent.width/8
        height: parent.height
        anchors.left: image.right

        visible: false

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
                        source: folderModel.folder + "/" + fileName

                        width: gallery.width
                        height: width * (2/3)


                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                changeImage(folderModel.folder + "/" + fileName)
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


    FolderDialog {
        id: folderDialog
        currentFolder: viewer.folder

        onAccepted: {
            folderModel.folder = selectedFolder
            allGallery.visible = true
        }
    }


}

