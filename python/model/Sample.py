import os

import cv2
import numpy as np

from common.CamPlus import CamPlus
from common.Model import Model, Camera
from common.Blob import Blob
from common.Common import image_extensions
from python.model.Color import Color


class Template(Model):
    """
    Template Matching is a method for searching and finding the location of a template image in a larger image. OpenCV
comes with a function cv2.matchTemplate() for this purpose. It simply slides the template image over the input
image (as in 2D convolution) and compares the template and patch of input image under the template image. Several
comparison methods are implemented in OpenCV. (You can check docs for more details). It returns a grayscale image,
where each pixel denotes how much does the neighbourhood of that pixel match with template
    """
    name = "Model_Template"
    num = 0

    # All the 6 methods for comparison in a list
    METHOD = ['cv2.TM_CCOEFF',
              'cv2.TM_CCOEFF_NORMED',
              'cv2.TM_CCORR',
              'cv2.TM_CCORR_NORMED',
              'cv2.TM_SQDIFF',
              'cv2.TM_SQDIFF_NORMED']

    BAR = [("Method", 3, 5)]

    def __init__(self):
        super().__init__()

        self.message = "Mouse Drag and Drop to select sample part of image for tracing"

        self.templates = []
        self.template_dir = f"{self.path.images_path}/{self.name}/"
        if not os.path.exists(self.template_dir):
            os.makedirs(self.template_dir)
        self.init_template()

    def init_template(self):
        print("[INFO]model {}: initiate template image...".format(self.name))

        self.templates.clear()

        for name in os.listdir(self.template_dir):
            ext = os.path.splitext(name)[1][1:]  # get the filename extension
            if f'.{ext}' in image_extensions:
                # == "png" or ext == "jpg" or ext == "bmp" or ext == "tiff" or ext == "pbm":
                image = cv2.imread(f'{self.template_dir}/{name}')
                self.templates.append(image)

    def detect(self, image):
        blobs = []
        image = image if len(image.shape) == 2 else cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        roi = self._init_roi(image)

        for i, template in enumerate(self.templates):
            sample_gray = template if len(template.shape) == 2 else cv2.cvtColor(template, cv2.COLOR_BGR2GRAY)

            # Apply sample Matching
            res = cv2.matchTemplate(roi, sample_gray, eval(Template.METHOD[self.trackbar.value[0]]))
            min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(res)

            # If the method is TM_SQDIFF or TM_SQDIFF_NORMED, take minimum
            if Template.METHOD[self.trackbar.value[0]] in [cv2.TM_SQDIFF, cv2.TM_SQDIFF_NORMED]:
                top_left = min_loc
            else:
                top_left = max_loc

            h, w = template.shape[:2]
            rect = (top_left[0], top_left[1], w, h)
            rect = self._frame_rect(rect)

            blob = Blob(f"{self.name}:{str(i)}", rect, fps=self.fps.fps())
            blobs.append(blob)

        self.blobs.track_blobs(blobs)
        self.fps.update()

    def clear(self):
        super(Template, self).clear()

        # clear selected shapes
        self.templates.clear()
        for name in os.listdir(self.template_dir):
            os.remove(f'{self.template_dir}/{name}')
        print(f"Model {self.name}: crop image cleared")

    def mouse_on(self, event, x, y, flags, camera):
        super(Template, self).mouse_on(event, x, y, flags, camera)

        if event == cv2.EVENT_LBUTTONUP:
            # camera's RECT is inside model's ROI
            if self.inside(self.roi, camera.rect) and (camera.rect[2] > 0 and camera.rect[3] > 0):
                camera.trim_image(camera.image, path=self.template_dir)
                self.init_template()


class ColorShape(Template, Color):
    """
    compare two shapes(one in video, one in template sample image), or two contours and returns a metric showing the
    similarity. The lower the result, the better match it is. It is calculated based on the hu-moment values
    """
    name = "Model_ColorShape"
    num = 0

    def __init__(self):
        super(ColorShape, self).__init__()
        self.message = "key(c) to select color, Mouse Drag and Drop to select sample part of image for tracing"

        self.shapes = []
        self.init_shape()

    def init_shape(self):
        print("[INFO]model {}: initiate shape...".format(self.name))
        self.shapes.clear()

        for template in self.templates:
            template = template if len(template.shape) == 3 else cv2.cvtColor(template, cv2.COLOR_GRAY2BGR)
            hsv = cv2.cvtColor(template, cv2.COLOR_BGR2HSV)
            for hsv_range in self.hsv_ranges:
                thread_hsv = cv2.inRange(hsv, hsv_range[0], hsv_range[1])
                contours, _ = self.contours(thread_hsv)

                if len(contours) > 0:
                    shape = max(contours, key=cv2.contourArea)
                    self.shapes.append(shape)

    def detect(self, image):
        h, w = image.shape[:2]
        blobs = []
        image = image if len(image.shape) == 3 else cv2.cvtColor(image, cv2.COLOR_GRAY2BGR)
        roi = self._init_roi(image)

        blurred = cv2.GaussianBlur(roi, (3, 3), 0)
        hsv = cv2.cvtColor(blurred, cv2.COLOR_BGR2HSV)
        for i, hsv_range in enumerate(self.hsv_ranges):
            thread_roi = cv2.inRange(hsv, hsv_range[0], hsv_range[1])
            contours, _ = self.contours(thread_roi)

            if len(contours) > 0 and len(self.shapes) > 0:
                contour = max(contours, key=cv2.contourArea)

                for shape in self.shapes:
                    ret = cv2.matchShapes(shape, contour, 1, 0.0)
                    if ret < 0.5:
                        rect, line, area, solidity, centroid = self.contour(contour, w)
                        # rect, line, area, solidity, centroid = self.contour(contours[0], w, h)
                        rect = self._frame_rect(rect)
                        area = self._frame_area(area)
                        line = self._frame_line(line)
                        centroid = self._frame_point(centroid)

                        blob = Blob(f"{self.name}:{str(i)}", rect, line, area, centroid)
                        blobs.append(blob)

        self.blobs.track_blobs(blobs)
        self.fps.update()

    def clear(self):
        super(ColorShape, self).clear()

        # clear selected shapes
        self.shapes.clear()
        print(f"Model {self.name}: cleared")

    def mouse_on(self, event, x, y, flags, camera):
        super(ColorShape, self).mouse_on(event, x, y, flags, camera)

        if event == cv2.EVENT_LBUTTONUP:
            # camera's RECT is inside model's ROI
            if self.inside(self.roi, camera.rect) and (camera.rect[2] > 0 and camera.rect[3] > 0):
                self.init_shape()


class Feature(Template):
    """
    Feature-based image matching sample.
    we are looking for specific patterns or specific features which are unique, which can be easily tracked,
which can be easily compared. If we go for a definition of such a feature, we may find it difficult to express it in
words, but we know what are they. If some one asks you to point out one good feature which can be compared across
several images, you can point out one. That is why, even small children can simply play these games. We search for these
features in an image, we find them, we find the same features in other images, we align them. That’s it. (In jigsaw
puzzle, we look more into continuity of different images). All these abilities are present in us inherently.

    """
    name = "Model_Feature"
    num = 0

    TYPE = ['sift', 'sift-flann',
            'surf', 'surf-flann',
            'orb', 'orb-flann',
            'akaze', 'akaze-flann',
            'brisk', 'brisk-flann']

    MAX_MATCHES = 400
    FLANN_INDEX_KDTREE = 1  # bug: flann enums are missing
    FLANN_INDEX_LSH = 6
    GOOD_MATCH_PERCENT = 0.1

    BAR = [("TYPE", 5, 9)]

    def __init__(self):
        super().__init__()
        self.message = "Mouse Drag and Drop to select sample part of image for tracing"

        self.detector = None
        self.norm = None
        self.matcher = None

        self.homos = []
        self.features = []

        self.type = Feature.TYPE[self.trackbar.value[0]]

        self.init_feature()

    def init_feature(self):
        print("[INFO]model {}: initiate feature...".format(self.name))

        self.type = Feature.TYPE[self.trackbar.value[0]]
        if self.type.split('-')[0] == 'sift':  # is excluded for non-free
            self.detector = cv2.SIFT_create()
            self.norm = cv2.NORM_L2
        # elif self.type.split('-')[0] == 'surf':  # is excluded for non-free
        #     self.detector = cv2.xfeatures2d.SURF_create(Feature.MAX_MATCHES)
        #     self.norm = cv2.NORM_L2
        elif self.type.split('-')[0] == 'orb':
            self.detector = cv2.ORB_create(Feature.MAX_MATCHES)
            self.norm = cv2.NORM_HAMMING
        elif self.type.split('-')[0] == 'akaze':
            self.detector = cv2.AKAZE_create()
            self.norm = cv2.NORM_HAMMING
        elif self.type.split('-')[0] == 'brisk':
            self.detector = cv2.BRISK_create()
            print(self.detector)
            self.norm = cv2.NORM_HAMMING
        else:
            print(f"{self.type.split('-')[0]}, No detector initiated")

        # FLANN stands for Fast Library for Approximate Nearest Neighbors. It contains a collection
        # of algorithms optimized for fast nearest neighbor search in large datasets and for high
        # dimensional features. It works more faster than BFMatcher for large datasets.
        # We will see the second example with FLANN based matcher.
        if 'flann' in self.type:
            if self.norm == cv2.NORM_L2:
                params = dict(algorithm=Feature.FLANN_INDEX_KDTREE,
                              trees=5)
            else:
                params = dict(algorithm=Feature.FLANN_INDEX_LSH,
                              table_number=6,  # 12
                              key_size=12,  # 20
                              multi_probe_level=1)  # 2
            self.matcher = cv2.FlannBasedMatcher(params, {})  # bug : need to pass empty dict (#1329)
        else:
            self.matcher = cv2.BFMatcher(self.norm)

        # Once it is created, two important methods are BFMatcher.match() and BFMatcher.knnMatch().
        # First one returns the best match. Second method returns k best matches where k is specified
        # by the user. It may be useful when we need to do additional work on that.

        self.features.clear()
        for sample in self.templates:
            gray_sample = sample if len(sample.shape) == 2 else cv2.cvtColor(sample, cv2.COLOR_BGR2GRAY)
            key_points, descriptors = self.detector.detectAndCompute(gray_sample, None)
            self.features.append((key_points, descriptors))

    @staticmethod
    def filter_matches(kp1, kp2, matches, ratio=0.75):
        mkp1, mkp2 = [], []
        for m in matches:
            if len(m) == 2 and m[0].distance < m[1].distance * ratio:
                m = m[0]
                mkp1.append(kp1[m.queryIdx])
                mkp2.append(kp2[m.trainIdx])
        p1 = np.float32([kp.pt for kp in mkp1])
        p2 = np.float32([kp.pt for kp in mkp2])
        # kp_pairs = zip(mkp1, mkp2)
        return p1, p2

    def detect(self, image):
        blobs = []
        image = image if len(image.shape) == 2 else cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        roi = self._init_roi(image)

        self.homos.clear()
        for i, feature in enumerate(self.features):
            key_points1, descriptors1 = feature

            # Apply feature Matching
            key_points2, descriptors2 = self.detector.detectAndCompute(roi, None)

            matches = self.matcher.knnMatch(descriptors1, trainDescriptors=descriptors2, k=2)  # 2
            p1, p2 = self.filter_matches(key_points1, key_points2, matches)
            if len(p1) > 3:
                homo, status = cv2.findHomography(p1, p2, cv2.RANSAC, 5.0)
            else:
                homo, status = None, None

            self.homos.append(homo)

            if len(p2) > 2:
                x_start, x_end = p2[:, 0].min(), p2[:, 0].max()
                y_start, y_end = p2[:, 1].min(), p2[:, 1].max()

                rect = self._frame_rect((x_start, y_start, x_end - x_start, y_end - y_start))

                blob = Blob(f"{self.name}", rect, fps=self.fps.fps())
                blobs.append(blob)

        self.blobs.track_blobs(blobs)
        self.fps.update()

    def draw_on(self, image, camera):
        super(Feature, self).draw_on(image, camera)

        for i, sample in enumerate(self.templates):
            h1, w1 = sample.shape[:2]
            corners = np.float32([[0, 0], [w1, 0], [w1, h1], [0, h1]])
            if self.homos[i] is not None:
                corners = np.int32(cv2.perspectiveTransform(corners.reshape(1, -1, 2),
                                                            self.homos[i]).reshape(-1, 2) / self.scale +
                                   (self.roi[0], self.roi[1]))

                cv2.polylines(image, [corners], True, (0, 255, 255))

        return image

    def clear(self):
        super(Feature, self).clear()

        # clear selected features
        self.features.clear()

    def mouse_on(self, event, x, y, flags, camera):
        super(Feature, self).mouse_on(event, x, y, flags, camera)

        if event == cv2.EVENT_LBUTTONUP:
            # camera's RECT is inside model's ROI
            if self.inside(self.roi, camera.rect) and (camera.rect[2] > 0 and camera.rect[3] > 0):
                self.init_feature()


class Hist(Template):
    """
    It is just another way of understanding the image. By looking at the histogram of an image, you get intuition about
contrast, brightness, intensity distribution etc of that image. Almost all image processing tools today, provides
features on histogram

    cv2.calcHist() function to find the histogram. Let’s familiarize with the function and its parameters :
    cv2.calcHist(images, channels, mask, histSize, ranges[, hist[, accumulate]])
    1. images : it is the source image of type uint8 or float32. it should be given in square brackets, ie, “[img]”.
    2. channels : it is also given in square brackets. It the index of channel for which we calculate histogram. For
    example, if input is grayscale image, its value is [0]. For color image, you can pass [0],[1] or [2] to calculate
    histogram of blue,green or red channel respectively.
    3. mask : mask image. To find histogram of full image, it is given as “None”. But if you want to find histogram
    of particular region of image, you have to create a mask image for that and give it as mask. (I will show an
    example later.)
    4. histSize : this represents our BIN count. Need to be given in square brackets. For full scale, we pass [256].
    5. ranges : this is our RANGE. Normally, it is [0,256].
    """
    name = "Model_Hist"
    num = 0

    def __init__(self):
        super().__init__()

        self.hists = []

        # [Using 50 bins for hue and 60 for saturation and 60 for value]
        h_bins = 50
        s_bins = 60
        v_bins = 60
        self.histSize = [h_bins, s_bins, v_bins]

        # hue varies from 0 to 179, saturation from 0 to 255, value from 0 to 255
        h_ranges = [0, 180]
        s_ranges = [0, 256]
        v_ranges = [0, 256]
        self.ranges = h_ranges + s_ranges + v_ranges  # concat lists

        # Use the 0-th and 1-st channels and 2-nd channels
        self.channels = [0, 1, 2]

        self.init_hist()

    def init_hist(self):
        print("[INFO]model {}: initiate HIST...".format(self.name))

        self.hists.clear()
        for sample in self.templates:
            # [Convert to HSV]
            sample_hsv = cv2.cvtColor(sample, cv2.COLOR_BGR2HSV)

            # [Calculate the histograms for the HSV images]
            hist = cv2.calcHist([sample_hsv], self.channels, None, self.histSize, self.ranges, accumulate=False)
            cv2.normalize(hist, hist, alpha=0, beta=1, norm_type=cv2.NORM_MINMAX)

            self.hists.append(hist)

    def detect(self, image):
        blobs = []
        image = image if len(image.shape) == 3 else cv2.cvtColor(image, cv2.COLOR_GRAY2BGR)
        roi = self._init_roi(image)
        roi_hsv = cv2.cvtColor(roi, cv2.COLOR_BGR2HSV)

        for i, hist in enumerate(self.hists):
            # Apply hist Matching comparing
            roi_hist = cv2.calcHist([roi_hsv], self.channels, None, self.histSize, self.ranges, accumulate=False)
            cv2.normalize(roi_hist, roi_hist, alpha=0, beta=1, norm_type=cv2.NORM_MINMAX)

            # [Apply the histogram comparison methods]
            # for compare_method in range(4):
            compare_method = 0
            compare_hist = cv2.compareHist(hist, roi_hist, compare_method)
            print(f'Method: {compare_method} compare: {compare_hist}')

        self.blobs.track_blobs(blobs)
        self.fps.update()

    def clear(self):
        super(Hist, self).clear()

        # clear selected samples hists data
        self.hists.clear()

    def key_on(self, key, camera):
        super(Hist, self).key_on(key, camera)
        try:
            if key == ord('t'):
                self.init_hist()

        except Exception as e:
            print(f"Key:{key}, Model {self.name}: KeyBoard Operation exit exception: {e}")


if __name__ == '__main__':
    cam = Camera(device=1).start()
    cam_plus = CamPlus(camera=cam)
    model = Template()

    cam_plus.register_models(model)

    # test Model instance
    cam_plus.test()
