import numpy as np
import random
from skimage.io import imsave

from select_tools import ellipse_select, labeled2rgb
#This script simulates a call to randomRectangle, except without the QML code.

def updateMask():
    rgb = labeled2rgb(labels,color_map)
    imsave("images/mask.png",rgb)

def randomEllipse():
    max_x = labels.shape[1]-1
    max_y = labels.shape[0]-1
    point1 = (random.randint(0, max_x),random.randint(0,max_y))
    point2 = (random.randint(0, max_x),random.randint(0,max_y))
    label = random.randint(1, 4)
    ellipse_select(labels, label, point1, point2)
    updateMask()


#Create labels matching the dimensions of an image from 2020 dataset
#Dataset/Jan2020_DairyBull_Cryptic_Original/DSCN4472.jpg is 4,608x3456
labels = np.zeros((4608,3456))
color_map = {
    0: (160,160,160), #gray
    1: (153, 0, 153), #magenta
    2: (255, 0, 0), #red
    3: (0, 255, 0), #green
    4: (255, 128, 0) #orange
    }
randomEllipse()
