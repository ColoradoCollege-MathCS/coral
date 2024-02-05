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

    property var currentTool: ""

    function refreshMask() {
        overlay.source = "images/mask2.png"
        overlay.source = "images/mask.png"
    }

    

    ///Top menu
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
                onTriggered: {
                    tbox.randomRectangle(), refreshMask()
                    saveIconButton.enabled = true
                }
            }
            Action {
                text: qsTr("Get AI Predictions")
                onTriggered: {
                    var labels = tbox.getPrediction(); 
                    refreshMask(); 
                    saveIconButton.enabled = true
                    populateLegend(labels)
                    labelLegend.visible = true
                    saveIconButton.enabled = true
                }
            }
        }
    }

    //row tool bar
    header: ToolBar {
        
        RowLayout {
            anchors.fill: parent
            
            //choose an image and display in image section
            ToolButton {
                id:chooseimg
                text: qsTr("Choose Image")
    
                onClicked: {
                    fileDialog.open()
                }
                Layout.alignment: Qt.AlignLeft
                //anchors.left: parent

            }

            //choose a folder for the gallery
            ToolButton {
                id:choosefolder
                text: qsTr("Choose Folder")

                onClicked: {
                   folderDialog.open()
                }
                //Layout.alignment: Qt.AlignLeft
                anchors.left: chooseimg.right
            }
                   

            //save button
            Button {
                id:saveIconButton
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50
                enabled: false
                icon.source: "save.png"
                
                MouseArea {
                    anchors.fill: parent
                        
                    onClicked: {
                        enabled = false
                        console.info("image clicked!")
                    }  
                }
                anchors.left: choosefolder.right


            }

            //slider value for opacity of mask
            Label {
                id: overlayTitle
                text: "Opacity"
                visible: true
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

            //slider value for either the magic wand or paintbrush
            Label {
                id: sliderTitle
                text: "value"
                visible: false
            }
            Slider {
                id: valueSlider
                from: 0.0
                to: 255.0
                visible: false
                height: 10
                width: 100
                stepSize: .01
                value: 1
                onMoved: {
                    if (currentTool == "magicwand"){
                        from = 0
                        to = 1
                        imageMouse.value = value
                    }

                    else if (currentTool == "paintbrush"){
                        from = 0
                        to = 255
                        imageMouse.value = value
                    }

                    else{
                        visible = false
                    }
                    
                }
    
            }
    
            //get image and put a mask on it
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

    //random rectangle for now to push image away from tool bar, gives margin for image
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

        //Overlay mask
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


            //fix where mouse gets clicked
            property var mouseFactorX: sourceSize.width / image.width
            property var mouseFactorY: sourceSize.height / image.height


            //When mouse is clicked with a certain tool
            MouseArea {
                id: imageMouse

                anchors.fill: parent

                property var fixedMouseX: 0
                property var fixedMouseY: 0


                //variable to hold when the mouse is pressed
                property var holdedx: 0
                property var holdedy: 0

                //variable for paint brush to be recognized when held down
                property var isPressed: false

                //threshold of magicwand or size of brush
                property var value: 1

                onPressed: { 
                    //for magic wand
                    if (currentTool == "magicwand"){

                        //console.log(mouseX, mouseY)
                        
                        fixedMouseX = mouseX * overlay.mouseFactorX
                        fixedMouseY = mouseY * overlay.mouseFactorY

                        tbox.magicWand(image.source, fixedMouseX, fixedMouseY, value), refreshMask()
                    }

                    //paintbrush if held down
                    else if (currentTool == "paintbrush"){
                        isPressed = true
                    }

                    //if circle is held down, record those coordinates
                    else if (currentTool == "circleselect"){
                        fixedMouseX = mouseX * overlay.mouseFactorX
                        fixedMouseY = mouseY * overlay.mouseFactorY

                        holdedx = fixedMouseX
                        holdedy = fixedMouseY
                    }

                    //if square is held down, record those coordinates
                    else if (currentTool == "squareselect"){
                        fixedMouseX = mouseX * overlay.mouseFactorX
                        fixedMouseY = mouseY * overlay.mouseFactorY

                        holdedx = fixedMouseX
                        holdedy = fixedMouseY
                    }

                    //means no tool was selected
                    else{
                        console.log("Please choose a tool")
                    }
                }


                //mouse released actions
                onReleased: {

                    //just not that the save needs to happen now
                    if (currentTool == "magicwand"){
                        //console.log(mouseX, mouseY)
                        //tbox.magicWand(image.source, mouseX * mouseFactorX, mouseY * mouseFactorY, value), refreshMask()
                        saveIconButton.enabled
                    }

                    //tell timer to stop and save needs to happen now
                    else if (currentTool == "paintbrush"){
                        isPressed = false
                        saveIconButton.enabled
                    }

                    //get last coordinate to make circle, save needs to happen now
                    else if (currentTool == "circleselect"){
                        fixedMouseX = mouseX * overlay.mouseFactorX
                        fixedMouseY = mouseY * overlay.mouseFactorY

                        tbox.selectCircle(holdedx, holdedy, fixedMouseX, fixedMouseY), refreshMask()
                        saveIconButton.enabled
                    }

                    //get last coordinate to make square, save needs to happen now
                    else if (currentTool == "squareselect"){
                        fixedMouseX = mouseX * overlay.mouseFactorX
                        fixedMouseY = mouseY * overlay.mouseFactorY

                        tbox.selectRect(holdedx, holdedy, fixedMouseX, fixedMouseY), refreshMask()
                        saveIconButton.enabled
                    }
                }
            }
        }  
    }
    
    //Timer to repeat the paintbrush action
    Timer {
        id: timer
        interval: 50

        repeat: true
        triggeredOnStart: true
        running: imageMouse.isPressed
        onTriggered: tbox.paintBrush(imageMouse.mouseX * overlay.mouseFactorX, imageMouse.mouseY * overlay.mouseFactorY, imageMouse.value), refreshMask()
    }

    //Tool buttons
    //diable when selected and enable everything else 
    ToolBar {
        ColumnLayout {
            id: toolbaryuh
                    
            width: parent.width/8
            anchors.fill: parent
                
            Button {

                id:magicWandIcon
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50
                icon.source: "magicwand.png"
                enabled: true
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        valueSlider.visible = true

                        sliderTitle.text = "Threshold"
                        sliderTitle.visible = true

                        magicWandIcon.enabled = false
                        paintbrushIcon.enabled = true
                        circleSelectIcon.enabled = true
                        squareSelectIcon.enabled = true
                        currentTool = "magicwand"
                    }

                }
            }

            Button {
                id:paintbrushIcon
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50
                icon.source: "paintbrush.png"
                enabled: true
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        valueSlider.visible = true

                        sliderTitle.text = "Size"
                        sliderTitle.visible = true

                        paintbrushIcon.enabled = false
                        magicWandIcon.enabled = true
                        circleSelectIcon.enabled = true
                        squareSelectIcon.enabled = true
                        currentTool = "paintbrush"
                    }

                }
            }
            Button {
                id:circleSelectIcon
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50
                icon.source: "circleselect.png"
                enabled: true
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        valueSlider.visible = false
                        sliderTitle.visible = false

                        circleSelectIcon.enabled = false
                        magicWandIcon.enabled = true
                        paintbrushIcon.enabled = true
                        squareSelectIcon.enabled = true
                        currentTool = "circleselect"
                    }

                }
            }
            Button {
                id:squareSelectIcon
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50
                icon.source: "squareselect.png"
                enabled: true
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        valueSlider.visible = false
                        sliderTitle.visible = false

                        squareSelectIcon.enabled = false
                        magicWandIcon.enabled = true
                        paintbrushIcon.enabled = true
                        circleSelectIcon.enabled = true
                        currentTool = "squareselect"
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
        anchors.right: parent.right


        visible: false


        //Places all images into a visible list
        ListView {
            id: gallery


            width: parent.width; height: parent.height

            //scrollable
            flickableDirection: Flickable.VerticalFlick

            //get contents of folder
            FolderListModel {
                id: folderModel

                folder: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]

                nameFilters: ["*.jpg"]
            }

            //use these contents
            model: folderModel

            //create a component for every image
            Component {
                id: fileDelegate

                //make this image for every content
                Image{
                    source: folderModel.folder + "/" + fileName

                    width: gallery.width
                    height: width * (2/3)


                    //if another images is clicked that's not saved yet, prompt user to save
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (saveIconButton.enabled == true){
                                savemask.title = fileName
                                savemask.open()
                            }
                            else{
                                tbox.initLabels(folderModel.folder + "/" + fileName), refreshMask()
                                changeImage(folderModel.folder + "/" + fileName)
                            }
                            
                        }

                    }
                }
            }

            //Make all components from folder
            delegate: fileDelegate
        }
    }

//-----------------------------------------
/*
  
Rectangle
    {
        id: mainRect

        width: 100
        height: 100

        x: parent.width/2 - (width/2)
        y: parent.height/2 - (height/2)

        border {
            color: "red"
            width: 2
        }

        Drag.active: mouseArea.drag.active

        MouseArea
        {
            id: mouseArea

            anchors.fill: parent
            drag.target: mainRect
        }
    }

Rectangle {

    id: circleleft
    color: "black"
    radius: 20
    width: radius
    height: radius

        anchors {
            horizontalCenter: mainRect.left
            verticalCenter: mainRect.verticalCenter
        }
        MouseArea {

            anchors.fill: parent

            onMouseXChanged: {
                mainRect.x = mainRect.x + mouseX
                mainRect.width = mainRect.width - mouseX
                if(mainRect.width < 5)
                {
                    mainRect.width = 5
                }
            }
        }
    }


Rectangle {

    id:circleright
    color: "black"
    radius: 20
    width: radius
    height: radius



        anchors {
            horizontalCenter: mainRect.right
            verticalCenter: mainRect.verticalCenter
        }

        MouseArea {
            anchors.fill: parent
            onMouseXChanged: {
                mainRect.width = mainRect.width + mouseX
                if(mainRect.width < 5)
                {
                    mainRect.width = 5
                }
            }
        }
    }


  Rectangle {
    id:circletop
    color: "black"
    radius: 20
    width: radius
    height: radius

        anchors {
            horizontalCenter: mainRect.horizontalCenter
            verticalCenter: mainRect.top
        }

        MouseArea {
            anchors.fill: parent
            onMouseYChanged: {
                mainRect.y = mainRect.y + mouseY
                mainRect.height = mainRect.height - mouseY
                if(mainRect.height < 5)
                {
                    mainRect.height = 5
                }
            }
        }
    }

   Rectangle {

    id:circlebottom
    color: "black"
    radius: 20
    width: radius
    height: radius

        anchors
        {

            horizontalCenter: mainRect.horizontalCenter
            verticalCenter: mainRect.bottom
        }

        MouseArea {
            anchors.fill: parent
            onMouseYChanged: {
                mainRect.height = mainRect.height + mouseY
                if(mainRect.height < 5)
                {
                    mainRect.height = 5
                }
            }
        }
    }

*/


// arrow buttons to navigate the gallery-----------------

/*
RowLayout{
    id:arrowbuttons
    anchors.bottom: parent.bottom
    spacing: 10 

Rectangle{

width: 50
height: 50
color: "blue"

MouseArea{

anchors.fill: parent

onClicked: {

if (gallery.currentIndex > 0){
gallery.currentIndex--

}

}

}
Text {
    anchors.centerIn: parent
    text: "<"
    font.pixelSize: 20
}

}


Rectangle{

width: 50
height: 50
color: "blue"

MouseArea{

anchors.fill: parent
onClicked: {

if (gallery.currentIndex > 0){
gallery.currentIndex++

}

}

}
Text {
    anchors.centerIn: parent
    text: ">"
    font.pixelSize: 20
}

}



}

*/

//------------------------


    FolderDialog {
        id: folderDialog

        onAccepted: {
            folderModel.folder = selectedFolder
            allGallery.visible = true
        }
    }

    
    //save dialog
    Dialog{
        id: savemask

        title: "Would you like to save?"

        width: 400
        height: 200

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        standardButtons: Dialog.Save|Dialog.No


        Text{
            text: "Would you like to save your mask before changing images?"


        }

        onAccepted: {
            console.log("save when we know how to save")
            saveIconButton.enabled = false
            changeImage(folderModel.folder + "/" + savemask.title)
            tbox.initLabels(folderModel.folder + "/" + savemask.title), refreshMask()
        }

        onRejected: {
            changeImage(folderModel.folder + "/" + savemask.title)
            tbox.initLabels(folderModel.folder + "/" + savemask.title), refreshMask()
        }
    }
    // Label Legend
    Rectangle {
        id: labelLegend
        color: "white"
        width: (allGallery.x - (image.x + image.width) ) - 20
        height: image.height / 3
        visible: false

        border.color: "black"
        anchors.verticalCenter: image.verticalCenter
        anchors.left: image.right
        anchors.leftMargin: 10
        anchors.right: allGallery.left
        anchors.rightMargin: 10

        ListModel {
            id: labelLegendModel
        }

        ListView {
            id: labelLegendList
            model: labelLegendModel
            clip: true
            spacing: 5

            anchors.fill: labelLegend

            delegate: Rectangle {
                id: labelRow
                height: 25
                width: parent.width
                color: "transparent"

                Rectangle {
                    id: labelSquare
                    height: parent.height / 1.5
                    width : parent.height / 1.5
                    color: labelColor

                    border.color: "black"
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    anchors.top: parent.top
                    anchors.topMargin: 5
                }
                
                Text {
                    id: labelText
                    text:labelName
                    width: parent.width
                    height: parent.height
                    minimumPointSize: 20
                    font.pointSize: 20
                    fontSizeMode: Text.Fit

                    anchors.verticalCenter: labelSquare.verticalCenter
                    anchors.left: labelSquare.right
                    anchors.leftMargin: 10 
                }
            }
        }

     }

    function populateLegend(labels) {
        labels.forEach(label => {
            labelLegendModel.append( {
                    labelColor: label[0],
                    labelName: label[1]
                })
        })
        

     }



}

