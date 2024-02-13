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
        yuh.child.fillColor = color
        yuh.child.strokeColor = color
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

    function makeVertices(shape){
        var vertices = []

        const component = Qt.createComponent("vertex.qml");

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
}
