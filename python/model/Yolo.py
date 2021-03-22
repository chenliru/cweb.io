import cv2
import numpy as np

from common.CamPlus import CamPlus
from common.Model import Model, Camera
from common.Blob import Blob

from common.Common import CWD


class Yolo(Model):
    name = "Model_Yolo"
    num = 0

    # derive the paths to the YOLO weights and model configuration
    config = "yolo/yolov3.cfg"
    weights = "yolo/yolov3.weights"
    confidence = 0.7  # confidence, default=0.5

    # initialize the list of class labels MobileNet SSD was trained to
    # detect, then generate a set of bounding box colors for each class
    with open(f"{CWD}/data/models/yolo/coco.names") as coco:
        LABELS = coco.read().strip().split("\n")

    # load our serialized model from disk
    def __init__(self,
                 target=("person",)
                 ):
        super().__init__()
        self.name = Yolo.name
        self.target = target

        # load YOLO object detector trained on COCO data (80 classes)
        self.net = cv2.dnn.readNetFromDarknet(f"{self.path.models_path}/{Yolo.config}",
                                              f"{self.path.models_path}/{Yolo.weights}")
        self.net.setPreferableBackend(cv2.dnn.DNN_BACKEND_DEFAULT)
        self.net.setPreferableTarget(cv2.dnn.DNN_TARGET_CPU)
        self.confidence = Yolo.confidence

    def detect(self, image):
        blobs = []

        # grab the frame dimensions and convert it to a blob
        image = image if len(image.shape) == 3 else cv2.cvtColor(image, cv2.COLOR_GRAY2BGR)
        roi = self._init_roi(image)
        h, w = roi.shape[:2]

        # construct a blob from the input image and then perform a forward
        # pass of the YOLO object detector, giving us our bounding boxes and
        # associated probabilities
        blob = cv2.dnn.blobFromImage(roi, 1 / 255.0, (416, 416), swapRB=True, crop=False)
        self.net.setInput(blob)

        # determine only the *output* layer names that we need from YOLO
        ln = [self.net.getLayerNames()[i[0] - 1] for i in self.net.getUnconnectedOutLayers()]
        outputs = self.net.forward(ln)

        # loop over each of the layer outputs
        for output in outputs:
            # loop over each of the detections
            for box in output:
                # it may be obvious which boxes are referring to the same object, sorted them by their scores
                # extract the class ID and confidence (i.e., probability) of the current object detection
                scores = box[5:]
                idx = np.argmax(scores)
                confidence = scores[idx]

                # filter out weak predictions by ensuring the detected probability is greater than
                # the minimum probability
                if confidence > self.confidence:
                    ######################################################################
                    # # Uncomment following 2 lines if only find objects in list
                    # if len(self.target) > 0 and self.labels[idx] not in self.target:
                    #     continue
                    #######################################################################

                    # scale the bounding box coordinates back relative to the size of the image,
                    # keeping in mind that YOLO actually returns the center (x, y)-coordinates of the bounding
                    # box followed by the boxes' width and height
                    center_x, center_y, w, h = (box[0:4] * np.array([w, h, w, h])).astype("int")

                    # use the center (x, y)-coordinates to derive the top and and left corner of the bounding box
                    x = int(center_x - (w / 2))
                    y = int(center_y - (h / 2))
                    roi_rect = (x, y, w, h)
                    rect = self._frame_rect(roi_rect)
                    roi_line = ((x + w // 2, y), (x + w // 2, y + h))
                    line = self._frame_line(roi_line)
                    label = f"{Yolo.LABELS[int(idx)]}:{str(idx)} {confidence * 100:.2f}%"

                    blob = Blob(label, rect, line=line, fps=self.fps.fps())
                    blobs.append(blob)

        self.blobs.track_blobs(blobs)
        self.fps.update()


if __name__ == '__main__':
    cam = Camera(device=1, sync=False).start()
    cam_plus = CamPlus(camera=cam)
    model = Yolo()

    # test Model instance
    cam_plus.register_models(model)
    cam_plus.test()
