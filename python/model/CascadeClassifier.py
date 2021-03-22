import cv2

from common.CamPlus import CamPlus
from common.Model import Model, Camera
from common.Blob import Blob


class CascadeClassifier(Model):
    # trained classifiers for detecting objects of a particular type, e.g. faces (frontal, profile), pedestrians etc.
    # Some of the classifiers have a special license - please, look into the files for details.
    name = "Model_CascadeClassifier"
    num = 0

    # load our serialized model from disk
    face = "haarcascades/haarcascade_frontalface_default.xml"
    eyes = "haarcascades/haarcascade_eye_tree_eyeglasses.xml"

    # nose="haarcascades/haarcascade_mcs_nose.xml"
    # body="haarcascades/haarcascade_fullbody.xml"
    # pedestrians="haarcascades/hogcascade_pedestrians.xml"

    def __init__(self):
        super().__init__()

        self.bool_alert = False

        # load CascadeClassifier object detector trained dataset
        self.face_cascade = cv2.CascadeClassifier()
        self.eyes_cascade = cv2.CascadeClassifier()
        # self.nose_cascade = cv2.CascadeClassifier()

        # Load the cascades
        self.face_cascade.load(f"{self.path.models_path}/{CascadeClassifier.face}")
        self.eyes_cascade.load(f"{self.path.models_path}/{CascadeClassifier.eyes}")

        self.message = "show your head to check face and eyes"

    def detect(self, image):
        blobs = []
        image = image if len(image.shape) == 2 else cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        roi = self._init_roi(image)

        # Detect faces
        faces = self.face_cascade.detectMultiScale(roi, 1.3, 5)

        for i, face in enumerate(faces):
            rect = self._frame_rect(face)

            blob = Blob(f"face:{str(i)}", rect)
            blobs.append(blob)

            # In each face, detect eyes
            x, y, w, h = face
            face_roi = roi[y:y + h, x:x + w]
            eyes = self.eyes_cascade.detectMultiScale(face_roi)
            # noses = self.nose_cascade.detectMultiScale(face_roi)
            for j, eye in enumerate(eyes):
                x2, y2, w2, h2 = eye
                eye = x2 + x, y2 + y, w2, h2

                # for nose detect
                # if abs(w / 2 - x2 - w2 / 2) < 20:
                rect = self._frame_rect(eye)

                blob = Blob(f"eye:{str(j)}", rect, fps=self.fps.fps())
                blobs.append(blob)

        self.blobs.track_blobs(blobs)
        self.fps.update()

        # face-mask detect and sound alert
        count = []
        for blob in self.blobs.blobs:
            if 'eye' in blob.label:
                count.append(blob.age)

        self.bool_alert = True if len(count) < 2 else False


if __name__ == '__main__':
    # camera instance, started before assigning to Model
    cam = Camera(device=1).start()
    cam_plus = CamPlus(camera=cam)
    # assigning camera to Model
    model = CascadeClassifier()

    # test Model instance
    cam_plus.register_models(model)
    cam_plus.test()
