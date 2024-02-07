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
    
    fm = mrcnn_model([img])
    
    ext_fm = activation['backbone']
    
    m = nn.Upsample((img.shape[1], img.shape[2]), mode='bicubic')
    ext_fm = m(ext_fm)
    ext_fm = ext_fm.squeeze(0)
    
    ext_fm = ext_fm.data.cpu().numpy()
    
    return ext_fm


def process_fm(fm):
    max_pool_chnls = np.max(fm, 0)
    
    return max_pool_chnls


def write_shape(polygon):
    with open('ShapeAI.csv', 'w') as file:
        writer = csv.writer(file, delimiter=',')

        writer.writerow(['Label', 'unknownAI'])
        writer.writerow(['Shape'])

        for vert in polygon:
            str_vert = [str(coord) for coord in vert]
            writer.writerow(str_vert)
    

def blob_ML(img_path, seed):
    
    ext_fm = get_fm(img_path)
    
    pro_fm = process_fm(ext_fm)
    
    blob = flood(pro_fm, seed, tolerance=0.05)
    
    shape = find_boundaries(blob, mode='inner')
    
    contours, hierarchy = cv2.findContours((shape * 255).astype(np.uint8), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    if len(contours) > 0:
        largest_contour = max(contours, key=cv2.contourArea)
        polygon = largest_contour.reshape(-1, 2)
        polygon = approximate_polygon(polygon, tolerance=10)
    
    write_shape(polygon)
    
    return polygon

