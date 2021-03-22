import cv2

from common.CamPlus import CamPlus
from common.Model import Model
from common.Camera import Camera
from common.Blob import Blob

import pyzbar.pyzbar as barcode


class BarCode(Model):
    name = "Model_BarCode"
    num = 0

    def __init__(self):
        super().__init__()

        self.bool_code = True
        self.code_data, self.code_points = None, None

        self.message = "Focus on BarCode"

    def detect(self, image):
        blobs = []
        image = image if len(image.shape) == 2 else cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        roi = self._init_roi(image)

        # self.code_data, self.code_points = None, None   # clear code for every detect
        codes = barcode.decode(roi)
        for code in codes:

            # example of code code reference number
            if str(code.data) == "b'http://weixin.qq.com/q/02iIyARwEba3e10000g03o'":
                self.code_data = "99"
            else:
                self.code_data = code.data

            self.code_points = self._frame_polygon(code.polygon)
            rect = (code.rect.left, code.rect.top, code.rect.width, code.rect.height)
            rect = self._frame_rect(rect)

            blob = Blob(f"{self.name}:{self.code_data}", rect, fps=self.fps.fps())
            blobs.append(blob)

        self.blobs.track_blobs(blobs)
        self.fps.update()
    #
    # def draw_on(self, image):
    #     super(BarCode, self).draw_on(image)
    #     if self.bool_code and self.code_points is not None:
    #         if len(self.code_points) > 4:
    #             hull = cv2.convexHull(np.array([point for point in self.code_points], dtype=int))
    #             hull = list(map(tuple, np.squeeze(hull)))
    #         else:
    #             hull = self.code_points
    #
    #         # Number of points in the convex hull
    #         n = len(hull)
    #
    #         # Draw the convex hull
    #         for j in range(0, n):
    #             cv2.line(image, hull[j], hull[(j + 1) % n], (255, 0, 0), 1)
    #
    #         # # text = "{} ({})".format('QR', )
    #         # cv2.putText(image, f'QR ({str(self.code_data)})',
    #         #             (hull[0][0], hull[0][1] - 10),
    #         #             cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
    #
    #     return image

    def clear(self):
        # clear detected Blobs
        super(BarCode, self).clear()

        # clear bar code initial data
        self.code_data, self.code_points = None, None
        print(f"Model {self.name}: bar code data cleared")


if __name__ == '__main__':
    # camera instance, started before assigning to Model
    cam = Camera(device=0).start()

    cam_plus = CamPlus(camera=cam)
    # assigning camera to Model
    model = BarCode()

    # test Model instance
    cam_plus.register_models(model)

    # test Model instance
    cam_plus.test()
