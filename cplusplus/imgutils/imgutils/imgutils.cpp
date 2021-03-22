// imgutils.cpp

#include<opencv2/highgui/highgui.hpp>
#include<opencv2/imgproc/imgproc.hpp>

#include "blob.hpp"
#include "imgutils.hpp"


#define SHOW_STEPS            // un-comment or comment this line to show steps or not

// global variables ///////////////////////////////////////////////////////////////////////////////
const cv::Scalar SCALAR_BLACK = cv::Scalar(0.0, 0.0, 0.0);
const cv::Scalar SCALAR_WHITE = cv::Scalar(255.0, 255.0, 255.0);
const cv::Scalar SCALAR_YELLOW = cv::Scalar(0.0, 255.0, 255.0);
const cv::Scalar SCALAR_GREEN = cv::Scalar(0.0, 200.0, 0.0);
const cv::Scalar SCALAR_RED = cv::Scalar(0.0, 0.0, 255.0);

std::vector<Blob> blobs;
cv::Point crossingLine[2];

int carCount = 0;
int frameCount = 2;

char chCheckForEscKey = 0;
// bool blnFirstFrame = true;
bool blnAtLeastOneBlobCrossedTheLine;

// function prototypes ////////////////////////////////////////////////////////////////////////////
void matchCurrentFrameBlobsToExistingBlobs(std::vector<Blob> &existingBlobs, std::vector<Blob> &currentFrameBlobs);
void addBlobToExistingBlobs(Blob &currentFrameBlob, std::vector<Blob> &existingBlobs, int &intIndex);
void addNewBlob(Blob &currentFrameBlob, std::vector<Blob> &existingBlobs);
double distanceBetweenPoints(cv::Point point1, cv::Point point2);
void drawAndShowContours(cv::Size imageSize, std::vector<std::vector<cv::Point> > contours, std::string strImageName);
void drawAndShowContours(cv::Size imageSize, std::vector<Blob> blobs, std::string strImageName);

// bool checkIfBlobsCrossedTheLine(std::vector<Blob> &blobs, int &intHorizontalLinePosition, int &carCount);

bool checkIfBlobsCrossedTheLine(std::vector<Blob> &blobs);
void drawBlobInfoOnImage(std::vector<Blob> &blobs, cv::Mat &imgFrame2Copy);
void drawCarCountOnImage(int &carCount, cv::Mat &imgFrame2Copy);


///////////////////////////////////////////////////////////////////////////////////////////////////
bool movingDirection(cv::Mat imgFrame1, cv::Mat imgFrame2) {

	std::vector<Blob> currentFrameBlobs;

	cv::Mat imgFrame1Copy = imgFrame1.clone();
	cv::Mat imgFrame2Copy = imgFrame2.clone();

	cv::Mat imgDifference;
	cv::Mat imgThresh;

	// int intHorizontalLinePosition = (int)std::round((double)imgFrame1.rows * 0.35);

	// crossingLine[0].x = 0;
	// crossingLine[0].y = intHorizontalLinePosition;

	// crossingLine[1].x = imgFrame1.cols - 1;
	// crossingLine[1].y = intHorizontalLinePosition;

	cv::cvtColor(imgFrame1Copy, imgFrame1Copy, cv::COLOR_BGR2GRAY);
	cv::cvtColor(imgFrame2Copy, imgFrame2Copy, cv::COLOR_BGR2GRAY);

	cv::GaussianBlur(imgFrame1Copy, imgFrame1Copy, cv::Size(5, 5), 0);
	cv::GaussianBlur(imgFrame2Copy, imgFrame2Copy, cv::Size(5, 5), 0);

	cv::absdiff(imgFrame1Copy, imgFrame2Copy, imgDifference);

	cv::threshold(imgDifference, imgThresh, 30, 255.0, cv::THRESH_BINARY);

	// cv::imshow("imgThresh", imgThresh);

	// cv::Mat structuringElement3x3 = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(3, 3));
	// cv::Mat structuringElement7x7 = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(7, 7));
	// cv::Mat structuringElement15x15 = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(15, 15));
	cv::Mat structuringElement5x5 = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(5, 5));

	for (unsigned int i = 0; i < 2; i++) {
		cv::dilate(imgThresh, imgThresh, structuringElement5x5);
		cv::dilate(imgThresh, imgThresh, structuringElement5x5);
		cv::erode(imgThresh, imgThresh, structuringElement5x5);
	}

	cv::Mat imgThreshCopy = imgThresh.clone();

	std::vector<std::vector<cv::Point> > contours;

	cv::findContours(imgThreshCopy, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);

	// drawAndShowContours(imgThresh.size(), contours, "imgContours");

	std::vector<std::vector<cv::Point> > convexHulls(contours.size());

	for (unsigned int i = 0; i < contours.size(); i++) {
		cv::convexHull(contours[i], convexHulls[i]);
	}

	// drawAndShowContours(imgThresh.size(), convexHulls, "imgConvexHulls");

	for (auto &convexHull : convexHulls) {
		Blob possibleBlob(convexHull);

		if (possibleBlob.currentBoundingRect.area() > 400 &&
			possibleBlob.dblCurrentAspectRatio > 0.2 &&
			possibleBlob.dblCurrentAspectRatio < 4.0 &&
			possibleBlob.currentBoundingRect.width > 30 &&
			possibleBlob.currentBoundingRect.height > 30 &&
			possibleBlob.dblCurrentDiagonalSize > 60.0 &&
			(cv::contourArea(possibleBlob.currentContour) / (double)possibleBlob.currentBoundingRect.area()) > 0.50) {
			currentFrameBlobs.push_back(possibleBlob);
		}
	}

	// drawAndShowContours(imgThresh.size(), currentFrameBlobs, "imgCurrentFrameBlobs");

	/*
	if (blnFirstFrame == true) {
		for (auto &currentFrameBlob : currentFrameBlobs) {
			blobs.push_back(currentFrameBlob);
		}
	} else {
		matchCurrentFrameBlobsToExistingBlobs(blobs, currentFrameBlobs);
	}
	*/

	matchCurrentFrameBlobsToExistingBlobs(blobs, currentFrameBlobs);

	// drawAndShowContours(imgThresh.size(), blobs, "imgBlobs");

	imgFrame2Copy = imgFrame2.clone();          // get another copy of frame 2 since we changed the previous frame 2 copy in the processing above

	drawBlobInfoOnImage(blobs, imgFrame2Copy);

	// bool blnAtLeastOneBlobCrossedTheLine = checkIfBlobsCrossedTheLine(blobs, intHorizontalLinePosition, carCount);
	bool blnAtLeastOneBlobCrossedTheLine = checkIfBlobsCrossedTheLine(blobs);

	/*
	if (blnAtLeastOneBlobCrossedTheLine == true) {
		cv::line(imgFrame2Copy, crossingLine[0], crossingLine[1], SCALAR_GREEN, 2);
	} else {
		cv::line(imgFrame2Copy, crossingLine[0], crossingLine[1], SCALAR_RED, 2);
	}
	*/


	// drawCarCountOnImage(carCount, imgFrame2Copy);

	// cv::imshow("imgFrame2Copy", imgFrame2Copy);

	//cv::waitKey(0);                 // uncomment this line to go frame by frame for debugging

	// now we prepare for the next iteration

	currentFrameBlobs.clear();

	// imgFrame1 = imgFrame2.clone();           // move frame 1 up to where frame 2 is

	// blnFirstFrame = false;
	//frameCount++;
	// chCheckForEscKey = cv::waitKey(1);

	return(blnAtLeastOneBlobCrossedTheLine);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void matchCurrentFrameBlobsToExistingBlobs(std::vector<Blob> &existingBlobs, std::vector<Blob> &currentFrameBlobs) {

	for (auto &existingBlob : existingBlobs) {

		existingBlob.blnCurrentMatchFoundOrNewBlob = false;

		existingBlob.predictNextPosition();
	}

	for (auto &currentFrameBlob : currentFrameBlobs) {

		int intIndexOfLeastDistance = 0;
		double dblLeastDistance = 100000.0;

		for (unsigned int i = 0; i < existingBlobs.size(); i++) {

			if (existingBlobs[i].blnStillBeingTracked == true) {

				double dblDistance = distanceBetweenPoints(currentFrameBlob.centerPositions.back(), existingBlobs[i].predictedNextPosition);

				if (dblDistance < dblLeastDistance) {
					dblLeastDistance = dblDistance;
					intIndexOfLeastDistance = i;
				}
			}
		}

		if (dblLeastDistance < currentFrameBlob.dblCurrentDiagonalSize * 0.5) {
			addBlobToExistingBlobs(currentFrameBlob, existingBlobs, intIndexOfLeastDistance);
		}
		else {
			addNewBlob(currentFrameBlob, existingBlobs);
		}

	}

	for (auto &existingBlob : existingBlobs) {

		if (existingBlob.blnCurrentMatchFoundOrNewBlob == false) {
			existingBlob.intNumOfConsecutiveFramesWithoutAMatch++;
		}

		if (existingBlob.intNumOfConsecutiveFramesWithoutAMatch >= 5) {
			existingBlob.blnStillBeingTracked = false;
		}

	}

}

///////////////////////////////////////////////////////////////////////////////////////////////////
void addBlobToExistingBlobs(Blob &currentFrameBlob, std::vector<Blob> &existingBlobs, int &intIndex) {

	existingBlobs[intIndex].currentContour = currentFrameBlob.currentContour;
	existingBlobs[intIndex].currentBoundingRect = currentFrameBlob.currentBoundingRect;

	existingBlobs[intIndex].centerPositions.push_back(currentFrameBlob.centerPositions.back());

	existingBlobs[intIndex].dblCurrentDiagonalSize = currentFrameBlob.dblCurrentDiagonalSize;
	existingBlobs[intIndex].dblCurrentAspectRatio = currentFrameBlob.dblCurrentAspectRatio;

	existingBlobs[intIndex].blnStillBeingTracked = true;
	existingBlobs[intIndex].blnCurrentMatchFoundOrNewBlob = true;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void addNewBlob(Blob &currentFrameBlob, std::vector<Blob> &existingBlobs) {

	currentFrameBlob.blnCurrentMatchFoundOrNewBlob = true;

	existingBlobs.push_back(currentFrameBlob);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
double distanceBetweenPoints(cv::Point point1, cv::Point point2) {

	int intX = abs(point1.x - point2.x);
	int intY = abs(point1.y - point2.y);

	return(sqrt(pow(intX, 2) + pow(intY, 2)));
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void drawAndShowContours(cv::Size imageSize, std::vector<std::vector<cv::Point> > contours, std::string strImageName) {
	cv::Mat image(imageSize, CV_8UC3, SCALAR_BLACK);

	cv::drawContours(image, contours, -1, SCALAR_WHITE, -1);

	cv::imshow(strImageName, image);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void drawAndShowContours(cv::Size imageSize, std::vector<Blob> blobs, std::string strImageName) {

	cv::Mat image(imageSize, CV_8UC3, SCALAR_BLACK);

	std::vector<std::vector<cv::Point> > contours;

	for (auto &blob : blobs) {
		if (blob.blnStillBeingTracked == true) {
			contours.push_back(blob.currentContour);
		}
	}

	cv::drawContours(image, contours, -1, SCALAR_WHITE, -1);

	cv::imshow(strImageName, image);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/*
bool checkIfBlobsCrossedTheLine(std::vector<Blob> &blobs, int &intHorizontalLinePosition, int &carCount) {
	bool blnAtLeastOneBlobCrossedTheLine = false;

	for (auto blob : blobs) {

		if (blob.blnStillBeingTracked == true && blob.centerPositions.size() >= 2) {
			int prevFrameIndex = (int)blob.centerPositions.size() - 2;
			int currFrameIndex = (int)blob.centerPositions.size() - 1;

			if (blob.centerPositions[prevFrameIndex].y > intHorizontalLinePosition && blob.centerPositions[currFrameIndex].y <= intHorizontalLinePosition) {
				carCount++;
				blnAtLeastOneBlobCrossedTheLine = true;
			}
		}

	}

	return blnAtLeastOneBlobCrossedTheLine;
}
*/

bool checkIfBlobsCrossedTheLine(std::vector<Blob> &blobs) {
	blnAtLeastOneBlobCrossedTheLine = false;

	for (auto blob : blobs) {

		if (blob.blnStillBeingTracked == true && blob.centerPositions.size() >= 2) {
			int prevFrameIndex = (int)blob.centerPositions.size() - 2;
			int currFrameIndex = (int)blob.centerPositions.size() - 1;

			if (blob.centerPositions[prevFrameIndex].y < blob.centerPositions[currFrameIndex].y) {
				// carCount++;
				blnAtLeastOneBlobCrossedTheLine = true;
			}
		}

	}

	return blnAtLeastOneBlobCrossedTheLine;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void drawBlobInfoOnImage(std::vector<Blob> &blobs, cv::Mat &imgFrame2Copy) {

	for (unsigned int i = 0; i < blobs.size(); i++) {

		if (blobs[i].blnStillBeingTracked == true) {
			cv::rectangle(imgFrame2Copy, blobs[i].currentBoundingRect, SCALAR_RED, 2);

			int intFontFace = cv::FONT_HERSHEY_SIMPLEX;
			double dblFontScale = blobs[i].dblCurrentDiagonalSize / 120.0;
			int intFontThickness = (int)std::round(dblFontScale * 1.0);

			if (blnAtLeastOneBlobCrossedTheLine) {
				cv::putText(imgFrame2Copy, std::to_string(i), blobs[i].centerPositions.back(), intFontFace, dblFontScale, SCALAR_GREEN, intFontThickness);
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void drawCarCountOnImage(int &carCount, cv::Mat &imgFrame2Copy) {

	int intFontFace = cv::FONT_HERSHEY_SIMPLEX;
	double dblFontScale = (imgFrame2Copy.rows * imgFrame2Copy.cols) / 300000.0;
	int intFontThickness = (int)std::round(dblFontScale * 1.5);

	cv::Size textSize = cv::getTextSize(std::to_string(carCount), intFontFace, dblFontScale, intFontThickness, 0);

	cv::Point ptTextBottomLeftPosition;

	ptTextBottomLeftPosition.x = imgFrame2Copy.cols - 1 - (int)((double)textSize.width * 1.25);
	ptTextBottomLeftPosition.y = (int)((double)textSize.height * 1.25);

	cv::putText(imgFrame2Copy, std::to_string(carCount), ptTextBottomLeftPosition, intFontFace, dblFontScale, SCALAR_GREEN, intFontThickness);

}

void doorEdgeCorner(cv::Mat &img, std::vector<cv::Point2f> &corners)
{
	/// Parameters for Shi-Tomasi algorithm
	int maxCorners = 2;
	double qualityLevel = 0.01;
	double minDistance = 10;
	int blockSize = 3;
	// bool useHarrisDetector = false;
	bool useHarrisDetector = true;
	double k = 0.04;

	cv::Mat imgCopy = img.clone();
	// cv::RNG rng(12345);

	/// Apply corner detection
	goodFeaturesToTrack(imgCopy,
		corners,
		maxCorners,
		qualityLevel,
		minDistance,
		cv::Mat(),
		blockSize,
		useHarrisDetector,
		k);

	/// Draw corners detected
	/*
	std::cout << "** Number of corners detected: " << corners.size() << std::endl;
	int r = 4;
	for (int i = 0; i < corners.size(); i++)
	{
		cv::circle(imgCopy, corners[i], r, cv::Scalar(rng.uniform(0, 255), rng.uniform(0, 255),
			rng.uniform(0, 255)), -1, 8, 0);
	}

	imshow("Corner", imgCopy);
	*/
}

void doorRotate(cv::Mat &img, cv::Mat &imgRotate, int angle)
{
	// cv::Mat imgCopy = img.clone();

	cv::Point2f center = cv::Point2f(static_cast<float>(img.cols / 2), static_cast<float>(img.rows / 2));
	cv::Mat affineTrans = getRotationMatrix2D(center, angle, 1.0);
	
	cv::warpAffine(img, imgRotate, affineTrans, img.size());
}


void img3Diff(cv::Mat &d1, cv::Mat &d2, cv::Mat &d3, cv::Mat &imgBitWiseAnd)
{
	cv::Mat img1Difference;
	cv::Mat img2Difference;
	/*
	cv::Mat d1Copy = d1.clone();
	cv::Mat d2Copy = d2.clone();
	cv::Mat d3Copy = d3.clone();
	*/

	cv::absdiff(d1, d2, img1Difference);
	cv::absdiff(d2, d3, img2Difference);

	cv::bitwise_and(img1Difference, img2Difference, imgBitWiseAnd);
}

