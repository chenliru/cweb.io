// imgutils.hpp

#include <iostream>
#include <opencv2/core/core.hpp>

///////////////////////////////////////////////////////////////////////////////////////////////////
#if defined DLL_EXPORT
#define DLL_API __declspec(dllexport)
#else
#define DLL_API __declspec(dllimport)
#endif

#define DLL_EXPORT

// basic functions used by smartvision package
DLL_API bool movingDirection(cv::Mat imgFrame1, cv::Mat imgFrame2);
DLL_API void img3Diff(cv::Mat &d1, cv::Mat &d2, cv::Mat &d3, cv::Mat &imgBitWiseAnd);
DLL_API void doorRotate(cv::Mat &img, cv::Mat &imgRotate, int angle);
DLL_API void doorEdgeCorner(cv::Mat &img, std::vector<cv::Point2f> &corners);
