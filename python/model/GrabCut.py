import cv2

from common.CamPlus import CamPlus
from common.Model import Model
from common.Camera import Camera
# from common.Blob import Blob

import numpy as np


class GrabCut(Model):
    name = "Model_GrabCut"
    num = 0

    BLUE = [255, 0, 0]  # rectangle color
    RED = [0, 0, 255]  # PR BG
    GREEN = [0, 255, 0]  # PR FG
    BLACK = [0, 0, 0]  # sure BG
    WHITE = [255, 255, 255]  # sure FG

    DRAW_BG = {'color': BLACK, 'val': 0}
    DRAW_FG = {'color': WHITE, 'val': 1}
    DRAW_PR_BG = {'color': RED, 'val': 2}
    DRAW_PR_FG = {'color': GREEN, 'val': 3}

    # setting up flags
    rect = (0, 0, 1, 1)
    drawing = False  # flag for drawing curves

    rect_or_mask = 0  # flag for selecting rect or mask mode
    value = DRAW_FG  # drawing initialized to FG
    thickness = 3  # brush thickness

    def __init__(self):
        super().__init__()

        self.image = self.mask = self.output = None
        self.boolean_mask = True

        self.message = "Draw rectangle, " \
                       "key 0: mark background regions" \
                       "key 1: mark foreground regions" \
                       "key 2: probable background regions" \
                       "key 3: probable foreground regions" \
                       "press the key 'n' a few times until no further change"

    def init_mask(self):
        self.mask = np.zeros(self.image.shape[:2], dtype=np.uint8)  # mask initialized to PR_BG
        self.output = np.zeros(self.image.shape, np.uint8)  # output image to be shown
        self.rect = [0, 0, 1, 1]
        cv2.namedWindow('output')

        self.boolean_mask = False

    def detect(self, image):
        blobs = []
        roi = self._init_roi(image)

        self.image = image.copy()  # a copy of original image
        if self.boolean_mask:
            self.init_mask()

        mask2 = np.where((self.mask == 1) + (self.mask == 3), 255, 0).astype('uint8')
        self.output = cv2.bitwise_and(self.image, self.image, mask=mask2)

        self.fps.update()

    def mouse_on(self, event, x, y, flags, camera):
        super(GrabCut, self).mouse_on(event, x, y, flags, camera)
        # draw touch up curves
        if event == cv2.EVENT_LBUTTONUP:
            self.rect = camera.rect
            self.rect_or_mask = 0
            print("press the key 'n' a few times until no further change \n "
                  "key(0, 1, 2, 3) for BackGround/ForeGround selection ")
        elif event == cv2.EVENT_MOUSEMOVE and flags == cv2.EVENT_FLAG_CTRLKEY:
            self.drawing = True
        else:
            self.drawing = False

    def key_on(self, key, camera):
        super(GrabCut, self).key_on(key, camera)

        if key == ord('0'):  # BG drawing
            print("press key(CTRL) mark background regions \n")
            self.value = self.DRAW_BG
        elif key == ord('1'):  # FG drawing
            print("press key(CTRL) mark foreground regions \n")
            self.value = self.DRAW_FG
        elif key == ord('2'):  # PR_BG drawing
            print("press key(CTRL) mark probable background regions \n")
            self.value = self.DRAW_PR_BG
        elif key == ord('3'):  # PR_FG drawing
            print("press key(CTRL) mark probable foreground regions \n")
            self.value = self.DRAW_PR_FG
        elif key == ord('n'):  # segment the image
            print(""" For finer touch ups, mark foreground and background after pressing keys 0-3
                      and again press 'n' \n""")
            try:
                if self.rect_or_mask == 0:  # grab cut with rect
                    bg_model = np.zeros((1, 65), np.float64)
                    fg_model = np.zeros((1, 65), np.float64)
                    cv2.grabCut(self.image, self.mask, self.rect, bg_model, fg_model, 1, cv2.GC_INIT_WITH_RECT)
                    self.rect_or_mask = 1
                elif self.rect_or_mask == 1:  # grab cut with mask
                    bg_model = np.zeros((1, 65), np.float64)
                    fg_model = np.zeros((1, 65), np.float64)
                    cv2.grabCut(self.image, self.mask, self.rect, bg_model, fg_model, 1, cv2.GC_INIT_WITH_MASK)

            except Exception as e:
                print(f"Key:{key}, Model {self.name}: GrabCut Operation exit exception: {e}")
                import traceback
                traceback.print_exc()
        elif key == ord('s') or key == ord(' '):
            # save grab cut output
            camera.save_image(self.output)

    def draw_on(self, image, camera):
        image = super(GrabCut, self).draw_on(image, camera)
        if self.drawing:
            cv2.circle(camera.image, (camera.x_mouse, camera.y_mouse), self.thickness, self.value['color'], -1)
            cv2.circle(self.mask, (camera.x_mouse, camera.y_mouse), self.thickness, self.value['val'], -1)
        cv2.imshow('output', self.output)
        return image

    def clear(self):
        # clear detected Blobs
        super(GrabCut, self).clear()

        self.rect = (0, 0, 1, 1)
        self.drawing = False
        self.rect_or_mask = 1
        self.value = self.DRAW_FG
        self.boolean_mask = True

        print(f"Model {self.name}: bar code data cleared")


if __name__ == '__main__':
    # camera instance, started before assigning to Model
    cam = Camera(device=1).start()
    cam_plus = CamPlus(camera=cam)
    # assigning camera to Model
    model = GrabCut()

    # test Model instance
    cam_plus.register_models(model)

    # test Model instance
    cam_plus.test()
