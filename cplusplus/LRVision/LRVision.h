#include "common/Model.h"

// model: //////////////////////////////////////////////////////////////////////////////////////
// LRModel, Background, SimpleBlob, Diff2Frame, Diff3Frame, 
// HOGDetector, HaarCascade, MultiTrack, Color, Caffe, Tensorflow;
////////////////////////////////////////////////////////////////////////////////////////////////

template <typename T, typename C>
class LRVision : public Camera{
private:
	bool visionThreading{ false };
	vector<string> target;

	void visionModel(C*);

public:
	C model;
	C* pModel = & model;
	vector<C> models;
	thread modelThread;
	vector<thread> modelThreads;

	// function prototypes /////////////////////////////////////////////////////////////////////
	LRVision(C model, T device, int direct, string name, bool sync=true);

	// function prototypes ////////////////////////////////////////////////////////////////////////
	void vision();
	void stop();

	void keyOnVision(Mat, C*);
	static void mouseOnVision(int, int, int, int, void*);
};

