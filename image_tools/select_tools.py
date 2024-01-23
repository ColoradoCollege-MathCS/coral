import cv2
import numpy as np

#Returns (width, height) of the passed image
def image_dims(image):
    return cv2.imread(image).shape[:2]

#Parameters:
#image - path to the image file
#labels - numpy array with an int for each pixel. 0=no label, other ints have meaning
#labelNum - What label ID to set select values to.
#point1 - Point in image where selection was started from
#point2 - point in image where selection ended.
def rectangle_select(labels, labelNum, point1, point2):
    min_x = max(min(point1[0],point2[0]),0)#if selection goes off the screen, truncate at 0
    max_x = max(point1[0],point2[0])
    min_y = max(min(point1[1],point2[1]),0)
    max_y = max(point1[1],point2[1])
    #get the slice of the np array and set every val to the new label, inclusive
    labels[min_y:max_y+1,min_x:max_x+1]=labelNum

#Standard form of an ellipse
#(x-h)^2/a^2 + (y-k)^2/b^2 = 1. width = 2a, h = 2b
#<=1 defines all the space inside ellipse
def ellipse_select(labels, labelNum, point1, point2):
    min_x = max(min(point1[0],point2[0]),0)#if selection goes off the screen, truncate at 0
    max_x = max(point1[0],point2[0])
    min_y = max(min(point1[1],point2[1]),0)
    max_y = max(point1[1],point2[1])
    
    a=(max_x-min_x)//2
    b=(max_y-min_y)//2
    h=min_x+a #center x
    k=min_y+b #center y
    
    for y in range(labels.shape[0]):
        for x in range(labels.shape[1]):
            if ( (x-h)**2/a**2 + (y-k)**2/b**2)<=1:
                labels[y,x] = labelNum


#test rectangle select
"""
image = "16x16.png" 
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
"""
#test ellipse select
image = "16x16.png"
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
