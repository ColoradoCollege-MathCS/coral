import QtCore
import QtQuick 
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts 
import Qt.labs.folderlistmodel
import QtQuick.Shapes



// rectangle select ------------------------------------- 
Shape{
    id: mainRect
    containsMode: Shape.FillContains

    visible: true


    property var label: ""

    property var coords: []
    property var color: ""
    property var colorline: ""

	property var child: thePath

    property var dx: 0
    property var dy: 0

    property var mX: 0
    property var mY: 0

    property var halfy: (bottomRect.y - topRect.y)/2 + topRect.y
    property var halfx: (rightRect.x - leftRect.x)/2 + leftRect.x

    property var controls: [circleleft, circletop, circleright, circlebottom]
    
                
    ShapePath{
        id:thePath

        strokeColor: mainRect.colorline
        strokeWidth: 1
        fillColor: mainRect.color

        startX: mX
        startY: mY

        PathLine{ id: topRect; x: mX + 100; y: mY}
        PathLine{ id: rightRect; x: mX + 100; y: mY + 100}
        PathLine{ id: bottomRect; x: mX; y: mY + 100}
        PathLine{ id: leftRect; x: mX; y: mY}

    }

    Rectangle {

        id: circleleft
        color: "black"
        radius: 20
        width: radius
        height: radius
        visible: true



        x: leftRect.x
        y: leftRect.y

        property var papa: leftRect
        
    }


    Rectangle {
        id:circleright
        color: "black"
        radius: 20
        width: radius
        height: radius
        visible: true

        x: rightRect.x - radius
        y: rightRect.y - radius

        property var papa: rightRect

    }


    

    Rectangle {

        id:circlebottom
        color: "black"
        radius: 20
        width: radius
        height: radius
        visible: true

        x: bottomRect.x
        y: bottomRect.y - radius

        property var papa: bottomRect


    }


    Rectangle {

        id:circletop
        color: "black"
        radius: 20
        width: radius
        height: radius
        visible: true

        x: topRect.x - radius
        y: topRect.y

        property var papa: topRect

    }
}

