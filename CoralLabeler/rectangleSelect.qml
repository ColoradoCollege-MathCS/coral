import QtCore
import QtQuick 
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts 
import Qt.labs.folderlistmodel
import QtQuick.Shapes



// rectangle select ------------------------------------- 
Item{ 
        id: mainRect

        visible: true

         
            width: 100
            height: 100

            x: parent.width/2 - (width/2)
            y: parent.height/2 - (height/2)
    
    Shape{
                
            ShapePath{
                startX: mainRect.width / 2
                startY: 0

                PathLine{ x: mainRect.width; y: 0}
                PathLine{ x: mainRect.width; y: mainRect.height }
                PathLine{ x: 0; y: mainRect.height }
                PathLine{ x: 0; y: 0}

        }
    }

        Drag.active: mouseArea.drag.active

        MouseArea
        {
            id: mouseArea

            anchors.fill: parent
            drag.target: mainRect
        }

    

Rectangle {

    id: circleleft
    color: "black"
    radius: 20
    width: radius
    height: radius
    visible: true

        anchors {
            horizontalCenter: mainRect.left
            verticalCenter: mainRect.verticalCenter
        }
        MouseArea {

            anchors.fill: parent

            onMouseXChanged: {
                mainRect.x = mainRect.x + mouseX
                mainRect.width = mainRect.width - mouseX
                if(mainRect.width < 5)
                {
                    mainRect.width = 5
                }
            }
        }
    }


Rectangle {

    id:circleright
    color: "black"
    radius: 20
    width: radius
    height: radius
    visible: true



        anchors {
            horizontalCenter: mainRect.right
            verticalCenter: mainRect.verticalCenter
        }

        MouseArea {
            anchors.fill: parent
            onMouseXChanged: {
                mainRect.width = mainRect.width + mouseX
                if(mainRect.width < 5)
                {
                    mainRect.width = 5
                }
            }
        }
    }


  Rectangle {
    id:circletop
    color: "black"
    radius: 20
    width: radius
    height: radius
    visible: true

        anchors {
            horizontalCenter: mainRect.horizontalCenter
            verticalCenter: mainRect.top
        }

        MouseArea {
            anchors.fill: parent
            onMouseYChanged: {
                mainRect.y = mainRect.y + mouseY
                mainRect.height = mainRect.height - mouseY
                if(mainRect.height < 5)
                {
                    mainRect.height = 5
                }
            }
        }
    }

   Rectangle {

    id:circlebottom
    color: "black"
    radius: 20
    width: radius
    height: radius
    visible: true

        anchors
        {

            horizontalCenter: mainRect.horizontalCenter
            verticalCenter: mainRect.bottom
        }

        MouseArea {
            anchors.fill: parent
            onMouseYChanged: {
                mainRect.height = mainRect.height + mouseY
                if(mainRect.height < 5)
                {
                    mainRect.height = 5
                }
            }
        }



    }
}



//--------------------------------------------------------
