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

    property var species: tbox.readCSV(tbox.getFileLocation() + "/" + "SpeciesList.csv")
    property var imageSpecies: []

    //////////////////////////////////////////////////////////toolbox/////////////////////////////////////////////////////////
    LoadFunctions{
        id: lf

        win: window
    }

    ToolFunctions{
        id:tf
    }

    ActionHandler{
        id:act
    }

    /////////////////////////////////////////////////////////functions///////////////////////////////////////////////////////

    function refreshMask() {
        overlay.source = "images/mask2.png"
        overlay.source = "images/mask.png"
    }

    function changeImage(fileName){
        image.source = fileName
    }

    //funcion to populate color and label name in the legend
    function populateLegend() {
        // for(var i = 0; i < species.length; i++){

        // }
        imageSpecies.forEach(label => {
            labelLegendModel.append( {
                    labelColor: labelAndColor[label[0]],
                    labelName: label[1]
            })
        })   
    }

    // function to clear legend when new img is selected
    function refreshLegend() {
        labelLegendModel.clear()
    }

    //function to find label number from name
    function findLabel(sp){
        var hold = ""
        for(var i = 0; i < species.length; i++){
            if(sp == species[i][1]){
                hold = species[i][0]
            }
        }
        return hold

    }


    //function to give all species names of an array of label numbers
    function labelToSpecies(labnames){
        var hold = []
        for(var i = 0; i < labnames.length; i++){
            for(var g = 0; g < species.length; g++){
                if(labnames[i] == species[g][0]){
                    hold.push(species[g][1])
                }
            }
        }
        return hold
    }

    //function to give all species and labels of an image
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
        print(component)
        print(component.status)
        print(Component.Ready)

        //make sure component works properly
        if (component.status === Component.Ready) {
            //make shapes
           
            return component
        }
        else if (component.status === Component.Error){       
            console.log(component.errorString())
        }
        return
    }
    function paintComponent(){

        const component = Qt.createComponent("paintbrush.qml");

        if (component.status === Component.Ready) {
            //make shapes
            // console.log("yuh3")
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
            return component
        }
        else if (component.status === Component.Error){
            console.log(component.errorString())
        }
        return
    }

    //Remove all vertices from previous shape after new button is clicked
    function noMoreVertices(){
        imageMouse.previousShape = imageMouse.shapeCurrent
        tf.removeVertices(imageMouse.previousShape)
    }

    function allToolsOn(){
        imageMouse.selected = false
        deleteIcon.enabled = true
        lassoSelectIcon.enabled = true
        moveSelectIcon.enabled = true
        squareSelectIcon.enabled = true
        magicWandIcon.enabled = true
        paintbrushIcon.enabled = true
        circleSelectIcon.enabled = true
        vertexSelectIcon.enabled = true
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
            Action { text: qsTr("&Undo")
                id: undoAction
                shortcut: StandardKey.Undo
                onTriggered: {
                    act.undo()
                    enabled = act.actToUndo()
                    redoAction.enabled = act.actToRedo()
                }
                enabled: false
            }
            Action { text: qsTr("&Redo")
                id: redoAction
                shortcut: StandardKey.Redo
                onTriggered: {
                    act.redo()
                    enabled = act.actToRedo()
                    undoAction.enabled = act.actToUndo()
                }
                enabled: false
            }
        }
        Menu {
            title: qsTr("&Help")
            Action { 
                text: qsTr("&About")
                onTriggered: {
                    aboutPopUp.open()
                }
            }
        }
        Menu {
            title: qsTr("&Tools")
            Action {
                text: qsTr("Random Rectangle")
                onTriggered: {
                    tbox.randomRectangle()//, refreshMask()
                    saveIconButton.enabled = true
                }
            }
            Action {
                text: qsTr("Statistics")
                onTriggered: {
                    statsPopUp.open()
                }
            }
            Action {
                text: qsTr("File Locations")
                onTriggered: {
                    saveLocationsPopup.updateText()
                    saveLocationsPopup.open()
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
                   

            //save labels button
            Button {
                id:saveIconButton
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50
                enabled: false
                icon.source: "icons/save.png"
                
                MouseArea {
                    anchors.fill: parent
                        
                    onClicked: {
                        saveIconButton.enabled = false
                        
                        lf.updateLabelsAndCoords()

                        tbox.saveLabels(labelsAndCoords, lf.split(image.source), lf.paintshapes)
                        // tbox.saveRasters(labelsAndCoords, imageMouse.getMouseX(), imageMouse.getMouseY(), overlay.mouseFactorX, overlay.mouseFactorY, image.sourceSize.width, image.sourceSize.height, lf.split(image.source), lf.paintshapes)
                    }
                    
                }
            }

            //save raster button
            Button {
                id:saveRasterIconButton
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50
                enabled: false
                icon.source: "icons/save.png"     
                        
                onClicked: {
                    saveRasterIconButton.enabled = false
                    // lf.updateLabelsAndCoords()
                    // tbox.saveLabels(labelsAndCoords, lf.split(image.source), lf.paintshapes)
                    tbox.saveRasters(labelsAndCoords, imageMouse.getMouseX(), imageMouse.getMouseY(), overlay.mouseFactorX, overlay.mouseFactorY, image.sourceSize.width, image.sourceSize.height, lf.split(image.source))
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

            //slider value for either the magic wand, paintbrush, or lasso
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
                        to = 20
                        imageMouse.value = value
                    }

                    else if (currentTool == "paintbrush"){
                        from = 0
                        to = 50
                        imageMouse.value = value
                    }

                    else if (currentTool == "lassotool") {
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
                    //tbox.initLabels(selectedFile)
                    //refreshMask()
                    refreshLegend()
                    populateLegend()

                    if(saveIconButton.enabled == true){
                        savemask.title = selectedFile
                        savemask.open()
                    }
                    if(lf.hasLabels(lf.split(image.source))){
                        lf.resetLabels()
                        lf.resetShapes()
                        imageSpecies = []
                        
                        lf.loadLabels(lf.split(image.source))

                        lf.loadShapes()
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
                        refreshLegend()
                        populateLegend()
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

                property var paintComp: paintComponent()


                property var magicWandComponent: aiComponent()
                property var polygon: []



                property var rectComponent: rectangleComponent()
                property var ellipComponent: ellipseComponent()

                property var g: undefined

                property var ogx: 0
                property var ogy: 0

                property var dx: 0
                property var dy: 0

                property var controlNum: undefined
                property var currentVertex: undefined

                property var shapeCurrent: undefined
                property var previousShape: undefined

                property var shapeLocation: 0

                property var selected: false

                //fix mouse coordinate
                function getMouseX() {
                    return (image.width - image.paintedWidth) * 0.5
                }

                function getMouseY() {
                    return (image.height - image.paintedHeight) * 0.5
                }

                function fixMouse(image) {
                    fixedMouseX = Math.floor((mouseX - getMouseX()) / overlay.mouseFactorX)
                    fixedMouseY = Math.floor((mouseY - getMouseY()) / overlay.mouseFactorY)             
                }

                //function to check whether a vertex or mouse click is in the boundary of the image
                function checkBoundary(vert, mx, my, dx, dy){
                    if (vert != undefined){
                        return (vert.papa.x + (mx - dx) <= image.paintedWidth + getMouseX() && 
                                vert.papa.x + (mx - dx) >= getMouseX() && 
                                vert.papa.y + (my - dy) >= getMouseY() &&
                                vert.papa.y + (my - dy) <= image.paintedHeight + getMouseY())
                    }
                    else if(vert == undefined && (dx != -100 && dy != -100)){
                        return ((mx - dx) <= image.paintedWidth + getMouseX() && 
                                (mx - dx) >= getMouseX() && 
                                (my - dy) >= getMouseY() &&
                                (my - dy) <= image.paintedHeight + getMouseY())
                    }
                    else{
                        return ((mx - dx) <= image.paintedWidth + getMouseX() && 
                                (mx) >= getMouseX() && 
                                (my) >= getMouseY() &&
                                (my - dy) <= image.paintedHeight + getMouseY())
                    }
                }


                onPressed: { 
                    //make sure a label and image is selected
                    if (image.source.toString() === "") {
                        errorMsg.text = "Please select an image"
                        errorPopUp.open()
                    }

                    else if (comboyuh.currentText === "") {
                        errorMsg.text = "Please select a label"
                        errorPopUp.open()
                    }

                    else {

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
                            polygon = tbox.getPrediction(image.source, fixedMouseY, fixedMouseX, getMouseX(), getMouseY(), overlay.mouseFactorX, overlay.mouseFactorY, imageMouse.value)
                            shapes.push(magicWandComponent.createObject(overlay, {"label": findLabel(comboyuh.currentText), "coords": polygon, "color": labelAndColor[findLabel(comboyuh.currentText)], "colorline": labelAndColor[findLabel(comboyuh.currentText)]}))

                            refreshLegend()
                            populateLegend()

                        }

                        //paintbrush if held down
                        else if (currentTool == "paintbrush"){
                            
                            if(checkBoundary(undefined, mouseX, mouseY, 0, 0)){
                                if(comboyuh.currentText != undefined){
                                    g = paintComp.createObject(overlay, {"label": findLabel(comboyuh.currentText)})
                                        
                                    g.child.strokeWidth = value

                                    g.child.startX = mouseX
                                    g.child.startY = mouseY

                                    shapes.push(g)

                                }
                            }
                            else{
                                g = undefined
                            }
                            

                        }

                        //if circle is held down, record those coordinates
                        else if (currentTool == "circleselect"){

                                
                                fixMouse(image)

                            //variable to solve shape + radius
                            var sizex = 0
                            var sizey = 0
                            

                            for(var i = 0; i < shapes.length; i++){
                                if(shapes[i].contains(Qt.point(mouseX, mouseY)) && shapes[i].label == findLabel(comboyuh.currentText)){
                                    if(shapeCurrent == shapes[i]){
                                        selected = true
                                    }
                                    
                                }
                            }


                            //get what circle was selected
                            if(selected == true){
                                for(var h = 0; h < shapeCurrent.controls.length; h++){

                                    sizex = shapeCurrent.controls[h].x + shapeCurrent.controls[h].radius
                                    sizey = shapeCurrent.controls[h].y + shapeCurrent.controls[h].radius
                                    
                                    if(shapeCurrent.controls[h].x < mouseX && sizex > mouseX
                                    && shapeCurrent.controls[h].y < mouseY && sizey > mouseY){
                                        controlNum = shapeCurrent.controls[h]

                                    }
                                }
                            }

                            //make new shape if no shape was selected
                            else{
                                if (shapeCurrent != undefined){
                                    previousShape = shapeCurrent
                                    noMoreVertices(previousShape)
                                }
                                var newShape = ellipComponent.createObject(overlay, {"label": findLabel(comboyuh.currentText), "color": labelAndColor[findLabel(comboyuh.currentText)], 
                            "colorline": labelAndColor[findLabel(comboyuh.currentText)], "mX": mouseX, "mY": mouseY})
                                shapes.push(newShape)

                                shapeCurrent = newShape


                                selected = true
                            }


                            dx = mouseX
                            ogx = mouseX
                            dy = mouseY
                            ogy = mouseY

                            refreshLegend()
                            populateLegend()

                            selected = false



                            /*fixMouse(image)

                            holdedx = fixedMouseX
                            holdedy = fixedMouseY



                            for(var i = 0; i < 2; i++){
                                console.log(labelAndColor[i])
                            }

                            shapes.push(ellipComponent.createObject(overlay, {"label": findLabel(comboyuh.currentText), "color": labelAndColor[findLabel(comboyuh.currentText)], "coorline": labelAndColor[findLabel(comboyuh.currentText)]}))

                            refreshLegend()
                            populateLegend()

                            for(var i = 0; i < 2; i++){log(labelAndColor[i])
                            }
                            

                            shapes.push(ellipComponent.createObject(overlay, {"label": findLabel(comboyuh.currentText), "color": labelAndColor[findLabel(comboyuh.currentText)], 
                            "colorline": labelAndColor[findLabel(comboyuh.currentText)], "mX": mouseX, "mY": mouseY}))

                            tf.removeVertices(shapeCurrent)
                        */
                        }

                        //if square is held down, record those coordinates
                        else if (currentTool == "squareselect"){
                            fixMouse(image)

                            //variable to solve shape + radius
                            var sizex = 0
                            var sizey = 0
                            

                            for(var i = 0; i < shapes.length; i++){
                                if(shapes[i].contains(Qt.point(mouseX, mouseY)) && shapes[i].label == findLabel(comboyuh.currentText)){
                                    if(shapeCurrent == shapes[i]){
                                        selected = true
                                    }
                                    
                                }
                            }


                            //get what circle was selected
                            if(selected == true){
                                for(var h = 0; h < shapeCurrent.controls.length; h++){

                                    sizex = shapeCurrent.controls[h].x + shapeCurrent.controls[h].radius
                                    sizey = shapeCurrent.controls[h].y + shapeCurrent.controls[h].radius
                                    
                                    if(shapeCurrent.controls[h].x < mouseX && sizex > mouseX
                                    && shapeCurrent.controls[h].y < mouseY && sizey > mouseY){
                                        controlNum = shapeCurrent.controls[h]

                                    }
                                }
                            }

                            //make new shape if no shape was selected
                            else{
                                if (shapeCurrent != undefined){
                                    previousShape = shapeCurrent
                                    noMoreVertices(previousShape)
                                }

                                var newShape = undefined
                                var theFactorX = undefined
                                var theFactorY = undefined

                                var defau = true

                                if (!checkBoundary(undefined, mouseX, mouseY, -100, -100)){
                                    if((mouseX + 100) > image.paintedWidth + getMouseX() && (mouseY + 100) > image.paintedHeight + getMouseY()){
                                        
                                        theFactorX = image.paintedWidth + getMouseX() - mouseX
                                        theFactorY = image.paintedHeight + getMouseY() - mouseY

                                        console.log(theFactorX + ", " + theFactorY)

                                    }
                                    else if ((mouseX + 100) > image.paintedWidth + getMouseX()){
                                        theFactorX = image.paintedWidth + getMouseX() - mouseX
                                        console.log(theFactorX + ", " + theFactorY)
                                    }
                                    else{
                                        theFactorY = image.paintedHeight + getMouseY() - mouseY
                                        console.log(theFactorX + ", " + theFactorY)
                                    }

                                    defau = false
                                    
                                }

                                if(checkBoundary(undefined, mouseX, mouseY, 0, 0)){
                                    if(theFactorX == undefined){
                                        theFactorX = 100
                                    }
                                    if(theFactorY == undefined){
                                        theFactorY = 100
                                    }
    
                                    if(defau == false){
                                        newShape = rectComponent.createObject(overlay, {"label": findLabel(comboyuh.currentText), "color": labelAndColor[findLabel(comboyuh.currentText)], 
                                            "colorline": labelAndColor[findLabel(comboyuh.currentText)], "mX": mouseX, "mY": mouseY, "factorX": theFactorX, "factorY": theFactorY})
                                    }
                                    else{
                                        newShape = rectComponent.createObject(overlay, {"label": findLabel(comboyuh.currentText), "color": labelAndColor[findLabel(comboyuh.currentText)], 
                                            "colorline": labelAndColor[findLabel(comboyuh.currentText)], "mX": mouseX, "mY": mouseY})
                                    }
                                    shapes.push(newShape)
                                    shapeCurrent = newShape

                                    var currAction = Qt.createQmlObject("import Actions; CreateAction{}", this)

                                    currAction.shapeParent = overlay
                                    currAction.target = imageMouse.shapeCurrent

                                    act.actionDone(currAction, false)

                                    selected = true
                                }
                            }


                            dx = mouseX
                            ogx = mouseX
                            dy = mouseY
                            ogy = mouseY

                            refreshLegend()
                            populateLegend()

                            selected = false

                            
                        }

                        //actions for vertex tool
                        else if(currentTool == "vertextool"){
                            //check if shape has already been selected
                            var no = false
                            print(currentTool, shapeCurrent)
                            //check if shape has been selected and mouse is in one of its vertices
                            for(var i = 0; i < shapes.length; i++){
                                if(shapes[i].contains(Qt.point(mouseX, mouseY)) && shapes[i].label == findLabel(comboyuh.currentText) && shapeCurrent != undefined){
                                    for(var h = 0; h < shapeCurrent.controls.length; h++){

                                        sizex = shapeCurrent.controls[h].x + shapeCurrent.controls[h].radius
                                        sizey = shapeCurrent.controls[h].y + shapeCurrent.controls[h].radius
                                                    
                                        if(shapeCurrent.controls[h].x < mouseX && sizex > mouseX
                                        && shapeCurrent.controls[h].y < mouseY && sizey > mouseY && shapeCurrent == shapes[i]){
                                        
                                            no = true

                                        }
                                    }
                                }
                            }

                            //if shape has not been selected go make vertices
                            if(no != true){
                                for(var i = 0; i < shapes.length; i++){
                                    if(shapes[i].contains(Qt.point(mouseX, mouseY)) && shapes[i].label == findLabel(comboyuh.currentText)){
                                        if(shapeCurrent != shapes[i]){
                                            selected = false
                                        }
                                    }
                                }
                            }

                            //if shape has already been selected, choose vertex

                            if(selected == true) {
                                console.log("slay")
                                for(var h = 0; h < shapeCurrent.controls.length; h++){

                                    sizex = shapeCurrent.controls[h].x + shapeCurrent.controls[h].radius
                                    sizey = shapeCurrent.controls[h].y + shapeCurrent.controls[h].radius
                                                
                                    if(shapeCurrent.controls[h].x < mouseX && sizex > mouseX
                                    && shapeCurrent.controls[h].y < mouseY && sizey > mouseY){
                                        currentVertex = shapeCurrent.controls[h]

                                    }
                                }
                            }

                            //make vertices
                            else{
                                for(var i = 0; i < shapes.length; i++){
                                    if(shapes[i].contains(Qt.point(mouseX, mouseY)) && shapes[i].label == findLabel(comboyuh.currentText)){
                                        if(shapeCurrent != shapes[i]){
                                            //make previous shape since we clicked on a new shape
                                            previousShape = shapeCurrent
                                            shapeCurrent = shapes[i]
                                            //make vertices function
                                            tf.makeVertices(shapeCurrent)

                                            selected = true
                                            break
                                        }
                                        
                                    }
                                        
                                }
                            }

                            //remove all vertices of previous shape
                            tf.removeVertices(previousShape)



                            dx = mouseX
                            ogx = mouseX
                            dy = mouseY
                            ogy = mouseY

                        }

                        //delete the selected shape
                        else if (currentTool == "deletetool"){
                            var start = []
                            var end = []
                            var all = []
                            var yuh = false
                            var wasSelected = false
                    
                            for(var i = 0; i < shapes.length; i++){

                                if(shapes[i].contains(Qt.point(mouseX, mouseY)) && shapes[i].label == findLabel(comboyuh.currentText)){
                                    shapeLocation = i
                                    
                                    wasSelected = true

                                    shapeCurrent = shapes[shapeLocation]

                                    var currAction = Qt.createQmlObject("import Actions; DeleteAction{}", this)
                            
                                    currAction.shapeParent = overlay
                                    currAction.target = shapeCurrent
                                    currAction.idxInParent = shapeLocation
                                    currAction.everything = window

                                    shapeCurrent = undefined

                                    act.actionDone(currAction, true)

                                    break
                                }
                            }

                            if(wasSelected){
                                for(var i = 0; i < shapes.length; i++){
                                    if(i > shapeLocation){
                                        all.push(shapes[i])
                                    }
                                    else if (i < shapeLocation){
                                        all.push(shapes[i])
                                    }
                                }

                                //shapeCurrent = shapes[shapeLocation]

                                shapes = all
                            }
                        }

                        //means no tool was selected
                        else{
                            errorMsg.text = "Please select a tool"
                            errorPopUp.open()
                        }
                    }

                    
                }

                
                onPositionChanged: {
                    //add new vertices in path of mouse
                    if (currentTool == "lassotool"){
                        if(comboyuh.currentText != undefined){
                            tf.drawShape(g, mouseX, mouseY)
                        }
                    }

                    //move shape in path of mouse
                    else if (currentTool == "movetool"){
                        //variable to say one of the points hit the boundary box
                        var nuhuh = false

                        //make sure a shape has been selected
                        if(shapeCurrent != undefined){

                            //loop through to see if any point hits the boundary
                            for(var i = 0; i < shapeCurrent.child.pathElements.length; i++){
                                if(!checkBoundary(undefined, mouseX + shapeCurrent.child.pathElements[i].x, 
                                    mouseY + shapeCurrent.child.pathElements[i].y, dx, dy)){
                                    
                                    nuhuh = true
                                }
                    
                            }

                            //if no point hits a boundary, move it based on the change of mouse movement
                            if(nuhuh == false){
                                for(var i = 0; i < shapeCurrent.child.pathElements.length; i++){
                                    shapeCurrent.child.pathElements[i].x += (mouseX - dx)
                                    shapeCurrent.child.pathElements[i].y += (mouseY - dy)
                        
                                }
                                shapeCurrent.child.startX += (mouseX - dx)
                                shapeCurrent.child.startY += (mouseY - dy)
                            }

                            //will be used to find difference of mouse movement
                            dx = mouseX
                            dy = mouseY
                        }
                    }

                    //draw shape in path of mouse
                    else if (currentTool == "paintbrush"){
                        if(g != undefined){
                            if(comboyuh.currentText != undefined) {
                                if(checkBoundary(undefined, mouseX, mouseY, 0, 0) && 
                                ((mouseX - dx > 10 || mouseX - dx < -10) || (mouseY - dy > 10 || mouseY - dy < -10))){
                                    tf.drawShape(g, mouseX, mouseY)
                                    dx = mouseX
                                    dy = mouseY
                                }
                            }
                        }
                    }

                    //move vertices in square in direction of mouse
                    else if(currentTool == "squareselect"){
                        //move pathlines based on circle movement
                        if(controlNum != undefined){
                            if(controlNum == shapeCurrent.controls[0]){

                                if(checkBoundary(controlNum, mouseX, mouseY, dx, dy)){
                                    console.log(getMouseX())
                                    //mouseX-dx because we want the the difference between the current mouse and the last mouse to move the shape
                                    controlNum.papa.y = controlNum.papa.y + (mouseY - dy)
                                    controlNum.papa.x = controlNum.papa.x + (mouseX - dx)

                                    shapeCurrent.child.startY = shapeCurrent.child.startY + (mouseY - dy)
                                    shapeCurrent.child.startX = shapeCurrent.child.startX + (mouseX - dx)
                                }
                            }
                            else{
                                if(checkBoundary(controlNum, mouseX, mouseY, dx, dy)){
                                    controlNum.papa.y = controlNum.papa.y + (mouseY - dy)
                                    controlNum.papa.x = controlNum.papa.x + (mouseX - dx)
                                }
                            }
                        }

                        dx = mouseX
                        dy = mouseY
                        
                    }


                     else if(currentTool == "circleselect"){
                        //move pathlines based on circle movement
                        if(controlNum != undefined){
                            if(controlNum == shapeCurrent.controls[0]){
                                
                                //mouseX-dx because we want the the difference between the current mouse and the last mouse to move the shape
                                controlNum.papa.y = controlNum.papa.y + (mouseY - dy)
                                controlNum.papa.x = controlNum.papa.x + (mouseX - dx)

                                shapeCurrent.child.startY = shapeCurrent.child.startY + (mouseY - dy)
                                shapeCurrent.child.startX = shapeCurrent.child.startX + (mouseX - dx)
                            }
                            else{
                                controlNum.papa.y = controlNum.papa.y + (mouseY - dy)
                                controlNum.papa.x = controlNum.papa.x + (mouseX - dx)
                            }
                        }

                        dx = mouseX
                        dy = mouseY
                        
                    }



                    //move the selected vertice if there is one
                    else if(currentTool == "vertextool"){
                        //move pathlines based on circle movement
                        if(currentVertex != undefined){
                            if(checkBoundary(currentVertex, mouseX, mouseY, dx, dy)){
                                //for the last vertice, move the startx and starty, but not for paintbrush
                                if(currentVertex == shapeCurrent.controls[shapeCurrent.controls.length-1] && currentVertex.papa.x == shapeCurrent.child.startX && currentVertex.papa.y == shapeCurrent.child.startY){
                                    
                                    //mouseX-dx because we want the the difference between the current mouse and the last mouse to move the shape
                                    currentVertex.papa.y = currentVertex.papa.y + (mouseY - dy)
                                    currentVertex.papa.x = currentVertex.papa.x + (mouseX - dx)

                                    shapeCurrent.child.startY = shapeCurrent.child.startY + (mouseY - dy)
                                    shapeCurrent.child.startX = shapeCurrent.child.startX + (mouseX - dx)

                                    currentVertex.x = currentVertex.x + (mouseX - dx)
                                    currentVertex.y = currentVertex.y + (mouseY - dy)
                                }
                                //for paintbrush, move first startX and starty for first vertex
                                else if (currentVertex == shapeCurrent.controls[0] && shapeCurrent.controls[shapeCurrent.controls.length-1].x != shapeCurrent.child.startX && shapeCurrent.controls[shapeCurrent.controls.length-1].y != shapeCurrent.child.startY){
                                    //mouseX-dx because we want the the difference between the current mouse and the last mouse to move the shape
                                    shapeCurrent.child.startY = shapeCurrent.child.startY + (mouseY - dy)
                                    shapeCurrent.child.startX = shapeCurrent.child.startX + (mouseX - dx)

                                    currentVertex.x = currentVertex.x + (mouseX - dx)
                                    currentVertex.y = currentVertex.y + (mouseY - dy)
                                }
                                else{
                                    currentVertex.papa.y = currentVertex.papa.y + (mouseY - dy)
                                    currentVertex.papa.x = currentVertex.papa.x + (mouseX - dx)

                                    currentVertex.x = currentVertex.x + (mouseX - dx)
                                    currentVertex.y = currentVertex.y + (mouseY - dy)
                                }
                            }
                        }

                        dx = mouseX
                        dy = mouseY
                    }


                }


                //mouse released actions
                onReleased: {
                    //lasso tool
                    if (currentTool == "lassotool"){
                        if(comboyuh.currentText != undefined){
                            tf.endShape(g, labelAndColor[g.label])
                            tf.simplify(g,imageMouse.value,tbox)
                        }


                        else{
                            console.log("select a label")
                        }
                        refreshLegend()
                        populateLegend()

                        saveIconButton.enabled = true
                        saveRasterIconButton.enabled = true

                        var currAction = Qt.createQmlObject("import Actions; CreateAction{}", this)
                        
                        currAction.shapeParent = overlay
                        currAction.target = g

                        act.actionDone(currAction, false)

                    }

                    //move tool
                    else if (currentTool == "movetool"){
                        if(shapeCurrent != undefined){
                            dx = mouseX - ogx
                            dy = mouseY - ogy
                            
                            saveIconButton.enabled = true
                            saveRasterIconButton.enabled = true

                            var currAction = Qt.createQmlObject("import Actions; MoveAction{}", this)
                            currAction.dX = dx
                            currAction.dY = dy

                            currAction.shapeParent = overlay
                            currAction.target = shapeCurrent


                            act.actionDone(currAction, false)
                        }

                        shapeCurrent = undefined
                        
                    }

                    //just not that the save needs to happen now
                    else if (currentTool == "magicwand"){
                        saveIconButton.enabled = true
                        saveRasterIconButton.enabled = true
                    }

                    //tell timer to stop and save needs to happen now
                    else if (currentTool == "paintbrush"){
                        if(g != undefined){
                            tf.endPaint(g, labelAndColor[g.label], tbox)

                            dx = 0
                            dy = 0

                            saveIconButton.enabled = true
                            saveRasterIconButton.enabled = true
                            refreshLegend()
                            populateLegend()

                            var currAction = Qt.createQmlObject("import Actions; CreateAction{}", this)
                            
                            currAction.shapeParent = overlay
                            currAction.target = g

                            act.actionDone(currAction, false)
                        }
                    }

                    //get last coordinate to make circle, save needs to happen now
                    else if (currentTool == "circleselect"){
                        fixMouse(image)

                        saveIconButton.enabled = true
                        saveRasterIconButton.enabled = true
                    }

                    //get last coordinate to make square, save needs to happen now
                    else if (currentTool == "squareselect"){
                        fixMouse(image)

                        saveIconButton.enabled = true
                        saveRasterIconButton.enabled = true
                    }

                    else if (currentTool == "vertextool"){
                        saveIconButton.enabled = true
                        saveRasterIconButton.enabled = true
                    }

                    else if (currentTool == "deletetool"){
                        saveIconButton.enabled = true
                        saveRasterIconButton.enabled = true
                    }


                    if (currentTool != "vertextool" && currentTool != ""){
                        redoAction.enabled = act.actToRedo()
                        undoAction.enabled = true
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
        onTriggered: tbox.paintBrush(imageMouse.mouseX * overlay.mouseFactorX, imageMouse.mouseY * overlay.mouseFactorY, imageMouse.value)//, refreshMask()
    }


    /////////////////////////////////////////////////////////labels//////////////////////////////////////////////////////////////

    //Labels select box
    ComboBox{
            id: comboyuh

            anchors.left: image.right


            //create an editable model to work with new labels added
            property var thisModel: labelToSpecies(labelNames)

            model: thisModel

            

            // When a label is chosen, change the shapes for that label.
            onActivated: {
                //if the shape is in the text box, highlight it yellow, if not, get rid of highlight
                for (var i = 0; i < shapes.length; i++){
                    if (shapes[i].label == findLabel(currentText)){
                        //console.log(shapes[i].colorline)
                        shapes[i].colorline = "yellow"
                    }

                    else {
                        //console.log(shapes[i].label)
                        //console.log(labelAndColor[shapes[i].label])
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
            var idxBox = 0
            var idxSpec = 0

            //find if species already has text
            for (var i = 0; i < species.length; i++){
                if(species[i][1] == curText){
                    alreadyInList = false
                    //check if the species is already in our combobox
                    for(var g = 0; g < imageSpecies.length; g++){
                        if(imageSpecies[g][1] == curText){
                            alreadyInList = true
                        }
                    }
                    aSpecies = true
                    idxSpec = i
                }
            }

            if(aSpecies == true && alreadyInList == false){
                imageSpecies.push(species[idxSpec])
                labelNames.push(species[idxSpec][0])
                comboyuh.thisModel.push(species[idxSpec][1])
                comboyuh.model = comboyuh.thisModel


                var color = Qt.rgba(Math.random(),Math.random(),Math.random(),1);
                labelAndColor[species[idxSpec][0]] = color;
            }

            //if it is a new label
            else if(aSpecies == false && alreadyInList == false){
                //add to combobox and species list and all other variables
                species.push(lf.addToSpeciesList(species[species.length-1][0], curText))
                imageSpecies.push(species[species.length-1])
                labelNames.push(species[species.length-1][0])
                comboyuh.thisModel.push(species[species.length-1][1])
                comboyuh.model = comboyuh.thisModel


                var color = Qt.rgba(Math.random(),Math.random(),Math.random(),1);
                labelAndColor[species[species.length-1][0]] = color;
            }

            //remove the text from box
            remove(0, text.length)

            //make current selection the entered text
            idxBox = comboyuh.find(curText)
            comboyuh.currentIndex = idxBox

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

                        if(imageMouse.shapeCurrent != undefined){
                            noMoreVertices()
                        }

                        valueSlider.visible = true

                        sliderTitle.text = "Threshold"
                        sliderTitle.visible = true

                        allToolsOn()
                        magicWandIcon.enabled = false

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

                        if(imageMouse.shapeCurrent != undefined){
                            noMoreVertices()
                        }

                        valueSlider.visible = true

                        sliderTitle.text = "Size"
                        sliderTitle.visible = true

                        allToolsOn()
                        paintbrushIcon.enabled = false

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

                        if(imageMouse.shapeCurrent != undefined){
                            noMoreVertices()
                        }

                        valueSlider.visible = false
                        sliderTitle.visible = false

                        allToolsOn()
                        circleSelectIcon.enabled = false

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
                        if(imageMouse.shapeCurrent != undefined){
                            noMoreVertices()
                        }
                        valueSlider.visible = false
                        sliderTitle.visible = false

                        allToolsOn()
                        squareSelectIcon.enabled = false

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
                        if(imageMouse.shapeCurrent != undefined){
                            noMoreVertices()
                        }
                        valueSlider.visible = false
                        sliderTitle.visible = false

                        allToolsOn()
                        moveSelectIcon.enabled = false

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
                        if(imageMouse.shapeCurrent != undefined){
                            noMoreVertices()
                        }
                        valueSlider.visible = true
                        valueSlider.from = 7
                        valueSlider.to = 0
                        valueSlider.value = 1
                        sliderTitle.visible = true
                        sliderTitle.text = "Quality"
                        
                        allToolsOn()
                        lassoSelectIcon.enabled = false

                        currentTool = "lassotool"
                    }

                }

            }

            //icon author
            //"https://iconscout.com/icons/selection" class="text-underline font-size-sm" target="_blank">Selection</a> by <a href="https://iconscout.com/contributors/petras-nargela" class="text-underline font-size-sm" target="_blank">Petras Nargėla</a>
            Button {
                id: vertexSelectIcon
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50
                icon.source: "icons/selection.png"
                enabled: true

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if(imageMouse.shapeCurrent != undefined){
                            noMoreVertices()
                        }
                        valueSlider.visible = false
                        sliderTitle.visible = false

                        allToolsOn()
                        vertexSelectIcon.enabled = false

                        currentTool = "vertextool"
                    }

                }

            }

            Button {
                id: deleteIcon
                Layout.preferredWidth: 50
                Layout.preferredHeight: 50
                icon.source: "icons/lasso.png"
                enabled: true

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if(imageMouse.shapeCurrent != undefined){
                            noMoreVertices()
                        }
                        valueSlider.visible = false
                        sliderTitle.visible = false

                        allToolsOn()
                        deleteIcon.enabled = false

                        currentTool = "deletetool"
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
                            
                            //tbox.initLabels(folderModel.folder + "/" + fileName), refreshMask()
                                
                            changeImage(folderModel.folder + "/" + fileName)

                            if(lf.hasLabels(fileName)){
                                lf.resetLabels()
                                lf.resetShapes()
                                imageSpecies = []
                                    
                                lf.loadLabels(lf.split(image.source))

                                lf.loadShapes()
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
                                refreshLegend()
                                populateLegend()
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
            saveIconButton.enabled = false
                        
            lf.updateLabelsAndCoords()
            tbox.saveLabels(labelsAndCoords, lf.split(image.source))
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





    /////////////////////////////////////////////////////////statistics pop up////////////////////////////////////////////////////////

      Popup {
        id: statsPopUp
        x: (parent.width - width) / 2  
        y: (parent.height - height) / 2 
        width: 200
        height: 150
        modal: true
        focus: true

         Rectangle {
            color: "white"
            anchors.fill: parent

            Column {
                spacing: 10
                anchors.centerIn: parent

                TextField {
                    id: imgWS
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "black"
                    placeholderText: "Width Scale (cm)"
                    placeholderTextColor: "lightgrey"
                }

                TextField {
                    id: imgHS
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "black"
                    placeholderText: "Height Scale (cm)"
                    placeholderTextColor: "lightgrey"
                }

                Button {
                    text: "Enter"
                    palette.buttonText: "black"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        tbox.saveStats(labelsAndCoords, species, imageMouse.getMouseX(), imageMouse.getMouseY(), overlay.mouseFactorX, overlay.mouseFactorY, image.sourceSize.width, image.sourceSize.height, lf.split(image.source), imgWS.text, imgHS.text)
                        statsPopUp.close()
                    }
                }
            }
         }
    }


    Popup {
        id: errorPopUp
        x: (parent.width - width) / 2  
        y: (parent.height - height) / 2 
        width: 200
        height: 150
        modal: true
        focus: true

         Rectangle {
            color: "white"
            anchors.fill: parent

            Column {
                spacing: 10
                anchors.centerIn: parent

                Text {
                    id: errorMsg
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "black"
                    text: ""
                }

                Button {
                    text: "OK"
                    palette.buttonText: "black"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        errorPopUp.close()
                    }
                }
            }
         }
    }
    AboutPopup {
        id: aboutPopUp
    }
    SaveLocationsPopup {
        id: saveLocationsPopup
        //the_tbox: tbox
    }
    ////Check if file preferences exist. If not, ask user
    Component.onCompleted: {
        if (tbox.fileExists(tbox.getFileLocation()+"/file_config")) {
            tbox.loadFilePreference()
            saveLocationsPopup.updateText()
        } else {
            //init with default values
            tbox.setFilePreference(StandardPaths.writableLocation(StandardPaths.AppDataLocation), StandardPaths.writableLocation(StandardPaths.DocumentsLocation) + "/CoralLabeler")
            saveLocationsPopup.updateText()
            //show popup
            saveLocationsPopup.open()
            //this will save the accepted value to file
        }
    }
}
