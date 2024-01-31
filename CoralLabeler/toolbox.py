from PySide6 import QtCore
from skimage.io import imread, imsave
import numpy as np
import random

from select_tools import labeled2rgb, rectangle_select
from prediction import machine_magic

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
        self.filename = filename[6:] #trim off file:// extension that QML uses
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

    @QtCore.Slot(result="QVariantList")
    def getPrediction(self):
        label_dict, pred_labels = machine_magic("mrcnn_model1.pth", self.filename)
        #Later, save label key to be displayed in the UI. Right now it will fail if any label is >4.
        self.labels = pred_labels
        self.updateMask()

        label_list = []
        for key, value in label_dict.items():
            hex_color = '#%02x%02x%02x' % color_map[key]           
            label_list.append([hex_color, value])
        return  label_list

    @QtCore.Slot(str)
    def printString(self, s):
        print(s)