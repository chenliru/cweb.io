import cv2
import numpy as np

from common.CamPlus import CamPlus
from common.Model import Model, Camera
from common.Blob import Blob


class GoodFeature(Model):
    """
    OpenCV has a function, cv2.goodFeaturesToTrack(). It finds N strongest corners in the image by Shi-Tomasi method
    (or Harris Corner Detection, if you specify it). As usual, image should be a grayscale image.
    """
    name = "Model_GoodFeature"
    num = 0

    BAR = [("max_corners", 8, 255),  # specify number of corners you want to find
           # the minimum quality of corner below which everyone is rejected
           ("quality_level", 99, 100),  # bar value: 99; quality level: (1 - 99*0.01) = 0.01, a value between 0-1
           ("min_distance", 10, 255),  # provide the minimum euclidean distance between corners detected
           ("block_size", 10, 255),
           ("bool_harris_detector", 0, 1)  # 0 == False, 1 == True
           ]

    def __init__(self):
        super().__init__()
        self.message = "finds N strongest corners in the image"

        # Setup GoodFeature parameters
        self.maxCorners = self.trackbar.value[0]
        self.qualityLevel = self.trackbar.value[1]
        self.minDistance = self.trackbar.value[2]
        self.blockSize = self.trackbar.value[3]
        self.useHarrisDetector = self.trackbar.value[4]

    def detect(self, image):
        blobs = []
        image = image if len(image.shape) == 2 else cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        roi = self._init_roi(image)

        key_points = cv2.goodFeaturesToTrack(roi,
                                             maxCorners=self.trackbar.value[0],
                                             qualityLevel=(1 - 0.01 * self.trackbar.value[1]),
                                             minDistance=self.trackbar.value[2],
                                             blockSize=self.trackbar.value[3],
                                             useHarrisDetector=self.trackbar.value[4],
                                             k=0.04)

        if key_points is not None:
            key_points = np.int0(key_points)

            points = self.point_rect(key_points)
            for i, rect in enumerate(points):
                rect = self._frame_rect(rect)
                blob = Blob(f"{self.name}:{str(i)}", rect, fps=self.fps.fps())
                blobs.append(blob)

        self.blobs.track_blobs(blobs)
        self.fps.update()


if __name__ == '__main__':
    cam = Camera(device=0).start()
    cam_plus = CamPlus(camera=cam)
    model = GoodFeature()

    # test Model instance
    cam_plus.register_models(model)
    cam_plus.test()
