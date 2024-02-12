import numpy as np
import matplotlib.pyplot as plt

from PIL import Image


from skimage import data, feature
from skimage.feature import corner_harris, corner_subpix, corner_peaks
from skimage.transform import warp, AffineTransform
from skimage.morphology import convex_hull_image
from skimage.util import random_noise
from skimage.io import imread
from skimage.draw import ellipse

from scipy import ndimage as ndi


# get image and place in np array
import cv2

def cropit(img_dir):
    yuh = cv2.imread(img_dir, cv2.IMREAD_GRAYSCALE)


    #Canny filters
    edges1 = feature.canny(yuh)
    edges2 = feature.canny(yuh, sigma=4)


    image = edges2

    #Detect Corners
    coords = corner_peaks(corner_harris(image), min_distance=300, threshold_rel=.3)


    minx = min(coords[:, 1])
    maxx = max(coords[:, 1])
    miny = min(coords[:, 0])
    maxy = max(coords[:, 0])

    nuh = Image.open(img_dir)

    #Crop Image
    return nuh.crop((minx, miny, maxx, maxy))
