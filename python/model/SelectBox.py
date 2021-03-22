import cv2
import numpy as np
from common.Model import Model, Camera
from common.Blob import Blob


class MultiTracker(Model):
    """ Create MultiTracker object
        There are two ways you can initialize MultiTracker
        1. tracker = cv2.MultiTracker("CSRT")
            All the trackers added to this MultiTracker
            will use CSRT algorithm as default
        2. tracker = cv2.MultiTracker()
            No default algorithm specified """

    name = "Model_MultiTracker"
    num = 0

    # All the 8 tracker types
    tracker_types = ['BOOSTING',
                     'MIL',
                     'KCF',
                     'TLD',
                     'MEDIANFLOW',
                     'GOTURN',
                     'MOSSE',
                     'CSRT']

    BAR = [("Track Type", 7, 7)]  # default 'CSRT'

    def __init__(self):
        super().__init__()

        self.boolean_box = False
        self.box = None  # Selected box

        # self._tracker = None
        # self._tracker_type = 7  # 'CSRT'
        self.message = "Mouse Drag and Drop to select area to trace"

        # Initialize MultiTracker
        self.multi_tracker = cv2.MultiTracker_create()

    def init_track(self):
        # Create a tracker based on tracker name
        if self.trackbar.value[0] == 0:
            track_type = cv2.TrackerBoosting_create()
        elif self.trackbar.value[0] == 1:
            track_type = cv2.TrackerMIL_create()
        elif self.trackbar.value[0] == 2:
            track_type = cv2.TrackerKCF_create()
        elif self.trackbar.value[0] == 3:
            track_type = cv2.TrackerTLD_create()
        elif self.trackbar.value[0] == 4:
            track_type = cv2.TrackerMedianFlow_create()
        elif self.trackbar.value[0] == 5:
            track_type = cv2.TrackerGOTURN_create()
        elif self.trackbar.value[0] == 6:
            track_type = cv2.TrackerMOSSE_create()
        elif self.trackbar.value[0] == 7:
            track_type = cv2.TrackerCSRT_create()
        else:
            print('Incorrect tracker name, Available trackers are:')
            for types in MultiTracker.tracker_types:
                print(types)
            track_type = None

        return track_type

    def detect(self, image):
        blobs = []
        roi = self._init_roi(image)

        if self.boolean_box:  # in CVision, mouse_on, middle-button down set True
            print("MultiTrack box selected")
            self.multi_tracker.add(self.init_track(), roi, self.box)
            self.boolean_box = False

        try:
            success, boxes = self.multi_tracker.update(roi)
            # draw tracked objects
            for i, box in enumerate(boxes):
                # roi_rect = (int(box[0]), int(box[1]), int(box[2]), int(box[3]))
                rect = self._frame_rect(box)

                blob = Blob(f"{self.name}:{str(i)}", rect, fps=self.fps.fps())
                blobs.append(blob)

        except Exception as e:
            print(f"model {self.name}: tracking exit Exception: {e}")

        self.blobs.track_blobs(blobs)
        self.fps.update()

    def mouse_on(self, event, x, y, flags, camera):
        super(MultiTracker, self).mouse_on(event, x, y, flags, camera)

        if event == cv2.EVENT_LBUTTONUP:
            # camera's RECT is inside model's ROI
            x, y, w, h = camera.rect
            if self.inside(self.roi, camera.rect) and (w > 0 and h > 0):
                self.box = (x - self.roi[0], y - self.roi[1], w, h)
                self.boolean_box = True

    def clear(self):
        super(MultiTracker, self).clear()

        print(f"Model {self.name}: multi-tracker re-initiated")
        self.multi_tracker = cv2.MultiTracker_create()


class CamShift(MultiTracker):
    """ So we normally pass the histogram back projected image and initial target location.
    When the object moves, obviously the movement is reflected in histogram back projected
    image. As a result, meanshift algorithm moves our window to the new location with maximum
    density """

    name = "Model_CamShift"
    num = 0

    def __init__(self):  # MeanShift or CamShift(Continuously Adaptive MeanShift)
        super().__init__()

        self.shift = "Cam"  # "Cam" | "Mean"

        self.boxes = []  # Selected boxes
        self.boxes_hist = []  # Selected boxes

        # Setup the termination criteria, either 10 iteration or move by at least 1 pt
        self.term_crit = (cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_COUNT, 10, 1)

    def detect(self, image):
        blobs = []
        image = image if len(image.shape) == 3 else cv2.cvtColor(image, cv2.COLOR_GRAY2BGR)
        roi = self._init_roi(image)

        if self.boolean_box:  # in CVision, mouse_on, middle-button down set True
            self.boxes.append(self.box)
            x, y, w, h = self.box
            box = roi[y:y + h, x:x + w]
            box_hsv = cv2.cvtColor(box, cv2.COLOR_BGR2HSV)  # box -> roi
            mask = cv2.inRange(box_hsv, np.array((0., 60., 32.)), np.array((180., 255., 255.)))
            box_hist = cv2.calcHist([box_hsv], [0], mask, [180], [0, 180])
            cv2.normalize(box_hist, box_hist, 0, 255, cv2.NORM_MINMAX)
            self.boxes_hist.append(box_hist)

            self.boolean_box = False

        try:
            # draw tracked objects
            i = 0
            for box, hist in zip(self.boxes, self.boxes_hist):
                hsv = cv2.cvtColor(roi, cv2.COLOR_BGR2HSV)
                dst = cv2.calcBackProject([hsv], [0], hist, [0, 180], 1)

                if self.shift == "mean":  # mean shift to get the new location
                    ret, box = cv2.meanShift(dst, box, self.term_crit)
                else:  # Cam shift to get the new location
                    ret, box = cv2.CamShift(dst, box, self.term_crit)

                # Draw it on image
                rect = self._frame_rect(box)

                blob = Blob(f"{self.name}:{str(i)}", rect, fps=self.fps.fps())
                blobs.append(blob)

                i += 1

        except Exception as e:
            print(f"model {self.name}: tracking exit Exception: {e}")

        self.blobs.track_blobs(blobs)
        self.fps.update()

    def clear(self):
        super(CamShift, self).clear()

        # clear selected tracing boxes
        self.boxes.clear()
        self.boxes_hist.clear()


if __name__ == '__main__':
    cam = Camera(device=0).start()
    model = CamShift()

    cam.register_models(model)

    # test Model instance
    cam.test()
