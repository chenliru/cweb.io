import cv2
import numpy as np
import xml.etree.ElementTree as Et

from common.CamPlus import CamPlus
from common.Camera import Camera
from python.model.Contour import Diff2frame


class Color(Diff2frame):
    name = "Model_Color"
    num = 0

    def __init__(self):
        super().__init__()

        self.message = "mouse point on selected color and click mouse left button to trace"

        # initiate hsv_ranges
        self.hsv = (0, 0, 0)
        self.hsv_ranges = []
        self.init_hsv()  # init selected hsv color from model.xml

    def init_hsv(self):
        print("[INFO]model {}: initiate HSV range...".format(self.name))

        self.hsv_ranges.clear()
        tree = Et.parse(f'{self.path.config_path}/model.xml')
        root = tree.getroot()
        for model_branch in root.findall('model'):
            if model_branch.get('name') == self.name:
                for color in model_branch.findall('color'):
                    print(color.tag, color.attrib)
                    h = int(color.attrib['h'])
                    s = int(color.attrib['s'])
                    v = int(color.attrib['v'])

                    self.hsv_range(h, s, v)

    def hsv_range(self, h, s, v):
        lower_h = 0 if h - 10 < 0 else h - 10
        lower_s = 0 if s - 30 < 0 else s - 30
        lower_v = 0 if v - 50 < 0 else v - 50

        upper_h = 179 if h + 10 > 179 else h + 10
        upper_s = 255 if s + 30 > 255 else s + 30
        upper_v = 255 if v + 50 > 255 else v + 50

        lower = np.array([lower_h, lower_s, lower_v])
        upper = np.array([upper_h, upper_s, upper_v])

        self.hsv_ranges.append((lower, upper))

        return lower, upper

    def write_hsv(self):
        with self.xml_lock:
            tree = Et.parse(f'{self.path.config_path}/model.xml')
            root = tree.getroot()
            for model_branch in root.findall('model'):
                if model_branch.get('name') == self.name:
                    c = Et.SubElement(Et.Element("model"), 'color',
                                      attrib={"h": str(self.hsv[0]),  # in CVision,
                                              "s": str(self.hsv[1]),  # hsv value of image in mouse position
                                              "v": str(self.hsv[2])})
                    Et.dump(c)
                    model_branch.append(c)
                    tree.write(f'{self.path.config_path}//model.xml')

    def detect(self, image):
        blobs = []
        image = image if len(image.shape) == 3 else cv2.cvtColor(image, cv2.COLOR_GRAY2BGR)
        roi = self._init_roi(image)

        blurred = cv2.GaussianBlur(roi, (3, 3), 0)
        # In HSV, it is more easier to represent a color than RGB color-space
        hsv = cv2.cvtColor(blurred, cv2.COLOR_BGR2HSV)

        for hsv_range in self.hsv_ranges:
            thresh_roi = cv2.inRange(hsv, hsv_range[0], hsv_range[1])
            blobs += self.contour_blobs(thresh_roi)

        self.blobs.track_blobs(blobs)
        self.fps.update()

    def clear(self):
        super(Color, self).clear()

        # clear selected color
        self.hsv_ranges.clear()
        with self.xml_lock:
            tree = Et.parse(f'{self.path.config_path}/model.xml')
            root = tree.getroot()
            for model_branch in root.findall('model'):
                if model_branch.get('name') == self.name:
                    for color in model_branch.findall('color'):
                        model_branch.remove(color)

            tree.write(f"{self.path.config_path}/model.xml")

        print(f"Model {self.name}: HSV data in model.xml cleared")

    def mouse_on(self, event, x, y, flags, camera):
        super(Color, self).mouse_on(event, x, y, flags, camera)

        # camera's mouse just click action (not moving)
        if event == cv2.EVENT_LBUTTONDOWN:
            camera.x_start, camera.y_start = x, y
        elif event == cv2.EVENT_LBUTTONUP:
            if (camera.x_start, camera.y_start) == (x, y):
                bgr = camera.image[y, x]
                # Convert the BGR pixel into HSV formats, H: 0 to 179 S: 0 to 255 V: 0 to 255
                self.hsv = cv2.cvtColor(np.uint8([[bgr]]), cv2.COLOR_BGR2HSV)[0][0]
                self.write_hsv()  # add new color to model.xml
                self.init_hsv()


if __name__ == '__main__':
    cam = Camera(device=0).start()
    cam_plus = CamPlus(camera=cam)
    model = Color()

    # test Model instance
    cam_plus.register_models(model)
    cam_plus.test()
