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

    function createLassoComponent(){
        //create a QML component from shapes.qml
        const component = Qt.createComponent("lassoShapes.qml");

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
        sp.startX = points[0][0]
        sp.startY = points[0][1]
        for (var i=1; i<points.length; i++) {
            var pl = Qt.createQmlObject('import QtQuick; import QtQuick.Shapes; PathLine{}', sp)
            pl.x = points[i][0]
            pl.y = points[i][1]
            sp.pathElements.push(pl)
        }
        var pl = Qt.createQmlObject('import QtQuick; import QtQuick.Shapes; PathLine{}', sp)
        pl.x = points[0][0]
        pl.y = points[0][1]
        sp.pathElements.push(pl)
    }
}
