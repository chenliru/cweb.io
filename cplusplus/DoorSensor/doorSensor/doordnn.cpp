// doordnn.cpp

#include "doordnn.hpp"

String modelBinFile = "ResNet.caffemodel";
String modelTxtFile = "ResNet.prototxt";

Net net = readNetFromCaffe(modelTxtFile, modelBinFile);

int Dnn::setDnn(bool setting)
{
	if (!setting)
	{
		return 1;
	}

	ifstream file("dnn.txt");

	std::vector<string> dnnParaNames;
	std::vector<float> values;

	string dnnParaName;
	float value;

	while (file >> dnnParaName >> value)
	{
		dnnParaNames.push_back(dnnParaName);
		values.push_back(value);
	}

	for (unsigned int i = 0; i < dnnParaNames.size(); i++)
	{

		if (dnnParaNames[i] == "xLabel")
		{
			xLabel = values[i];		// raspberry pin
		}
		else if (dnnParaNames[i] == "yLabel")
		{
			yLabel = values[i];		// camera number
		}
		else if (dnnParaNames[i] == "widthRect")
		{
			widthRect = values[i];
		}
		else if (dnnParaNames[i] == "heightRect")
		{
			heightRect = values[i];		// various tracking parameters (in seconds)
		}
		else if (dnnParaNames[i] == "width")
		{
			width = values[i];		// camera installation direction: (0 | 90)
		}
		else if (dnnParaNames[i] == "height")
		{
			height = values[i];		// central monitoring area, column, width
		}
		else if (dnnParaNames[i] == "scaleFactor")
		{
			scaleFactor = values[i];		// central monitoring area, rows, height
		}
		
	}

	return 0;
}


bool monitorCentral(Mat &srcImg, int &classIndx)
{
	Dnn dnn;

	/*get region of interest Mat*/
	Mat frameROI;
	
	Rect rect(dnn.xLabel, dnn.yLabel, dnn.widthRect, dnn.heightRect);
	frameROI = srcImg(rect);

	imshow("frameROI", frameROI);
	waitKey(1);

	if (frameROI.empty())
	{
		printf("could not load current frame...\n");
		return 1;
	}

	/*preprocess the ROI Mat*/
	Mat processedROI;
	
	frameROI.convertTo(processedROI, CV_32F);
	resize(processedROI, processedROI, Size(dnn.width, dnn.height)); // 32 x 32 image

	/*get the blob image*/
	Mat inputBlob = blobFromImage(processedROI, dnn.scaleFactor, Size(dnn.width, dnn.height), 
		Scalar(104, 117, 123), false);
	
	net.setInput(inputBlob, "data");
	
	Mat prob;
	prob = net.forward("Addmm_1");

	// Mat probMat = prob.reshape(1, 1);
	Mat probMat = prob;

	/*get the predict results*/
	Point classNumber;
	double classProb;
	
	minMaxLoc(probMat, NULL, &classProb, NULL, &classNumber);
	
	classIndx = classNumber.x;
	
	cout << "current image classification:" << classIndx << endl;

	/*print the predict results*/
	if (classIndx == 0)
	{
		cout << "Object Moving !!!" << endl;
		return true;
	}

	else if (classIndx == 1)
	{
		cout << "No Object Moving" << endl;
		return false;
	}

}
