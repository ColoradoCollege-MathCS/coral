import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

import Actions

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: "QML Canvas Test"

	ActionHandler {
		id: actHandler
	}

	function drawToCanvas(curShape) {
		//Takes in a Shape object containg a ShapePath with startX/Y and multiple PathLine s.
		var ctx = rasterCanvas.getContext("2d")
		var sp = curShape.data[0]; //Assuming Shape contains a ShapePath
		ctx.fillStyle=  Qt.rgba(1,0,0,1)
		ctx.beginPath()
		ctx.moveTo(sp.startX, sp.startY)
		for (var pathEle of sp.pathElements) {
			ctx.lineTo(pathEle.x, pathEle.y)
		}
		ctx.closePath()
		ctx.fill()
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
    	id: do_action
		width: 100
		height:30
		text: qsTr("do action")
		onPressed: {
			var curAction = myMouseArea.todoStack.pop()
			console.log(curAction.typeString)
			if (curAction !== null) {
				actHandler.parseActionDo(curAction)
			}
			myMouseArea.doneStack.push(curAction)
		}
    }
	Button {
		id: undo_action
		width: 100
		height: 30
		x: 110
		text: qsTr("Undo action")
		onPressed: {
			var  curAction = myMouseArea.doneStack.pop()
			if (curAction !== null) {
				actHandler.parseActionUndo(curAction)
			}
			myMouseArea.undoneStack.push(curAction)
		}
	}
	Button {
		id: redo_action
		width: 100
		height: 30
		x: 220
		text: qsTr("Redo action")
		onPressed: {
			var curAction = myMouseArea.undoneStack.pop()
			if (curAction !== null) {
				actHandler.parseActionDo(curAction)
			}
			myMouseArea.doneStack.push(curAction)
		}
	}
	Button {
		id: rasterize
		width: 100
		height: 30
		x: 330
		text: qsTr("rasterize")
		onPressed: {
			drawToCanvas(scaleshape)
			console.log(rasterCanvas.toDataURL())
		}
	}
    Rectangle {
	width: 640
	height: 450
	y: 30
    color: "lightblue"
	Canvas {
	MouseArea {
		id: myMouseArea
		width: 640
		height: 450
		property list<Action> todoStack: [
			DeleteAction { id: delLabelShape; target: labelshape; shapeParent: myMouseArea},
			ScaleAction {id:shd; target: labelshape; shapeParent: myMouseArea; sX:1; sY:2},
			MoveAction {id:ash; target: scaleshape; shapeParent: myMouseArea; dX:100; dY: 50}
			];
		property list<Action> doneStack: []
		property list<Action> undoneStack: []
		Canvas {
			id: rasterCanvas
			anchors.fill: parent
			visible: false
			width: myMouseArea.width
			height: myMouseArea.height
		}

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
		}
		Shape {
			id: shape2
			anchors.fill: parent
			ShapePath{
				strokeWidth: 3
				strokeColor: "darkgray"
				fillColor: "pink"
				startX: 200
				startY: 200
				PathLine {
					x: 300
					y: 250
				}
				PathLine {
					x:300
					y:300
				}
				PathLine {
					x:175
					y:300
				}
				PathLine {
					x:200
					y:200
				}
			}
		}
		Shape {
			id: scaleshape
			anchors.fill: parent
			ShapePath{
				startX: 250
				startY: 250
				strokeWidth: 3
				strokeColor: "darkgray"
				fillColor: "green"
			
				PathLine {
					x: 300
					y: 250
				}
				PathLine {
					x: 300
					y: 300
				}
				PathLine {
					x: 250
					y: 300
				}
				PathLine {
					x: 250
					y: 250
				}
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
	}

	Image {
		id: bgImage
		source: "DSCN4472.jpg"
		visible: false
	}
	

    }
}

