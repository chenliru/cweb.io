#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"

#include <iostream>
#include <stdio.h>
#include <stdlib.h>

using namespace cv;
using namespace std;

/// Global variables
Mat src, src_gray;
Mat f1;

int maxCorners = 23;
int maxTrackbar = 100;

RNG rng(12345);
string source_window = "Image";

const int direction = 90;	// camera installation direction

int range = 10;		// central monitoring area
int angle = 0;		// door rotate angle
int edge = -5;		// door edge line

int Y = 0;			// door central row
int X = 0;			// door central column


/// Function header
void goodFeaturesToTrack_Demo(int, void*);
void imgProcess(cv::Mat &img, cv::Mat &imgProcessed);
void rotate(cv::Mat &img, cv::Mat &imgRotate, int angle);
void crossLine(int &x, int &y, int &angle);

/**
 * @function main
 */
int main(int argc, char** argv)
{
	/// Load source image and convert it to gray
	src = imread("sample_x_output6.jpg");

	crossLine(X, Y, angle);

	cvtColor(src, src_gray, COLOR_BGR2GRAY);
	imgProcess(src, f1);

	/// Create Window
	namedWindow(source_window, WINDOW_AUTOSIZE);

	/// Create Trackbar to set the number of corners
	createTrackbar("Max  corners:", source_window, &maxCorners, maxTrackbar, goodFeaturesToTrack_Demo);

	imshow(source_window, src);
	imshow("f1", f1);

	goodFeaturesToTrack_Demo(0, 0);

	waitKey(0);
	return(0);
}

/**
 * @function goodFeaturesToTrack_Demo.cpp
 * @brief Apply Shi-Tomasi corner detector
 */
void goodFeaturesToTrack_Demo(int, void*)
{
	if (maxCorners < 1) { maxCorners = 1; }

	/// Parameters for Shi-Tomasi algorithm
	vector<Point2f> corners;
	double qualityLevel = 0.01;
	double minDistance = 10;
	int blockSize = 3;

	// bool useHarrisDetector = false;
	bool useHarrisDetector = true;
	double k = 0.04;

	/// Copy the source image
	Mat copy;
	copy = f1.clone();

	/// Apply corner detection
	goodFeaturesToTrack(f1,
		corners,
		maxCorners,
		qualityLevel,
		minDistance,
		Mat(),
		blockSize,
		useHarrisDetector,
		k);


	/// Draw corners detected
	cout << "** Number of corners detected: " << corners.size() << endl;
	int r = 4;
	for (int i = 0; i < corners.size(); i++)
	{
		circle(copy, corners[i], r, Scalar(rng.uniform(0, 255), rng.uniform(0, 255),
			rng.uniform(0, 255)), -1, 8, 0);
	}

	/// Show what you got
	namedWindow(source_window, WINDOW_AUTOSIZE);
	imshow(source_window, copy);
}


void imgProcess(cv::Mat &img, cv::Mat &imgProcessed)
{
	cv::Mat imgProcessing;

	if (direction == 90)
	{
		cv::rotate(img, img, cv::ROTATE_90_COUNTERCLOCKWISE);
	}

	imgProcessing = img(cv::Range(Y - range, Y + range), cv::Range((int)(img.cols * 0.01), (int)(img.cols * 0.99)));

	cv::cvtColor(imgProcessing, imgProcessing, COLOR_BGR2GRAY);
	cv::GaussianBlur(imgProcessing, imgProcessing, cv::Size(3, 3), 0);

	rotate(imgProcessing, imgProcessed, angle);
}


void rotate(cv::Mat &img, cv::Mat &imgRotate, int angle)
{
	// cv::Mat imgCopy = img.clone();

	cv::Point2f center = cv::Point2f(static_cast<float>(img.cols / 2), static_cast<float>(img.rows / 2));
	cv::Mat affineTrans = getRotationMatrix2D(center, angle, 1.0);

	cv::warpAffine(img, imgRotate, affineTrans, img.size());
}


void crossLine(int &x, int &y, int &angle)
{
	cv::Mat imgXCopy, imgYCopy, imgXRotate, imgYRotate, imgXLine, imgYLine;
	cv::Scalar meanX, meanY;

	cv::Mat imgX = cv::imread("sample_x_output6.jpg");
	cv::Mat imgY = cv::imread("sample_y_output6.jpg");

	if (direction == 90)
	{
		cv::rotate(imgX, imgX, cv::ROTATE_90_COUNTERCLOCKWISE);
		cv::rotate(imgY, imgY, cv::ROTATE_90_COUNTERCLOCKWISE);
	}

	imgXCopy = imgX.clone();
	imgYCopy = imgY.clone();

	cv::cvtColor(imgXCopy, imgXCopy, COLOR_BGR2GRAY);
	cv::cvtColor(imgYCopy, imgYCopy, COLOR_BGR2GRAY);
	cv::GaussianBlur(imgXCopy, imgXCopy, cv::Size(3, 3), 0);
	cv::GaussianBlur(imgYCopy, imgYCopy, cv::Size(3, 3), 0);

	int	minBlack = 255;

	for (int k = -5; k < 6; k++)
	{
		rotate(imgXCopy, imgXRotate, k);

		for (int i = 0; i < imgXRotate.rows - 1; i++)
		{
			imgXLine = imgXRotate(cv::Range(i, i + 1), cv::Range::all());
			meanX = cv::mean(imgXLine);

			if ((int)meanX[0] < minBlack)
			{
				minBlack = (int)meanX[0];

				y = i;
				angle = k;

				std::cout << "Y " << y << "  " << minBlack << "  " << angle << meanX << std::endl;
			}
		}
	}

	rotate(imgYCopy, imgYRotate, angle);

	int maxBlack = 0;

	for (int i = 0; i < imgYRotate.cols - 1; i++)
	{
		imgYLine = imgYRotate(cv::Range::all(), cv::Range(i, i + 1));
		meanY = cv::mean(imgYLine);

		if ((int)meanY[0] > maxBlack)
		{
			maxBlack = (int)meanY[0];

			x = i;

			std::cout << "X " << x << "  " << maxBlack << "  " << meanY << std::endl;
		}
	}

	// rotate(imgX, imgXR, angle);

	cv::line(imgX, cv::Point(0, y), cv::Point(imgX.cols, y), cv::Scalar(0, 0, 255), 2);	// horizontal
	cv::line(imgX, cv::Point(x, 0), cv::Point(x, imgY.rows), cv::Scalar(255, 0, 0), 2);	// Vertical

	cv::line(imgX, cv::Point(0, y - range), cv::Point(imgX.cols, y - range), cv::Scalar(0, 255, 0), 1);
	cv::line(imgX, cv::Point(0, y + range), cv::Point(imgX.cols, y + range), cv::Scalar(0, 255, 0), 1);

	cv::imshow("Good Matches & Object detection", imgX);

	cv::waitKey(0);
}

