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
                return 0 #file exists and is a directory. all is well.
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
    
    @QtCore.Slot(str, result = str)
    def fixTempUrl(self, url):
        """fixes the url for Windows"""
        url = url[8:]
        return url
    

    @QtCore.Slot(str, int, int, int, int, float, float, float, result="QVariantList")
    def getPrediction(self, img_path, seedX, seedY, x_coord, y_coord, x_factor, y_factor, threshold):
        
        if sys.platform == 'darwin' or sys.platform == "linux" or sys.platform == "linux2":
            img_path = img_path[6:]
        elif sys.platform == 'win32':
            img_path = img_path[8:]
        
        polygon = blob_ML(img_path, (seedX-1, seedY-1), threshold)

        scaled_polygon = []
        for vert in polygon:
            vert_x = str(math.floor((vert[0] * x_factor) + x_coord))
            vert_y = str(math.floor((vert[1] * y_factor) + y_coord))
            scaled_polygon.append([vert_x, vert_y])

        return scaled_polygon


    @QtCore.Slot(str, result="QVariantList")
    def readCSV(self, fileName):
        labelsFile = open(fileName)
        csvreader = csv.reader(labelsFile)

        labels = []

        for row in csvreader:
            labels.append(row)

        return labels
    

    @QtCore.Slot(dict, str, result="QVariantList")
    def saveLabels(self, data, fileName):
        name = ""
        external_dir = self.trimFileUrl(self.getTempUrl())
        filename = os.path.join(external_dir, fileName+'.csv')
        with open(filename, 'w') as file:
            for keys in data.keys():
                file.write('Label'+',' + keys)
                file.write('\n')
                for shapes in data[keys].keys():
                        file.write('Shape' + ',' + shapes)
                        file.write('\n')
                        for coord in range(len(data[keys][shapes])):
                            if coord == 0:
                                file.write(str(int(data[keys][shapes][len(data[keys][shapes])-1][0])) + ',' + str(int(data[keys][shapes][len(data[keys][shapes])-1][1])))
                                file.write('\n')
                                file.write(str(int(data[keys][shapes][coord][0])) + ',' + str(int(data[keys][shapes][coord][1])))
                            else:
                                file.write(str(int(data[keys][shapes][coord][0])) + ',' + str(int(data[keys][shapes][coord][1])))
                            file.write('\n')
        
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

    
    # convert shape window coords to shape img pixel coords 
    def toPixels(self, coords, x_coord, y_coord, x_factor, y_factor):
        numpy_shapes = {}
        for label_num, coords_dict in coords.items():
            numpy_shapes[label_num] = {}
            for shape_num, shape_coords in coords_dict.items():
                numpy_shapes[label_num][shape_num] = []
                for coord in shape_coords:
                    x = math.floor((coord[0] - x_coord) / x_factor) - 1
                    y  = math.floor((coord[1] - y_coord) / y_factor) - 1

                    numpy_coord = [x, y]
                    numpy_shapes[label_num][shape_num].append(numpy_coord)
                
                numpy_shapes[label_num][shape_num] = np.array(numpy_shapes[label_num][shape_num])

        return numpy_shapes
    

    @QtCore.Slot(dict, int, int, float, float, int, int, str)
    def saveRasters(self, coords, x_coord, y_coord, x_factor, y_factor, img_width, img_height, filename):

        # get the shape and vertices coords as numpy coords
        numpy_shapes = self.toPixels(coords, x_coord, y_coord, x_factor, y_factor)

        # make order of shape as key, value: [label id, [shape coords]], sort it in asc order
        ordered_shape = {}
        for label_id, order_dict in numpy_shapes.items():
            for order_num, shape_coords in order_dict.items():
                ordered_shape[order_num] = {label_id: shape_coords}
        ordered_shape = dict(sorted(ordered_shape.items()))

        # make polygons out of coordinates,
        # rasterize shapes into numpy in order
        final_array = np.zeros((img_height, img_width))
        for n_shape_order, n_coords_dict in ordered_shape.items():
            for n_label_id, n_shape_coords in n_coords_dict.items():
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
        # get the shape and vertices coords as numpy coords
        numpy_shapes = self.toPixels(coords, x_coord, y_coord, x_factor, y_factor)

        # img pixel area
        img_pix_area = img_p_width * img_p_height
        area_per_pix = (int(imgWS) * int(imgHS)) / img_pix_area

        # stats file header
        headers = ['species id', 'species', 'pixel %', 'area (cm2)']

        stats_list = []
        for n_label_num, n_coords_dict in numpy_shapes.items():
                for n_shape_num, n_shape_coords in n_coords_dict.items():
                    # make polygon
                    shape = np.zeros((img_p_height, img_p_width))
                    r = n_shape_coords[:, 0]
                    c = n_shape_coords[:, 1]
                    rr, cc = polygon(c, r)
                    shape[rr, cc] = n_label_num
                    binary_label = label(shape)

                    # get area of polygon
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
                    
                    # save row info
                    stats_list.append(shape_stats)
                    
        # write to file
        external_dir = self.trimFileUrl(self.getOutUrl())
        save_to = os.path.join(external_dir,'statistics',filename+".csv")
        with open(save_to, 'w') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=headers)
            writer.writeheader()
            writer.writerows(stats_list)
