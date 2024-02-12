import QtCore
import QtQuick 
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts 
import QtQuick.Shapes 1.6
import Qt.labs.folderlistmodel


//import QtGraphicalEffects 1.15
//import AppStyle 1.0

import Actions

ApplicationWindow {
    id: window

    width: 800
    height: 600
    visible: true

    property var currentTool: ""
    property var labelsAndCoords: {}
    property var labelAndColor: ({})
    property var labelNames: []

    property var labelAndSize: {}

    property var shapes: []

    property var species: tbox.readCSV("SpeciesList.csv")
    property var imageSpecies: []

    //////////////////////////////////////////////////////////toolbox/////////////////////////////////////////////////////////
    LoadFunctions{
        id: lf

        win: window
    }

    ToolFunctions{
        id:tf
    }


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


    function populateLegend() {
        comboyuh.model.forEach(label => {
            labelLegendModel.append( {
                    labelColor: labelAndColor[findLabel(label)],
                    labelName: label
                })
        })   
    }

    function refreshLegend() {
        labelLegendModel.clear()
    }

    function findLabel(sp){
        var hold = ""
        for(var i = 0; i < species.length; i++){
            if(sp == species[i][1]){
                hold = species[i][0]
            }
        }
        return hold

    }


	function actionCreate(shape){
		//actionStack.push(CreateAction{"target": shape});
	}

	function actionMove(shape, dx, dy){
		//actionStack.push(MoveAction{"target": shape, "dX": dx, "dY": dy});
	}

    function labelToSpecies(yuh){
        var hold = []
        for(var i = 0; i < yuh.length; i++){
            for(var g = 0; g < species.length; g++){
                if(yuh[i] == species[g][0]){
                    hold.push(species[g][1])
                }
            }
        }
        return hold
    }

    function getImageSpecies(labnames){
        var hold = []
        for(var i = 0; i < labnames.length; i++){
            for(var g = 0; g < species.length; g++){
                if(labnames[i] == species[g][0]){
                    imageSpecies.push(species[g])
                }
            }
        }
    }

    function rectangleComponent(){

        //create a QML component from shapes.qml
        const component = Qt.createComponent("rectangleSelect.qml");

        //make sure component works properly
        if (component.status === Component.Ready) {
            //make shapes
            console.log("yuh1")
            return component
        }
        else if (component.status === Component.Error){
            console.log(component.errorString())
        }
        return
    }


    function ellipseComponent(){

        //create a QML component from shapes.qml
        const component = Qt.createComponent("ellipseSelect.qml");

        //make sure component works properly
        if (component.status === Component.Ready) {
            //make shapes
            console.log("yuh2")
            return component
        }
        else if (component.status === Component.Error){
            console.log(component.errorString())
        }
        return
    }


    function aiComponent(){
        //create a QML component from shapes.qml
        const component = Qt.createComponent("shapes.qml");
        //make sure component works properly
        if (component.status === Component.Ready) {
            //make shapes
            console.log("yuh3")
            return component
        }
        else if (component.status === Component.Error){
            console.log(component.errorString())
        }
        return
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
                    // refreshMask()
                    // populateLegend(labels)
                    // labelLegend.visible = true
                    // saveIconButton.enabled = true
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
                icon.source: "icons/save.png"
                
                MouseArea {
                    anchors.fill: parent
                        
                    onClicked: {
                        enabled = false
                        
                        lf.updateLabelsAndCoords()
                        tbox.saveLabels(labelsAndCoords, lf.split(image.source))

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
                    //console.log(lf.split(image.source))
                    if(lf.hasLabels(lf.split(image.source))){
                        lf.resetLabels()
                        lf.resetShapes()
                        imageSpecies = []
                        
                        lf.loadLabels(lf.split(image.source))

                        lf.loadShapes()
                        getImageSpecies(labelNames)
                        comboyuh.model = labelToSpecies(labelNames)
                        populateLegend()
                    }
                    else{
                        lf.resetLabels()
                        lf.resetShapes()
                        imageSpecies = []
                        comboyuh.model = []
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

                property var comp: tf.createLassoComponent()

                property var magicWandComponent: aiComponent()
                property var polygon: []

                property var rectComponent: rectangleComponent()
                property var ellipComponent: ellipseComponent()

                property var g: undefined

                property var ogx: 0
                property var ogy: 0

                property var dx: 0
                property var dy: 0

                property var shapeCurrent: undefined

                //fix mouse coordinate
                function getMouseX() {
                    return (overlay.width - overlay.paintedWidth) * 0.5
                }

                function getMouseY() {
                    return (overlay.height - overlay.paintedHeight) * 0.5
                }

                function fixMouse(image) {
                    fixedMouseX = Math.floor((mouseX - getMouseX()) / overlay.mouseFactorX)
                    fixedMouseY = Math.floor((mouseY - getMouseY()) / overlay.mouseFactorY)             
                }


                onPressed: { 
                    //lasso tool
                    if (currentTool == "lassotool"){
                        if(comboyuh.currentText != undefined){
                            g = comp.createObject(overlay, {"label": findLabel(comboyuh.currentText)})
                            g.child.startX = mouseX
                            g.child.startY = mouseY
                            shapes.push(g)
                        }
                    }

                    //move tool
                    else if (currentTool == "movetool"){
                        shapeCurrent = undefined
                        for(var i = 0; i < shapes.length; i++){
                            if(shapes[i].contains(Qt.point(mouseX, mouseY)) && shapes[i].label == findLabel(comboyuh.currentText)){
                                shapeCurrent = shapes[i]
                            }
                            
                        }
                        dx = mouseX
                        ogx = mouseX
                        dy = mouseY
                        ogy = mouseY
                        
                    }

                    //for magic wand
                    else if (currentTool == "magicwand"){
                        //scale mouse to image
                        fixMouse(image)
                        
                        //get AI polygon as shape object
                        polygon = tbox.getPrediction(findLabel(comboyuh.currentText), image.source, fixedMouseY, fixedMouseX, getMouseX(), getMouseY(), overlay.mouseFactorX, overlay.mouseFactorY)
                        shapes.push(magicWandComponent.createObject(overlay, {"label": findLabel(comboyuh.currentText), "coords": polygon, "color": labelAndColor[findLabel(comboyuh.currentText)], "colorline": labelAndColor[findLabel(comboyuh.currentText)]}))

                        refreshLegend()
                        populateLegend()

                        // tbox.magicWand(image.source, fixedMouseX, fixedMouseY, value), refreshMask()
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


                        for(var i = 0; i < 2; i++){
                            console.log(labelAndColor[i])
                        }

                        shapes.push(ellipComponent.createObject(overlay, {"label": findLabel(comboyuh.currentText), "color": labelAndColor[findLabel(comboyuh.currentText)], "coorline": labelAndColor[findLabel(comboyuh.currentText)]}))

                        refreshLegend()
                        populateLegend()
                    }

                    //if square is held down, record those coordinates
                    else if (currentTool == "squareselect"){
                        fixMouse(image)

                        holdedx = fixedMouseX
                        holdedy = fixedMouseY

                        shapes.push(rectComponent.createObject(overlay, {"label": findLabel(comboyuh.currentText), "color": labelAndColor[findLabel(comboyuh.currentText)], "colorline": labelAndColor[findLabel(comboyuh.currentText)]}))

                        refreshLegend()
                        populateLegend()
                    }

                    //means no tool was selected
                    else{
                        console.log("Please choose a tool")
                    }
                }

                
                onPositionChanged: {
                    if (currentTool == "lassotool"){
                        if(comboyuh.currentText != undefined){
                            tf.drawShape(g, mouseX, mouseY)
                        }
                    }
                    else if (currentTool == "movetool"){
                        if(shapeCurrent != undefined){
                            for(var i = 0; i < shapeCurrent.child.pathElements.length; i++){
                                shapeCurrent.child.pathElements[i].x += (mouseX - dx)
                                shapeCurrent.child.pathElements[i].y += (mouseY - dy)
                    
                            }
                            shapeCurrent.child.startX += (mouseX - dx)
                            shapeCurrent.child.startY += (mouseY - dy)
                            dx = mouseX
                            dy = mouseY
                        }
                    }
                }


                //mouse released actions
                onReleased: {
                    //lasso tool
                    if (currentTool == "lassotool"){
                        if(comboyuh.currentText != undefined){
                            tf.endShape(g, labelAndColor[g.label])
                            actionCreate(g)
                            if(comboyuh.currentText != undefined){
                                tf.endShape(g, labelAndColor[g.label])
                                actionCreate(g)
                            }
                            else{
                                console.log("select a label")
                            }
                        }
                        refreshLegend()
                        populateLegend()
                    }

                    //move tool
                    else if (currentTool == "movetool"){
                        if(shapeCurrent != undefined){
                            dx = mouseX - ogx
                            dy = mouseY - ogy

                            actionMove(shapeCurrent, dx, dy)
                        }
                         saveIconButton.enabled = true
                    }

                    //just not that the save needs to happen now
                    if (currentTool == "magicwand"){
                        //console.log(mouseX, mouseY)
                        //tbox.magicWand(image.source, mouseX * mouseFactorX, mouseY * mouseFactorY, value), refreshMask()
                         saveIconButton.enabled = true
                    }

                    //tell timer to stop and save needs to happen now
                    else if (currentTool == "paintbrush"){
                        isPressed = false
                         saveIconButton.enabled = true
                    }

                    //get last coordinate to make circle, save needs to happen now
                    else if (currentTool == "circleselect"){
                        fixMouse(image)

                        //tbox.selectCircle(holdedx, holdedy, fixedMouseX, fixedMouseY), refreshMask()
                        saveIconButton.enabled = true
                    }

                    //get last coordinate to make square, save needs to happen now
                    else if (currentTool == "squareselect"){
                        fixMouse(image)

                        //tbox.selectRect(holdedx, holdedy, fixedMouseX, fixedMouseY), refreshMask()
                        saveIconButton.enabled = true
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

            property var thisModel: labelToSpecies(labelNames)

            model: thisModel

            

            // When a label is chosen, change the shapes for that label.
            onActivated: {
                for (var i = 0; i < shapes.length; i++){
                    if (shapes[i].label == findLabel(currentText)){
                        shapes[i].colorline = "yellow"
                    }
                    else {
                        shapes[i].colorline = labelAndColor[shapes[i].label]
                    }
                }
                
            }

    }

    
    //new label text field
    TextField {
        anchors.top: comboyuh.bottom
        anchors.left: image.right
        placeholderText: qsTr("Enter new label")

        //went typed and pressed enter
        onAccepted: {
            var aSpecies = false
            var alreadyInList = false

            var curText = text


            //find if species already has text
            for (var i = 0; i < species.length; i++){
                if(species[i][1] == curText){
                    //check if the species is already in our combobox
                    for(var g = 0; g < imageSpecies; g++){
                        if(imageSpecies[i][1] == curText){
                            alreadyInList = true
                        }
                    }

                    //if it is, just ignore text
                    if(alreadyInList == true){
                        aSpecies = false
                        comboyuh.currentText = curText
                    }

                    //else, add it to the combobox and our image labels
                    else{
                        aSpecies = true
                        imageSpecies.push(species[i])
                        labelNames.push(species[i][0])
                        comboyuh.thisModel.push(species[i][1])
                        comboyuh.model = comboyuh.thisModel

                        var color = Qt.rgba(Math.random(),Math.random(),Math.random(),1);


                        labelAndColor[species[i][0]] = color;
                    }

                }
            }

            //if it is a new label
            if(aSpecies != true){
                //add to combobox and species list and all other variables
                species.push(lf.addToSpeciesList(species[species.length-1][0], curText))
                imageSpecies.push([species[species.length-1]])
                labelNames.push(species[species.length-1][0])
                comboyuh.thisModel.push(species[species.length-1][1])
                comboyuh.model = comboyuh.thisModel


                var color = Qt.rgba(Math.random(),Math.random(),Math.random(),1);
                labelAndColor[species[species.length-1][0]] = color;
            }

            //remove the text from box
            remove(0, text.length)


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
                icon.source: "icons/magicwand.png"
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
                        lassoSelectIcon.enabled = true
                        moveSelectIcon.enabled = true

                        currentTool = "magicwand"
                    }

                }
            }

            Button {
                id:paintbrushIcon
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50
                icon.source: "icons/paintbrush.png"
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
                        lassoSelectIcon.enabled = true
                        moveSelectIcon.enabled = true

                        currentTool = "paintbrush"
                    }

                }
            }
            Button {
                id:circleSelectIcon
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50
                icon.source: "icons/circleselect.png"
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
                        lassoSelectIcon.enabled = true
                        moveSelectIcon.enabled = true

                        currentTool = "circleselect"
                    }

                }
            }
            Button {
                id:squareSelectIcon
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50
                icon.source: "icons/squareselect.png"
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
                        lassoSelectIcon.enabled = true
                        moveSelectIcon.enabled = true

                        currentTool = "squareselect"
                    }

                }
            }

            Button {
                id:moveSelectIcon
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50
                icon.source: "icons/move.png"
                enabled: true

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        valueSlider.visible = false
                        sliderTitle.visible = false

                        moveSelectIcon.enabled = false
                        lassoSelectIcon.enabled = true
                        squareSelectIcon.enabled = true
                        magicWandIcon.enabled = true
                        paintbrushIcon.enabled = true
                        circleSelectIcon.enabled = true

                        currentTool = "movetool"
                    }

                }
            }

            Button {
                id: lassoSelectIcon
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50
                icon.source: "icons/lasso.png"
                enabled: true

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        valueSlider.visible = false
                        sliderTitle.visible = false

                        lassoSelectIcon.enabled = false
                        moveSelectIcon.enabled = true
                        squareSelectIcon.enabled = true
                        magicWandIcon.enabled = true
                        paintbrushIcon.enabled = true
                        circleSelectIcon.enabled = true

                        currentTool = "lassotool"
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

                                if(lf.hasLabels(folderModel.folder + "/" + fileName)){
                                    lf.resetLabels()
                                    lf.resetShapes()
                                    imageSpecies = []


                                    lf.loadLabels(fileName)
                                    getImageSpecies(labelNames)
                                    comboyuh.model = labelToSpecies(labelNames)
                                    refreshLegend()
                                    populateLegend()
                                }
                                else{
                                    lf.resetLabels()
                                    lf.resetShapes()
                                    imageSpecies = []
                                    comboyuh.model = []
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
                width: labelLegendList.width
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
>>>>>>> integration
