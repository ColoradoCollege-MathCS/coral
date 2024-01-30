import numpy as np
import matplotlib.pyplot as plt
from skimage.io import imsave
def labeled2rgb(labels, color_map):
    v_get = np.vectorize(color_map.get)
    return np.stack(v_get(labels), -1)


color_map = {
    0: (160,160,160), #gray
    1: (153, 0, 153), #magenta
    2: (255, 0, 0), #red
    3: (0, 255, 0), #green
    4: (255, 128, 0) #orange
    }

my_array = np.array([[1,2,2],
                     [1,0,3],
                     [4,3,0]],dtype=np.int32)
rgb = labeled2rgb(my_array,color_map)
plt.imshow(rgb.astype(np.uint8))
plt.show()
#print(rgb.dtype)
imsave("test_images/testrgbsave.png",rgb.astype(np.uint8))
