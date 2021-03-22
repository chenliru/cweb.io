import cv2

from common.CamPlus import CamPlus
from common.Common import CWD
from common.Model import Model, Camera
from common.Blob import Blob


class HOGDescriptor(Model):
    # detect upright people in images using HOG features
    name = "Model_HOGDescriptor"

    def __init__(self):
        super().__init__()

        self.hog = cv2.HOGDescriptor()
        self.hog.setSVMDetector(cv2.HOGDescriptor_getDefaultPeopleDetector())

    def detect(self, image):
        blobs = []
        image = image if len(image.shape) == 3 else cv2.cvtColor(image, cv2.COLOR_GRAY2BGR)
        roi = self._init_roi(image)

        roi_rectangles, w = self.hog.detectMultiScale(roi, winStride=(8, 8), padding=(32, 32), scale=1.05)
        for i, roi_rect in enumerate(roi_rectangles):
            rect = self._frame_rect(roi_rect)
            blob = Blob(f"{self.name}:{str(i)}", rect, fps=self.fps.fps())
            blobs.append(blob)

        self.blobs.track_blobs(blobs)
        self.fps.update()


if __name__ == '__main__':
    video = ["airport.mp4", "weco.mp4", "count1.mp4", "overpass.mp4", "cars.mp4", "walk.avi", "run.mp4"]
    v0 = f"{CWD}//data//Sample//videos//{video[5]}"

    cam = Camera(device=v0).start()
    cam_plus = CamPlus(camera=cam)
    model = HOGDescriptor()

    # test Model instance
    cam_plus.register_models(model)
    cam_plus.test()
