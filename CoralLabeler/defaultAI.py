import torch
import torch.nn as nn

import torchvision.transforms as T
from torchvision.models.detection import maskrcnn_resnet50_fpn, MaskRCNN_ResNet50_FPN_Weights

from skimage.morphology import flood

from PIL import Image

import numpy as np

    
    
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
    
    
def get_fm(img):  
    # get Mask RCNN model 
    mrcnn_model = get_model()
    
    # extract layer with forward hook
    activation = {}
    def get_activation(name):
        def hook(model, input, output):
            activation[name] = output
        return hook 
    
    mrcnn_model.backbone.body.layer1.register_forward_hook(get_activation('backbone'))
    preds = mrcnn_model([img])
    
    # get extracted layer output
    ext_fm = activation['backbone']
    
    m = nn.Upsample((img.shape[1], img.shape[2]), mode='bicubic')
    ext_fm = m(ext_fm)
    ext_fm = ext_fm.squeeze(0)
    
    ext_fm = ext_fm.data.cpu().numpy()
    
    return ext_fm


def process_output(fm, seed):
    # upsample array back to original image size
    max_pool_chnls = np.max(fm, 0)

    # use glood algorithm to perform segmentation 
    blob = flood(max_pool_chnls, seed, tolerance=0.05)
    
    return blob


def default_pred(img_path, seed):
    # transform image, return PyTorch Tensor
    img = transform_img(img_path)

    # extract Pytorch model intermediate layer output, 
    ext_fm = get_fm(img)

    # given a seed pixel (x,y),
    # perform segmentation using Pytorch model intermediate layer output,
    # return numpy 2D boolean array w/ original image WxH 
    blob = process_output(ext_fm, seed)

    return blob