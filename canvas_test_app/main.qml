import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

import Actions

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: "QML Canvas Test"

	function addNewPolyline(){
		//var newPolyline = PathPolyline([Qt.point(myMouseArea.mouseX,myMouseArea.mouseY)]);
		var newPolyline = Qt.createQmlObject(`
			import QtQuick
			PathPolyline {
				path: [Qt.point(myMouseArea.mouseX,myMouseArea.mouseY)]
			}`,
			myfirstpath
		);

		//myfirstpath.addPathItem(newPolyline);

		return newPolyline;
	}

	function addNewShapePath(x, y) {
		var newShapePath = Qt.createQmlObject(`
			import QtQuick
			import QtQuick.Shapes
			ShapePath {
				strokeWidth: 3
				strokeColor: "darkgray"
				fillColor: "transparent"
			}
		`, labelshape);
		newShapePath.startX = x;
		newShapePath.startY = y;
		labelshape.all_paths.push(newShapePath)
		labelshape.data.push(newShapePath)
	}


    Button {
    id: save_canvas
	width: 100
	height:30
	text: qsTr("Save canvas")
    }

    Rectangle {
	width: 640
	height: 450
	y: 30
    color: "lightblue"
	MouseArea {
		id: myMouseArea
		width: 640
		height: 450
		property list<Action> actionStack: [MoveAction {}, DeleteAction {}, CreateAction {}, ScaleAction {}]
		Shape {
			id: labelshape
			anchors.fill: parent
			property list<ShapePath> all_paths: []

			ShapePath {
				id: myfirstpath
				strokeWidth: 3
				strokeColor: "darkgray"
				fillColor: "blue"
				startX: 100
				startY: 50
				PathLine {
					x: 150
					y:79
				}
				PathLine {
					x:175
					y:180
				}
				PathLine {
					x: 150
					y: 200
				}
				PathLine{
					x: 100
					y: 50
				}
			}
			MouseArea {
				onPressed: console.log("Inside Triangle")
			}
		}
		onPressed: addNewShapePath(mouseX, mouseY)
		onPositionChanged: {
			var path = Qt.createQmlObject('import QtQuick; PathLine{}', labelshape.all_paths.slice(-1)[0]);
			path.x = mouseX;
			path.y = mouseY;
			labelshape.all_paths.slice(-1)[0].pathElements.push(path);
		}
		onReleased: { //close the shape by returning to the beginning
			var path = Qt.createQmlObject('import QtQuick; PathLine{}', labelshape.all_paths.slice(-1)[0]);
			path.x = labelshape.all_paths.slice(-1)[0].startX;
			path.y = labelshape.all_paths.slice(-1)[0].startY;
			labelshape.all_paths.slice(-1)[0].pathElements.push(path);
			labelshape.all_paths.slice(-1)[0].fillColor="blue"
		}


	}

	Image {
		id: bgImage
		source: "DSCN4472.jpg"
		visible: false
	}
	

    }
}

