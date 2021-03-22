import cv2

from common.CamPlus import CamPlus
from common.Model import Model, Camera
from common.Blob import Blob


class SimpleBlob(Model):
    name = "Model_SimpleBlob"

    BAR = [("minThresh", 30, 255),
           ("maxThresh", 255, 255),
           ("fByArea", 1, 1),  # True/False
           ("minArea", 25, 300),  # 5 x 5 params.maxArea = 3500
           ("ByCircularity", 1, 1),  # True/False
           ("minCircularity", 15, 100),
           ("ByConvexity", 1, 1),  # True/False
           ("minConvexity", 80, 100),
           ("ByInertia", 1, 1),  # True/False
           ("minInertia", 1, 100)
           ]

    def __init__(self):
        super().__init__()

        self.message = "change trackbar value and key(t) to renew Simple Blob detect param"
        self.simple_blob_detector = None

    def init_bar(self, image):
        # Setup SimpleBlobDetector parameters
        params = cv2.SimpleBlobDetector_Params()

        # Change thresholds
        params.minThreshold = float(self.trackbar.value[0])   # 30
        params.maxThreshold = float(self.trackbar.value[1])   # 255

        # Filter by Area
        params.filterByArea = self.trackbar.value[2]    # True
        params.minArea = float(self.trackbar.value[3])   # 25  # 5 x 5
        # params.maxArea = 3500

        # Filter by Circularity
        params.filterByCircularity = self.trackbar.value[4]    # True
        params.minCircularity = self.trackbar.value[5] / 100    # 0.15

        # Filter by Convexity
        params.filterByConvexity = self.trackbar.value[6]    # True
        params.minConvexity = self.trackbar.value[7] / 100    # 0.8

        # Filter by Inertia
        params.filterByInertia = self.trackbar.value[8]    # True
        params.minInertiaRatio = self.trackbar.value[9] / 100    # 0.01

        self.simple_blob_detector = cv2.SimpleBlobDetector_create(params)

    def detect(self, image):
        self.init_bar(image)

        blobs = []
        roi = self._init_roi(image)

        key_points = self.simple_blob_detector.detect(roi)
        for i, point in enumerate(key_points):
            center_x = point.pt[0]
            center_y = point.pt[1]

            x = center_x - point.size / 2
            y = center_y - point.size / 2
            w = point.size
            h = point.size
            rect = self._frame_rect((x, y, w, h))

            blob = Blob(f"{self.name}:{str(i)}", rect)
            blobs.append(blob)

        self.blobs.track_blobs(blobs)
        self.fps.update()


if __name__ == '__main__':
    cam = Camera(device=0).start()
    cam_plus = CamPlus(camera=cam)
    model = SimpleBlob()

    # test Model instance
    cam_plus.register_models(model)
    cam_plus.test()
