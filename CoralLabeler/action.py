from PySide6.QtCore import QObject, Property, Signal
from PySide6.QtQml import QmlElement, QmlUncreatable
import sys

QML_IMPORT_NAME = "Actions"
QML_IMPORT_MAJOR_VERSION = 1

@QmlElement
@QmlUncreatable("Action is an abstract base class.")
class Action(QObject):
    """Abstract class to represent an action that can be taken on a shape"""
    @Property(QObject, doc="The QML Shape that this action acts on")
    def target(self):
        return self._target
    
    @target.setter
    def target(self, target):
        self.target = target
    
    @Property(QObject, doc="The parent that the target shape is attached to / should be attached to")
    def shapeParent(self):
        return self.shapeParent
    
    @shapeParent.setter
    def shapeParent(self, shapeParent):
        self.shapeParent = shapeParent
    


@QmlElement
class CreateAction(Action) :
    """This action creates a polygon shape with a specified set of points"""
    def __init__(self,parent = None, shapeParent=None, target=None, coordinate_array = None):
        super().__init__(parent)
        if coordinate_array is not None:
            print("Creating from arrays in python not supported yet", file=sys.stderr)
        if coordinate_array is None and target is None:
            print("No coordinate array or pre-created object provided", file=sys.stderr)
        self.target = target
        self.shapeParent = shapeParent


@QmlElement
class DeleteAction(Action) :
    """This action deletes a specified shape"""
    def __init__(self,parent=None, shapeParent=None, target=None):
        super().__init__(parent)
        self.target = target
        self.shapeParent = shapeParent


@QmlElement
class MoveAction(Action) :
    """This action moves a shape by specified distances in the x and y directions"""
    def __init(self,parent = None,shapeParent=None, target=None, dX=0, dY=0):
        super().__init__(parent)
        self.target = target
        self.shapeParent = shapeParent
        self.dX = dX
        self.dY = dY
    
    @Property(int, doc="The change in X position performed by this move")
    def dX(self):
        return self.dX
    
    @dX.setter
    def dX(self, dX):
        self.dX = dX
    
    @Property(int, doc="The change in Y position performed by this move")
    def dY(self):
        return self.dY
    
    @dY.setter
    def dY(self, dY):
        self.dY = dY

@QmlElement
class ScaleAction(Action):
    """This action operates on shapes that can be scaled, like rectangles and ovals,
        and changes their height and width by the specified amounts
    """
    def __init__(self, parent = None, shapeParent=None, target=None,sX=1,sY=1):
        super().__init__(parent)
        self.target = target
        self.shapeParent = shapeParent
        self.sX = sX
        self.sY = sY

    @Property(int, doc="The scaling factor for the width of this object")
    def sX(self):
        return self.sX
    
    @sX.setter
    def sX(self,sX):
        self.sX= sX
    
    @Property(int, doc="The scaling factor for the height of this object")
    def sY(self):
        return self.sY

    @sY.setter
    def sY(self,sY):
        self.sY= sY