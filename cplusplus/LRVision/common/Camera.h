#include <thread>
#include "Common.h"

//#include <X11/Xlib.h>		//Linux only

//template <typename T>
class Camera {
	static int num;
	
	void readSync();
	void readAsync();
	void rotate(Mat&, Mat&, int);
	void showCamera();
	void keyOnCamera(Mat);
	static void mouseOnCamera(int, int, int, int, void*);
	thread readThread, showThread;

public:
	// member variables ///////////////////////////////////////////////////////////////////////////
	VideoCapture capture;
	string cameraName{ "Camera" };
	int direction{ 0 };

	int width, height;
	Mat image, frame, drawFrame;

	bool paused{ false }, async{ false }, showThreading{ false }, info{ true };
	bool writeVideo{ false }, writeImages{ false };

	int x_start{ 0 }, y_start{ 0 }, x_end{ 0 }, y_end{ 0 };
	int	x_mouse{ 0 }, y_mouse{ 0 };
	int cameraFPS{ 0 };
	int frames{ -1 };
	float readRate{ 0.0 };
	double frameID{ 0.0 };

	string imagePath, videoPath;
	FPS fpsMean;

	VideoWriter writer;

	// function prototypes ////////////////////////////////////////////////////////////////////////
	Camera(int device, int direct, string name, bool sync=true);

	void start();
	void stop();
	Mat read();
	void show();

	void imageOnCamera(Mat);
	void cropOnCamera(Mat);
	void recordOnCamera(Mat);
	void imagesOnCamera(Mat);
	Mat drawOnCamera(Mat&);
};
