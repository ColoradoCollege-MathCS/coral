import torch
import torch.nn as nn

import torchvision.transforms as T
from torchvision.models.detection import maskrcnn_resnet50_fpn, MaskRCNN_ResNet50_FPN_Weights

from skimage.morphology import flood
from skimage.segmentation import find_boundaries
from skimage.measure import approximate_polygon

import cv2

from PIL import Image

import numpy as np

import csv

import os.path

import math

    
    
def get_model():
    # TEMP HARD CODE MASK RCNN
    # load pretrained model
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    weights = MaskRCNN_ResNet50_FPN_Weights.DEFAULT
    mrcnn_model = maskrcnn_resnet50_fpn(weights=weights, progress=False).to(device)
    mrcnn_model = mrcnn_model.eval()
    
    return mrcnn_model


def transform_img(img_path):
    img = Image.open(img_path)
    transform = T.Compose([T.ToTensor()]) 
    img = transform(img)
    
    return img
    
    
def get_fm(img_path):   
    mrcnn_model = get_model()
    
    # extract layer with forward hook
    activation = {}
    def get_activation(name):
        def hook(model, input, output):
            activation[name] = output
        return hook 
    
    mrcnn_model.backbone.body.layer1.register_forward_hook(get_activation('backbone'))
    
    img = transform_img(img_path)
    
    preds = mrcnn_model([img])
    
    ext_fm = activation['backbone']
    
    m = nn.Upsample((img.shape[1], img.shape[2]), mode='bicubic')
    ext_fm = m(ext_fm)
    ext_fm = ext_fm.squeeze(0)
    
    ext_fm = ext_fm.data.cpu().numpy()
    
    return ext_fm


def process_fm(fm):
    max_pool_chnls = np.max(fm, 0)
    
    return max_pool_chnls


def write_shape(label_name, polygon, img_path, x_coord, y_coord, x_factor, y_factor):
    img_path = './labels/' + img_path.rsplit('/',1)[1] + '.csv'

    cur_content = []
    line_append = -1

    to_add = []
    for vert in polygon:
        vert_x = str(math.floor((vert[0] * x_factor) + x_coord))
        vert_y = str(math.floor((vert[1] * y_factor) + y_coord))
        to_add.append([vert_x, vert_y])
    
    if os.path.exists(img_path):
        with open(img_path, 'r') as file_r:
            line_num = 0
            for line in file_r:
                cur_content.append(line.strip().split(','))
                if label_name in line.strip().split(','):
                    line_append = line_num
                line_num +=1
        
    with open(img_path, 'w') as file:
        writer = csv.writer(file, delimiter=',')     
        
        if line_append != -1:
            to_add.insert(0, ['Shape'])
            for coords in reversed(to_add):
                cur_content.insert(line_append + 1, coords)
        else:
            cur_content.append(['Label', label_name])
            cur_content.append(['Shape'])
            for coords in to_add:
                cur_content.append(coords)

        for line in cur_content:
                writer.writerow(line)
    

def blob_ML(label_name, img_path, seed, x_coord, y_coord, x_factor, y_factor):
    ext_fm = get_fm(img_path)
    
    pro_fm = process_fm(ext_fm)
    
    blob = flood(pro_fm, seed, tolerance=0.05)
    
    shape = find_boundaries(blob, mode='inner')
    
    contours, hierarchy = cv2.findContours((shape * 255).astype(np.uint8), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if len(contours) > 0:
        largest_contour = max(contours, key=cv2.contourArea)
        polygon = largest_contour.reshape(-1, 2)
        polygon = approximate_polygon(polygon, tolerance=1)
    
    write_shape(label_name, polygon, img_path, x_coord, y_coord, x_factor, y_factor)
    
    return polygon
  