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
                var idx = curAction.shapeParent.data.indexOf(curAction.target);
                curAction.shapeParent.data.splice(idx,1);
                curAction.idxInParent = idx;
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
                var idx = curAction.shapeParent.data.indexOf(curAction.target);
                curAction.shapeParent.data.splice(idx,1);
                break;
            case "DeleteAction": //here we are undoing a delete, so putting it back
                curAction.shapeParent.data.splice(curAction.idxInParent, 0, curAction.target);
                break;
            case "MoveAction":
                break;
            case "ScaleAction":
                break;
            
        }
    }
}