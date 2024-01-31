import torch

import torchvision
from torchvision.models.detection.faster_rcnn import FastRCNNPredictor
from torchvision.models.detection.mask_rcnn import MaskRCNNPredictor
from torchvision import transforms as T

from PIL import Image

import numpy as np

# hard coded instances for the training dataset
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


# load Pytorch model, hard coded number of instances for the traning data set
def load_mrcnn_model(model_path, num_classes=9):
    
    model = torchvision.models.detection.maskrcnn_resnet50_fpn()
    
    in_features = model.roi_heads.box_predictor.cls_score.in_features
    model.roi_heads.box_predictor = FastRCNNPredictor(in_features, num_classes)
    
    hidden_layer = 256
    in_features_mask = model.roi_heads.mask_predictor.conv5_mask.in_channels
    model.roi_heads.mask_predictor = MaskRCNNPredictor(in_features_mask, 
                                                       hidden_layer, 
                                                       num_classes)
    device = torch.device('cuda') if torch.cuda.is_available() else torch.device('cpu')
    weights = torch.load(model_path, map_location=device)
    model.load_state_dict(weights)
    model.eval()
    
    return model


# filter overlapping predictions, lower threshold => more strict, less overlapping
def nms(masks, scores, threshold=0.1):
    masks = torch.as_tensor(masks, dtype=torch.uint8)
    bboxes = torchvision.ops.masks_to_boxes(masks)
    
    keep = torchvision.ops.nms(bboxes, torch.as_tensor(scores, dtype=torch.float32), threshold)
    keep = keep.numpy()
        
    return keep


# get image masks, boxesm and instances predictions
def get_prediction(model, image_path, threshold=0.5):

    image = Image.open(image_path) 
    image_w, image_h = image.size
    transform = T.Compose([T.ToTensor()]) 
    image = transform(image)
    

    pred = model([image]) 
    pred_score = list(pred[0]['scores'].detach().cpu().numpy())
    
    try:
        pred_t = [pred_score.index(x) for x in pred_score if x > threshold][-1]
    except IndexError:
        print("No predictions for threshold.")
        empty_array = np.zeros((1, image_h, image_w), dtype=np.int32)
        empty_dict = {}
        empty_list = []
        return empty_array, empty_list, empty_dict
    
    pred_masks = (pred[0]['masks'] > 0.5).squeeze().detach().cpu().numpy()
    pred_class = [coral_classes[i] for i in list(pred[0]['labels'].cpu().numpy())]
    pred_boxes = [[(i[0], i[1]), (i[2], i[3])] for i in list(pred[0]['boxes'].detach().cpu().numpy())]

    pred_masks = pred_masks[:pred_t+1]
    pred_boxes = pred_boxes[:pred_t+1]
    pred_class = pred_class[:pred_t+1]
    pred_score = pred_score[:pred_t+1]
    
    keep = nms(pred_masks, pred_score, 0.3)
    
    ppred_masks, ppred_boxes, ppred_class = [], [], []
    for idx in keep:
        ppred_masks.append(pred_masks[idx])
        ppred_boxes.append(pred_boxes[idx])
        ppred_class.append(pred_class[idx])
     
    return np.array(ppred_masks), np.array(ppred_boxes), np.array(ppred_class)

# combines masks multiple instances predctions into one numpy array of pixels
# if prediction of one instance overlaps another
# instance with higher confidences core takes the pixel
def merge_masks(masks):
    
    merged = masks[0]
    masks = masks[1:]
    
    for mask in masks:
        for i, j in np.ndindex(mask.shape):
            cur_val = merged[i][j]
            nxt_val = mask[i][j]

            if cur_val == 0 and nxt_val > 0:
                merged[i][j] = nxt_val
            
    return merged


# MACHINE MAGIC, 
# return labels of the insances, a numpy array of pixels
def machine_magic(model_path, image_path, threshold=0.2):
    
    model = load_mrcnn_model(model_path)
    masks, pred_boxes, pred_class = get_prediction(model, image_path, threshold)
    
    label_keys = {}
    num_objs = len(pred_class)
    for i in range(1, num_objs + 1):
        label_keys[i] = pred_class[i-1]
        
     
    masks = masks.astype(np.int32)
    rslt_masks = []
    for index, mask in enumerate(masks):
        mask = np.where(mask == 1, mask * (index + 1), mask)
        rslt_masks.append(mask)
    
    mrg_mask = merge_masks(rslt_masks)
        
    return label_keys, mrg_mask


# TEST
'''
def display_array(array):
    unique_values = np.unique(array)
    num_colors = len(unique_values)
    cmap = plt.cm.get_cmap('tab10', num_colors)
    
    color_map = {}
    for i, value in enumerate(unique_values):
        if value == 0:
            color_map[value] = (1, 1, 1, 0) 
        else:
            color_map[value] = cmap(i)[:3] + (0.5,)
    
    colored_image = np.zeros((array.shape[0], array.shape[1], 4), dtype=np.float32)
    
    for i in range(array.shape[0]):
        for j in range(array.shape[1]):
            colored_image[i, j] = color_map[array[i, j]]
    
    plt.imshow(colored_image)
    plt.axis('off')  # Hide axis
    plt.show()
'''
   
