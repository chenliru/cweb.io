#include <opencv2/video/background_segm.hpp>
#include <opencv2/features2d.hpp>
#include <opencv2/objdetect.hpp>
#include <opencv2/tracking.hpp>
#include <opencv2/dnn.hpp>

#include "Blob.h"
#include "Camera.h"

//using namespace cv::dnn;

class Model : public Blobs {
public:
	vector<string> target;

	string modelName{ "model" };	// use uniform initialization
	string imagePath;
	string videoPath;
	string modelPath;
	//float modelRate { 0.0};
	FPS modelFPS{};
	
	//define Region Of Interest
	bool defaultROI{ true };
	int xROI{ 0 }, yROI{ 0 }, wROI{ 0 }, hROI{ 0 };

	//scale factor along the horizontal axis and the vertical axis
	float scale{ 1.0 };
	float xScale{ 1.0 };
	float yScale{ 1.0 };

	//Model info
	bool infoModel{ true };
	bool infoBlob{ true };
	bool infoCount{ false };
	bool infoDirection{ false };
	bool infoDistance{ false };

	int BLOB_COUNT_UP{ 0 }, BLOB_COUNT_DOWN{ 0 };

	//control properties used in inheritance class

	//#################################################################
	//	Model Diff2frame, Diff3frame
	//#################################################################
	bool firstFrame{ true };
	Mat roiDiff0, roiDiff1, roiDiff2;

	//#################################################################
	//	Model MultiTrack #
	//#################################################################
	Rect box;	// Selected boxes
	bool selectMultiTrack{ false };
	bool deselectMultiTrack{ false };

	// ################################################################
	//  Model Color
	//  define the lower and upper boundaries of the "green"
	//  in the HSV color space : H: 0 to 179 S : 0 to 255 V : 0 to 255
	//#################################################################

	Vec3b hsv;	// tracking color
	bool selectColor{ false };
	bool deselectColor{ false };

	//#################################################################
	// Model CascadeClassifier
	//#################################################################
	bool beepOn{ false };

	//#################################################################
	// Model Lane
	//#################################################################
	bool infoLanes{ false };

	//	self.left_lane, self.right_lane = None, None
	Point2i	leftFoot { 0, 0 };
	Point2i	rightFoot { 0, 0 };

	//#################################################################
	// Model BarCode
	//#################################################################
	bool infoBarCode{ false };
	//self.barcode_data, self.barcode_points, self.barcode_rect = None, None, None

	/////////////////////////////////////////////////////////////////////////////////////////
	Model();	// create a default constructor

	Mat frameROI(Mat);
	Rect frameRect(Rect);
	void detect(Mat);

	Mat drawOnModel(Mat);
	Mat drawBlobsOn(Mat);
	//Mat drawBarCodeOn(Mat);
	//Mat drawLanesOn(Mat);

	Mat drawCountOn(Mat, Blob);
	Mat drawBlobDirectionOn(Mat, Blob);
	Mat drawDistanceOn(Mat, Blob);
};

class Diff2Frame : public Model {
public:
	string modelName{ "Diff2frame" };
	
	Mat f0, f1;
	bool firstFrame{ true };

	/////////////////////////////////////////////////////////////////////////////////////////
	vector<Blob> boundContour(Mat);
	Diff2Frame() {};
	void detect(Mat);
};

class Diff3Frame : public Diff2Frame {
public:
	string modelName{ "Diff3Frame" };

	// initialize the list of class labels MobileNet SSD was trained to
	// detect, then generate a set of bounding box colors for each class
	bool firstFrame{ true };

	// Function to calculate difference between 3 images/////////////////////
	Diff3Frame() {};
	void detect(Mat);
};

class Background : public Diff2Frame {
	//create Background Subtractor objects
	Ptr<BackgroundSubtractor> pBackSubMOG2 = createBackgroundSubtractorMOG2();
	Ptr<BackgroundSubtractor> pBackSubKNN = createBackgroundSubtractorKNN();
public:
	string name{ "Background" };

	// Function to calculate difference using Backgroung substractor /////////////
	void detect(Mat);
};

class SimpleBlob : public Model {
	// Setup SimpleBlobDetector parameters
	SimpleBlobDetector::Params params;

	// Storage for blobs
	vector<KeyPoint> keypoints;
public:
	string modelName{ "SimpleBlob" };

	// Set up detector
	Ptr<SimpleBlobDetector> detector;

	// Function to calculate simple blobs ////////////////////////////////////////
	SimpleBlob();
	void detect(Mat);
};

class HOGDetector : public Model {
	HOGDescriptor hog, hog_d;
public:
	string modelName{ "HOGDetector" };

	// Function to calculate HOGDetector blobs ///////////////////////////////////
	HOGDetector();
	vector<Rect> hogRect(InputArray);
	void adjustRect(Rect&) const;
	void detect(Mat);
};

class HaarCascade : public Model {
	CascadeClassifier faceCascade, eyesCascade;
public:
	// Load HAAR cascade
	string modelName{ "HaarCascade" };

	// Function to calculate HOGDetector blobs //////////////////////////////////
	HaarCascade();
	void detect(Mat);
};

class MultiTrack : public Model {
	vector<string> trackerTypes = { "BOOSTING", "MIL", "KCF", "TLD", "MEDIANFLOW", "GOTURN", "MOSSE", "CSRT" };
public:
	/* Create MultiTracker object
		There are two ways you can initialize MultiTracker
		1. tracker = cv2.MultiTracker("CSRT")
		All the trackers added to this MultiTracker
		will use CSRT algorithm as default
		2. tracker = cv2.MultiTracker()
		No default algorithm specified """
	*/

	string modelName{ "MultiTracker" };

	Ptr<MultiTracker> multiTracker;

	/////////////////////////////////////////////////////////////////////////////////////////
	MultiTrack();
	Ptr<Tracker> createTracker(string);
	void detect(Mat);
};

class Color : public Diff2Frame {
public:
	string modelName = "Color";

	// define the lower and upper boundaries of the "green"
	// ball in the HSV color space : H: 0 to 179 S : 0 to 255 V : 0 to 255
	int HMin{ 0 }, SMin{ 0 }, VMin{ 0 };
	int HMax{ 179 }, SMax{ 255 }, VMax{ 255 };

	vector<vector<Scalar>> colorRanges;

	/////////////////////////////////////////////////////////////////////////////////////////
	void detect(Mat);
};

class Caffe : public Model {
	// initialize the list of class labels MobileNet SSD was trained to
	// detect, then generate a set of bounding box colors for each class
	vector<string> LABELS = { "background", "aeroplane", "bicycle", "bird", "boat",
		"bottle", "bus", "car", "cat", "chair", "cow", "diningtable",
		"dog", "horse", "motorbike", "person", "pottedplant", "sheep",
		"sofa", "train", "tvmonitor" };

public:
	string modelName{ "Caffe" };
	cv::dnn::Net net;
	float confThreshold{ 0.5 };

	/////////////////////////////////////////////////////////////////////////////////////////
	Caffe();
	void detect(Mat frame);
};

class Tensorflow : public Model {
	// initialize the list of class labels MobileNet SSD was trained to
	// detect, then generate a set of bounding box colors for each class
	vector<string> LABELS = { "background",
				  "person", "bicycle", "car", "motorcycle", "airplane", "bus",
				  "train", "truck", "boat", "traffic light", "fire hydrant",
				  "stop sign", "parking meter", "bench", "bird", "cat",
				  "dog", "horse", "sheep", "cow", "elephant", "bear",
				  "zebra", "giraffe", "backpack", "umbrella", "handbag",
				  "tie", "suitcase", "frisbee", "skis", "snowboard",
				  "sports ball", "kite", "baseball bat", "baseball glove",
				  "skateboard", "surfboard", "tennis racket", "bottle",
				  "wine glass", "cup", "fork", "knife", "spoon",
				  "bowl", "banana", "apple", "sandwich", "orange",
				  "broccoli", "carrot", "hot dog", "pizza", "donut",
				  "cake", "chair", "couch", "potted plant", "bed",
				  "dining table", "toilet", "tv", "laptop", "mouse",
				  "remote", "keyboard", "cell phone", "microwave", "oven",
				  "toaster", "sink", "refrigerator", "book", "clock",
				  "vase", "scissors", "teddy bear", "hair drier", "toothbrush" };

public:
	string modelName{ "Tensorflow" };
	cv::dnn::Net net;
	float confThreshold{ 0.5 };

	/////////////////////////////////////////////////////////////////////////////////////////
	Tensorflow();
	void detect(Mat frame);
};
