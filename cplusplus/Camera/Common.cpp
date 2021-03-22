#include "Common.h"

DataSet::DataSet(string root) {
	string rootDir = root;
	imagePath = rootDir + "/images/", videoPath = rootDir + "/videos/", modelPath = rootDir + "/models/";

//	if (!exists(imagePath))	{
//		create_directories(imagePath);
//		cout << imagePath << " created\n";
//	}
//	if (!exists(videoPath))	{
//		create_directories(videoPath);
//		cout << videoPath << " created\n";
//	}
//	if (!exists(modelPath))	{
//		create_directories(modelPath);
//		cout << modelPath << " created\n";
//	}
}

FPS::FPS() {}

float FPS::elapsed() {
	clock_t t = clock() - tStart;
	return ((float)t / CLOCKS_PER_SEC);
}

void FPS::update() {
	num += 1;
}

float FPS::fps() {
	return num / elapsed();
}
