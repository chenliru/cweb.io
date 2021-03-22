#pragma once

#include "doorimg.hpp"

#include <opencv2/optflow.hpp>
#include <opencv2/videoio.hpp>


using namespace cv::motempl;

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

//
//bool monitorCenterBlack(cv::Mat &imgC, cv::Mat &img1, cv::Mat &img2);
DLL_API bool monitorCenterBlack(cv::Mat &imgC, cv::Mat &img1, cv::Mat &img2, int *point, Monitor &monitor, bool show = false);
//
DLL_API bool updateMHI(const cv::Mat& img, cv::Mat& dst, int thresholdDiff, Monitor& monitor);
//
DLL_API void saveSample(char flag, Monitor &monitor, bool show = false);
//
DLL_API void findWhiteLine(int &y, Monitor &monitor, bool show = false);
//
DLL_API void swapPixel(int *px, int *py);