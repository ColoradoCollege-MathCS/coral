from skimage import io, color
from skimage.segmentation import flood
import cv2 #just for image sizes used by test code. remove later.
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


#When a user selects a point, this tool automatically fills the label to similar 
#colors in the surrounding area, like the Fuzzy Select tool in GIMP
#Params
#image - img filename. Needed to examine color similarities
#labels - numpy array with int for each pixel in image, representing what coral species is there
#labelNum - what number to change the selected pixels to
#pointClicked - pixel coordinates in the image where the user clicked
#threshold - how tolerant the fill is to differences in color
def magic_wand_select(image, labels, labelNum, pointClicked, threshold):
    #Load image
    image_arr = io.imread(image)
    if image_arr.shape[2]==4:
        image_arr = color.rgba2rgb(image_arr) #strip alpha chan with alpha blending if necc.
    #convert to Hue Saturation Value space
    image_arr = color.rgb2hsv(image_arr)
    #flood according to hue, returning boolean mask of pixels that should be selected
    mask = flood(image_arr[...,0], pointClicked, tolerance=threshold)
    #Use np.place or np.copyto to replace    
    np.place(labels, mask, labelNum) #Where mask is true, set pixel in labels to labelNum
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
