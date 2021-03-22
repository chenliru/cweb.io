import cv2

from common.CamPlus import CamPlus
from common.Model import Model, Camera
from common.Common import CWD
from common.Blob import Blob


class Diff2frame(Model):
    name = "Model_Diff2frame"
    num = 0

    BAR = [("thresh", 30, 255)]

    def __init__(self):
        super().__init__()
        self.message = "trace moving objects by compare 2 continuous images"

        self.roi_diff0 = self.roi_diff1 = self.roi_diff2 = None

    # @staticmethod
    def contours(self, image):
        # It would be better to apply morphological opening to the result to remove the noises
        # (1), Opening ...
        morphology_image = cv2.morphologyEx(image, cv2.MORPH_OPEN, (3, 3))
        # (2), Closing ...
        morphology_image = cv2.morphologyEx(morphology_image, cv2.MORPH_CLOSE, (3, 3))

        # (3), The function used is cv2.threshold. First argument is the source
        # image, which should be a grayscale image. Second argument is the threshold value which is used to classify
        # the pixel values. Third argument is the maxVal which represents the value to be given if pixel value is
        # more than (sometimes less than) the threshold value. OpenCV provides different styles of thresholding and
        # it is decided by the fourth parameter of the function.

        # Otsu binarization automatically calculates a threshold value from image histogram for a bimodal image
        # ret, image = cv2.threshold(morphology_image, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
        ret, image = cv2.threshold(morphology_image, self.trackbar.value[0], 255, cv2.THRESH_BINARY)

        # (4), The basic idea of erosion is just like soil erosion only,
        # it erodes away the boundaries of foreground object (Always try to keep foreground in white).
        erode_image = cv2.erode(image, (3, 3))

        # (5),  It is just opposite of erosion. Here, a pixel element is ‘1’ if at least one pixel under the
        # kernel is ‘1’. So it increases the white region in the image or size of foreground object increases.
        # Normally, in cases like noise removal, erosion is followed by dilation. Because, erosion removes white noises,
        # but it also shrinks our object. So we dilate it.
        dilate_image = cv2.dilate(erode_image, (3, 3))
        dilate_image = cv2.dilate(dilate_image, (3, 3))

        contours, hierarchy = cv2.findContours(dilate_image, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        return contours, hierarchy

    @staticmethod
    def contour(contour, w):
        # if the contour is too small, ignore it. min-area, type=int, default=100
        area = cv2.contourArea(contour)

        # solidity: float(area) / cv2.contourArea(hull)
        # if the ratio of contour area to its convex hull area is too small, ignore it
        hull = cv2.convexHull(contour)
        hull_area = cv2.contourArea(hull)
        solidity = -1 if hull_area == 0 else float(area) / hull_area

        # center of mass of the object
        moment = cv2.moments(contour)
        cx = -1 if moment['m00'] == 0 else int(moment['m10'] / moment['m00'])
        cy = -1 if moment['m00'] == 0 else int(moment['m01'] / moment['m00'])
        centroid = (cx, cy)

        # Straight Bounding Rectangle
        rect = cv2.boundingRect(contour)

        # Fitting a Line
        [vx, vy, x, y] = cv2.fitLine(contour, cv2.DIST_L2, 0, 0.01, 0.01)
        left = int((-x * vy / vx) + y)
        right = int(((w - x) * vy / vx) + y)
        line = (w - 1, right), (0, left)

        return rect, line, area, solidity, centroid

    def contour_blobs(self, image):
        """
        Contours can be explained simply as a curve joining all the continuous points
        (along the boundary), having same color or intensity.
        The contours are a useful tool for shape analysis and object detection and recognition
        """
        blobs = []
        h, w = image.shape[:2]

        # use the cv2.findContours() function to detect objects(contours)
        contours, hierarchy = self.contours(image)

        # get contours' properties and added to detected blobs
        for i, contour in enumerate(contours):
            rect, line, area, solidity, centroid = self.contour(contour, w)
            rect = self._frame_rect(rect)
            area = self._frame_area(area)
            line = self._frame_line(line)
            centroid = self._frame_point(centroid)

            if area < 50:
                continue

            blob = Blob(f"{self.name}:{str(i)}", rect, line=line, area=area, centroid=centroid, fps=self.fps.fps())
            blobs.append(blob)

        return blobs

    # Function to calculate difference between 2 images.
    def detect(self, image):
        image = image if len(image.shape) == 2 else cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        roi = self._init_roi(image)

        self.roi_diff0 = roi if self.roi_diff0 is None else self.roi_diff1
        self.roi_diff1 = roi

        if self.roi_diff0.shape == self.roi_diff1.shape:
            m0, m1 = map(lambda im: cv2.GaussianBlur(im, (3, 3), 0), (self.roi_diff0, self.roi_diff1))
        else:
            m0, m1 = roi, roi

        diff2image = cv2.absdiff(m0, m1)

        blobs = self.contour_blobs(diff2image)
        self.blobs.track_blobs(blobs)
        self.fps.update()


class Diff3frame(Diff2frame):
    name = "Model_Diff3frame"
    num = 0

    def __init__(self):
        super().__init__()
        self.message = "trace moving objects by compare 3 continuous images"

    # Function to calculate difference between 3 images.
    def detect(self, image):
        image = image if len(image.shape) == 2 else cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        roi = self._init_roi(image)

        self.roi_diff0 = roi if self.roi_diff0 is None else self.roi_diff1
        self.roi_diff1 = roi if self.roi_diff1 is None else self.roi_diff2
        self.roi_diff2 = roi

        if self.roi_diff0.shape == self.roi_diff1.shape == self.roi_diff2.shape:
            m0, m1, m2 = map(lambda im: cv2.GaussianBlur(im, (3, 3), 0),
                             (self.roi_diff0, self.roi_diff1, self.roi_diff2))
        else:
            m0, m1, m2 = roi, roi, roi

        diff0 = cv2.absdiff(m1, m0)
        diff1 = cv2.absdiff(m2, m1)
        diff3image = cv2.bitwise_or(diff0, diff1)

        blobs = self.contour_blobs(diff3image)
        self.blobs.track_blobs(blobs)
        self.fps.update()


class Background(Diff2frame):
    name = "Model_Background"
    num = 0

    BAR = [("thresh", 210, 255)]

    def __init__(self):
        super().__init__()
        self.message = "trace moving objects by cv2 Background sub-tractor"
        self.background_subtract = cv2.createBackgroundSubtractorMOG2()

    # Gaussian mixture model background subtraction
    # background_subtract = cv2.createBackgroundSubtractorMOG2()
    def detect(self, image):
        roi = self._init_roi(image)

        foreground = self.background_subtract.apply(roi)

        # Due to tiny variations in the digital camera sensors, no two frames will be 100% the same
        # some pixels will most certainly have different intensity values.
        # That said, we need to account for this and apply Gaussian smoothing
        # to average pixel intensities across an 5 x 5 region
        foreground = cv2.GaussianBlur(foreground, (5, 5), 0)

        # It would be better to apply morphological opening to the result to remove the noises
        foreground = cv2.morphologyEx(foreground, cv2.MORPH_OPEN, (3, 3))
        foreground = cv2.morphologyEx(foreground, cv2.MORPH_CLOSE, (3, 3))

        ret, foreground_thresh = cv2.threshold(foreground, self.trackbar.value[0], 255.0, cv2.THRESH_BINARY)
        # move_points = cv2.countNonZero(roi_thresh_image)  # this is total difference number

        blobs = self.contour_blobs(foreground_thresh)
        self.blobs.track_blobs(blobs)
        self.fps.update()


if __name__ == '__main__':
    video = ["airport.mp4", "weco.mp4", "count1.mp4", "overpass.mp4", "cars.mp4", "walk.avi", "run.mp4"]
    v0 = f"{CWD}//data//Sample//videos//{video[5]}"

    cam = Camera(device=v0).start()

    cam_plus = CamPlus(camera=cam)

    # model_diff2frame = Diff2frame()
    model_background = Background()

    cam_plus.register_models(model_background)
    # cam_plus.register_models(model_diff2frame, model_background)

    # test Model instance
    cam_plus.test()
