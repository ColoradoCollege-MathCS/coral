from PySide6 import QtCore

from skimage.io import imread, imsave
from skimage.draw import polygon
from skimage.measure import label, regionprops

import sys
import numpy as np
import random
import csv
import os
import math
from rdp import rdp
from scipy import ndimage

from select_tools import labeled2rgb, rectangle_select, magic_wand_select, ellipse_select, circle_select
from prediction import blob_ML

dirname = os.path.dirname(__file__)

def image_dims(filename):
    return imread(filename).shape

color_map = {
    0: (160,160,160), #gray
    1: (153, 0, 153), #magenta
    2: (255, 0, 0), #red
    3: (0, 255, 0), #green
    4: (255, 128, 0) #orange
    }

class Toolbox(QtCore.QObject):
    @QtCore.Slot(str)
    def initLabels(self, filename):
        self.labels = np.zeros((image_dims(filename)[:2]))
        self.filename = filename
        self.updateMask()

    def updateMask(self):
        rgb = labeled2rgb(self.labels,color_map)
        mask_file = os.path.join(dirname, "images", "mask.png")
        imsave("images/mask.png",rgb, check_contrast=False)

    @QtCore.Slot()
    def randomRectangle(self):
        max_x = self.labels.shape[1]-1
        max_y = self.labels.shape[0]-1
        point1 = (random.randint(0, max_x),random.randint(0,max_y))
        point2 = (random.randint(0, max_x),random.randint(0,max_y))
        label = random.randint(1, 4)
        rectangle_select(self.labels, label, point1, point2)
        self.updateMask()

    @QtCore.Slot(str, result=str)
    def trimFileUrl(self, file_url):
        if sys.platform == 'win32':
            return file_url[8:]
        elif sys.platform == 'darwin' or sys.platform == "linux" or sys.platform == "linux2":
            return file_url[7:]
        else:
            return file_url[7:] #default to some unix-like
    
    @QtCore.Slot(str,result=str)
    def reFileUrl(self, file_path):
        if sys.platform == 'win32':
            return "file:///"+file_path
        elif sys.platform == 'darwin' or sys.platform == "linux" or sys.platform == "linux2":
            return "file://"+file_path # file path starts with slash to represent root
        else:
            return "file://"+file_path
    @QtCore.Slot(str,str)
    def saveFilePreference(self, temp_url, out_url):
        #save to a file named file_config in format temp_url\nout_url
        self.temp_url = temp_url
        self.out_url = out_url
        cfg = open(os.path.join(dirname,"file_config"), "w")
        cfg.write(temp_url+"\n"+out_url)
        cfg.close()
    
    @QtCore.Slot(str,str, result=int)
    def initFilePreference(self, temp_url, out_url):
        temp_fp = self.trimFileUrl(temp_url)
        out_fp = self.trimFileUrl(out_url)
        for fp in (temp_fp, out_fp):
            if not os.path.exists(fp):
                try:
                    os.makedirs(fp)
                except PermissionError:
                    return 2
                except OSError:
                    return 3
            else:
                if not os.path.isdir(fp):
                    return 1 #a non directory file exists with that name
        try:
            os.makedirs(os.path.join(out_fp,'raster_labels'))
            os.makedirs(os.path.join(out_fp,'statistics'))
        except PermissionError:
            return 2
        except OSError:
            return 3
        return 0

    @QtCore.Slot()
    def loadFilePreference(self):
        #load from the file, return (temp_url,out_url)
        cfg = open(os.path.join(dirname,"file_config"), "r")
        pieces = cfg.read().split("\n")
        cfg.close()
        self.temp_url = pieces[0]
        self.out_url = pieces[1]
    
    @QtCore.Slot(str,str)
    def setFilePreference(self, temp_url, out_url):
        self.temp_url = temp_url
        self.out_url = out_url

    @QtCore.Slot(result=str)
    def getTempUrl(self):
        """Returns the url to write temporary files into, like shape definitions"""
        try:
            return self.temp_url
        except AttributeError:
            return "temp not initialized"
    
    @QtCore.Slot(result=str)
    def getOutUrl(self):
        """Returns the url to write output files into. file:///<something>"""
        try:
            return self.out_url
        except AttributeError:
            return "out not initialized"
        
    @QtCore.Slot(result=str)
    def getFileLocation(self):
        """Returns the path (not url) to the directory containing main.py/main.qml"""
        return dirname
    

    @QtCore.Slot(str, int, int, int, int, float, float, float, result="QVariantList")
    def getPrediction(self, img_path, seedX, seedY, x_coord, y_coord, x_factor, y_factor, threshold):
        
        if sys.platform == 'darwin' or sys.platform == "linux" or sys.platform == "linux2":
            img_path = img_path[6:]
        elif sys.platform == 'win32':
            img_path = img_path[8:]
        
        polygon = blob_ML(img_path, (seedX, seedY), threshold)

        scaled_polygon = []
        for vert in polygon:
            vert_x = str(math.floor((vert[0] * x_factor) + x_coord))
            vert_y = str(math.floor((vert[1] * y_factor) + y_coord))
            scaled_polygon.append([vert_x, vert_y])

        return scaled_polygon


    @QtCore.Slot(str, int, int, float)
    def magicWand(self, image, mouse1, mouse2, threshold):
        label = random.randint(1, 4)
        coor = (mouse1, mouse2)
        magic_wand_select(image, self.labels, label, coor, threshold)
        self.updateMask()

    #@QtCore.Slot(int, int, int, int)
    #def selectCircle(self, point1x, point1y, point2x, point2y):
    #    label = random.randint(1, 4)
    #    point1 = (point1x, point1y)
    #    point2 = (point2x, point2y)
    #    ellipse_select(self.labels, label, point1, point2)
    #    self.updateMask()

    #@QtCore.Slot(int, int, int, int)
    #def selectRect(self, point1x, point1y, point2x, point2y):
    #    label = random.randint(1, 4)
    #    point1 = (point1x, point1y)
    #    point2 = (point2x, point2y)
    #    rectangle_select(self.labels, label, point1, point2)
    #    self.updateMask()

    @QtCore.Slot(int, int, int)
    def paintBrush(self, point1x, point1y, size):
        label = random.randint(1, 4)
        point1 = (point1x, point1y)
        circle_select(self.labels, label, point1, size)
        self.updateMask()

    @QtCore.Slot(str, result="QVariantList")
    def readCSV(self, fileName):
        labelsFile = open(fileName)
        csvreader = csv.reader(labelsFile)

        labels = []

        for row in csvreader:
            labels.append(row)

        return labels
    

    @QtCore.Slot(dict, str, list, result="QVariantList")
    def saveLabels(self, data, fileName, paintshapes):
        name = ""
        external_dir = self.trimFileUrl(self.getTempUrl())
        filename = os.path.join(external_dir, fileName+'.csv')
        check = False
        paintSize = ''
        paintFirstCoords = []
        with open(filename, 'w') as file:
            #get all labels
            for keys in data.keys():
                #make sure label has at least one shape
                if len(data[keys]) != 0:
                    file.write('Label'+',' + keys)
                    file.write('\n')

                    #get all shapes
                    for shapes in data[keys].keys():
                            file.write('Shape' + ',' + shapes)

                            #check for paint shapes
                            for paints in paintshapes:
                                if shapes == str(paints[0]):
                                    # print(paints)
                                    paintFirstCoords = paints[2]
                                    paintSize = paints[1]
                                    check = True
                            if check == True:
                                file.write(',' + str(int(paintSize)))
                            else:
                                file.write(',n')

                            file.write('\n')

                            #write all coords of a shape
                            for coord in range(len(data[keys][shapes])):
                                if check == False:
                                    if coord == 0:
                                        file.write(str(int(data[keys][shapes][len(data[keys][shapes])-1][0])) + ',' + str(int(data[keys][shapes][len(data[keys][shapes])-1][1])))
                                        file.write('\n')
                                        file.write(str(int(data[keys][shapes][coord][0])) + ',' + str(int(data[keys][shapes][coord][1])))
                                    else:
                                        file.write(str(int(data[keys][shapes][coord][0])) + ',' + str(int(data[keys][shapes][coord][1])))
                                else:
                                    if coord == 0:
                                        file.write(str(int(paintFirstCoords[0])) + ',' + str(int(paintFirstCoords[1])))
                                        file.write('\n')
                                        file.write(str(int(data[keys][shapes][coord][0])) + ',' + str(int(data[keys][shapes][coord][1])))
                                    else:
                                        file.write(str(int(data[keys][shapes][coord][0])) + ',' + str(int(data[keys][shapes][coord][1])))
                                file.write('\n')

                            check = False
        
        file.close()

    
    @QtCore.Slot(str, result = bool)
    def fileExists(self, fileName):
        return os.path.exists(fileName)
    
    @QtCore.Slot(str, result="QString")
    def splited(self, fileName):
        yuh = fileName.split('/')
        return yuh[-1]

    @QtCore.Slot(str)
    def printString(self, s):
        print(s)

    @QtCore.Slot(str, str, str, result="QVariantList")
    def addToCSV(self, data, name, fileName):
        fileName = os.path.join(dirname,fileName) #hardcoded to internal file. fine bc only used to operate on SpeciesList.csv which is internal
        with open(fileName, 'a') as file:
 
            # write row
            file.write("\n")
            file.write(str(int(data) + 1) + "," + name)

            # Close the file object
            file.close()

        return [str(int(data) + 1), name]
    

    @QtCore.Slot(list,float, result="QVariantList")
    def simplifyLasso(self, points, epsilon):
        #epsilon functions like a tolerance I think
        return rdp(points, epsilon=epsilon)

    
    # conver shape window coords to shape img pixel coords 
    def toPixels(self, coords, x_coord, y_coord, x_factor, y_factor):
        numpy_shapes = {}
        for label_num, coords_dict in coords.items():
            numpy_shapes[label_num] = {}
            for shape_num, shape_coords in coords_dict.items():
                numpy_shapes[label_num][shape_num] = []
                for coord in shape_coords:
                    x = math.floor((coord[0] - x_coord) / x_factor)
                    y  = math.floor((coord[1] - y_coord) / y_factor) 

                    numpy_coord = [x, y]
                    numpy_shapes[label_num][shape_num].append(numpy_coord)
                
                numpy_shapes[label_num][shape_num] = np.array(numpy_shapes[label_num][shape_num])

        return numpy_shapes
    

    @QtCore.Slot(dict, int, int, float, float, int, int, str, list)
    def saveRasters(self, coords, x_coord, y_coord, x_factor, y_factor, img_width, img_height, filename, paintshapes):
        # get the shape and vertices coords as numpy coords
        numpy_shapes = self.toPixels(coords, x_coord, y_coord, x_factor, y_factor)

        # make order of shape as key, value: [label id, [shape coords]], sort it in asc order
        ordered_shape = {}
        for label_id, order_dict in numpy_shapes.items():
            for order_num, shape_coords in order_dict.items():
                ordered_shape[order_num] = {label_id: shape_coords}
        ordered_shape = dict(sorted(ordered_shape.items()))

        # get brush size of painted shapes
        paint_size = {}
        for paintshape in paintshapes:
            paint_size[int(paintshape[0])] = int(paintshape[1])

        # make polygons out of coordinates,
        # rasterize shapes into numpy in order
        final_array = np.zeros((img_height, img_width))
        for n_shape_order, n_coords_dict in ordered_shape.items():
            for n_label_id, n_shape_coords in n_coords_dict.items():
                # if shape is paint, raterize based on brush size
                if int(n_shape_order) in paint_size.keys():
                    temp_array = np.zeros((img_height, img_width))

                    r = n_shape_coords[:, 0]
                    c = n_shape_coords[:, 1]
                    rr, cc = polygon(c, r)
                    temp_array[cc, rr] = 1
                    
                    dilated_coords = ndimage.binary_dilation(temp_array, iterations=math.floor(paint_size[int(n_shape_order)]/2)).nonzero()
                    dilated_coords = np.array(dilated_coords).T
                    r = dilated_coords[:, 0]
                    c = dilated_coords[:, 1]

                else:
                    r = n_shape_coords[:, 0]
                    c = n_shape_coords[:, 1]
                
                rr, cc = polygon(c, r)
                final_array[rr, cc] = n_label_id

        # save to csv file
        external_dir = self.trimFileUrl(self.getOutUrl())
        save_to = os.path.join(external_dir,'raster_labels',filename+".csv")
        np.savetxt(save_to, final_array, fmt='%d', delimiter=',')


    @QtCore.Slot(dict, list, int, int, float, float, int, int, str, str, str)
    def saveStats(self, coords, specs_list, x_coord, y_coord, x_factor, y_factor, img_p_width, img_p_height, filename, imgWS, imgHS):
        numpy_shapes = self.toPixels(coords, x_coord, y_coord, x_factor, y_factor)
        img_pix_area = img_p_width * img_p_height
        area_per_pix = (int(imgWS) * int(imgHS)) / img_pix_area

        headers = ['species id', 'species', 'pixel %', 'area (cm2)']

        stats_list = []
        for n_label_num, n_coords_dict in numpy_shapes.items():
                for n_shape_num, n_shape_coords in n_coords_dict.items():
                    shape = np.zeros((img_p_height, img_p_width))
                    r = n_shape_coords[:, 0]
                    c = n_shape_coords[:, 1]
                    rr, cc = polygon(c, r)
                    shape[rr, cc] = n_label_num
                    binary_label = label(shape)
                    measurements = regionprops(binary_label)
                    pixel_area =  int(measurements[0]['area'])
                    pixel_prop = pixel_area / img_pix_area
                    img_area = pixel_area * area_per_pix
                    spec_id = n_label_num
                    spec_name = specs_list[int(n_label_num)][1]

                    shape_stats = {'species id': spec_id, 
                             'species': spec_name, 
                             'pixel %': pixel_prop * 100, 
                             'area (cm2)': img_area}
                    
                    stats_list.append(shape_stats)
        external_dir = self.trimFileUrl(self.getOutUrl())
        save_to = os.path.join(external_dir,'statistics',filename+".csv")
        with open(save_to, 'w') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=headers)
            writer.writeheader()
            writer.writerows(stats_list)
