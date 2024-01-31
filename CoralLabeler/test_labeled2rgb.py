import numpy as np
import matplotlib.pyplot as plt
from skimage.io import imsave
def labeled2rgb(labels, color_map):
    v_get = np.vectorize(color_map.get)
    return np.stack(v_get(labels), -1).astype(np.uint8)

def circle_select(labels, labelNum, pointClicked, radius):
    h = labels.shape[0]
    w = labels.shape[1]
    Y, X = np.ogrid[:h, :w] #height, width
    #Calculate dist from center for each pt, mask according to radius to boolean
    in_circle = np.sqrt((X-pointClicked[0])**2 + (Y-pointClicked[1])**2) <=radius
    #Fill in labelNum where true
    np.place(labels, in_circle, labelNum)

def ellipse_select(labels, labelNum, point1, point2):
    min_x = max(min(point1[0],point2[0]),0)#if selection goes off the screen, truncate at 0
    max_x = max(point1[0],point2[0])
    min_y = max(min(point1[1],point2[1]),0)
    max_y = max(point1[1],point2[1])
    
    a=(max_x-min_x)//2
    b=(max_y-min_y)//2
    h=min_x+a #center x
    k=min_y+b #center y

    img_h = labels.shape[0]
    img_w = labels.shape[1]

    Y, X = np.ogrid[:img_h, :img_w]
    in_ellipse = ( (X-h)**2/a**2 + (Y-k)**2 / b**2 ) <=1
    np.place(labels, in_ellipse, labelNum)


color_map = {
    0: (160,160,160), #gray
    1: (153, 0, 153), #magenta
    2: (255, 0, 0), #red
    3: (0, 255, 0), #green
    4: (255, 128, 0) #orange
    }

labels = np.zeros((500,500),dtype=np.int32)
ellipse_select(labels, 4, (100,200), (400,300))


rgb = labeled2rgb(labels,color_map)
plt.imshow(rgb)
plt.show()
