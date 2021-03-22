#include "Camera.h"

//template <typename T>
int Camera::num = 0;

//template <typename T>
Camera::Camera(int device, int direct, string name, bool sync) {
	capture.open(device);
	if (capture.isOpened()) {
		width = (int)capture.get(CAP_PROP_FRAME_WIDTH);
		height = (int)capture.get(CAP_PROP_FRAME_HEIGHT);
		cameraFPS = (int)capture.get(CAP_PROP_FPS);
		frames = (int)capture.get(CAP_PROP_FRAME_COUNT);
	}
	else {
		cout << "Camera Device VideoCapture Not Opened" << endl;
		cameraFPS = -1;
		frames = -1;
		width = 640;
		height = 480;
	}

	direction = direct;
	cameraName = name;
	async = !sync;

	DataSet dataset{ DATASET };	// use uniform initialization
	imagePath = dataset.imagePath;
	videoPath = dataset.videoPath;

	image = Mat(Size(width, height), CV_8UC3, Scalar(0, 255, 0));
	frame = Mat(Size(width, height), CV_8UC3, Scalar(0, 255, 0));
	drawFrame = Mat(Size(width, height), CV_8UC3, Scalar(0, 255, 0));

	//frameDeque = { drawFrame };

	num++;
	cout << num << " Camera(s) openned\n";
}

//template <typename T>
Mat Camera::read() {
	if (!async){ readSync(); }
	return frame;
}

//template <typename T>
void Camera::readSync() {
	FPS fps;
	if (capture.isOpened() && !paused) {
		if (capture.read(image)) rotate(image, frame, direction);
		frameID++;
	}
	else { rotate(image, frame, direction); }

	fps.update();
	readRate = fps.fps();
	fpsMean.update();

	//return frame;
}

//template <typename T>
void Camera::readAsync() {
	while (async) {
		readSync();
	}
}

//template <typename T>
void Camera::start() {
	//This is equivalent to running this->readAsync()
	// thread (&Camera::readAsync, this).detach();
	if (async) {
		//readThread = thread(&Camera::readAsync, this);
		thread (&Camera::readAsync, this).detach();
		cout << cameraName << " Async reading started\n";
	} else {
		cout << cameraName << " Sync reading started\n";
	}
}

//template <typename T>
void Camera::show() {
	//This is equivalent to running this->readAsync()
	// thread (&Camera::readAsync, this).detach();
	showThreading = true;
	showThread = thread(&Camera::showCamera, this);
	//thread (&Camera::show, this).detach();
}

//template <typename T>
void Camera::stop() {
	//delete currentCamera;
	if (showThreading) {
		showThreading = false;
	}
	if (async) {
		async = false;
	}
	writer.release();
	capture.release();

	num--;
	if (num == 0) {
		destroyAllWindows();
		exit(0);
	}
 }

//template <typename T>
void Camera::showCamera() {
	// for multi_thread program, all variables can be passed between each function
	// including objects(instance), like detect_model object here.
	namedWindow(cameraName, WINDOW_NORMAL);
	setMouseCallback(cameraName, &Camera::mouseOnCamera, this);

	while (showThreading) {
		frame = read();
		drawFrame = frame.clone();
		
		imshow(cameraName, drawOnCamera(drawFrame));

		recordOnCamera(drawFrame);
		imagesOnCamera(drawFrame);
		
		keyOnCamera(drawFrame);
	}
}

//template <typename T>
Mat Camera::drawOnCamera(Mat& frame) {
	if (info) {
		rectangle(frame, Rect(x_start, y_start, x_end - x_start, y_end - y_start), SCALAR_GREEN, 2);
		putText(frame, format("Mean FPS: %.2f, reading rate: %.2f", fpsMean.fps(), readRate),
			Point(width / 3, height - 20),
			FONT_HERSHEY_COMPLEX_SMALL, 0.8, SCALAR_RED, 1);

		//mouse position
		int xText = 0, yText = 0;
		xText = (x_mouse < (height / 2)) ? x_mouse : x_mouse - 100;
		yText = (y_mouse < (width / 2)) ? y_mouse : y_mouse + 10;
		putText(frame, format("X:%d Y:%d", x_mouse, y_mouse),
			Point(xText, yText), FONT_HERSHEY_COMPLEX_SMALL, 0.6, SCALAR_RED, 1);

		putText(frame, format("Active: %s", cameraName),
			Point(20, 20), FONT_HERSHEY_COMPLEX_SMALL, 0.6, SCALAR_RED, 1);
	}
	return frame;
}

//template <typename T>
void Camera::mouseOnCamera(int event, int x, int y, int flags, void* param) {
	Camera* pCam = (Camera*)param;
	if (event == EVENT_MOUSEMOVE) {
		pCam->x_mouse = x, pCam->y_mouse = y;
	}

	// double LEFT button clicks
	if (event == EVENT_LBUTTONDBLCLK) {
		pCam->paused = pCam->paused ? false : true;
	}

	// Left mouse button was DOWN, active current window, and start cropping image
	if (event == EVENT_LBUTTONDOWN) {
		pCam->x_start = x, pCam->y_start = y, pCam->x_end = x, pCam->y_end = y;
	}

	//Mouse is Moving with left button down, draw rectangle
	if (event == EVENT_MOUSEMOVE && flags == EVENT_FLAG_LBUTTON) {
		pCam->x_end = x > pCam->width ? pCam->width : x;
		pCam->y_end = y > pCam->height ? pCam->height : y;
	}
}

//template <typename T>
void Camera::keyOnCamera(Mat frame) {
	//frame showing rate 30
	char key = waitKey(1000 / 30);
	if (key == 'q') {
		// quit all windows, stop program
		stop();
	}
	else if (key == 'i') {
		// showing information on images
		info = info ? false : true;
	}
	else if (key == 't') {
		// save cropped image
		cropOnCamera(frame);
	}
	else if (key == 's') {
		//# save image
		imageOnCamera(frame);
	}
	else if (key == 'S') {
		// save images continuously
		writeImages = writeImages ? false : true;
	}
	else if (key == 'r') {
		// recording video
		writeVideo = writeVideo ? false : true;
	}
}

//template <typename T>
void Camera::imageOnCamera(Mat frame) {
	string imageName = imagePath + cameraName + to_string(frameID) + ".jpg";

	imwrite(imageName, frame);
	cout << imageName << " saved\n";
}

//template <typename T>
void Camera::cropOnCamera(Mat frame) {
	Mat	cr_image(frame, Rect(x_start, y_start, x_end - x_start, y_end - y_start));

	string imageName = imagePath
		+ cameraName + to_string(frameID)
		+ "X" + to_string(x_start) + "Y" + to_string(y_start)
		+ "W" + to_string(x_end - x_start) + "H" + to_string(y_end - y_start)
		+ ".jpg";

	imwrite(imageName, cr_image);
	cout << imageName << "  is cropped\n";
}

//template <typename T>
void Camera::recordOnCamera(Mat frame) {
	// Types of Codes : http://www.fourcc.org/codecs.php
	// mp4 for better compress rate
	string videoName = videoPath + cameraName + to_string(frameID) + ".mp4";
	//int codec = VideoWriter::fourcc('M', 'J', 'P', 'G');  // avi, select desired codec (must be available at runtime)
	int codec = VideoWriter::fourcc('m', 'p', '4', 'v');	// mp4, select desired codec (must be available at runtime)
	int fps = 30;		 // framerate of the created video stream
	//--- INITIALIZE VIDEOWRITER
	if (writeVideo) {
		if (!writer.isOpened()) {
			writer.open(videoName, codec, fps, Size(width, height), true);
			cout << videoName << "  recording started\n";

			if (!writer.isOpened()) {
				cerr << "  recording failed\n";
				return;
			}
		}
		writer.write(frame);
	} else {
		if (writer.isOpened()) {
			writer.release();
			cout << videoName << "  recording ended\n";
		}
	}
}

//template <typename T>
void Camera::imagesOnCamera(Mat frame) {
	if (writeImages) { imageOnCamera(frame); }
}

//template <typename T>
void Camera::rotate(Mat& img, Mat& imgRotate, int angle) {
	Point2f center = Point2f(static_cast<float>(img.cols / 2), static_cast<float>(img.rows / 2));
	Mat affineTrans = getRotationMatrix2D(center, angle, 1.0);

	warpAffine(img, imgRotate, affineTrans, img.size());
}
