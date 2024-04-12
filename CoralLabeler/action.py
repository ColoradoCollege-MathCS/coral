from PySide6.QtCore import QObject, Property, Signal
from PySide6.QtQml import QmlElement, QmlUncreatable
import sys

QML_IMPORT_NAME = "Actions"
QML_IMPORT_MAJOR_VERSION = 1

@QmlElement
@QmlUncreatable("Action is an abstract base class.")
class Actions(QObject):
    """Abstract class to represent an action that can be taken on a shape"""
    @Property(QObject, doc="The QML Shape that this action acts on")
    def target(self):
        return self._target
    
    @target.setter
    def target(self, target):
        self._target = target
    
    @Property(QObject, doc="The parent that the target shape is attached to / should be attached to")
    def shapeParent(self):
        return self._shapeParent
    
    @shapeParent.setter
    def shapeParent(self, shapeParent):
        self._shapeParent = shapeParent

    @Property(QObject, doc="The entire window in order to get shape list")
    def everything(self):
        return self._everything
    
    @everything.setter
    def everything(self, _everything):
        self._everything = _everything

    @Property(str, doc="The string representation of the class name")
    def typeString(self):
        return self._typeString

    @Property(int, doc="The index of this element in its parent's array. Stored so items are restored at the right z value")
    def idxInParent(self):
        return self._idxInParent
    
    @idxInParent.setter
    def idxInParent(self, _idxInParent):
        self._idxInParent = _idxInParent

    def do(self):
        """Execute the action represented by this class"""
        #Abstract class to be overriden by children    
        pass
    
    def undo(self):
        """Execute the opposite of the action represented by this class"""
        #Abstract class to be overriden by children
        pass


@QmlElement
class CreateAction(Actions) :
    """This action creates a polygon shape with a specified set of points"""
    def __init__(self,parent = None, shapeParent=None, target=None):
        super().__init__(parent)

        self._target = target
        self._shapeParent = shapeParent
        self._typeString = "CreateAction"


@QmlElement
class DeleteAction(Actions) :
    """This action deletes a specified shape"""
    def __init__(self,parent=None, shapeParent=None, target=None, shapeIndex = None):
        super().__init__(parent)
        self._target = target
        self._shapeParent = shapeParent
        self._idxInParent = shapeIndex
        self._typeString = "DeleteAction"


@QmlElement
class MoveAction(Actions) :
    """This action moves a shape by specified distances in the x and y directions"""
    def __init__(self,parent = None,shapeParent=None, target=None, dX=0, dY=0):
        super().__init__(parent)
        self._target = target
        self._shapeParent = shapeParent
        self._dX = dX
        self._dY = dY
        self._typeString = "MoveAction"
    
    @Property(int, doc="The change in X position performed by this move")
    def dX(self):
        return self._dX
    
    @dX.setter
    def dX(self, dX):
        self._dX = dX
    
    @Property(int, doc="The change in Y position performed by this move")
    def dY(self):
        return self._dY
    
    @dY.setter
    def dY(self, dY):
        self._dY = dY

@QmlElement
class ScaleAction(Actions):
    """This action operates on shapes that can be scaled, like rectangles and ovals,
        and changes their height and width by the specified amounts
    """
    def __init__(self, parent = None, shapeParent=None, target=None,sX=1,sY=1):
        super().__init__(parent)
        self._target = target
        self.shapeParent = shapeParent
        self._sX = sX
        self._sY = sY
        self._typeString = "ScaleAction"

    @Property(int, doc="The scaling factor for the width of this object")
    def sX(self):
        return self._sX
    
    @sX.setter
    def sX(self,sX):
        self._sX= sX
    
    @Property(int, doc="The scaling factor for the height of this object")
    def sY(self):
        return self._sY

    @sY.setter
    def sY(self,sY):
        self._sY= sY