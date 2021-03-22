import face_recognition
import pickle

import cv2

from common.CamPlus import CamPlus
from common.Model import Model, Camera
from common.Blob import Blob


class Face(Model):
    name = "Model_Face"
    num = 0

    # load our serialized model from disk, face detection model to use
    face = "face_recognize/encodings_hog.pickle"

    def __init__(self,
                 target=("person",)
                 ):

        # python 3 super function
        super().__init__()

        self.target = target

        # load the known faces and embeddings
        print("[INFO] loading Face encodings...")
        self.face = pickle.loads(open(f"{self.path.models_path}/{Face.face}", "rb").read())

    def detect(self, image):
        # grab the frame dimensions and convert it to a blob
        image = image if len(image.shape) == 3 else cv2.cvtColor(image, cv2.COLOR_GRAY2BGR)
        roi = self._init_roi(image)
        # (h, w) = roi.shape[:2]

        # convert the input frame from BGR to RGB then resize it to have
        # a width of 750px (to speedup processing)
        rgb = cv2.cvtColor(roi, cv2.COLOR_BGR2RGB)

        # detect the (x, y)-coordinates of the bounding boxes
        # corresponding to each face in the input frame, then compute
        # the facial embeddings for each face
        boxes = face_recognition.face_locations(rgb, model="hog")
        encodings = face_recognition.face_encodings(rgb, boxes)

        blobs = []
        labels = []

        # loop over the facial embeddings
        for encoding in encodings:
            # attempt to match each face in the input image to our known
            # encodings
            matches = face_recognition.compare_faces(self.face["encodings"],
                                                     encoding)
            label = "Unknown"

            # check to see if we have found a match
            if True in matches:
                # find the indexes of all matched faces then initialize a
                # dictionary to count the total number of times each face
                # was matched
                matched_idxs = [i for (i, b) in enumerate(matches) if b]
                counts = {}

                # loop over the matched indexes and maintain a count for
                # each recognized face
                for i in matched_idxs:
                    label = self.face["names"][i]
                    counts[label] = counts.get(label, 0) + 1

                # determine the recognized face with the largest number
                # of votes (note: in the event of an unlikely tie Python
                # will select first entry in the dictionary)
                label = max(counts, key=counts.get)

            # update the list of names
            labels.append(label)

        # loop over the recognized faces
        for ((start_y, end_x, end_y, start_x), label) in zip(boxes, labels):
            # rescale the face coordinates
            roi_rect = (start_x, start_y, end_x - start_x, end_y - start_y)
            rect = self._frame_rect(roi_rect)

            blob = Blob(label, rect, fps=self.fps.fps())
            blobs.append(blob)

        self.blobs.track_blobs(blobs)
        self.fps.update()


if __name__ == '__main__':
    cam = Camera(device=1, sync=False).start()
    cam_plus = CamPlus(camera=cam)
    model = Face()

    # test Model instance
    cam_plus.register_models(model)
    cam_plus.test()
