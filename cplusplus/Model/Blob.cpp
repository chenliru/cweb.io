// Blob.cpp
#include<conio.h>			// it may be necessary to change or remove this line if not using Windows
#include "Blob.h"

#define SHOW_STEPS			// un-comment or comment this line to show steps or not

///////////////////////////////////////////////////////////////////////////////////////////////////
Blob::Blob(Rect rawRect, String rawLabel) {
	Point center;

	rect = rawRect;
	label = rawLabel;

	center.x = rect.x + rect.width / 2;
	center.y = rect.y + rect.height / 2;
	centerPositions.push_back(center);
	
	color = Scalar(rand() % 255, rand() % 255, rand() % 255);
	diagonalSize = sqrt(pow(rect.width, 2) + pow(rect.height, 2));
	aspectRatio = (float)rect.width / (float)rect.height;
	area = (double)rect.width * (double)rect.height;
	age = 0;
	counted = false;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
Point Blob::predictNextPosition(void) {

	//auto Positions = centerPositions.size();

	if (centerPositions.size() == 1) {

		nextPosition.x = centerPositions.back().x;
		nextPosition.y = centerPositions.back().y;

	}
	else if (centerPositions.size() == 2) {

		int deltaX = centerPositions[1].x - centerPositions[0].x;
		int deltaY = centerPositions[1].y - centerPositions[0].y;

		nextPosition.x = centerPositions.back().x + deltaX;
		nextPosition.y = centerPositions.back().y + deltaY;

	}
	else if (centerPositions.size() == 3) {

		int sumOfXChanges = ((centerPositions[2].x - centerPositions[1].x) * 2) +
			((centerPositions[1].x - centerPositions[0].x) * 1);

		int deltaX = (int)round((float)sumOfXChanges / 3.0);

		int sumOfYChanges = ((centerPositions[2].y - centerPositions[1].y) * 2) +
			((centerPositions[1].y - centerPositions[0].y) * 1);

		int deltaY = (int)round((float)sumOfYChanges / 3.0);

		nextPosition.x = centerPositions.back().x + deltaX;
		nextPosition.y = centerPositions.back().y + deltaY;

	}
	else if (centerPositions.size() == 4) {

		int sumOfXChanges = ((centerPositions[3].x - centerPositions[2].x) * 3) +
			((centerPositions[2].x - centerPositions[1].x) * 2) +
			((centerPositions[1].x - centerPositions[0].x) * 1);

		int deltaX = (int)round((float)sumOfXChanges / 6.0);

		int sumOfYChanges = ((centerPositions[3].y - centerPositions[2].y) * 3) +
			((centerPositions[2].y - centerPositions[1].y) * 2) +
			((centerPositions[1].y - centerPositions[0].y) * 1);

		int deltaY = (int)round((float)sumOfYChanges / 6.0);

		nextPosition.x = centerPositions.back().x + deltaX;
		nextPosition.y = centerPositions.back().y + deltaY;

	}
	else if (centerPositions.size() >= 5) {

		int sumOfXChanges = ((centerPositions[centerPositions.size() -1].x - centerPositions[centerPositions.size() -2].x) * 4) +
			((centerPositions[centerPositions.size() -2].x - centerPositions[centerPositions.size() -3].x) * 3) +
			((centerPositions[centerPositions.size() -3].x - centerPositions[centerPositions.size() -4].x) * 2) +
			((centerPositions[centerPositions.size() -4].x - centerPositions[centerPositions.size() -5].x) * 1);

		int deltaX = (int)round((float)sumOfXChanges / 10.0);

		int sumOfYChanges = ((centerPositions[centerPositions.size() -1].y - centerPositions[centerPositions.size() -2].y) * 4) +
			((centerPositions[centerPositions.size() -2].y - centerPositions[centerPositions.size() -3].y) * 3) +
			((centerPositions[centerPositions.size() -3].y - centerPositions[centerPositions.size() -4].y) * 2) +
			((centerPositions[centerPositions.size() -4].y - centerPositions[centerPositions.size() -5].y) * 1);

		int deltaY = (int)round((float)sumOfYChanges / 10.0);

		nextPosition.x = centerPositions.back().x + deltaX;
		nextPosition.y = centerPositions.back().y + deltaY;
	}
	else {
		// should never get here
	}

	return nextPosition;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
Blobs::Blobs() {
	//"""Initializes the data."""
	firstFrame = true;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void Blobs::trackBlobs(vector<Blob>& blobs) {
	//"""
	//	build detect blobs to tracked existing blobs(Blob's blobs)
	//		:param detect_blobs : detect blobs by model
	//		: return : blobs
	//		"""

	// blobs, new or existing blob with new position
	if (firstFrame == true) {
		for (auto& blob : blobs) {
			addBlobAsNew(blob);
			firstFrame = false;
		}
	} else matchBlobs(blobs);

	for (unsigned i = 0; i < this->blobs.size(); ++i) {
		this->blobs[i].age += 1;
		if (this->blobs[i].age >= LIFETIME) this->blobs.erase(this->blobs.begin() + i);
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void Blobs::matchBlobs(vector<Blob>& blobs) {

	for (auto& blob : blobs) {
		int idx = 0;
		double minDistance = 100000.0;

		for (unsigned int i = 0; i < this->blobs.size(); i++) {
			double curDistance = distance(blob.centerPositions.back(), this->blobs[i].predictNextPosition());
			if (curDistance < minDistance) {
				minDistance = curDistance;
				idx = i;
			}
		}
		
		if (minDistance < blob.diagonalSize * 1.15) addBlobAsOld(blob, idx);
		else addBlobAsNew(blob);
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void Blobs::addBlobAsOld(Blob& blob, int& idx) {
	this->blobs[idx].label = blob.label;
	this->blobs[idx].rect = blob.rect;
	this->blobs[idx].diagonalSize = blob.diagonalSize;
	this->blobs[idx].aspectRatio = blob.aspectRatio;
	this->blobs[idx].area = blob.area;
	this->blobs[idx].age = 0;
	
	this->blobs[idx].centerPositions.push_back(blob.centerPositions.back());

	while (this->blobs[idx].centerPositions.size() > 16)
	{
		this->blobs[idx].centerPositions.pop_front();
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
void Blobs::addBlobAsNew(Blob& blob) {
	blob.age = 0;
	this->blobs.push_back(blob);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
double Blobs::distance(Point point1, Point point2) {

	int intX = abs(point1.x - point2.x);
	int intY = abs(point1.y - point2.y);

	return(sqrt(pow(intX, 2) + pow(intY, 2)));
}
