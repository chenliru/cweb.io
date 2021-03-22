#pragma once

#include<iostream>
#include<opencv2/core/core.hpp>

////////////////////////////////////////////////////////////////////////////////////////////
class Blob {
public:
	// member variables ///////////////////////////////////////////////////////////////////////////
	std::vector<cv::Point> currentContour;

	cv::Rect currentBoundingRect;

	std::vector<cv::Point> centerPositions;

	double dblCurrentDiagonalSize;
	double dblCurrentAspectRatio;

	bool blnCurrentMatchFoundOrNewBlob;

	bool blnStillBeingTracked;

	int intNumOfConsecutiveFramesWithoutAMatch;

	cv::Point predictedNextPosition;

	// function prototypes ////////////////////////////////////////////////////////////////////////
	Blob(std::vector<cv::Point> _contour);
	void predictNextPosition(void);
};

