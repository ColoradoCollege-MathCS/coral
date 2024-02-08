import QtQuick
import QtQuick.Shapes
import Actions

QtObject {
    function parseActionDo(curAction) {
        switch (curAction.typeString) {
            case "CreateAction"://insert into parent data at end
                curAction.shapeParent.data.push(curAction.target);
                break;
            case "DeleteAction":
                //remove elements until I have removed the right element.
                var removedElement = curAction.shapeParent.data.pop();
                var toPutBack = [];
                var idx = 0;
                while (removedElement !== curAction.target) {
                    toPutBack.push(removedElement);
                    removedElement = curAction.shapeParent.data.pop();
                    idx++;
                }
                curAction.idxInParent = idx
                //sucessfully removed, time 2 put the others back
                for (removedElement of toPutBack) {
                    curAction.shapeParent.data.push(removedElement)
                }
                break;
            case "MoveAction":
                break;
            case "ScaleAction":
                break;
            
        }
        
    }

    function parseActionUndo(curAction) {
        switch (curAction.typeString) {
            case "CreateAction"://undo a create = remove
                //can we assume it will always be at the end and not save idx?
                curAction.shapeParent.data.pop()
                break;
            case "DeleteAction": //here we are undoing a delete, so putting it back
                //temporarily remove all elements in front of it
                var removedElement;
                var toPutBack = [];
                for (var i = 0; i<curAction.idxInParent; i++) {
                    toPutBack.push(curAction.shapeParent.data.pop());
                }
                //insert target
                curAction.shapeParent.data.push(curAction.target);
                //put things back
                for (var i = 0; i<curAction.idxInParent; i++) {
                    curAction.shapeParent.data.push(toPutBack.pop())
                }
                break;
            case "MoveAction":
                break;
            case "ScaleAction":
                break;
            
        }
    }
}