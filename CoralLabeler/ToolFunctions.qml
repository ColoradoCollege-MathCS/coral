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

    function endPaint(yuh, color, toolbox){
        var strWidth = 0
        var newShapePath = []
        var up = []
        var down = []

        yuh.data[0].strokeColor = color;
        strWidth = yuh.data[0].strokeWidth

        yuh.data[0].strokeWidth = 1


        var angle = 0
        for(var i = 0; i < yuh.data[0].pathElements.length - 1; i++){
            var tanx = yuh.data[0].pathElements[i + 1].x - yuh.data[0].pathElements[i].x
            var tany = yuh.data[0].pathElements[i + 1].y - yuh.data[0].pathElements[i].y

            angle = Math.atan(tanx/tany)


            var pointup = Qt.createQmlObject('import QtQuick; import QtQuick.Shapes; PathLine{}', yuh.data[0])

            if(tanx >= 0 && tany <= 0){
                pointup.x = yuh.data[0].pathElements[i + 1].x - (strWidth/2) * Math.cos(Math.abs(angle))
                pointup.y = yuh.data[0].pathElements[i + 1].y - (strWidth/2) * Math.sin(Math.abs(angle))
            }
            else if(tanx > 0 && tany > 0){
                pointup.x = yuh.data[0].pathElements[i + 1].x + (strWidth/2) * Math.cos(angle)
                pointup.y = yuh.data[0].pathElements[i + 1].y - (strWidth/2) * Math.sin(angle)
            }
            else if(tanx < 0 && tany < 0){
                pointup.x = yuh.data[0].pathElements[i + 1].x - (strWidth/2) * Math.cos(angle)
                pointup.y = yuh.data[0].pathElements[i + 1].y + (strWidth/2) * Math.sin(angle)
            }
            else{
                pointup.x = yuh.data[0].pathElements[i + 1].x + (strWidth/2) * Math.cos(Math.abs(angle))
                pointup.y = yuh.data[0].pathElements[i + 1].y + (strWidth/2) * Math.sin(Math.abs(angle))
            }

            var pointdown = Qt.createQmlObject('import QtQuick; import QtQuick.Shapes; PathLine{}', yuh.data[0])

            if(tanx >= 0 && tany <= 0){
                pointdown.x = yuh.data[0].pathElements[i + 1].x + ((strWidth/2) * Math.cos(Math.abs(angle)))
                pointdown.y = yuh.data[0].pathElements[i + 1].y + ((strWidth/2) * Math.sin(Math.abs(angle)))
            }
            else if(tanx > 0 && tany > 0){
                pointdown.x = yuh.data[0].pathElements[i + 1].x - ((strWidth/2) * Math.cos(angle))
                pointdown.y = yuh.data[0].pathElements[i + 1].y + ((strWidth/2) * Math.sin(angle))
            }
            else if(tanx < 0 && tany < 0){
                pointdown.x = yuh.data[0].pathElements[i + 1].x + ((strWidth/2) * Math.cos(angle))
                pointdown.y = yuh.data[0].pathElements[i + 1].y - ((strWidth/2) * Math.sin(angle))
            }
            else{
                pointdown.x = yuh.data[0].pathElements[i + 1].x - ((strWidth/2) * Math.cos(Math.abs(angle)))
                pointdown.y = yuh.data[0].pathElements[i + 1].y - ((strWidth/2) * Math.sin(Math.abs(angle)))
            }
            

            up.push(pointup)
            down.push(pointdown)
        }

        up.push(yuh.data[0].pathElements[yuh.data[0].pathElements.length - 1])

        var reversedDown = []
        for(var g = down.length-1; g >= 0; g--){
            reversedDown.push(down[g])
        }
        var finalPoint = Qt.createQmlObject('import QtQuick; import QtQuick.Shapes; PathLine{}', yuh.data[0])
        finalPoint.x = yuh.data[0].startX
        finalPoint.y = yuh.data[0].startY
        reversedDown.push(finalPoint)

        for(var e = 0; e < reversedDown.length; e++){
            up.push(reversedDown[e])
        }

        var num = yuh.data[0].pathElements.length

        for(var f = 0; f <= num; f++){
            yuh.data[0].pathElements.pop()
        }

        for(var t = 0; t < up.length; t++){
            yuh.data[0].pathElements.push(up[t])
        }

        yuh.data[0].fillColor = color

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

        sp.pathElements.pop()
        

    }
}