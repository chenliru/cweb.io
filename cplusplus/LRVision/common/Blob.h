// Blob.h

#ifndef MY_BLOB
#define MY_BLOB

#include<opencv2/core/core.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<opencv2/imgproc/imgproc.hpp>

#include <deque>

#include <iostream>
#include <stdlib.h>
#include <string>

using namespace cv;
using namespace std;

///////////////////////////////////////////////////////////////////////////////////////////////////
/*
    A Blob is a group of connected pixels in an image that share some common property
    ( E.g grayscale value, color, shape...). In the image above, the common property connected regions are blobs,
    and the goal of blob detection is to identify and mark these regions with rich properties
*/

class Blob {
public:
	// member variables ///////////////////////////////////////////////////////////////////////////
	Rect rect;
	string label;

	Point nextPosition;
	deque<cv::Point> centerPositions;

	Scalar color;
	Point center;
	double diagonalSize;
	double aspectRatio;
	double area{ 0 };
	Vec4i line{ 0, 0, 0, 0 };
	int age{ 0 };
	bool counted{ false };
	string direction{ "" };
	bool infoBlob{ true };

	// function prototypes ////////////////////////////////////////////////////////////////////////
	Blob(Rect, String);
	Point predictNextPosition(void);
	string checkDirection(int, int);

	Mat drawBlob(Mat);
	Mat drawDirection(Mat);
	Mat drawLine(Mat);
	Mat drawDistance(Mat);

};

class Blobs {
	bool firstFrame;

	void matchBlobs(vector<Blob>&);
	void addBlobAsOld(Blob&, int&);
	void addBlobAsNew(Blob&);
	double distance(Point, Point);

public:
	const static int LIFETIME = 7;

	//# tracked blobs
	vector<Blob> blobs;

	// function prototypes ////////////////////////////////////////////////////////////////////////////
	Blobs();
	void trackBlobs(vector<Blob>&);
};
#endif    // MY_BLOB
