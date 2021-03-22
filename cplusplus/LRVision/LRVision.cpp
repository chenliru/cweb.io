#include "LRVision.h"

// model: //////////////////////////////////////////////////////////////////////////////////////
// LRModel, Background, SimpleBlob, Diff2Frame, Diff3Frame, 
// HOGDetector, HaarCascade, MultiTrack, Color, Caffe, Tensorflow;
////////////////////////////////////////////////////////////////////////////////////////////////

template <typename T, typename C>
LRVision<T, C>::LRVision(C model, T device, int direct, string name, bool sync) :
	model{ model }, Camera{ device, direct, name, sync }{}

template <typename T, typename C>
void LRVision<T, C>::vision() {
	visionThreading = true;	//Model detect
	modelThread = thread(&LRVision::visionModel, this, &model);
}

template <typename T, typename C>
void LRVision<T, C>::stop() {
	// detector run by thread, join main detecting,
	// this thread will close successfully before main detecting stop
	if (visionThreading) {
		visionThreading = false;
	}
	Camera::stop();
}

template <typename T, typename C>
void LRVision<T, C>::visionModel(C* pModel) {
	// for multi_thread program, all variables can be passed between each function
	// including objects(instance), like detect_model object here.

	namedWindow(pModel->modelName, WINDOW_NORMAL);
	
	this->pModel = pModel;
	setMouseCallback(pModel->modelName, &LRVision::mouseOnVision, this);

	while (visionThreading) {
		//if (!async)
		Mat frame = read();
		pModel->detect(frame);

		drawFrame = frame.clone();
		drawFrame = drawOnCamera(drawFrame);
		drawFrame = pModel->drawOnModel(drawFrame);
		
		imshow(pModel->modelName, drawFrame);

		recordOnCamera(drawFrame);
		imagesOnCamera(drawFrame);

		keyOnVision(drawFrame, pModel);
	}
	capture.release();
	destroyWindow(pModel->modelName);
}

template <typename T, typename C>
void LRVision<T, C>::keyOnVision(Mat frame, C* pModel) {
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
	else if (key == 'z') {
		if (pModel->infoModel) {
			// clear MultiTracker selected tracing boxes
			pModel->deselectMultiTrack = true;
			pModel->deselectColor = true;

			pModel->blobs.clear();

			//model.left_lane, model.right_lane = None, None
			//model.left_foot = (0, 0)
			//model.right_foot = (0, 0)
			//model.barcode_data, model.barcode_points, model.barcode_rect = None, None, None
		}
	}
	else if (key == 'c') {
		if (pModel->infoModel) {
			// clear MultiTracker selected tracing boxes
			pModel->selectColor = true;
		}
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

template <typename T, typename C>
void LRVision<T, C>::mouseOnVision(int event, int x, int y, int flags, void* param) {
	LRVision* pLR = (LRVision*) param;

	if (event == EVENT_MOUSEMOVE) {
		pLR->x_mouse = x, pLR->y_mouse = y;

		// get mouse point HVS for Color LRModel
		if (pLR->pModel->infoModel) {
			// Convert the BGR pixel into HSV formats, H: 0 to 179 S : 0 to 255 V : 0 to 255
			Vec3b bgrPixel = pLR->drawFrame.at<Vec3b>(y, x);

			// Create Mat object from vector since cvtColor accepts a Mat object
			Mat3b imgBGR(bgrPixel);

			Mat3b imgHSV;
			//Convert the single pixel BGR Mat to other formats
			cvtColor(imgBGR, imgHSV, COLOR_BGR2HSV);

			//Get back the vector from Mat
			pLR->pModel->hsv = imgHSV.at<Vec3b>(0, 0);
		}
	}

	// double LEFT button clicks
	if (event == EVENT_LBUTTONDBLCLK) {
		pLR->paused = pLR->paused ? false : true;
	}

	// Left mouse button was DOWN, active current window, and start cropping image
	if (event == EVENT_LBUTTONDOWN) {
		pLR->x_start = x, pLR->y_start = y, pLR->x_end = x, pLR->y_end = y;
	}

	//Mouse is Moving with left button down, draw rectangle
	if (event == EVENT_MOUSEMOVE && flags == EVENT_FLAG_LBUTTON) {
		pLR->x_end = x > pLR->width ? pLR->width : x;
		pLR->y_end = y > pLR->height ? pLR->height : y;
	}

	//right button down
	if (event == EVENT_RBUTTONDOWN) {
		if (pLR->x_start < pLR->x_end) {
			if (pLR->pModel->infoModel) {
				pLR->pModel->xROI = pLR->x_start;
				pLR->pModel->yROI = pLR->y_start;
				pLR->pModel->wROI = pLR->x_end - pLR->x_start;
				pLR->pModel->hROI = pLR->y_end - pLR->y_start;
				pLR->pModel->defaultROI = false;
			}
		}
	}

	// middle button down
	if (event == EVENT_MBUTTONDOWN) {
		if (pLR->pModel->infoModel &&
			pLR->pModel->xROI < pLR->x_start &&
			pLR->pModel->yROI <pLR->y_start &&
			pLR->pModel->xROI + pLR->pModel->wROI > pLR->x_end&&
			pLR->pModel->yROI + pLR->pModel->hROI > pLR->y_end)
		{
			pLR->pModel->box = Rect(pLR->x_start - pLR->pModel->xROI, pLR->y_start - pLR->pModel->yROI,
				(pLR->x_end - pLR->x_start), (pLR->y_end - pLR->y_start));
			pLR->x_start = 0, pLR->y_start = 0, pLR->x_end = 0, pLR->y_end = 0;
			pLR->pModel->selectMultiTrack = true;
		}
	}
}

//Camera ///////////////////////////////////////////////////////////////////////////////////////////////////
int main() {
	DataSet dataset(DATASET);

	//weco.mp4, run.mp4, airport.mp4, cars.mp4, count.mp4, overpass.mp4, run.mp4, walk.avi
	//LRVision cam0 (dataset.videoPath + "/Samples/walk.avi", 0);

	Color d2 = Color(); //Diff3Frame d3;

	//LRVision cam0(0, 0, "Cam0");
	LRVision<int, Color> cam1 { d2, 1, 0, "Cam1" };
	
	//cam0.start;
	cam1.start();
	cam1.vision();

	// Postprocessing and rendering loop
	//cam0.detectThread.join();
	//for (auto& th : cam1.modelThreads) {
	cam1.modelThread.join();
	//}
	destroyAllWindows();
}
