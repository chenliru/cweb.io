#include<opencv2/core/core.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<opencv2/imgproc/imgproc.hpp>

#include <filesystem>
#include <iostream>
#include <string>

//#define LINUX
#define WINDOWS

using namespace std;
using namespace cv;
using namespace std::filesystem;

// global variables ///////////////////////////////////////////////////////////////////////////
#ifdef WINDOWS
	constexpr auto DATASET = "c://users//chenliru//github//data//";
#else
	constexpr auto DATASET = "/home/pi/data/";
#endif

const Scalar SCALAR_WHITE = Scalar(255.0, 255.0, 255.0);
const Scalar SCALAR_BLACK = Scalar(0.0, 0.0, 0.0);
const Scalar SCALAR_BLUE = Scalar(255.0, 0.0, 0.0);
const Scalar SCALAR_GREEN = Scalar(0.0, 200.0, 0.0);
const Scalar SCALAR_RED = Scalar(0.0, 0.0, 255.0);

class DataSet {
public:
	//initialize the data set directories
	string imagePath, videoPath;
	string modelPath;

	// function prototypes ////////////////////////////////////////////////////////////////////////
	DataSet(string root);
};

class FPS {
private:
	clock_t tStart = clock();
	float num = 0.0;
public:
	// function prototypes ////////////////////////////////////////////////////////////////////////
	FPS();
	void update(void);
	float elapsed(void);
	float fps(void);
};
