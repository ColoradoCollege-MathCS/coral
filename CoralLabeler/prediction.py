import importlib
import config

from skimage.segmentation import find_boundaries
from skimage.measure import approximate_polygon

import cv2

import numpy as np


def blob_ML(img_path, seed):
    # import module and functions as defined in config file
    module = importlib.import_module(config.module_name)
    transform_img = getattr(module, config.pipeline[0])
    get_fm = getattr(module, config.pipeline[1])
    process_output = getattr(module, config.pipeline[2])

    # transform image, return PyTorch Tensor
    img = transform_img(img_path)

    # extract Pytorch model intermediate layer output, 
    # return numpy ndarray same WxH as image
    ext_fm = get_fm(img)

    # given a seed pixel (x,y),
    # perform segmentation using Pytorch model intermediate layer output,
    # return numpy 1D boolean array 
    blob = process_output(ext_fm, seed)
    
    # get polygon from numpy 1D boolean array
    shape = find_boundaries(blob, mode='inner')
    contours, hierarchy = cv2.findContours((shape * 255).astype(np.uint8), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if len(contours) > 0:
        largest_contour = max(contours, key=cv2.contourArea)
        polygon = largest_contour.reshape(-1, 2)
        polygon = approximate_polygon(polygon, tolerance=1)
    
    # return list of polygon coordinates
    return polygon
  