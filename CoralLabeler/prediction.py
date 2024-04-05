import importlib
import config

from skimage.segmentation import find_boundaries
from skimage.measure import approximate_polygon

import cv2

import numpy as np


def blob_ML(img_path, seed, threshold):
    # import module and pipeline as defined in config file
    module = importlib.import_module(config.module_name)
    get_pred = getattr(module, config.pipeline)

    # given a seed pixel and an image path
    # get AI area of interest prediction 
    blob = get_pred(img_path, seed)
    
    # get polygon from numpy 2D boolean array
    shape = find_boundaries(blob, mode='inner')
    contours, hierarchy = cv2.findContours((shape * 255).astype(np.uint8), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if len(contours) > 0:
        largest_contour = max(contours, key=cv2.contourArea)
        polygon = largest_contour.reshape(-1, 2)
        polygon = approximate_polygon(polygon, tolerance=threshold)
    
    # return list of polygon coordinates
    return polygon
  