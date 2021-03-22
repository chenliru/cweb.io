#include <thread>
#include <mutex>
#include <chrono>
#include <deque>

#include "Common.h"

//#include <X11/Xlib.h>		//Linux only

int num = 0;	//Camera number

template <class T>
class Camera {
	// member variables ///////////////////////////////////////////////////////////////////////////

	VideoCapture capture;
	string cameraName = "";
	int direction = 0;

	int width, height;
	Mat image, frame, drawFrame;

	bool paused = false, async = false, showing = false, info = true;
	bool writeVideo = false, writeImages = false;

	int x_start = 0, y_start = 0, x_end = 0, y_end = 0;
	int	x_mouse = 0, y_mouse = 0;
	int cameraFPS = 30;
	int frames = -1;
	float readRate = 0.0;
	double frameID= 0.0;

	string imagePath, videoPath;
	FPS fpsMean;

	mutex mtx, mtxDraw;
	deque<Mat> frameDeque;

	VideoWriter writer;
	

	// function prototypes ////////////////////////////////////////////////////////////////////////
	Camera() {
		DataSet dataset(DATASET);
		imagePath = dataset.imagePath;
		videoPath = dataset.videoPath;

		num++;
	};
	//Camera(string device, int direct, string name);
	Mat read();
	void readSync();
	void readAsync();
	void rotate(Mat&, Mat&, int);

	void showCamera();

	void drawOn(Mat&);
	void imageOn(Mat);
	void cropOn(Mat);
	void recordOn(Mat);
	void imagesOn(Mat);
	void keyOnCamera(Mat);
	static void mouseOnCamera(int, int, int, int, void*);

public:
	Camera(T device, int direct, string name, bool sync=true);
	void start();
	void stop();
	void show();
	thread readThread, showThread;
};


