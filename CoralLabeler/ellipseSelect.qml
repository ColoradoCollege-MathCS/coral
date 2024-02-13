import QtCore
import QtQuick 
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts 
import Qt.labs.folderlistmodel
import QtQuick.Shapes



// ellipse select-----------------------------------------

Item {

    id: mainEllipse

        width: 100
        height: 100

        visible: true

        x: parent.width/2 - (width/2)
        y: parent.height/2 - (height/2)

        property var label: ""

        property var coords: []
        property var color: ""
        property var colorline: ""

        property var child: thePath


        Shape{
            containsMode: Shape.FillContains

            ShapePath{

                id:thePath

                strokeColor: mainEllipse.colorline
                strokeWidth: 1
                fillColor: mainEllipse.color

                startX: mainEllipse.width / 2
                startY: 0

                PathAngleArc{ 

                        centerX: mainEllipse.width/2
                        centerY: mainEllipse.height/2
                        radiusX: mainEllipse.width/2
                        radiusY: mainEllipse.height/2


                        sweepAngle: 360



            }
        }

    }    

    Drag.active: mouseArea2.drag.active

    MouseArea{
        id: mouseArea2

        anchors.fill: parent
        drag.target: mainEllipse
    }


    Rectangle {

        id: circleleft2
        color: "black"
        radius: 20
        width: radius
        height: radius

        visible: true

        anchors {
            horizontalCenter: mainEllipse.left
            verticalCenter: mainEllipse.verticalCenter
        }
        MouseArea {

            anchors.fill: parent

            onMouseXChanged: {
                mainEllipse.x = mainEllipse.x + mouseX
                mainEllipse.width = mainEllipse.width - mouseX
                if(mainEllipse.width < 5)
                {
                    mainEllipse.width = 5
                }
            }
        }
    }


    Rectangle {

        id:circleright2
        color: "black"
        radius: 20
        width: radius
        height: radius

        visible: true

        anchors {
            horizontalCenter: mainEllipse.right
            verticalCenter: mainEllipse.verticalCenter
        }

        MouseArea {
            anchors.fill: parent
            onMouseXChanged: {
                mainEllipse.width = mainEllipse.width + mouseX
                if(mainEllipse.width < 5)
                {
                    mainEllipse.width = 5
                }
            }
        }
    }


    Rectangle {
        id:circletop2
        color: "black"
        radius: 20
        width: radius
        height: radius

        visible: true

        anchors {
            horizontalCenter: mainEllipse.horizontalCenter
            verticalCenter: mainEllipse.top
        }

        MouseArea {
            anchors.fill: parent
            onMouseYChanged: {
                mainEllipse.y = mainEllipse.y + mouseY
                mainEllipse.height = mainEllipse.height - mouseY
                if(mainEllipse.height < 5)
                {
                    mainEllipse.height = 5
                }
            }
        }
    }

    Rectangle {

        id:circlebottom2
        color: "black"
        radius: 20
        width: radius
        height: radius

        visible: true

        anchors
        {

            horizontalCenter: mainEllipse.horizontalCenter
            verticalCenter: mainEllipse.bottom
        }

        MouseArea {
            anchors.fill: parent
            onMouseYChanged: {
                mainEllipse.height = mainEllipse.height + mouseY
                if(mainEllipse.height < 5)
                {
                    mainEllipse.height = 5
                }
            }
        }
    }

}