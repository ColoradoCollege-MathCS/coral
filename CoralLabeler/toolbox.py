from PySide6 import QtCore
from skimage.io import imread, imsave
import numpy as np
import random
import csv
import os
from rdp import rdp


from select_tools import labeled2rgb, rectangle_select, magic_wand_select, ellipse_select, circle_select
from prediction import blob_ML

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
        imsave("images/mask.png",rgb, check_contrast=False)

    @QtCore.Slot()
    def randomRectangle(self):
        max_x = self.labels.shape[1]-1
        max_y = self.labels.shape[0]-1
        point1 = (random.randint(0, max_x),random.randint(0,max_y))
        point2 = (random.randint(0, max_x),random.randint(0,max_y))
        label = random.randint(1, 4)
        rectangle_select(self.labels, label, point1, point2)
        self.updateMask()

    @QtCore.Slot(str, str, int, int, int, int, float, float)
    def getPrediction(self, label_name, img_path, seedX, seedY, x_coord, y_coord, x_factor, y_factor):
        polygon = blob_ML(label_name, img_path[6:], (seedX, seedY), x_coord, y_coord, x_factor, y_factor)


    @QtCore.Slot(str, int, int, float)
    def magicWand(self, image, mouse1, mouse2, threshold):
        label = random.randint(1, 4)
        coor = (mouse1, mouse2)
        magic_wand_select(image, self.labels, label, coor, threshold)
        self.updateMask()

    @QtCore.Slot(int, int, int, int)
    def selectCircle(self, point1x, point1y, point2x, point2y):
        label = random.randint(1, 4)
        point1 = (point1x, point1y)
        point2 = (point2x, point2y)
        ellipse_select(self.labels, label, point1, point2)
        self.updateMask()

    @QtCore.Slot(int, int, int, int)
    def selectRect(self, point1x, point1y, point2x, point2y):
        label = random.randint(1, 4)
        point1 = (point1x, point1y)
        point2 = (point2x, point2y)
        rectangle_select(self.labels, label, point1, point2)
        self.updateMask()

    @QtCore.Slot(int, int, int)
    def paintBrush(self, point1x, point1y, size):
        label = random.randint(1, 4)
        point1 = (point1x, point1y)
        circle_select(self.labels, label, point1, size)
        self.updateMask()

    @QtCore.Slot(str, result="QVariantList")
    def readCSV(self, fileName):
        labelsFile = open(fileName)
        csvreader = csv.reader(labelsFile)

        labels = []

        for row in csvreader:
            labels.append(row)

        return labels
    
    @QtCore.Slot(dict, str, result="QVariantList")
    def saveLabels(self, data, fileName):
        
        filename = 'labels/' + fileName + '.csv'
        with open(filename, 'w') as file:
            for keys in data.keys():
                file.write('Label'+',' + keys)
                file.write('\n')
                for shapes in data[keys].keys():
                        file.write('Shape')
                        file.write('\n')
                        for coord in range(len(data[keys][shapes])):
                            if coord == 0:
                                file.write(str(int(data[keys][shapes][len(data[keys][shapes])-1][0])) + ',' + str(int(data[keys][shapes][len(data[keys][shapes])-1][1])))
                                file.write('\n')
                                file.write(str(int(data[keys][shapes][coord][0])) + ',' + str(int(data[keys][shapes][coord][1])))
                            else:
                                file.write(str(int(data[keys][shapes][coord][0])) + ',' + str(int(data[keys][shapes][coord][1])))

                            file.write('\n')
        
        file.close()

    
    @QtCore.Slot(str, result = bool)
    def fileExists(self, fileName):
        return os.path.exists(fileName)
    
    @QtCore.Slot(str, result="QString")
    def splited(self, fileName):
        yuh = fileName.split('/')
        return yuh[-1]

    @QtCore.Slot(str)
    def printString(self, s):
        print(s)

    @QtCore.Slot(str, str, str, result="QVariantList")
    def addToCSV(self, data, name, fileName):
        with open(fileName, 'a') as file:

            # write row
            file.write("\n")
            file.write(str(int(data) + 1) + "," + name)

            # Close the file object
            file.close()

        return [str(int(data) + 1), name]
    
    @QtCore.Slot(list, result="QVariantList")
    def simplifyLasso(self, points):
        epsi = .3 #functions like a tolerance I think
        return rdp(points, epsilon=epsi)
