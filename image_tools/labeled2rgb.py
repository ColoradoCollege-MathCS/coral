import numpy as np
from skimage.io import imsave

#
#Params:
#labels - Numpy array with labeled pixels
#color_map - dictionary mapping label numbers to colors (rgb tuples)
#Returns:
#RGB data as a w x h x 3 numpy array
def labeled2rgb(labels, color_map):
    out = np.zeros(labels.shape+(3,), dtype=np.uint8)
    for y in range(labels.shape[0]):
        for x in range(labels.shape[1]):
            out[y,x]=color_map[labels[y,x]]
    return out



#Test Code, to be removed:
from select_tools import rectangle_select, circle_select
from matplotlib import pyplot as plt
color_map = {
    0: (160,160,160), #gray
    1: (153, 0, 153), #magenta
    2: (255, 0, 0), #red
    3: (0, 255, 0), #green
    4: (255, 128, 0) #orange
}
labels = np.zeros((500,500))
rectangle_select(labels,1,(0,0),(100,100))
circle_select(labels,2,(250,250),178)
circle_select(labels,3,(400,300),100)
rectangle_select(labels,4,(0,400),(257,499))
img = labeled2rgb(labels, color_map)
plt.imshow(img)
plt.show()
imsave("../CoralLabeler/test_images/mask.png",img)