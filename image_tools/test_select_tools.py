from cv2 import imread
import numpy as np
from select_tools import rectangle_select, ellipse_select, circle_select, magic_wand_select

def image_dims(image):
    return imread(image).shape[:2]

#test rectangle select
"""
image = "test_images/16x16.png" 
point1 = (2,4)
point2 = (10, 14)
labels = np.zeros(image_dims(image))
newLabelNum = 5
print("labels before")
print(labels)
rectangle_select(labels,newLabelNum,point1,point2)
print("after:")
print(labels)
"""
#test ellipse select
"""
image = "test_images/16x16.png"
point1 = (2,4)
point2 = (10,14)
labels = np.zeros(image_dims(image))
newLabelNum=5
print("labels before")
print(labels)
ellipse_select(labels,newLabelNum,point1,point2)
print("labels after: ")
print(labels)
"""
#test magic select
"""
image = "test_images/checkerboard-larger-red-green-16x16.png"
point = (2,4)
labels = np.zeros(image_dims(image),dtype=np.int64)
newLabelNum=5
print("beofre")
print(labels)
magic_wand_select(image,labels,newLabelNum,point,0)
print("after")
print(labels)
"""
#test circle select

image="test_images/16x16.png"
pointClicked= (1,1)
labels=np.zeros(image_dims(image))
newLabelNum=5
radius=5
print("beofre")
print(labels)
circle_select(labels,newLabelNum,pointClicked,radius)
print("after")
print(labels)

