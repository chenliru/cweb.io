//doorimg.cpp

#include "doorimg.hpp"
#include "../../imgutils/imgutils/imgutils.hpp"

using namespace std;
using namespace cv;


int Monitor::setMonitor(bool setting)
{
	if (!setting)
	{
		return 1;
	}

	ifstream file("monitor.txt");

	std::vector<string> monitorParaNames;
	std::vector<float> values;

	string monitorParaName;
	float value;

	while (file >> monitorParaName >> value)
	{
		monitorParaNames.push_back(monitorParaName);
		values.push_back(value);
	}

	for (unsigned int i = 0; i < monitorParaNames.size(); i++)
	{

		if (monitorParaNames[i] == "RelayPin")
		{
			RelayPin = values[i];		// raspberry pin
		}
		else if (monitorParaNames[i] == "videoDevice")
		{
			videoDevice = values[i];		// camera number
		}
		else if (monitorParaNames[i] == "videoWidth")
		{
			videoWidth = values[i];		
		}
		else if (monitorParaNames[i] == "videoHight")
		{
			videoHight = values[i];		// various tracking parameters (in seconds)
		}
		else if (monitorParaNames[i] == "direction")
		{
			direction = values[i];		// camera installation direction: (0 | 90)
		}
		else if (monitorParaNames[i] == "rangeX")
		{
			rangeX = values[i];		// central monitoring area, column, width
		}
		else if (monitorParaNames[i] == "rangeY")
		{
			rangeY = values[i];		// central monitoring area, rows, height
		}
		else if (monitorParaNames[i] == "angle")
		{
			angle = values[i];		// door rotate angle
		}
		else if (monitorParaNames[i] == "edge")
		{
			edge = values[i];		// door edge line
		}
		else if (monitorParaNames[i] == "X")
		{
			X = values[i];			// door central column
		}
		else if (monitorParaNames[i] == "Y")
		{
			Y = values[i];			// door central row
		}
		else if (monitorParaNames[i] == "whiteY")
		{
			whiteY = values[i];			
		}
		else if (monitorParaNames[i] == "frames")
		{
			frames = values[i];		// total frames monitored, 4 bytes, 0 to 4,294,967,295
		}
		else if (monitorParaNames[i] == "fps")
		{
			fps = values[i];			
		}
		else if (monitorParaNames[i] == "last")
		{
			last = values[i];			
		}
		else if (monitorParaNames[i] == "frameSkipNum")
		{
			frameSkipNum = values[i];
		}
	}

	return 0;
}

int Monitor::setThreadhold(bool setting)
{
	if (!setting)
	{
		return 1;
	}

	ifstream file("threadhold.txt");

	std::vector<string> threadNames;
	std::vector<float> values;

	string threadName;
	float value;

	while (file >> threadName >> value)
	{
		threadNames.push_back(threadName);
		values.push_back(value);
	}

	for (unsigned int i = 0; i < threadNames.size(); i++) 
	{

		if (threadNames[i] == "thresholdMoving" ) 
		{
			thresholdMoving = values[i];		// bright threshold detecting moving object
		}
		else if(threadNames[i] == "thresholdStatic")
		{
			thresholdStatic = values[i];		// bright threshold detecting static object
		}
		else if (threadNames[i] == "thresholdFrame")
		{
			thresholdFrame = values[i];
		}
		else if (threadNames[i] == "MHI_DURATION")
		{
			MHI_DURATION = values[i];		// various tracking parameters (in seconds)
		}
		else if (threadNames[i] == "MAX_TIME_DELTA")
		{
			MAX_TIME_DELTA = values[i];		// various tracking parameters (in seconds)
		}
		else if (threadNames[i] == "MIN_TIME_DELTA")
		{
			MIN_TIME_DELTA = values[i];		// various tracking parameters (in seconds)
		}
		else if (threadNames[i] == "thresholdMovingNum")
		{
			thresholdMovingNum = values[i];
		}
		else if (threadNames[i] == "thresholdStaticNum")
		{
			thresholdStaticNum = values[i];
		}
		else if (threadNames[i] == "thresholdBlackMinNum")
		{
			thresholdBlackMinNum = values[i];
		}
		else if (threadNames[i] == "thresholdBlack")
		{
			thresholdBlack = values[i];			//bright threshold detecting black object
		}
		else if (threadNames[i] == "thresholdBlackPoint")
		{
			thresholdBlackPoint = values[i];	//find door Point
		}
		else if (threadNames[i] == "alpha")
		{
			alpha = values[i];			// Simple contrast control
		}

	}

	return 0;
}

int Monitor::setStatus(bool setting)
{
	if (!setting)
	{
		return 1;
	}

	ifstream file("status.txt");

	std::vector<string> statusNames;
	std::vector<bool> values;

	string statusName;
	bool value;

	while (file >> statusName >> value)
	{
		statusNames.push_back(statusName);
		values.push_back(value);
	}

	for (unsigned int i = 0; i < statusNames.size(); i++)
	{

		if (statusNames[i] == "front")
		{
			front = values[i];		// monitor front: yes | no
		}
		else if (statusNames[i] == "gpioStatus")
		{
			gpioStatus = values[i];		// control gpio output of raspberry
		}
		else if (statusNames[i] == "centralStatus")
		{
			centralStatus = values[i];		// objects in central area: yes | no
		}
		else if (statusNames[i] == "centralBlackStatus")
		{
			centralBlackStatus = values[i];		//black objects in central area: yes | no
		}
		else if (statusNames[i] == "frontStatus")
		{
			frontStatus = values[i];			// objects in front area: yes: | no
		}

	}

	return 0;
}

int Monitor::setFile(bool setting)
{
	if (!setting)
	{
		return 1;
	}

	ifstream file("file.txt");

	std::vector<string> fileNames;
	std::vector<string> values;

	string fileName;
	string value;

	while (file >> fileName >> value)
	{
		fileNames.push_back(fileName);
		values.push_back(value);
	}

	for (unsigned int i = 0; i < fileNames.size(); i++)
	{

		if (fileNames[i] == "inputFileName")
		{
			inputFileName = values[i];			// processing recorded video, or using real time camera
		}
		else if (fileNames[i] == "outputFileName")
		{
			outputFileName = values[i];		// control gpio output of raspberry
		}
	}

	return 0;
}


void imgProcess(cv::Mat &img, cv::Mat &imgProcessed, Monitor& monitor)
{
	Mat imgProcessing;

	imgProcessing = img(Range(monitor.Y - monitor.rangeY, monitor.Y + monitor.rangeY), Range::all());

	cvtColor(imgProcessing, imgProcessing, COLOR_BGR2GRAY);
	GaussianBlur(imgProcessing, imgProcessing, Size(3, 3), 0);

	doorRotate(imgProcessing, imgProcessed, monitor.angle);
}


void coordinateLine(Monitor& monitor, bool show)
{
	Mat imgXCopy, imgYCopy, imgXRotate, imgYRotate, imgXLine, imgYLine;
	Scalar meanX, meanY;
	
	string fileX = "sample_x_" + monitor.inputFileName + ".jpg";
	string fileY = "sample_y_" + monitor.inputFileName + ".jpg";
	
	Mat imgX = imread(fileX);
	Mat imgY = imread(fileY);

	cout << "Direction " << monitor.direction << endl;

	if (monitor.direction == 90)
	{
		// rotate function from openCV
		rotate(imgX, imgX, cv::ROTATE_90_COUNTERCLOCKWISE);
		rotate(imgY, imgY, cv::ROTATE_90_COUNTERCLOCKWISE);
	}

	imgXCopy = imgX.clone();
	imgYCopy = imgY.clone();

	cvtColor(imgXCopy, imgXCopy, COLOR_BGR2GRAY);
	cvtColor(imgYCopy, imgYCopy, COLOR_BGR2GRAY);

	GaussianBlur(imgXCopy, imgXCopy, Size(3, 3), 0);
	GaussianBlur(imgYCopy, imgYCopy, Size(3, 3), 0);

	int minBlack = 255;

	for (int k = -5; k < 6; k++)
	{
		doorRotate(imgXCopy, imgXRotate, k);	//rotate from imgutils

		//		for (int i = 4; i < imgXRotate.rows - 1; i++)
		for (int i = 30; i < 400; i++)
		{
			imgXLine = imgXRotate(Range(i, i + 1), Range::all());
			meanX = cv::mean(imgXLine);

			if ((int)meanX[0] < minBlack)
			{
				minBlack = (int)meanX[0];

				monitor.Y = i;
				monitor.angle = k;

				cout << "Y " << monitor.Y << " minBlack  " << minBlack 
					 << "angle  " << monitor.angle << " meanBlack " << meanX << endl;
			}
		}
	}

	doorRotate(imgYCopy, imgYRotate, monitor.angle);

	int maxBlack = 0;

	for (int i = 0; i < imgYRotate.cols - 1; i++)
	{
		imgYLine = imgYRotate(Range::all(), Range(i, i + 1));
		meanY = mean(imgYLine);

		if ((int)meanY[0] > maxBlack)
		{
			maxBlack = (int)meanY[0];

			monitor.X = i;

			// std::cout << "X " << x << "  " << maxBlack << "  " << meanY << std::endl;
		}
	}

	// rotate(imgX, imgXR, angle);

	line(imgX, Point(0, monitor.Y), Point(imgX.cols, monitor.Y), Scalar(0, 0, 255), 2);	// horizontal
	line(imgX, Point(monitor.X, 0), Point(monitor.X, imgY.rows), Scalar(255, 0, 0), 2);	// Vertical

	line(imgX, Point(0, monitor.Y - monitor.rangeY), Point(imgX.cols, monitor.Y - monitor.rangeY), Scalar(0, 255, 0), 1);
	line(imgX, Point(0, monitor.Y + monitor.rangeY), Point(imgX.cols, monitor.Y + monitor.rangeY), Scalar(0, 255, 0), 1);
	line(imgX, Point(monitor.X - monitor.rangeX, monitor.Y - monitor.rangeY), Point(monitor.X - monitor.rangeX, monitor.Y 
		+ monitor.rangeY), Scalar(0, 255, 0), 1);
	line(imgX, Point(monitor.X + monitor.rangeX, monitor.Y - monitor.rangeY), Point(monitor.X + monitor.rangeX, monitor.Y 
		+ monitor.rangeY), Scalar(0, 255, 0), 1);

	if (show)
	{
		imshow("Good Matches", imgX);
		waitKey(0);
	}
}

bool monitorCentral(cv::Mat &imgDiff, cv::Mat &imgOri, Monitor& monitor, bool show)
{
	//	cv::namedWindow("imgOri", CV_WINDOW_NORMAL);
	
	// # Calculate Threshold value
	// # signal = False

	int diffNum = 0, oriNum = 0;
	Scalar imgOriMean;

	Mat imgDiffMonitoring = imgDiff(Range(monitor.rangeY, monitor.rangeY + 1), Range(0, imgDiff.cols));
	Mat imgOriMonitoring = imgOri(Range(monitor.rangeY - 1, monitor.rangeY + 1), Range(0, imgOri.cols));

	Mat meanDiff = monitor.alpha * imgDiffMonitoring - mean(imgDiffMonitoring);
	//std::cout << "meanDiff: " << meanDiff << std::endl;

	imgOriMean = mean(imgOriMonitoring);
	//	std::cout << "imgOrimean: " << imgOriMean << std::endl;
	for (int i = 0; i < meanDiff.cols; ++i)
	{
		if (meanDiff.at<uchar>(0, i) > monitor.thresholdMoving)
		{
			diffNum++;
		}
	}

	Mat meanOri = monitor.alpha * imgOriMonitoring - mean(imgOriMonitoring);
	//	std::cout << "meanOri: " << meanOri << std::endl;
	
	for (int k = 0; k < 2; ++k)
	{
		for (int j = 0; j < meanOri.cols; ++j)
		{
			if ((int)meanOri.at<uchar>(k, j) > monitor.thresholdStatic)
			{
				oriNum++;
			}
		}
	}

	cout << "DIFF Number: " << diffNum << endl;
	cout << "ORI Number: " << oriNum << endl;

	if (show)
	{
		imshow("imgOri", imgOriMean);
		waitKey(1);
	}

	if (diffNum > monitor.thresholdMovingNum)
	{
		cout << "Moving Object !" << endl;
		return true;
	}

	if (oriNum > monitor.thresholdStaticNum)
	{
		cout << "Static Object !" << endl;
		return true;
	}
	
	return false;
}

bool monitorFront(cv::Mat &imgC, cv::Mat &img1, cv::Mat &img2, Monitor& monitor, bool show)
{
	// cv::Point pointLeft, pointRight;
	vector<Point2f> corners;
	Mat imgCopy = img2.clone();

	Mat imgCentor = imgC(Range::all(), Range(monitor.X - monitor.rangeX + 2, monitor.X + monitor.rangeX - 2));
	
	doorEdgeCorner(imgCentor, corners);

	if (monitor.front &&
		corners.size() == 2 &&
		abs(corners[0].x - corners[1].x) > 5 &&
		(((corners[1].x < monitor.rangeX && corners[0].x > monitor.rangeX)) ||
		((corners[0].x < monitor.rangeX && corners[1].x > monitor.rangeX))) &&
		abs((abs(monitor.rangeX - corners[0].x) - abs(monitor.rangeX - corners[1].x))) < 10
		)
	{
		cout << "Corners : " << abs(monitor.rangeX - corners[0].x) << " "
			<< abs(monitor.rangeX - corners[1].x) << endl;

		// Draw the corners
		circle(imgCopy, Point2d(corners[0].x + monitor.X - monitor.rangeX, corners[0].y +
			monitor.Y - monitor.rangeY), 2, Scalar(0, 0, 255), -1, 8);
		circle(imgCopy, Point2d(corners[1].x + monitor.X - monitor.rangeX, corners[1].y +
			monitor.Y - monitor.rangeY), 2, Scalar(0, 255, 0), -1, 8);

		rectangle(imgCopy, Point2d(corners[0].x + monitor.X - monitor.rangeX, corners[0].y +
			monitor.Y - monitor.rangeY - 50),
			Point2d(corners[1].x + monitor.X - monitor.rangeX, corners[1].y + monitor.Y -
			monitor.rangeY - 140), Scalar(0, 0, 255), 1, 8);

		Mat imgFrame1 = img1(Rect(Point2d(corners[0].x + monitor.X - monitor.rangeX, corners[0].y
			+ monitor.Y - monitor.rangeY - 50), Point2d(corners[1].x + monitor.X - monitor.rangeX,
			corners[1].y + monitor.Y - monitor.rangeY - 140)));

		Mat imgFrame2 = img2(Rect(Point2d(corners[0].x + monitor.X - monitor.rangeX, corners[0].y 
			+ monitor.Y - monitor.rangeY - 50), Point2d(corners[1].x + monitor.X - monitor.rangeX,
			corners[1].y + monitor.Y - monitor.rangeY - 140)));

		if (show)
		{
			imshow("showCentral", imgCopy);
			waitKey(1);

		}

		return movingDirection(imgFrame1, imgFrame2);
	}
	return false;
}

