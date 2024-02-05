import QtCore
import QtQuick 
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts 
import QtQuick.Shapes 1.6
import Qt.labs.folderlistmodel

//create a shape
Shape{
    id: theShape
    anchors.fill: parent

    property var coords: []

    //create its path
    ShapePath{
        strokeColor: "black"
        strokeWidth: 18
        fillColor: "blue"
        capStyle: ShapePath.RoundCap


        startX: theShape.coords[0][0]
        startY: theShape.coords[0][1]

        //when this class is completed, create its path based on the coordinates
        Component.onCompleted:{

            //loop through all coordinates and create a new PathLine per coordinate
            //https://stackoverflow.com/questions/55299987/qml-append-new-pathcurve-elements-to-listpathelements-in-shapepath
            for(var i = 1; i < theShape.coords.length; i++){
                var path = Qt.createQmlObject('import QtQuick; PathLine {}', this);

                path.x = theShape.coords[i][0]
                path.y = theShape.coords[i][1]

            
                this.pathElements.push(path)
            }
        }
            
    }
    
    
}