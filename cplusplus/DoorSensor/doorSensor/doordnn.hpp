#pragma once
#include <iostream>
#include <fstream>

#include <opencv2/dnn.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

using namespace std;
using namespace cv;
using namespace cv::dnn;

///////////////////////////////////////////////////////////////////////////////////////////////////
#if defined DLL_EXPORT
#define DLL_API __declspec(dllexport)
#else
#define DLL_API __declspec(dllimport)
#endif

#define DLL_EXPORT

DLL_API class Dnn
{
public:

	/*define region of interest on frame*/
	int xLabel = 64;
	int yLabel = 204;
	int widthRect = 512;
	int heightRect = 38;

	/*the processed frame size*/
	size_t width = 32;
	size_t height = 32;

	/*default params for frame Mat to blob*/
	float scaleFactor = 0.007843f;

	int setDnn(bool setting = true);

};


DLL_API bool monitorCentral(Mat &srcImg, int &classIndx);
