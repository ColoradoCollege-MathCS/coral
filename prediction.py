import torch

import torchvision
from torchvision.models.detection.faster_rcnn import FastRCNNPredictor
from torchvision.models.detection.mask_rcnn import MaskRCNNPredictor
from torchvision import transforms as T

from PIL import Image

import numpy as np


coral_classes = {
    0: "Coral-growth-forms",
    1: "Encrusting",
    2: "Parascolymia",
    3: "branching",
    4: "foliose",
    5: "massive",
    6: "mushroom",
    7: "phaceolid",
    8: "submassive"
}



def load_mrcnn_model(model_path, num_classes=9):
    
    model = torchvision.models.detection.maskrcnn_resnet50_fpn()
    
    in_features = model.roi_heads.box_predictor.cls_score.in_features
    model.roi_heads.box_predictor = FastRCNNPredictor(in_features, num_classes)
    
    hidden_layer = 256
    in_features_mask = model.roi_heads.mask_predictor.conv5_mask.in_channels
    model.roi_heads.mask_predictor = MaskRCNNPredictor(in_features_mask, 
                                                       hidden_layer, 
                                                       num_classes)
    weights = torch.load(model_path)
    model.load_state_dict(weights)
    model.eval()
    
    return model


def get_prediction(model, img_path, threshold=0.5):

    img = Image.open(img_path) 
    transform = T.Compose([T.ToTensor()]) 
    img = transform(img)

    pred = model([img]) 
    pred_score = list(pred[0]['scores'].detach().cpu().numpy())
    
    try:
        pred_t = [pred_score.index(x) for x in pred_score if x > threshold][-1]
    except IndexError:
        print("No predictions for threshold.")
        return [], [], []
    
    masks = (pred[0]['masks'] > 0.5).squeeze().detach().cpu().numpy()
    pred_class = [coral_classes[i] for i in list(pred[0]['labels'].cpu().numpy())]
    pred_boxes = [[(i[0], i[1]), (i[2], i[3])] for i in list(pred[0]['boxes'].detach().cpu().numpy())]

    masks = masks[:pred_t+1]
    pred_boxes = pred_boxes[:pred_t+1]
    pred_class = pred_class[:pred_t+1]

    return masks, pred_boxes, pred_class


def machine_magic(model_path, image_path, threshold=0.5):
    
    model = load_mrcnn_model(model_path)
    masks, pred_boxes, pred_class = get_prediction(model, image_path, threshold)
    
    label_keys = {}
    num_objs = len(pred_class)
    for i in range(1, num_objs + 1):
        label_keys[i] = pred_class[i-1]
    
    masks = masks.astype(int)
    rslt_masks = []
    for index, mask in enumerate(masks):
        mask = np.where(mask == 1, mask * (index + 1), mask)
        rslt_masks.append(mask)
        
    rslt_masks = np.array(rslt_masks)
        
    return label_keys, rslt_masks
    
   