import importlib
import config

from skimage.segmentation import find_boundaries
from skimage.measure import approximate_polygon

import cv2

import numpy as np


global g_img_path


def blob_ML(img_path, seed):
    module = importlib.import_module(config.module_name)

    transform_img = getattr(module, config.pipeline[0])
    get_fm = getattr(module, config.pipeline[1])
    process_output = getattr(module, config.pipeline[2])

    global g_img_path
    g_img_path = img_path
    g_img_path = transform_img(g_img_path)

    ext_fm = get_fm(g_img_path)
    
    blob = process_output(ext_fm, seed)
    
    shape = find_boundaries(blob, mode='inner')
    
    contours, hierarchy = cv2.findContours((shape * 255).astype(np.uint8), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if len(contours) > 0:
        largest_contour = max(contours, key=cv2.contourArea)
        polygon = largest_contour.reshape(-1, 2)
        polygon = approximate_polygon(polygon, tolerance=1)
    
    return polygon
  