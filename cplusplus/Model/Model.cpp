#include "Model.h"
#include "../Camera/Common.h"

Model::Model() {
	DataSet dataset(DATASET);
	imagePath = dataset.imagePath;
	videoPath = dataset.videoPath;
	modelPath = dataset.modelPath;
}

Mat Model::frameROI(Mat frame) {
	//"""
	//	Region Of Interest(roi) of input image
	//	: param frame : input image
	//	: param scale : roi resize rate, enlarge roi if objects are too small
	//	: return : roi
	//	"""
	
	// grab the frame dimensions and convert it to a blob
	int w = frame.cols;
	int h = frame.rows;

	// initiate a default ROI
	if (defaultROI) {
		xROI = w / 3;
		yROI = h / 3;
		wROI = w / 3;
		hROI = h / 3;
	}
	// select a ROI
	//roi = frame[self.roi_y:self.roi_y + self.roi_h, self.roi_x : self.roi_x + self.roi_w]
	
	Mat roi = frame(Rect(xROI, yROI, wROI, hROI));
	//Mat roi = frame(Range(yROI, yROI + hROI), Range(xROI+1, xROI + wROI));

	// resize the ROI
	Mat roiResize;
	resize(roi, roiResize, Size((int)(xScale * wROI), (int)(yScale * hROI)));

	return roiResize;
}

Rect Model::frameRect(Rect rectROI) {
	//"""
	//resize and relocate objects(rectangles) in ROI to original frame
	//: param roi_rect : rectangles in ROI
	//: return : rectangles' location on frame
	//"""

	//expanding or shrinking a rectangle by a certain amount
	rectROI.x = (int)(rectROI.x / xScale), rectROI.width = (int)(rectROI.width / xScale);
	rectROI.y = (int)(rectROI.y / yScale), rectROI.height = (int)(rectROI.height / yScale);
	
	//shifting a rectangle by a certain offset
	Rect rect = rectROI + Point2i(xROI, yROI);

	return rect;
}

void Model::detect(Mat frame) {
	//"""
	//	working horse of Detector
	//	: param frame : input frames
	//	: return : recognized blobs with determined labels
	//	"""
	vector<Blob> blobs;

	// example: get the blob position and size,
	// it should be calculated by detect_model through input resized image	
	Mat	roi = frameROI(frame);
	
	int w = roi.cols;
	int h = roi.rows;
	Rect rectROI (w / 4, h / 4, w / 2, h / 2);

	// resize rect from ROI to frame, and blob it.
	Blob blob(frameRect(rectROI), "Blob:");

	blobs.push_back(blob);
	modelFPS.update();
	trackBlobs(blobs);
}

Mat Model::draw(Mat frame) {
	if (infoModel) {
		// grab the frame dimensions and convert it to a blob
		int w = frame.cols;
		int h = frame.rows;

		//# pronounce voice from Model
		//if self.beep_on:
			//# winsound.Beep(1000, 500)
			//self.beep_on = False
		// Draw Model process rate, Model detect ROI
		rectangle(frame, Rect(xROI, yROI, wROI, hROI), SCALAR_RED, 2);
		putText(frame, format("%s Number: %d detected, FPS: %.2f", modelName, blobs.size(), modelFPS.fps()), Point(w / 2, h - 20), FONT_HERSHEY_SIMPLEX, 0.4, (0, 0, 255), 1);

		frame = drawBlobsOn(frame);
		//frame = drawBarCodeOn(frame);
		//frame = drawLanesOn(frame);
	}
	return frame;
}

Mat Model::drawBlobsOn(Mat frame) {
	//# Draw Blobs
	if (infoBlob && blobs.size() > 0) {
		for (auto blob : blobs) {
			//draw rectangle around blob
			rectangle(frame, blob.rect, blob.color, 2);
			if (blob.centerPositions.size() > 0) {
				putText(frame, format("X:%d Y:%d", blob.centerPositions.back().x, blob.centerPositions.back().y),
					Point(blob.centerPositions.back().x, blob.centerPositions.back().y), FONT_HERSHEY_SIMPLEX, 0.4, blob.color, 1);
				//loop over the set of tracked points
				for (unsigned int j = 1; j < blob.centerPositions.size(); j++) {
					// compute the thickness of the lineand draw the connecting lines
					int thickness = (int)(sqrt(double(j)) * 1.25);
					line(frame, Point(blob.centerPositions[j - 1].x, blob.centerPositions[j - 1].y),
						Point(blob.centerPositions[j].x, blob.centerPositions[j].y), blob.color, thickness);
					frame = drawBlobDirectionOn(frame, blob);
				}
			}
			//# 2 additional functions : blobs' lanes and distance
			frame = drawDistanceOn(frame, blob);
		}
	}
	return frame;
}

Mat Model::drawBlobDirectionOn(Mat frame, Blob blob) {
	// if either of the tracked blob central points are less then 4, ignore them
	if (blob.centerPositions.size() > 4) {
		// compute the difference between the x and y coordinates and re - initialize the direction
		int xDelta = blob.centerPositions[blob.centerPositions.size() - 4].x - blob.centerPositions.back().x;
		int	yDelta = blob.centerPositions[blob.centerPositions.size() - 4].y - blob.centerPositions.back().y;
		string xDirection = "", yDirection = "", direction = "";	// text variables

		// ensure there is significant movement in the x - direction
		if (abs(xDelta) > 4) xDirection = xDelta > 0 ? "West" : "East";
		// ensure there is significant movement in the y - direction
		if (abs(yDelta) > 4) yDirection = yDelta > 0 ? "North" : "South";

		// handle when both directions are non - empty
		if (xDirection != "" && yDirection != "") { direction = yDirection + "-" + xDirection; }
		// otherwise, only one direction is non - empty
		else direction = xDirection != "" ? xDirection : yDirection;
		putText(frame, blob.label + " -> " + direction,
			Point(blob.rect.x, blob.rect.y - 5), FONT_HERSHEY_SIMPLEX, 0.4, blob.color, 1);
		frame = drawCountOn(frame, blob);
	}
	return frame;
}

Mat Model::drawCountOn(Mat frame, Blob blob) {
	// grab the frame dimensions and convert it to a blob
	int w = frame.cols;
	int h = frame.rows;

	if (infoCount) {
		//# Draw Counting Line
		int yLine = yROI + hROI / 2;
		if (!blob.counted) {
			// if the direction is negative (indicating the object is moving up) 
			// AND the centroid is above the center line, count the object
			if (blob.centerPositions.back().y > yLine&& yLine > blob.centerPositions.front().y) {
				BLOB_COUNT_UP += 1;
				blob.counted = true;
			}

			// if the direction is negative (indicating the object is moving up) 
			// AND the centroid is above the center line, count the object
			if (blob.centerPositions.front().y > yLine&& yLine > blob.centerPositions.back().y) {
				BLOB_COUNT_DOWN += 1;
				blob.counted = true;
			}
		}
		putText(frame, format("Counting Up : %d Down : %d", BLOB_COUNT_UP, BLOB_COUNT_DOWN),
			Point(10, yLine - 15), FONT_HERSHEY_SIMPLEX, 0.6, (0, 0, 255), 1);
		line(frame, Point(0, yLine), Point(w, yLine), (0, 0, 255), 1);
	}
	return frame;
}

Mat Model::drawDistanceOn(Mat frame, Blob blob) {
	int knowDiagonalSize = 10, focal = 100;
	if (infoDistance) {
		//# computeand return the distance from the maker to the camera
		float distance = knowDiagonalSize / blob.diagonalSize * focal;
		putText(frame, format("{:.2f}mm", distance),
			Point(blob.rect.x - 60, blob.rect.y), FONT_HERSHEY_SIMPLEX, 0.4, blob.color, 1);
	}
	return frame;
}
	

// use the findContours() function to detect objects
vector<Blob> Diff2Frame::boundContour(Mat imgDiff) {
	vector<vector<Point>> contours;
	vector<Blob> blobs;

	// It would be better to apply morphological opening to the result to remove the noises
	morphologyEx(imgDiff, imgDiff, MORPH_OPEN, (5, 5));
	morphologyEx(imgDiff, imgDiff, MORPH_CLOSE, (5, 5));

	Mat imgThread;
	double ret = threshold(imgDiff, imgThread, 30, 255.0, THRESH_BINARY);
	// move_points = countNonZero(thresh_image)  # this is total difference number

	Mat imgContour;
	dilate(imgThread, imgContour, (3, 3));
	dilate(imgContour, imgContour, (3, 3));
	erode(imgContour, imgContour, (3, 3));

	findContours(imgContour, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);

	for (auto& contour : contours) {
		//# solidity : float(area) / cv2.contourArea(hull) < 0.5 or
		//# if the contour is too small, ignore it. min-area, type=int, default=100
		if (contourArea(contour) < 100) continue;
		
		Rect rectROI = boundingRect(contour);
		Blob blob(frameRect(rectROI), "Blob: ");
		blobs.push_back(blob);
	}
	
	return blobs;
}

// Function to calculate difference between 2 images.
void Diff2Frame::detect(Mat frame){
	Mat ROI = frameROI(frame);
	if (firstFrame) {
		roiDiff0 = ROI;
		roiDiff1 = ROI.clone();
		firstFrame = false;
	}
	roiDiff0 = roiDiff1;
	roiDiff1 = ROI.clone();

	Mat g0, g1;
	cvtColor(roiDiff0, g0, COLOR_BGR2GRAY);
	cvtColor(roiDiff1, g1, COLOR_BGR2GRAY);

	GaussianBlur(g0, g0, Size(5, 5), 0);
	GaussianBlur(g1, g1, Size(5, 5), 0);

	Mat img2Diff;
	absdiff(g0, g1, img2Diff);

	vector<Blob> blobs = boundContour(img2Diff);
	modelFPS.update();
	trackBlobs(blobs);
}

void Diff3Frame::detect(Mat frame) {
	Mat ROI = frameROI(frame);
	if (firstFrame) {
		roiDiff0 = ROI;
		roiDiff1 = ROI.clone();
		roiDiff2 = ROI.clone();
		firstFrame = false;
	}
	roiDiff0 = roiDiff1;
	roiDiff1 = roiDiff2.clone();
	roiDiff2 = ROI.clone();

	Mat g0, g1, g2;
	cvtColor(roiDiff0, g0, COLOR_BGR2GRAY);
	cvtColor(roiDiff1, g1, COLOR_BGR2GRAY);
	cvtColor(roiDiff2, g2, COLOR_BGR2GRAY);

	GaussianBlur(g0, g0, Size(5, 5), 0);
	GaussianBlur(g1, g1, Size(5, 5), 0);
	GaussianBlur(g2, g2, Size(5, 5), 0);

	Mat diff0, diff1, img3Diff;
	absdiff(g1, g0, diff0);
	absdiff(g2, g1, diff1);
	bitwise_or(diff0, diff1, img3Diff);

	vector<Blob> blobs = boundContour(img3Diff);
	modelFPS.update();
	trackBlobs(blobs);
}

// Gaussian mixture model background subtraction
// background_subtract = cv2.createBackgroundSubtractorMOG2()
void Background::detect(Mat frame) {
	Mat	roi = frameROI(frame);

	Mat foreground;
	//pBackSubMOG2->apply(roi, foreground);
	pBackSubKNN->apply(roi, foreground);

	// Due to tiny variations in the digital camera sensors, no two frames will be 100 % the same
	// some pixels will most certainly have different intensity values.
	// That said, we need to account for thisand apply Gaussian smoothing
	// to average pixel intensities across an 5 x 5 region
	GaussianBlur(foreground, foreground, Size(5, 5), 0);

	// It would be better to apply morphological opening to the result to remove the noises
	morphologyEx(foreground, foreground, MORPH_OPEN, (3, 3));
	morphologyEx(foreground, foreground, MORPH_CLOSE, (3, 3));

	Mat imgThread;
	double ret = threshold(foreground, imgThread, 210, 255.0, THRESH_BINARY);
	// move_points = cv2.countNonZero(roi_thresh_image)  # this is total difference number
	
	vector<Blob> blobs = boundContour(imgThread);
	modelFPS.update();
	trackBlobs(blobs);
}

SimpleBlob::SimpleBlob() {
	// Change thresholds
	params.minThreshold = 10;
	params.maxThreshold = 200;

	// Filter by Area.
	params.filterByArea = true;
	params.minArea = 150;

	// Filter by Circularity
	params.filterByCircularity = true;
	params.minCircularity = 0.1f;

	// Filter by Convexity
	params.filterByConvexity = true;
	params.minConvexity = 0.87f;

	// Filter by Inertia
	params.filterByInertia = true;
	params.minInertiaRatio = 0.01f;

	// Set up detector with params
	detector = SimpleBlobDetector::create(params);
}

void SimpleBlob::detect(Mat frame) {
	Mat	roi = frameROI(frame);

	// Detect blobs
	detector->detect(roi, keypoints);

	vector<Blob> blobs;

	for (auto& point : keypoints) {
		float center_x = point.pt.x;
		float center_y = point.pt.y;

		float x = center_x - point.size / 2;
		float y = center_y - point.size / 2;
		float w = point.size;
		float h = point.size;
		Rect rectROI = Rect((int)x, (int)y, (int)w, (int)h);
		blobs.push_back(Blob(frameRect(rectROI), "Blob:"));
	}
	modelFPS.update();
	trackBlobs(blobs);
}

HOGDetector::HOGDetector() {
	hog.setSVMDetector(HOGDescriptor::getDefaultPeopleDetector());
	
	hog_d = HOGDescriptor(Size(48, 96), Size(16, 16), Size(8, 8), Size(8, 8), 9);
	hog_d.setSVMDetector(HOGDescriptor::getDaimlerPeopleDetector());
}

vector<Rect> HOGDetector::hogRect(InputArray img) {
	// Run the detector with default parameters. to get a higher hit-rate
	// (and more false alarms, respectively), decrease the hitThreshold and
	// groupThreshold (set groupThreshold to 0 to turn off the grouping completely).
	vector<Rect> rect;
	
	//hog.detectMultiScale(img, rect, 0, Size(8, 8), Size(32, 32), 1.05, 2, false);
	hog_d.detectMultiScale(img, rect, 0.5, Size(8, 8), Size(32, 32), 1.05, 2, true);
	return rect;
}

void HOGDetector::adjustRect(Rect& r) const
{
	// The HOG detector returns slightly larger rectangles than the real objects,
	// so we slightly shrink the rectangles to get a nicer output.
	r.x += cvRound(r.width * 0.1);
	r.width = cvRound(r.width * 0.8);
	r.y += cvRound(r.height * 0.07);
	r.height = cvRound(r.height * 0.8);
}

void HOGDetector::detect(Mat frame) {
	Mat	roi = frameROI(frame);
	vector<Rect> rect = hogRect(roi);

	vector<Blob> blobs;
	for (auto& rectROI : rect) {
		adjustRect(rectROI);
		blobs.push_back(Blob(frameRect(rectROI), "HOGDetector:"));
	}
	modelFPS.update();
	trackBlobs(blobs);
}

HaarCascade::HaarCascade() {
	// trained classifiers for detecting objects of a particular type, e.g.faces(frontal, profile), pedestrians etc.
	// Some of the classifiers have a special license - please, look into the files for details.

	// derive the paths to the YOLO weights and model configuration
	string faceCascadeName = "haarcascades/haarcascade_frontalface_default.xml";
	string eyesCascadeName = "haarcascades/haarcascade_eye.xml";
	// body_cascade_name = "haarcascades/haarcascade_fullbody.xml"
	// pedestrians_cascade_name = "haarcascades/hogcascade_pedestrians.xml"

	// Load the cascades
	faceCascade.load(modelPath + faceCascadeName);
	eyesCascade.load(modelPath + eyesCascadeName);
	// self.body_cascade.load("{}/{}".format(self.data.models_path, body_cascade_name))
	// self.pedestrians_cascade.load(pedestrians_cascade_name)
}

void HaarCascade::detect(Mat frame) {
	Mat	roi = frameROI(frame);
	Mat gray, smallImg;

	cvtColor(roi, gray, COLOR_BGR2GRAY);
	equalizeHist(gray, smallImg);

	vector<Rect> faces, eyes;
	faceCascade.detectMultiScale(smallImg, faces,
		1.1, 2, 0
		//|CASCADE_FIND_BIGGEST_OBJECT
		//|CASCADE_DO_ROUGH_SEARCH
		| CASCADE_SCALE_IMAGE,
		Size(30, 30));

#	// Detect faces
	vector<Blob> blobs;
	for (auto& rectFace : faces) {
		blobs.push_back(Blob(frameRect(rectFace), "face:"));

		// In each face, detect eyes
		Mat faceROI = smallImg(rectFace);
		eyesCascade.detectMultiScale(faceROI, eyes,
			1.1, 2, 0
			//|CASCADE_FIND_BIGGEST_OBJECT
			//|CASCADE_DO_ROUGH_SEARCH
			| CASCADE_SCALE_IMAGE,
			Size(30, 30));
		for (auto& rectEye : eyes) {
			blobs.push_back(Blob(frameRect(rectEye + Point(rectFace.x, rectFace.y)), "eye:"));
		}
	}		
	modelFPS.update();
	trackBlobs(blobs);
}

MultiTrack::MultiTrack(){
	multiTracker = MultiTracker::create();
}

Ptr<Tracker> MultiTrack::createTracker(string trackerType)
// create tracker by name
{
	Ptr<Tracker> tracker;
	if (trackerType == trackerTypes[0])
		tracker = TrackerBoosting::create();
	else if (trackerType == trackerTypes[1])
		tracker = TrackerMIL::create();
	else if (trackerType == trackerTypes[2])
		tracker = TrackerKCF::create();
	else if (trackerType == trackerTypes[3])
		tracker = TrackerTLD::create();
	else if (trackerType == trackerTypes[4])
		tracker = TrackerMedianFlow::create();
	else if (trackerType == trackerTypes[5])
		tracker = TrackerGOTURN::create();
	else if (trackerType == trackerTypes[6])
		tracker = TrackerMOSSE::create();
	else if (trackerType == trackerTypes[7])
		tracker = TrackerCSRT::create();
	else {
		cout << "Incorrect tracker name" << endl;
		cout << "Available trackers are: " << endl;
		for (vector<string>::iterator it = trackerTypes.begin(); it != trackerTypes.end(); ++it)
			cout << " " << *it << endl;
	}
	return tracker;
}

void MultiTrack::detect(Mat frame) {
	Mat	roi = frameROI(frame);

	if (selectMultiTrack && !box.empty()) {
		cout << "box selected\n";
		multiTracker->add(createTracker("CSRT"), roi, box);
		selectMultiTrack = false;
	}
	
	if (deselectMultiTrack) {
		cout << "deselected, and multi-tracker re-initiated\n";
		multiTracker = MultiTracker::create();
		deselectMultiTrack = false;
	}
	
	// update the tracking result with new frame
	
	multiTracker->update(roi);
	vector<Rect2d> boxes = multiTracker->getObjects();

	// draw tracked objects
	vector<Blob> blobs;
	for (auto& box : boxes) {
		blobs.push_back(Blob(frameRect(box), "MutiTrack:"));
	}
	modelFPS.update();
	trackBlobs(blobs);
}

void Color::detect(Mat frame) {
	Mat	roi = frameROI(frame);

	Mat blurred, roiHSV;
	GaussianBlur(roi, blurred, Size(11, 11), 0);
	cvtColor(blurred, roiHSV, COLOR_BGR2HSV);

	vector<Scalar> colorRange;
	if (selectColor) {
		// construct a mask for the color in Range(hsv, self.lower, self.upper), then perform
		// a series of dilationand erosion to remove any small blobs left in the mask
		// Get values from the HSV trackbar
		HMin = hsv[0] - 5 < 0 ? 0 : hsv[0] - 5;
		SMin = hsv[1] - 60 < 0 ? 0 : hsv[1] - 60;
		VMin = hsv[2] - 60 < 0 ? 0 : hsv[2] - 60;
		colorRange.push_back(Scalar(HMin, SMin, VMin));

		HMax = hsv[0] + 5 > 179 ? 179 : hsv[0] + 5;
		SMax = hsv[1] + 60 > 255 ? 255 : hsv[1] + 60;
		VMax = hsv[2] + 60 > 255 ? 255 : hsv[1] + 60;
		colorRange.push_back(Scalar(HMax, SMax, VMax));

		colorRanges.push_back(colorRange);
		selectColor = false;
	}

	if (deselectColor) {
		colorRanges.clear();
		deselectColor = false;
	}
	
	vector<Blob> blobs;
	for (auto& color : colorRanges) {
		Mat roiRange;
		vector<Blob> colorBlobs;
		inRange(roiHSV, color[0], color[1], roiRange);
		colorBlobs = boundContour(roiRange);
		
		//append a vector to another
		blobs.insert(end(blobs), begin(colorBlobs), end(colorBlobs));
	}
	modelFPS.update();
	trackBlobs(blobs);
}

Caffe::Caffe() {
	string protoFile = modelPath + "MobileNetSSD/MobileNetSSD_deploy.prototxt";
	string weightsFile = modelPath + "MobileNetSSD/MobileNetSSD_deploy.caffemodel";
	net = cv::dnn::readNetFromCaffe(protoFile, weightsFile);

	net.setPreferableBackend(cv::dnn::DNN_BACKEND_DEFAULT);
	net.setPreferableTarget(cv::dnn::DNN_TARGET_CPU);
}

void Caffe::detect(Mat frame) {
	Mat	roi = frameROI(frame);
	vector<Blob> blobs;

	static Mat imgRect;
	// Create a 4D blob from a frame.
	imgRect = cv::dnn::blobFromImage(roi, 0.007843, Size(300, 300),	127.5);

	// pass the blob through the network and obtain the detections and predictions
	net.setInput(imgRect);

	// Network produces output blob with a shape 1x1xNx7 where N is a number of
	// detections and an every detection is a vector of values
	// [batchId, classId, confidence, left, top, right, bottom]
	vector<Mat> outputs;
	net.forward(outputs);

	// loop over the detections
	for (size_t k = 0; k < outputs.size(); k++)
	{
		float* data = (float*)outputs[k].data;
		for (size_t i = 0; i < outputs[k].total(); i += 7)
		{
			float confidence = data[i + 2];
			if (confidence > confThreshold)
			{
				int left = (int)data[i + 3];
				int top = (int)data[i + 4];
				int right = (int)data[i + 5];
				int bottom = (int)data[i + 6];
				int width = right - left + 1;
				int height = bottom - top + 1;
				if (width * height <= 1)
				{
					left = (int)(data[i + 3] * roi.cols);
					top = (int)(data[i + 4] * roi.rows);
					right = (int)(data[i + 5] * roi.cols);
					bottom = (int)(data[i + 6] * roi.rows);
					width = right - left + 1;
					height = bottom - top + 1;
				}
				blobs.push_back(Blob(frameRect(Rect(left, top, width, height)), 
					LABELS[(int)data[i + 1]] + to_string((int)(confidence * 100)) + "%"));
			}
		}
	}
	modelFPS.update();
	trackBlobs(blobs);
}

Tensorflow::Tensorflow() : Model() {
	string protoFile = modelPath + "MobileNetSSD_V2/ssd_mobilenet_v2_coco_2018_03_29.pbtxt";
	string weightsFile = modelPath + "MobileNetSSD_V2/frozen_inference_graph.pb";
	net = cv::dnn::readNetFromTensorflow(weightsFile, protoFile);

	net.setPreferableBackend(cv::dnn::DNN_BACKEND_DEFAULT);
	net.setPreferableTarget(cv::dnn::DNN_TARGET_CPU);
}

void Tensorflow::detect(Mat frame) {
	Mat	roi = frameROI(frame);
	vector<Blob> blobs;

	static Mat imgRect;
	// Create a 4D blob from a frame.
	cv::dnn::blobFromImage(roi, imgRect, 1.0, Size(300, 300), Scalar(), true);

	// pass the blob through the network and obtain the detections and predictions
	net.setInput(imgRect);

	// Network produces output blob with a shape 1x1xNx7 where N is a number of
	// detections and an every detection is a vector of values
	// [batchId, classId, confidence, left, top, right, bottom]
	vector<Mat> outputs;
	net.forward(outputs);

	// loop over the detections
	for (size_t k = 0; k < outputs.size(); k++)
	{
		float* data = (float*)outputs[k].data;
		for (size_t i = 0; i < outputs[k].total(); i += 7)
		{
			float confidence = data[i + 2];
			if (confidence > confThreshold)
			{
				int left = (int)data[i + 3];
				int top = (int)data[i + 4];
				int right = (int)data[i + 5];
				int bottom = (int)data[i + 6];
				int width = right - left + 1;
				int height = bottom - top + 1;
				if (width * height <= 1)
				{
					left = (int)(data[i + 3] * roi.cols);
					top = (int)(data[i + 4] * roi.rows);
					right = (int)(data[i + 5] * roi.cols);
					bottom = (int)(data[i + 6] * roi.rows);
					width = right - left + 1;
					height = bottom - top + 1;
				}
				blobs.push_back(Blob(frameRect(Rect(left, top, width, height)), 
					LABELS[(int)data[i] + 1] + to_string((int)(confidence * 100)) + "%"));
			}
		}
	}
	modelFPS.update();
	trackBlobs(blobs);
}