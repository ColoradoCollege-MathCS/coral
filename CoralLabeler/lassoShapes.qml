import QtCore
import QtQuick 
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts 
import QtQuick.Shapes
import Qt.labs.folderlistmodel

import Actions

Shape {
	id: labelshape
	anchors.fill: parent
	containsMode: Shape.FillContains

    property var label: ""

    property var coords: []
    property var color: ""
    property var colorline: "black"

	property list<ShapePath> all_paths: []

    property var shapeType: "lasso"

	property var child: thePath

    property var controls: []

	//create its path
    ShapePath{
        id: thePath
        strokeColor: labelshape.colorline
        strokeWidth: 1
        fillColor: "blue"

            
    }
}