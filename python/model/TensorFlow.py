import cv2
import numpy as np

from common.CamPlus import CamPlus
from common.Model import Model, Camera
from common.Blob import Blob


class Caffe(Model):
    name = "Model_Caffe"

    # Caffe 'deploy' prototxt file and Caffe pre-trained model
    # load our serialized model from disk
    proto_txt = "MobileNetSSD/MobileNetSSD_deploy.prototxt"
    model = "MobileNetSSD/MobileNetSSD_deploy.caffemodel"
    confidence = 0.5  # confidence, default=0.2

    def __init__(self,
                 target=("person",)
                 ):

        # python3 super function
        super().__init__()

        self.target = target

        self.net = cv2.dnn.readNetFromCaffe(f"{self.path.models_path}/{Caffe.proto_txt}",
                                            f"{self.path.models_path}/{Caffe.model}")
        self.net.setPreferableBackend(cv2.dnn.DNN_BACKEND_DEFAULT)
        self.net.setPreferableTarget(cv2.dnn.DNN_TARGET_CPU)
        self.confidence = Caffe.confidence

        self.labels = ["background", "aeroplane", "bicycle", "bird", "boat",
                       "bottle", "bus", "car", "cat", "chair", "cow", "diningtable",
                       "dog", "horse", "motorbike", "person", "pottedplant", "sheep",
                       "sofa", "train", "tvmonitor"]

    def net_blobs(self, h, w):
        blobs = []

        outputs = self.net.forward()

        # loop over the detections
        for i in np.arange(0, outputs.shape[2]):
            # extract the confidence (i.e., probability) associated with the prediction
            confidence = outputs[0, 0, i, 2]
            # filter out weak detections by ensuring the `confidence` is
            # greater than the minimum confidence
            if confidence > self.confidence:
                # extract the index of the class label from the
                # `detections`, then compute the (x, y)-coordinates of
                # the bounding box for the object
                idx = int(outputs[0, 0, i, 1])
                #
                ######################################################################
                # # Uncomment following 2 lines if only find objects in list
                # if len(self.target) > 0 and self.labels[idx] not in self.target:
                #     continue
                #######################################################################
                start_x, start_y, end_x, end_y = (outputs[0, 0, i, 3:7] * np.array([w, h, w, h])).astype("int")
                roi_rect = (start_x, start_y, end_x - start_x, end_y - start_y)
                roi_line = ((start_x // 2 + end_x // 2, start_y), (start_x // 2 + start_y // 2, end_y))
                rect = self._frame_rect(roi_rect)
                line = self._frame_line(roi_line)
                label = f"{self.labels[idx]}:{str(i)} {confidence * 100:.2f}%"

                blob = Blob(label, rect, line=line, fps=self.fps.fps())
                blobs.append(blob)

        return blobs

    def detect(self, image):
        # grab the frame dimensions and convert it to a blob
        image = image if len(image.shape) == 3 else cv2.cvtColor(image, cv2.COLOR_GRAY2BGR)
        roi = self._init_roi(image)
        h, w = roi.shape[:2]

        # pass the blob through the webcam and obtain the detections and predictions
        blob = cv2.dnn.blobFromImage(roi, 0.007843, (300, 300), 127.5)
        self.net.setInput(blob)
        blobs = self.net_blobs(h, w)

        self.blobs.track_blobs(blobs)
        self.fps.update()


class Tensorflow(Caffe):
    name = "Model_Tensorflow"
    num = 0

    # load our serialized model from disk
    model = "MobileNetSSD_V2/frozen_inference_graph.pb"
    pbtxt = "MobileNetSSD_V2/ssd_mobilenet_v2_coco_2018_03_29.pbtxt"
    confidence = 0.5  # confidence, default=0.2

    def __init__(self,
                 target=("person",)
                 ):
        # python 3 super function
        super().__init__(target=target)

        self.name = Tensorflow.name

        self.net = cv2.dnn.readNetFromTensorflow(f"{self.path.models_path}/{Tensorflow.model}",
                                                 f"{self.path.models_path}/{Tensorflow.pbtxt}")
        self.confidence = Tensorflow.confidence
        self.net.setPreferableBackend(cv2.dnn.DNN_BACKEND_DEFAULT)
        self.net.setPreferableTarget(cv2.dnn.DNN_TARGET_CPU)

        # pre_trained classes in the model
        self.labels = {0: 'background',
                       1: 'person', 2: 'bicycle', 3: 'car', 4: 'motorcycle', 5: 'airplane', 6: 'bus',
                       7: 'train', 8: 'truck', 9: 'boat', 10: 'traffic light', 11: 'fire hydrant',
                       13: 'stop sign', 14: 'parking meter', 15: 'bench', 16: 'bird', 17: 'cat',
                       18: 'dog', 19: 'horse', 20: 'sheep', 21: 'cow', 22: 'elephant', 23: 'bear',
                       24: 'zebra', 25: 'giraffe', 27: 'backpack', 28: 'umbrella', 31: 'handbag',
                       32: 'tie', 33: 'suitcase', 34: 'frisbee', 35: 'skis', 36: 'snowboard',
                       37: 'sports footballer', 38: 'kite', 39: 'baseball bat', 40: 'baseball glove',
                       41: 'skateboard', 42: 'surfboard', 43: 'tennis racket', 44: 'bottle',
                       46: 'wine glass', 47: 'cup', 48: 'fork', 49: 'knife', 50: 'spoon',
                       51: 'bowl', 52: 'banana', 53: 'apple', 54: 'sandwich', 55: 'orange',
                       56: 'broccoli', 57: 'carrot', 58: 'hot dog', 59: 'pizza', 60: 'donut',
                       61: 'cake', 62: 'chair', 63: 'couch', 64: 'potted plant', 65: 'bed',
                       67: 'dining table', 70: 'toilet', 72: 'tv', 73: 'laptop', 74: 'mouse',
                       75: 'remote', 76: 'keyboard', 77: 'cell phone', 78: 'microwave', 79: 'oven',
                       80: 'toaster', 81: 'sink', 82: 'refrigerator', 84: 'book', 85: 'clock',
                       86: 'vase', 87: 'scissors', 88: 'teddy bear', 89: 'hair drier', 90: 'toothbrush'}

    def detect(self, image):
        # grab the frame dimensions and convert it to a blob
        image = image if len(image.shape) == 3 else cv2.cvtColor(image, cv2.COLOR_GRAY2BGR)
        roi = self._init_roi(image)
        h, w = roi.shape[:2]

        # pass the blob through the webcam and obtain the detections and predictions
        blob = cv2.dnn.blobFromImage(roi, size=(300, 300), swapRB=True)
        self.net.setInput(blob)
        blobs = self.net_blobs(h, w)

        self.blobs.track_blobs(blobs)
        self.fps.update()


if __name__ == '__main__':
    cam = Camera(device=1, sync=False).start()
    cam_plus = CamPlus(camera=cam)
    model = Caffe()

    # test Model instance
    cam_plus.register_models(model)
    cam_plus.test()
