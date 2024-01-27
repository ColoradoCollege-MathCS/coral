from PySide6 import QtCore
from skimage.io import imread, imsave
import numpy as np
import random

from select_tools import labeled2rgb, rectangle_select

def image_dims(filename):
    return imread(filename).shape

color_map = {
    0: (160,160,160), #gray
    1: (153, 0, 153), #magenta
    2: (255, 0, 0), #red
    3: (0, 255, 0), #green
    4: (255, 128, 0) #orange
    }

class Toolbox(QtCore.QObject):

    @QtCore.Slot(str)
    def initLabels(self, filename):
        self.labels = np.zeros((image_dims(filename)[:2]))
        self.filename = filename
        self.updateMask()

    def updateMask(self):
        rgb = labeled2rgb(self.labels,color_map)
        imsave("images/mask.png",rgb)

    @QtCore.Slot()
    def randomRectangle(self):
        max_x = self.labels.shape[1]-1
        max_y = self.labels.shape[0]-1
        point1 = (random.randint(0, max_x),random.randint(0,max_y))
        point2 = (random.randint(0, max_x),random.randint(0,max_y))
        label = random.randint(1, 4)
        rectangle_select(self.labels, label, point1, point2)
        self.updateMask()

    @QtCore.Slot()
    def getPrediction(self):
        print("Here is where I would get my model predictions, and save them in labels")

    @QtCore.Slot(str)
    def printString(self, s):
        print(s)