
#include "doorimg.hpp"

#include <opencv2/optflow.hpp>
#include <opencv2/videoio.hpp>


using namespace cv::motempl;


bool updateMHI(const cv::Mat& img, cv::Mat& dst, int thresholdDiff, Monitor& monitor)
{
	double timestamp = (double)clock() / CLOCKS_PER_SEC; // get current time in seconds
	Size size = img.size();

	Rect compRect;
	Point center;
	Scalar color;

	double count;
	double angle;
	double magnitude;

	bool single = false;
	int i, idx1 = monitor.last;


	// allocate images at the beginning or
	// reallocate them if the frame size is changed
	if (mhi.size() != size)
	{
		mhi = cv::Mat::zeros(size, CV_32F);
		zplane = cv::Mat::zeros(size, CV_8U);

		monitor.buf[0] = cv::Mat::zeros(size, CV_8U);
		monitor.buf[1] = cv::Mat::zeros(size, CV_8U);
	}

	cvtColor(img, monitor.buf[monitor.last], COLOR_BGR2GRAY); // convert frame to grayscale

	int idx2 = (monitor.last + 1) % 2; // index of (last - (N-1))th frame
	monitor.last = idx2;

	Mat silh = monitor.buf[idx2];
	absdiff(monitor.buf[idx1], monitor.buf[idx2], silh); // get difference between frames

	threshold(silh, silh, thresholdDiff, 1, THRESH_BINARY); // and threshold it
	updateMotionHistory(silh, mhi, timestamp, monitor.MHI_DURATION); // update MHI

	// convert MHI to blue 8u image
	mhi.convertTo(mask, CV_8U, 255. / monitor.MHI_DURATION, (monitor.MHI_DURATION - timestamp)*255. / monitor.MHI_DURATION);

	Mat planes[] = { mask, zplane, zplane };
	merge(planes, 3, dst);

	// calculate motion gradient orientation and valid orientation mask
	calcMotionGradient(mhi, mask, orient, monitor.MAX_TIME_DELTA, monitor.MIN_TIME_DELTA, 3);

	// segment motion: get sequence of motion components
	// segmask is marked motion components map. It is not used further
	regions.clear();
	segmentMotion(mhi, segmask, regions, timestamp, monitor.MAX_TIME_DELTA);

	// iterate through the motion components,
	// One more iteration (i == -1) corresponds to the whole image (global motion)
	for (i = -1; i < (int)regions.size(); i++) {

		if (i < 0) { // case of the whole image
			compRect = Rect(0, 0, size.width, size.height);
			color = Scalar(255, 255, 255);
			magnitude = 100;
		}
		else { // i-th motion component
			compRect = regions[i];
			if (compRect.width + compRect.height < 100) // reject very small components
				continue;
			color = Scalar(0, 0, 255);
			magnitude = 30;
		}

		// select component ROI
		Mat silhROI = silh(compRect);
		Mat mhiROI = mhi(compRect);
		Mat orientROI = orient(compRect);
		Mat maskROI = mask(compRect);

		// calculate orientation
		angle = calcGlobalOrientation(orientROI, maskROI, mhiROI, timestamp, monitor.MHI_DURATION);
		angle = 360.0 - angle;  // adjust for images with top-left origin

		count = norm(silhROI, NORM_L1);; // calculate number of points within silhouette ROI

		// check for the case of little motion
		if (count < compRect.width*compRect.height * 0.05)
			continue;

		// draw a clock with arrow indicating the direction
		center = Point((compRect.x + compRect.width / 2),
			(compRect.y + compRect.height / 2));

		circle(img, center, cvRound(magnitude*1.2), color, 3, 16, 0);
		line(img, center, Point(cvRound(center.x + magnitude * cos(angle*CV_PI / 180)),
			cvRound(center.y - magnitude * sin(angle*CV_PI / 180))), color, 3, 16, 0);

		if ((angle > 220) && (angle < 320))
		{
			single = true;
			std::cout << "angle = " << angle << std::endl;
		}
		return single;
	}
	return single;
}


void findWhiteLine(int &y, Monitor& monitor, bool show)
{
	int whiteNum = 0;
	int whiteNumCopy = 0;

	Mat img = imread("sample_x_" + monitor.outputFileName + ".jpg");

	if (monitor.direction == 90)
	{
		rotate(img, img, ROTATE_90_COUNTERCLOCKWISE);
	}

	Mat imgCopy = img.clone();

	Mat imgcenter1 = imgCopy(Range(monitor.Y - monitor.rangeY - 1, monitor.Y),
		Range(monitor.X - monitor.rangeX, monitor.X + monitor.rangeX + 20));

	Mat imgcenter = monitor.alpha * imgcenter1 - mean(imgcenter1);

	cvtColor(imgcenter, imgcenter, CV_BGR2GRAY);
	GaussianBlur(imgcenter, imgcenter, Size(3, 3), 0);

	cout << "angle = " << monitor.angle << endl;
	rotate(imgcenter, imgcenter, monitor.angle);

	//	cv::Mat imgcenter= imgCopy(cv::Rect(cv::Point2d(X+rangeX+20 , Y- rangeY - 1), cv::Point2d(X - rangeX, Y - rangeY + 10)));
	//	cv::Mat imgcenter = imgCopy(cv::Rect(cv::Point2d(X+rangeX, Y+rangeY-1), cv::Point2d(X-rangeX, Y - rangeY - 10)));

	for (int j = 0; j < imgcenter.rows; ++j)
	{
		for (int i = 0; i < imgcenter.cols; ++i)
		{
			if (imgcenter.at<uchar>(j, i) > 0)
			{
				whiteNumCopy++;
			}
		}

		cout << "whiteNum = " << whiteNumCopy << endl;

		if (whiteNumCopy > whiteNum)
		{
			whiteNum = whiteNumCopy;
			y = j;
			cout << "whiteY = " << y << endl;
		}
		whiteNumCopy = 0;
	}

	if (show)
	{
		imshow("imgcenter", imgcenter);
		imshow("img", img);
		waitKey(0);
	}
}


bool monitorCenterBlack(cv::Mat &imgC, cv::Mat &img1, cv::Mat &img2, int *point, Monitor& monitor, bool show)
{
	bool single = false;
	int k1, k2;
	int blackNum = 0;

	vector<Point2f> corners;
	Mat imgCopy = img2.clone();

	Mat imgFrame1 = imgCopy(Range(monitor.Y - monitor.rangeY - 1, monitor.Y),
		Range(monitor.X - monitor.rangeX, monitor.X + monitor.rangeX));

	cvtColor(imgFrame1, imgFrame1, CV_BGR2GRAY);
	rotate(imgFrame1, imgFrame1, monitor.angle);
	// write line
	Mat meanBlack2 = 1.2* imgFrame1 - mean(imgFrame1);
	// cout << "meanBlack2:" << meanBlack2<< endl;

	Mat meanBlack = meanBlack2(Range(monitor.whiteY, monitor.whiteY + 1), Range::all());
	//	cout << "meanBlack:" << meanBlack<< endl;

	for (k1 = 0; k1 < meanBlack.cols - 3; ++k1)
	{
		int c = fabs(meanBlack.at<uchar>(0, k1) - meanBlack.at<uchar>(0, k1 + 1));

		if (meanBlack.at<uchar>(0, k1) > monitor.thresholdBlackPoint)
		{
			break;
		}
	}

	for (k2 = (meanBlack.cols - 1); k2 > 0; --k2)
	{
		int c = fabs(meanBlack.at<uchar>(0, k2) - meanBlack.at<uchar>(0, k2 - 1));

		if (meanBlack.at<uchar>(0, k2) > monitor.thresholdBlackPoint)
		{
			break;
		}
	}

	circle(imgCopy, Point2d(k2 + monitor.X - monitor.rangeX, monitor.Y + monitor.whiteY),
		2, Scalar(0, 0, 255), -1, 8);
	circle(imgCopy, Point2d(k1 + monitor.X - monitor.rangeX, monitor.Y + monitor.whiteY),
		2, Scalar(0, 0, 255), -1, 8);

	if ((k1 < k2))
	{
		Mat meanBlack1 = meanBlack(Range::all(), Range((k1), (k2)));
		//		std::cout << "meanBlack1:" << meanBlack1 << std::endl;
		point[0] = k1;
		point[1] = k2;
		for (int j = 0; j < meanBlack1.cols; ++j)
		{
			if (meanBlack1.at<uchar>(0, j) < monitor.thresholdBlack)
			{
				blackNum++;
			}
		}

		cout << "blackNum:" << blackNum << endl;
	}

	//	if((blackNum > thresholdBlackMinNum) && (blackNum < thresholdBlackMaxNum) && (blackAllNum < 110))
	if ((blackNum > monitor.thresholdBlackMinNum))
	{
		cout << "black block" << endl;
		single = true;
	}

	if (show)
	{
		imshow("meanBlack2", meanBlack2);
		waitKey(1);

		imshow("showCentral", meanBlack);
		waitKey(1);

		imshow("imgCopy", imgCopy);
		waitKey(1);

	}

	return single;
}

//flag = 0 save sample_x*, flag = 1 save sample_y_*.jpg
void saveSample(char flag, Monitor& monitor, bool show)
{
	VideoCapture capVideo;

	capVideo.open(monitor.videoDevice);

	char chCheckForEscKey = 0;

	capVideo.set(3, monitor.videoWidth);
	capVideo.set(4, monitor.videoHight);

	while (capVideo.isOpened() && chCheckForEscKey != 27)
	{
		Scalar average;
		Mat frame, imgFramMinus, imgFrame, imgBitWiseAnd, img1Diff, img2Diff,
			dstframe, dstimgFramMinus, dstimgFrame;
		vector<int> compression_params;

		compression_params.push_back(CV_IMWRITE_JPEG_QUALITY);
		compression_params.push_back(100);

		capVideo >> frame;
		capVideo >> imgFramMinus;
		capVideo >> imgFrame;

		cvtColor(frame, dstframe, COLOR_BGR2GRAY);
		cvtColor(imgFramMinus, dstimgFramMinus, COLOR_BGR2GRAY);
		cvtColor(imgFrame, dstimgFrame, COLOR_BGR2GRAY);

		img3Diff(dstframe, dstimgFramMinus, dstimgFrame, imgBitWiseAnd);
		medianBlur(imgBitWiseAnd, imgBitWiseAnd, (3, 3));

		average = mean(imgBitWiseAnd);

		cout << "\n" << average[0] << endl;
		cout << "mean(frame) = " << mean(frame)[0] << endl;

		if ((flag == 0) && (0 < average[0]) && (average[0] < 0.3) && (mean(frame)[0] > 68))
		{
			imwrite("sample_x_" + monitor.outputFileName + ".jpg", frame, compression_params);
			break;
		}
		if ((flag == 1) && (1 < average[0]) && (average[0] < 2) && (mean(frame)[0] < 50))
		{
			imwrite("sample_y_" + monitor.outputFileName + ".jpg", frame, compression_params);
			break;
		}

		chCheckForEscKey = waitKey(1);

		if (show)
		{
			imshow("frame", frame);
			waitKey(1);
		}

	}
	capVideo.release();

}

void swapPixel(int *px, int *py)
{
	int tmp = *px;
	*px = *py;
	*py = tmp;
}
