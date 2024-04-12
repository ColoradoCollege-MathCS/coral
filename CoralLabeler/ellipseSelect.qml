import QtCore
import QtQuick 
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts 
import Qt.labs.folderlistmodel
import QtQuick.Shapes


Shape {
    id: mainEllipse
    containsMode: Shape.FillContains
    visible: true

    property var label: ""
    property var coords: []
    property var color: ""
    property var colorline: ""
    property var shapeType: "ellipse"
    property var child: thePath

    property var dx: 0
    property var dy: 0

    property var mX: 0
    property var mY: 0

    property var halfy: ((p3.y + p4.y + p2.y) - (p7.y + p6.y + p8.y))/2 + (p7.y + p6.y + p8.y)
    property var halfx: ((p1.x + p8.x + p2.x) - (p5.x + p6.x + p4.x))/2 + (p5.x + p6.x + p4.x)



    property var controls: [circleleft, circletop, circleright, circlebottom,
     circletopright, circletopleft, circlebottomleft,circlebottomright]

    ShapePath {
        id: thePath
        strokeColor: mainEllipse.colorline
        strokeWidth: 1
        fillColor: mainEllipse.color

        startX: mX
        startY: mY


        //pathline creating the sideof our ellipse. Each pathline has the coordinates of where it will appear on the screen 
        //when the user clicks on it

        PathLine {id:p1 ; x: mX ; y: mY }
        PathLine {id:p2; x: mX + 25; y: mY + 30 }
        
        PathLine {id:p3 ; x: mX + 50; y: mY + 50 }
        PathLine {id:p4 ; x: mX + 75; y: mY + 30 }

        PathLine {id:p5 ; x: mX + 100; y: mY }
        PathLine {id:p6 ; x: mX + 75; y: mY - 30 }
       
        PathLine {id:p7; x: mX + 50; y: mY - 50}
        PathLine {id:p8; x: mX + 25; y: mY - 30 }


    


    }


    //the circle verticies and their location with regards to the ellipse shape, we have 8 verticies at each edge  

    Rectangle {
        id: circleleft
        color: "black"
        radius: 20
        width: radius
        height: radius
        visible: true
        x: p1.x
        y: p1.y - radius / 2
        property var papa: p1
    }

    Rectangle {
        id: circleright
        color: "black"
        radius: 20
        width: radius
        height: radius
        visible: true

        x: p5.x - radius
        y: p5.y - radius/2
        property var papa: p5
    }


    Rectangle {
        id: circlebottom
        color: "black"
        radius: 20
        width: radius
        height: radius
        visible: true
        x: p7.x - radius/2
        y: p7.y
        property var papa: p7
    }

    Rectangle {
        id: circletop
        color: "black"
        radius: 20
        width: radius
        height: radius
        visible: true
        x: p3.x - radius/2
        y: p3.y - radius
        property var papa: p3
    }


 Rectangle {
        id: circletopright
        color: "black"
        radius: 20
        width: radius
        height: radius
        visible: true
        x: p6.x - radius/3
        y: p6.y - radius/3
        property var papa: p6
    }



Rectangle {
        id: circletopleft
        color: "black"
        radius: 20
        width: radius
        height: radius
        visible: true
        x: p8.x - radius/3
        y: p8.y - radius/3
        property var papa: p8
    }


    Rectangle {
        id: circlebottomleft
        color: "black"
        radius: 20
        width: radius
        height: radius
        visible: true
        x: p2.x - radius/3
        y: p2.y - radius/3
        property var papa: p2
    }




Rectangle {
        id: circlebottomright
        color: "black"
        radius: 20
        width: radius
        height: radius
        visible: true
        x: p4.x - radius/3
        y: p4.y - radius/3
        property var papa: p4
    }

}

