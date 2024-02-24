import QtCore
import QtQuick 
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts 
import QtQuick.Shapes
import Qt.labs.folderlistmodel

Rectangle{
    width: 0
    height: 0
    visible: false


    property var win: null
    property var shapesInOrder: []

    function resetLabels(){
        win.labelsAndCoords = {}
        win.labelNames = []
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
        var labelAndS = {};
        var coordinates = new Array(0);

        var hold = ""
        var shape = 0

        var preShapeName = ""


        //loop through the whole array per line
        for (var i = 0; i < everything.length; i++){

            //if we have a label line, make a new label
            if (everything[i][0] == "Label"){
                if (coordinates.length == 0){
                    labelNames1.push(everything[i][1]);
                    hold = everything[i][1];
                }
                else{
                    shapeAndCoordinates[preShapeName] = coordinates;

                    getOrderLocation(preShapeName, [hold, coordinates])

                    labelsAndCoordinates[hold] = shapeAndCoordinates;

                    labelAndS[hold] = shape

                    shape = 0
                    shapeAndCoordinates = {};
                    coordinates = new Array(0);

                    labelNames1.push(everything[i][1]);
                    hold = everything[i][1];
                }
                labelAndCol[everything[i][1]] = ""
                
            }

            //if we have a shape line, make a new shape for the label
            else if (everything[i][0] == "Shape"){
                if (coordinates.length == 0){
                    shape += 1;

                    preShapeName = everything[i][1]
                }
                else{
                    shapeAndCoordinates[preShapeName] = coordinates;
                    getOrderLocation(preShapeName, [hold, coordinates])

                    preShapeName = everything[i][1]
                    
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
        shapeAndCoordinates[preShapeName] = coordinates;
        getOrderLocation(preShapeName, [hold, coordinates])
        labelsAndCoordinates[hold] = shapeAndCoordinates;
        labelAndS[hold] = shape

        //make them global variables
        win.labelsAndCoords = labelsAndCoordinates
        win.labelNames = labelNames1
        win.labelAndColor = labelAndCol
        win.labelAndSize = labelAndS
    }

    function getOrderLocation(number, shape){
        var start = []
        var end = []
        var all = []
        var yuh = false

        for(var i = 0; i < shapesInOrder.length; i++){
            if(shapesInOrder[i][0] > number){
                end.push(shapesInOrder[i])
            }
            else{
                start.push(shapesInOrder[i])
            }
        }

        for(var i = 0; i < start.length; i++){
            all.push(start[i])
        }

        all.push([number, shape])
    

        for(var i = 0; i < end.length; i++){
            all.push(end[i])
        }

        shapesInOrder = all
    }


    //function to check if current image has a label file
    function hasLabels(imgsource){
        //console.log(tbox.fileExists("labels/" + imgsource + ".csv"))
        return tbox.fileExists("labels/" + imgsource + ".csv")
    }

    //a function to loop through the current label's shapes and create shapes from coordinates
    function loopy(comp, label, shapeNum){
        if(win.labelAndColor[label] != ""){
            win.shapes.push(comp.createObject(overlay, {"coords": win.labelsAndCoords[label][shapeNum], "label": label, 
            "color": win.labelAndColor[label], "colorline": win.labelAndColor[label]}));
        }
        else{
            var color = Qt.rgba(Math.random(),Math.random(),Math.random(),1);
            win.labelAndColor[label] = color
            win.shapes.push(comp.createObject(overlay, {"coords": win.labelsAndCoords[label][shapeNum], "label": label, 
            "color": color, "colorline": color}));
        }
    }

    //a function to display shapes
    function loadShapes(){
        //create a QML component from shapes.qml
        const component = Qt.createComponent("shapes.qml");

        //make sure component works properly
        if (component.status === Component.Ready) {
            //make shapes
            print(shapesInOrder)
            for(var i = 0; i < shapesInOrder.length; i++){
                loopy(component, shapesInOrder[i][1][0], shapesInOrder[i][0])
            }
        }
        else if (component.status === Component.Error){
            console.log(component.errorString())
        }
    }

    //a function to destroy all shapes
    function resetShapes(){
        for(var i = 0; i < win.shapes.length; i++){
            win.shapes[i].destroy()
        }
        win.shapes = []
        shapesInOrder = []
    }


    //function to update labels and coords to save
    function updateLabelsAndCoords(shapes){
        win.labelsAndCoords = {}
        var holdDict = {};
        var hold = [];

        var count = 0

        //dictionary stuff
        for(var f = 0; f < win.labelNames.length; f++){
            for(var i = 0; i < win.shapes.length; i++){
                //get label
                if(win.shapes[i].label == win.labelNames[f]){
                    //for each shape, find its label, add coordinates to hold
                    for(var g = 0; g < win.shapes[i].child.pathElements.length; g++){
                        hold.push([win.shapes[i].child.pathElements[g].x, win.shapes[i].child.pathElements[g].y])
                    }


                    holdDict[i] = hold;

                    hold = []

                }
            }
            
            //place all shapes in label dict
            win.labelsAndCoords[win.labelNames[f]] = holdDict
            holdDict = {};
        }
    }

    //add new label
    function addToSpeciesList(labelNumber, name){
        return tbox.addToCSV(labelNumber, name, "SpeciesList.csv")
    }

}
