import os.path
import random
import torchvision.transforms as transforms
import torch
from data.base_dataset import BaseDataset, get_params, get_transform
from data.image_folder import make_grouped_dataset
from PIL import Image, ImageDraw
import numpy as np

from scipy.optimize import curve_fit
import cv2
from skimage import feature
import warnings

def func(x, a, b, c):    
    return a * x**2 + b * x + c

def linear(x, a, b):
    return a * x + b

def drawEdge(im, x, y, bw=1, value=255):    
    h, w = im.shape
    for i in range(-bw, bw):
        for j in range(-bw, bw):
            yy = np.maximum(0, np.minimum(h-1, y+i))
            xx = np.maximum(0, np.minimum(w-1, x+j))
            im[yy, xx] = value

def interpPoints(x, y):
    if abs(x[-1] - x[0]) < abs(y[-1] - y[0]):
        curve_y, curve_x = interpPoints(y, x)
    else:
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")    
            if len(x) < 3:
                popt, _ = curve_fit(linear, x, y)
            else:
                popt, _ = curve_fit(func, x, y)
        if x[0] > x[-1]:
            x = list(reversed(x))
            y = list(reversed(y))
        curve_x = np.linspace(x[0], x[-1], (x[-1]-x[0]))
        if len(x) < 3:
            curve_y = linear(curve_x, *popt)
        else:
            curve_y = func(curve_x, *popt)
    return curve_x.astype(int), curve_y.astype(int)


class FaceDataset(BaseDataset):
    def initialize(self, opt):
        self.opt = opt
        self.root = opt.dataroot
        
        if opt.isTrain:
            self.dir_A = os.path.join(opt.dataroot, 'train_keypoints')
            self.dir_B = os.path.join(opt.dataroot, 'train_img')
        else:
            self.dir_A = opt.dataroot
            self.dir_B = opt.dataroot.replace('keypoints', 'img')

        self.A_paths = sorted(make_grouped_dataset(self.dir_A))
        self.B_paths = sorted(make_grouped_dataset(self.dir_B))    
        assert(len(self.A_paths) == len(self.B_paths))          
        if opt.isTrain:
            for a, b in zip(self.A_paths, self.B_paths):            
                assert(len(a) == len(b))

        self.n_of_seqs = len(self.A_paths)
        self.seq_len_max = max([len(A) for A in self.A_paths])  # max number of frames in the training sequences
        if opt.isTrain:
            self.n_frames_total = self.opt.n_frames_total  

    def __getitem__(self, index):
        tG = self.opt.n_frames_G                
        A_paths = self.A_paths[index % self.n_of_seqs]
        B_paths = self.B_paths[index % self.n_of_seqs]

        if self.opt.isTrain:
            n_gpus = self.opt.n_gpus_gen // self.opt.batchSize         # number of gpus for each batch
            n_frames_per_load = self.opt.n_frames_per_gpu * n_gpus     # number of frames to load into GPUs at one time (for each batch)
            n_frames_per_load = min(self.n_frames_total, n_frames_per_load)
            n_loadings = self.n_frames_total // n_frames_per_load      # how many times are needed to load entire sequence into GPUs 
            n_loadings = min(n_loadings, (len(A_paths)-(tG-1)) // n_frames_per_load)
            n_frames = n_frames_per_load * n_loadings + tG - 1         # overall number of frames to read from the sequence        
            offset_max = max(1, len(A_paths) - n_frames + 1)           # maximum possible index for the first frame
            start_idx = np.random.randint(offset_max)                  # offset for the first frame to load
            if self.opt.debug:
                print("loading %d frames in total, first frame starting at index %d" % (n_frames, start_idx))
        else:
            n_frames = tG
        
        B_img = Image.open(B_paths[0]).convert('RGB')     
        B_size = B_img.size
        params = get_params(self.opt, B_size)          
        transform_scaleA = get_transform(self.opt, params, method=Image.BILINEAR, normalize=False)
        transform_inst = get_transform(self.opt, params, method=Image.NEAREST, normalize=False)
        transform_scaleB = get_transform(self.opt, params, color_aug=True)
        
        for i in range(n_frames):
            if self.opt.isTrain:
                A_path = A_paths[start_idx+i]
                B_path = B_paths[start_idx+i]
                first = i == 0
            else:
                A_path = self.A_paths[0][index + i]
                B_path = self.B_paths[0][index + i]
                first = not hasattr(self, 'min_x')
                
            B_img = Image.open(B_path)
            Ai, Ii = self.get_face_image(A_path, transform_scaleA, transform_inst, B_size, img=B_img, first=first)
            Bi = transform_scaleB(self.crop(B_img)) 
            #Bi = self.get_image(B_path, transform_scaleB)
            A = Ai if i == 0 else torch.cat([A, Ai], dim=0)            
            B = Bi if i == 0 else torch.cat([B, Bi], dim=0)
            I = Ii if i == 0 else torch.cat([I, Ii], dim=0)        

        A_path = os.path.dirname(A_path) + '_' + os.path.basename(A_path)
        return_list = {'A': A, 'B': B, 'inst': I, 'A_paths': A_path}        

        return return_list

    def get_image(self, A_path, transform_scaleA):
        A_img = Image.open(A_path)                
        A_scaled = transform_scaleA(self.crop(A_img))        

        return A_scaled

    def get_face_image(self, label_path, transform_label, transform_inst, size, img=None, first=False, edge_only=False):
        edge_len = 3        
        part_list = [[list(range(0, 17)) + list(range(68, 83)) + [0]], # face
                     [range(17, 22)], # left eyebrow
                     [range(22, 27)], # right eyebrow
                     [[28, 31], range(31, 36), [35, 28]], # nose
                     [[36,37,38,39], [39,40,41,36]], # left eye
                     [[42,43,44,45], [45,46,47,42]], # right eye
                     [range(48, 55), [54,55,56,57,58,59,48]], # mouth
                     [range(60, 65), [64,65,66,67,60]] # tongue
                    ]
        label_list = [1, 2, 2, 3, 4, 4, 5, 6]
        
        points = np.loadtxt(label_path, delimiter=',')
        if first:
            self.crop_valid(points, size)
        
        w, h = size
        # add upper half face            
        pts = points[:17, :].astype(np.int32)
        baseline_y = (pts[0,1] + pts[-1,1]) / 2
        upper_pts = pts[1:-1,:].copy()
        upper_pts[:,1] = baseline_y + (baseline_y-upper_pts[:,1]) * 2 // 3
        points = np.vstack((points, upper_pts[::-1,:]))   

        # labels
        part_labels = np.zeros((h, w), np.uint8)
        for p, edge_list in enumerate(part_list):                
            indices = [item for sublist in edge_list for item in sublist]
            pts = points[indices, :].astype(np.int32)
            cv2.fillPoly(part_labels, pts=[pts], color=label_list[p])

        # edges
        im_edges = np.zeros((h, w), np.uint8)
        e = 1                
        for edge_list in part_list:
            for edge in edge_list:
                im_edge = np.zeros((h, w), np.uint8)
                for i in range(0, max(1, len(edge)-1), edge_len-1):             
                    sub_edge = edge[i:i+edge_len]                                                     
                    x = points[sub_edge, 0]
                    y = points[sub_edge, 1]
                                    
                    curve_x, curve_y = interpPoints(x, y)                    
                    drawEdge(im_edge, curve_x, curve_y)
                    drawEdge(im_edges, curve_x, curve_y)
                                
                if not edge_only:
                    # distance transform map on each part
                    im_edge = cv2.distanceTransform(255-im_edge, cv2.DIST_L1, 3)    
                    im_edge = np.clip((im_edge / 3), 0, 255).astype(np.uint8)
                    im_edge = Image.fromarray(im_edge)
                    #label_tensor[e,:,:] = transform_label(im_edge)
                    if e == 1:                    
                        label_tensor = transform_label(self.crop(im_edge))
                    else:
                        label_tensor = torch.cat([label_tensor, transform_label(self.crop(im_edge))])
                    e += 1

        # canny edge for background
        edges = feature.canny(np.array(img.convert('L')))        
        edges = edges * (part_labels == 0)
        im_edges += (edges * 255).astype(np.uint8)

        # normal edge map
        if edge_only:
            label_tensor = transform_label(Image.fromarray(self.crop(im_edges)))
        else:
            label_tensor = torch.cat([transform_label(Image.fromarray(self.crop(im_edges))), label_tensor])

        inst_tensor = transform_inst(Image.fromarray(self.crop(part_labels.astype(np.uint8)))) * 255.0

        return label_tensor, inst_tensor

    def crop_valid(self, points, size):                
        min_y, max_y = points[:,1].min(), points[:,1].max()
        min_x, max_x = points[:,0].min(), points[:,0].max()
        offset = (max_x-min_x) // 2
        min_y = max(0, min_y - offset*2)
        min_x = max(0, min_x - offset)
        max_x = min(size[0], max_x + offset)
        max_y = min(size[1], max_y + offset)
        self.min_y, self.max_y, self.min_x, self.max_x = int(min_y), int(max_y), int(min_x), int(max_x)        

    def crop(self, img):
        if isinstance(img, np.ndarray):
            return img[self.min_y:self.max_y, self.min_x:self.max_x]
        else:
            return img.crop((self.min_x, self.min_y, self.max_x, self.max_y))

    def update_training_batch(self, ratio): # update the training sequence length to be longer      
        seq_len_max = min(128, self.seq_len_max) - (self.opt.n_frames_G - 1)
        if self.n_frames_total < seq_len_max:
            self.n_frames_total = min(seq_len_max, self.opt.n_frames_total * (2**ratio))
            #self.n_frames_total = min(seq_len_max, self.opt.n_frames_total * (ratio + 1))
            print('--------- Updating training sequence length to %d ---------' % self.n_frames_total)

    def __len__(self):
        if self.opt.isTrain:
            return len(self.A_paths)
        else:
            return len(self.A_paths[0])

    def name(self):
        return 'FaceDataset'