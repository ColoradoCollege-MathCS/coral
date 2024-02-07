import QtCore
import QtQuick 
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts 
import QtQuick.Shapes 1.6
import Qt.labs.folderlistmodel


//import QtGraphicalEffects 1.15
//import AppStyle 1.0



ApplicationWindow {
    width: 800
    height: 600
    visible: true

    property var currentTool: ""
    property var labelsAndCoords: {}
    property var labelAndColor: {}
    property var labelNames: []

    property var shapes: []


    /////////////////////////////////////////////////////////functions///////////////////////////////////////////////////////

    function refreshMask() {
        overlay.source = "images/mask2.png"
        overlay.source = "images/mask.png"
    }

    function changeImage(fileName){
        image.source = fileName
        image.width = sourceSize.width / parent.width * 4/8
        image.height = sourceSize.height / (parent.height - 50)
    }

    function resetLabels(){
        labelsAndCoords = {}
        labelNames = []
    }

    function split(filePath){
        return tbox.splited(filePath)
    }


    //function to parse a big array and load all labels if an image has a set of labels
    function loadLabels(imgLoad){
        //load in csv from python function
        var everything = tbox.readCSV("labels/" + imgLoad + ".csv");

        //holding dictionaries, arrays, and variables
        var labelsAndCoordinates = {};
        var labelNames1 = new Array(0);
        var shapeAndCoordinates = {};
        var labelAndCol = {};
        var coordinates = new Array(0);

        var hold = ""
        var shape = 0


        //loop through the whole array per line
        for (var i = 0; i < everything.length; i++){

            //if we have a label line, make a new label
            if (everything[i][0] == "Label"){
                if (coordinates.length == 0){
                    labelNames1.push(everything[i][1]);
                    hold = everything[i][1];
                }
                else{
                    shapeAndCoordinates[shape] = coordinates;
                    labelsAndCoordinates[hold] = shapeAndCoordinates;

                    shape = 0
                    shapeAndCoordinates = {};
                    labelNames1.push(everything[i][1]);
                    hold = everything[i][1];
                }
                labelAndCol[everything[i][1]] = ""
                
            }

            //if we have a shape line, make a new shape for the label
            else if (everything[i][0] == "Shape"){
                if (coordinates.length == 0){
                    shape += 1;
                }
                else{
                    shapeAndCoordinates[shape] = coordinates;
                    coordinates = new Array(0);
                    shape += 1;
                }
            }

            //if we have a coordinate line, make a new coordinate for the line
            else{
                coordinates.push([parseInt(everything[i][0]), parseInt(everything[i][1])]);
            }
            
        }


        //reached end, place all items in correct locations
        shapeAndCoordinates[shape] = coordinates;
        labelsAndCoordinates[hold] = shapeAndCoordinates;

        //make them global variables
        labelsAndCoords = labelsAndCoordinates
        labelNames = labelNames1
        labelAndColor = labelAndCol
    }

    //function to check if current image has a label file
    function hasLabels(imgsource){
        console.log(tbox.fileExists("labels/" + imgsource + ".csv"))
        return tbox.fileExists("labels/" + imgsource + ".csv")
    }

    //a function to loop through the current label's shapes and create shapes from coordinates
    function loopy(comp, label){
        for(var i = 1; i <= 2; i++){
            if(labelAndColor[label] != ""){
                shapes.push(comp.createObject(overlay, {"coords": labelsAndCoords[label][i], "label": label, 
                "color": labelAndColor[label], "colorline": labelAndColor[label]}));
            }
            else{
                var color = Qt.rgba(Math.random(),Math.random(),Math.random(),1);
                labelAndColor[label] = color
                shapes.push(comp.createObject(overlay, {"coords": labelsAndCoords[label][i], "label": label, 
                "color": color, "colorline": color}));
            }
        }
    }

    //a function to display shapes
    function loadShapes(){
        //create a QML component from shapes.qml
        const component = Qt.createComponent("shapes.qml");

        //make sure component works properly
        if (component.status === Component.Ready) {
            //make shapes
            for(var i = 0; i < labelNames.length; i++){
                loopy(component, labelNames[i])
            }
        }
        else if (component.status === Component.Error){
            console.log(component.errorString())
        }
    }

    //a function to destroy all shapes
    function resetShapes(){
        for(var i = 0; i < shapes.length; i++){
            shapes[i].destroy()
        }
        shapes = []
    }


    //function to update labels and coords to save
    function updateLabelsAndCoords(){
        labelsAndCoords = {}
        var holdDict = {};
        var hold = [];

        var count = 0;

        //dictionary stuff
        for(var f = 0; f < labelNames.length; f++){
            for(var i = 0; i < shapes.length; i++){
                //get label
                if(shapes[i].label == labelNames[f]){
                    //for each shape, find its label, add coordinates to hold
                    for(var g = 0; g < shapes[i].child.pathElements.length; g++){
                        hold.push([shapes[i].child.pathElements[g].x, shapes[i].child.pathElements[g].y])
                    }

                    //add coordinates to shape
                    holdDict[count] = hold;

                    hold = []
                    
                    count += 1;
                }
            }
            
            //place all shapes in label dict
            labelsAndCoords[labelNames[f]] = holdDict
            holdDict = {};
            count = 0;
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



    

    ///////////////////////////////////////////////////////////Top menu/////////////////////////////////////////////////////////
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
                    // var labels = tbox.getPrediction(filename, (30,30)); 
                    tbox.getPrediction(image.source, 225, 250)
                    refreshMask()
                    // populateLegend(labels)
                    labelLegend.visible = true
                    saveIconButton.enabled = true
                }
            }
        }
    }

    /////////////////////////////////////////////////////////row tool bar////////////////////////////////////////////////////////
    header: ToolBar {
        
        RowLayout {
            anchors.fill: parent
            
            //choose an image and display in image section
            ToolButton {
                text: qsTr("Choose Image")
    
                onClicked: fileDialog.open()
                Layout.alignment: Qt.AlignLeft

            }

            //choose a folder for the gallery
            ToolButton {
                text: qsTr("Choose Folder")

                onClicked: {
                    folderDialog.open()
                }
                Layout.alignment: Qt.AlignLeft
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
                        
                        updateLabelsAndCoords()
                        tbox.saveLabels(labelsAndCoords, split(image.source))

                    }
                    
                }
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
                onAccepted: {
                    image.source = selectedFile
                    tbox.initLabels(selectedFile)
                    refreshMask()
                    console.log(split(image.source))
                    if(hasLabels(split(image.source))){
                        console.log("periodt")
                        loadLabels(split(image.source))

                        loadShapes()

                    }
                    else{
                        resetLabels()
                        resetShapes()
                    }
                }
            }


            StackView {
                id: stack
                //anchors.fill: parent
            }
        }
    }


    /////////////////////////////////////////////////////////image interface////////////////////////////////////////////////////////


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
            property var mouseFactorX: image.paintedWidth / image.sourceSize.width
            property var mouseFactorY: image.paintedHeight / image.sourceSize.height


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


                //fix mouse coordinate
                function getMouseX(image) {
                    return (overlay.width - overlay.paintedWidth) * 0.5
                }

                function getMouseY(image) {
                    return (overlay.height - overlay.paintedHeight) * 0.5
                }

                function fixMouse(image) {
                    fixedMouseX = Math.floor((mouseX - getMouseX(image)) / overlay.mouseFactorX)
                    fixedMouseY = Math.floor((mouseY - getMouseY(image)) / overlay.mouseFactorY)             
                }


                onPressed: { 
                    //for magic wand
                    if (currentTool == "magicwand"){

                        //console.log(mouseX, mouseY)
                        
                        fixMouse(image)

                        tbox.magicWand(image.source, fixedMouseX, fixedMouseY, value), refreshMask()
                    }

                    //paintbrush if held down
                    else if (currentTool == "paintbrush"){
                        isPressed = true
                    }

                    //if circle is held down, record those coordinates
                    else if (currentTool == "circleselect"){
                        fixMouse(image)

                        holdedx = fixedMouseX
                        holdedy = fixedMouseY
                    }

                    //if square is held down, record those coordinates
                    else if (currentTool == "squareselect"){
                        fixMouse(image)

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
                        fixMouse(image)

                        tbox.selectCircle(holdedx, holdedy, fixedMouseX, fixedMouseY), refreshMask()
                        saveIconButton.enabled
                    }

                    //get last coordinate to make square, save needs to happen now
                    else if (currentTool == "squareselect"){
                        fixMouse(image)

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


    /////////////////////////////////////////////////////////labels//////////////////////////////////////////////////////////////
            
    ComboBox{
            id: comboyuh

            anchors.left: image.right
            
            // Set the initial currentIndex to the value stored in the backend.
            Component.onCompleted: currentIndex = indexOfValue(backend.modifier)

            model: labelNames
            

            // When a label is chosen, change the shapes for that label.
            onActivated: {
                for (var i = 0; i < shapes.length; i++){
                    if (shapes[i].label == currentText){
                        shapes[i].colorline = "yellow"
                    }
                    else {
                        shapes[i].colorline = labelAndColor[shapes[i].label]
                    }
                }
                
            }

    }
            
    

    //////////////////////////////////////////////////////////side tool bar////////////////////////////////////////////////////////
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


    ////////////////////////////////////////////////////////////gallery///////////////////////////////////////////////////////////
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

                                if(hasLabels(folderModel.folder + "/" + fileName)){
                                    loadLabels(fileName)
                                }
                                else{
                                    resetLabels()
                                }
                            }
                            
                        }

                    }
                }
            }

            //Make all components from folder
            delegate: fileDelegate
        }
    }



    //choose a filder dialog
    FolderDialog {
        id: folderDialog

        onAccepted: {
            folderModel.folder = selectedFolder
            allGallery.visible = true
        }
    }

    
    //////////////////////////////////////////////////////////////save////////////////////////////////////////////////////////////
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




    /////////////////////////////////////////////////////////label legend////////////////////////////////////////////////////////
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
}
