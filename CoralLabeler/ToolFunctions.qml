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

    function drawShape(yuh, x, y){
        var path = Qt.createQmlObject('import QtQuick; PathLine {}', yuh.child);

        path.x = x;
        path.y = y;
        yuh.child.pathElements.push(path);
    }

    function endShape(yuh, color){
        var path = Qt.createQmlObject('import QtQuick; PathLine{}', yuh.child);
            
        path.x = yuh.child.startX;
        path.y = yuh.child.startY;
        yuh.child.pathElements.push(path);
        yuh.child.fillColor = color;
        yuh.child.strokeColor = color;
    }

    function endPaint(yuh, color){
        yuh.child.strokeColor = color;

    }

    function createLassoComponent(){
        //create a QML component from shapes.qml
        const component = Qt.createComponent("lassoShapes.qml");

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

    //make vertices for vertex tool
    function makeVertices(shape){
        var vertices = []

        const component = Qt.createComponent("vertex.qml");

        //check if theres a paint element to put vertice at the start
        if(shape.shapeType == "paint"){
            vertices.push(component.createObject(shape, {"x": shape.child.startX - 10, "y": shape.child.startY - 10, "papa": shape.child.pathElements[0]}))
        }

        for(var i = 0; i < shape.child.pathElements.length; i++){
            var pathy = shape.child.pathElements[i]

            vertices.push(component.createObject(shape, {"x": pathy.x - 10, "y": pathy.y - 10, "papa": pathy}))
        }


        shape.controls = vertices
    }

    function removeVertices(shape){
        if(shape != undefined){
            for(var t = 0; t < shape.controls.length; t++){
                shape.controls[t].destroy()
            }

            shape.controls = []
            shape = undefined
        }
    }

    function simplify(curShape,epsilon, toolbox) {
        var points = []
        var sp = curShape.data[0]
        points.push([sp.startX, sp.startY])
        var listLen = sp.pathElements.length
        for (var i = 0; i< listLen; i++) {
            var pathEle = sp.pathElements.pop()
            points.push([pathEle.x,pathEle.y])
        }
        //console.log("Before: "+points.length+" points")
        points = toolbox.simplifyLasso(points, epsilon)
        //console.log("After: "+points.length+" points with eps: "+epsilon)
        console.log
        sp.startX = points[points.length-1][0]
        sp.startY = points[points.length-1][1]
        for (var i = points.length-2; i >= 0; i--) {
            var pl = Qt.createQmlObject('import QtQuick; import QtQuick.Shapes; PathLine{}', sp)
            pl.x = points[i][0]
            pl.y = points[i][1]
            sp.pathElements.push(pl)
        }
        if (curShape.shapeType != "paint") {
            //console.log("yuh")
            var pl = Qt.createQmlObject('import QtQuick; import QtQuick.Shapes; PathLine{}', sp)
            pl.x = points[points.length-1][0]
            pl.y = points[points.length-1][1]
            sp.pathElements.push(pl)
        }
        else{
            sp.pathElements.pop()
        }

    }
}
