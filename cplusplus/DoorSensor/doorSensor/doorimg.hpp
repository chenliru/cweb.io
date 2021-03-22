#pragma once
#include <fstream>
#include <string>
#include <chrono>
#include <ctime>

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>


using namespace std;
using namespace cv;

//#include <conio.h>           // it may be necessary to change or remove this line if not using Window
//#include <unistd.h>
//#include <wiringPi.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
#if defined DLL_EXPORT
#define DLL_API __declspec(dllexport)
#else
#define DLL_API __declspec(dllimport)
#endif

#define DLL_EXPORT


DLL_API class Monitor
{
public:

	// global variables ///////////////////////////////////////////////////////////////////////////////
	int RelayPin = 13;

	int videoDevice = 0;

	int videoWidth = 640;
	int videoHight = 480;

	int direction = 0;			// camera installation direction: (0 | 90)

	int thresholdMoving = 50;	// bright threshold detecting moving object
	int thresholdStatic = 100;	// bright threshold detecting static object
	int thresholdFrame = 0;

	// various tracking parameters (in seconds)
	double MHI_DURATION = 0.2;
	double MAX_TIME_DELTA = 0.2;
	double MIN_TIME_DELTA = 0.02;

	int thresholdMovingNum = 5;                         //5
	int thresholdStaticNum = 20;                        //6
	int thresholdBlackMinNum = 10;
	//int thresholdBlackMaxNum = 90;
	int thresholdBlack = 25;                //bright threshold detecting black object
	int thresholdBlackPoint = 40;			//find door Point
	double alpha = 1.2;						// Simple contrast control

	int rangeX = 75;			// central monitoring area, column, width
	int rangeY = 4;				// central monitoring area, rows, height

	int angle = 0;				// door rotate angle
	int edge = -5;				// door edge line

	int X = 0;					// door central column
	int Y = 0;					// door central row
	int whiteY = 0;

	unsigned int frames = 0;	// 4 bytes, 0 to 4,294,967,295
	double fps = 0.0;

	int last = 0;

	int frameSkipNum = 0;

	string inputFileName = "None";
	string outputFileName = "output10";

	bool front = true;			// monitor front door area: (true | false)

	bool gpioStatus = true;				// False = open,  True = close
	bool centralStatus = false;			// False = open,  True = close
	bool centralBlackStatus = false;
	bool frontStatus = false;

	const Scalar SCALAR_GREEN = Scalar(0.0, 200.0, 0.0);
	const Scalar SCALAR_RED = Scalar(0.0, 0.0, 255.0);

	vector<Mat> buf;

	// temporary images
	Mat mhi, orient, mask, segmask, zplane;
	vector<Rect> regions;

	// function prototypes /////////////////////////////////////////////////////////
	DLL_API int setMonitor(bool setting = true);
	DLL_API int setThreadhold(bool setting = true);
	DLL_API int setStatus(bool setting = true);
	DLL_API int setFile(bool setting = true);
};

//
DLL_API bool monitorCentral(cv::Mat &imgDiff, cv::Mat &imgOri, Monitor &monitor, bool show = false);
//
DLL_API void imgProcess(cv::Mat &img, cv::Mat &imgProcessed, Monitor &monitor);
//
DLL_API void coordinateLine(Monitor& monitor, bool show = false);
//
DLL_API bool monitorFront(cv::Mat &imgC, cv::Mat &img1, cv::Mat &img2, Monitor &monitor, bool show = false);
//

