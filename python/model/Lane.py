import cv2
from collections import deque
import numpy as np

from common.CamPlus import CamPlus
from python.model.Color import Color, Camera

""" HoughLinesP simply returns an array of  values.  is measured in pixels
and is measured in radians. First parameter, Input image should be a binary image,
so apply threshold or use canny edge detection before finding applying hough
transform. Second and third parameters are  and  accuracies respectively.
Fourth argument is the threshold, which means minimum vote it should get for
it to be considered as a line. Remember, number of votes depend upon number of
points on the line. So it represents the minimum length of line that should be detected.
`image` should be the output of a Canny transform.

Returns hough lines (not the image with lines)
"""


class Lane(Color):
    name = "Model_Lane"
    num = 0

    QUEUE_LENGTH = 4

    BAR = [("minVal", 50, 100),     # canny
           ("maxVal", 200, 400),    # canny
           ("threshold", 60, 255),  # HoughLineSP
           ("minLineLength", 50, 100),  # HoughLineSP
           ("maxLineGap", 200, 400)]    # HoughLineSP

    def __init__(self):
        super().__init__()
        self.message = "mouse point on selected color and key(c) to trace lane(s)"

        self.left_lane, self.right_lane = None, None
        self.left_foot, self.right_foot = None, None

        self.left_lanes = deque(maxlen=Lane.QUEUE_LENGTH)
        self.right_lanes = deque(maxlen=Lane.QUEUE_LENGTH)

    @staticmethod
    def slope_intercept(lines):
        left_lines = []  # [(slope, intercept),]
        left_weights = []  # [length,]
        right_lines = []  # [(slope, intercept),]
        right_weights = []  # [length,]

        for line in lines:
            for x1, y1, x2, y2 in line:
                if x2 == x1:
                    continue  # ignore a vertical line and horizontal line
                slope = (y2 - y1) / (x2 - x1)
                intercept = y1 - slope * x1
                length = np.sqrt((y2 - y1) ** 2 + (x2 - x1) ** 2)

                if slope < 0:  # y is reversed in image
                    left_lines.append((slope, intercept))
                    left_weights.append(length)

                else:
                    right_lines.append((slope, intercept))
                    right_weights.append(length)

        # add more weight to longer lines
        left_line = np.dot(left_weights, left_lines) / np.sum(left_weights) if len(left_weights) > 0 else None
        right_line = np.dot(right_weights, right_lines) / np.sum(right_weights) if len(right_weights) > 0 else None

        return left_line, right_line  # (slope, intercept)

    # turn lines detect by cv2.HoughLinesP to lane(s)
    def find_lane(self, roi, lines):
        left_line, right_line = self.slope_intercept(lines)
        h, w = roi.shape[:2]
        top, bottom, left, right = 0, h, 0, w  # bottom, top of the image

        def line_ends(y1, y2, x1, x2, line):
            """
            Convert a line represented in slope and intercept into pixel points
            """
            slope, intercept = line

            # make sure everything is integer as cv2.line requires it
            if slope == 0:
                x1 = int(x1)
                x2 = int(x2)
                y1 = int(intercept)
                y2 = int(intercept)
            else:
                x1 = int((y1 - intercept) / slope)
                x2 = int((y2 - intercept) / slope)
                y1 = int(y1)
                y2 = int(y2)

            return (x1, y1), (x2, y2)

        left_lane = line_ends(top, bottom, left, right, left_line) if left_line is not None else None
        right_lane = line_ends(top, bottom, left, right, right_line) if right_line is not None else None

        return left_lane, right_lane

    @staticmethod
    def foot_point(line, point):  # find foot from point on line
        """
        :param line: (x1, y1), (x2, y2)
        :param point: (x, y)
        :return: foot
        """

        begin, end = line[0], line[1]
        dx = begin[0] - end[0]
        dy = begin[1] - end[1]

        if abs(dx) < 0.00000001 and abs(dy) < 0.00000001:
            return begin

        try:
            u = (point[0] - begin[0]) * (begin[0] - end[0]) + (point[1] - begin[1]) * (begin[1] - end[1])
            u = u / ((dx * dx) + (dy * dy))
            x = begin[0] + u * dx
            y = begin[1] + u * dy
            return int(x), int(y)
        except Exception as e:
            print(f"Camera Reading sync exit Exception: {e}")
            return -1, -1

    def detect(self, image):
        image = image if len(image.shape) == 3 else cv2.cvtColor(image, cv2.COLOR_GRAY2BGR)
        roi = self._init_roi(image)

        h, w = image.shape[:2]
        p0 = [(w // 2, h // 4), (w // 2, h // 2), (w // 2, (3 * h) // 4)]
        #
        # # clear lane data if no lane found
        # self.left_lane, self.right_lane = None, None

        if len(self.hsv_ranges) > 0:
            # bilateralFilter, which was defined for, and is highly effective at noise removal while preserving edges
            roi = cv2.bilateralFilter(roi, 9, 75, 75)
            hsv_roi = cv2.cvtColor(roi, cv2.COLOR_BGR2HSV)  # HSV color space
            lower, upper = self.hsv_ranges[-1][0], self.hsv_ranges[-1][1]  # only last hsv used a lane selection
            roi_thresh = cv2.inRange(hsv_roi, lower, upper)

            # Canny Edge Detection, minVal=50 and maxVal=200
            canny = cv2.Canny(roi_thresh, self.trackbar.value[0], self.trackbar.value[1])
            lines = cv2.HoughLinesP(canny, rho=1, theta=np.pi / 180,
                                    threshold=self.trackbar.value[2],
                                    minLineLength=self.trackbar.value[3],
                                    maxLineGap=self.trackbar.value[4])

            # print("lines:{}".format(lines))
            if lines is not None:
                left_lane, right_lane = self.find_lane(roi, lines)

                # lane(s) in ROI to frame
                left_lane = self._frame_line(left_lane) if left_lane is not None else None
                right_lane = self._frame_line(right_lane) if right_lane is not None else None

                def mean_lanes(lane, mean_lane):
                    if lane is not None:
                        mean_lane.append(lane)
                    else:
                        mean_lane.clear()

                    if len(mean_lane) > 0:
                        lane = np.mean(mean_lane, axis=0, dtype=np.int32)
                        lane = tuple(map(tuple, lane))  # make sure it's tuples not numpy array for cv2.line to work

                    return lane

                left_lane = mean_lanes(left_lane, self.left_lanes)
                right_lane = mean_lanes(right_lane, self.right_lanes)

                if left_lane is not None:
                    self.left_foot = list(map(lambda p: self.foot_point(left_lane, p), p0))
                if right_lane is not None:
                    self.right_foot = list(map(lambda p: self.foot_point(right_lane, p), p0))

                self.left_lane, self.right_lane = left_lane, right_lane

        self.fps.update()

    def draw_on(self, image, camera):
        super(Lane, self).draw_on(image, camera)
        # make a separate image to draw lines and combine with the original later
        h, w = image.shape[:2]
        p0 = [(w // 2, h // 4), (w // 2, h // 2), (w // 2, (3 * h) // 4)]

        def draw(lane, foot):
            cv2.line(image, *lane, color=(0, 0, 255), thickness=2)
            cv2.line(image, (w // 2, 0), (w // 2, h), color=(0, 255, 255), thickness=1)

            for i in range(len(foot)):
                sign = 1 if foot[i][0] > w // 2 else -1
                distance = self.blobs.distance_between_points(p0[i], foot[i]) * sign
                cv2.line(image, p0[i], foot[i], color=(255, 0, 0), thickness=2)

                cv2.putText(image, f"{distance:.2f}", foot[i], cv2.FONT_HERSHEY_SIMPLEX, 0.8, (0, 0, 255), 1)

        if self.left_lane is not None:
            draw(self.left_lane, self.left_foot)
        if self.right_lane is not None:
            draw(self.right_lane, self.right_foot)

        # image1 * α + image2 * β + λ
        # image1 and image2 must be the same shape.
        return image

    def clear(self):
        super(Lane, self).clear()

        # clear lane initial data
        self.left_lane, self.right_lane = None, None
        self.left_foot, self.right_foot = None, None
        print(f"Model {self.name}: Lanes data cleared")


if __name__ == '__main__':
    cam = Camera(device=0).start()
    cam_plus = CamPlus(camera=cam)
    model_lane = Lane()
    model_color = Color()

    # test Model instance
    cam_plus.register_models(model_lane, model_color)
    cam_plus.test()
