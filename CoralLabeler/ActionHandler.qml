import QtQuick
import QtQuick.Shapes
import Actions

QtObject {
    function parseActionDo(curAction) {
        switch (curAction.typeString) {
            case "CreateAction":
                break;
            case "DeleteAction":
                var idx = curAction.shapeParent.data.indexOf(curAction.target);
                curAction.shapeParent.data.splice(idx,1);
                break;
            case "MoveAction":
                break;
            case "ScaleAction":
                break;
            
        }
        
    }

    function parseActionUndo {
    }
}