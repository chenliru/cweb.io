#include <opencv2/highgui/highgui.hpp>    
#include <opencv2/imgproc/imgproc.hpp>
#include <iostream>

using namespace cv;

int main(int argc, char *argv[])
{
	Mat image = imread("Test.jpg", 1);
	if (image.empty())
	{
		std::cout << "open photo failed, please check if photo is still there" << std::endl;
		return -1;
	}
	imshow("Orignal", image);

	/*
	1. 基于直方图均衡化的图像增强

	直方图均衡化是通过调整图像的灰阶分布，使得在0~255灰阶上的分布更加均衡，
	提高了图像的对比度，达到改善图像主观视觉效果的目的。对比度较低的图像适
	合使用直方图均衡化方法来增强图像细节。

	*/

	Mat imageRGB[3], equalizeHistImage;
	split(image, imageRGB);
	for (int i = 0; i < 3; i++)
	{
		equalizeHist(imageRGB[i], imageRGB[i]);
	}
	merge(imageRGB, 3, equalizeHistImage);
	imshow("equalizeHistImage", equalizeHistImage);

	/*
	2. 基于拉普拉斯算子的图像增强

	使用中心为5的8邻域拉普拉斯算子与图像卷积可以达到锐化增强图像的目的，拉普拉斯算子如下图所示：

	拉普拉斯算子可以增强局部的图像对比度
	*/

	Mat imageEnhance;
	Mat kernel = (Mat_<float>(3, 3) << 0, -1, 0, 0, 5, 0, 0, -1, 0);
	filter2D(image, imageEnhance, CV_8UC3, kernel);
	imshow("LaplasEnhence", imageEnhance);

	/*
	3. 基于对数Log变换的图像增强

	对数变换可以将图像的低灰度值部分扩展，显示出低灰度部分更多的细节，
	将其高灰度值部分压缩，减少高灰度值部分的细节，从而达到强调图像低灰
	度部分的目的。变换方法：

	对数变换对图像低灰度部分细节增强的功能过可以从对数图上直观理解：

	x轴的0.4大约对应了y轴的0.8，即原图上0~0.4的低灰度部分经过对数运算后扩展到0~0.8的部分，
	而整个0.4~1的高灰度部分被投影到只有0.8~1的区间，这样就达到了扩展和增强低灰度部分，
	压缩高灰度部分的值的功能。

	从上图还可以看到，对于不同的底数，底数越大，对低灰度部分的扩展就越强，对高灰度部分
	的压缩也就越强。
	*/

	Mat imageLog(image.size(), CV_32FC3);
	for (int i = 0; i < image.rows; i++)
	{
		for (int j = 0; j < image.cols; j++)
		{
			imageLog.at<Vec3f>(i, j)[0] = log(1 + image.at<Vec3b>(i, j)[0]);
			imageLog.at<Vec3f>(i, j)[1] = log(1 + image.at<Vec3b>(i, j)[1]);
			imageLog.at<Vec3f>(i, j)[2] = log(1 + image.at<Vec3b>(i, j)[2]);
		}
	}
	//归一化到0~255
	normalize(imageLog, imageLog, 0, 255, NORM_MINMAX);
	//转换成8bit图像显示  
	convertScaleAbs(imageLog, imageLog);
	imshow("LogChangeEnhence", imageLog);

	/*
	4. 基于伽马变换的图像增强

	伽马变换主要用于图像的校正，将灰度过高或者灰度过低的图片进行修正，增强对比度。
	变换公式就是对原图像上每一个像素值做乘积运算：

	伽马变换对图像的修正作用其实就是通过增强低灰度或高灰度的细节实现的，从伽马曲线可以直观理解：

	γ值以1为分界，值越小，对图像低灰度部分的扩展作用就越强，值越大，对图像高灰度部分的扩展
	作用就越强，通过不同的γ值，就可以达到增强低灰度或高灰度部分细节的作用。

	伽马变换对于图像对比度偏低，并且整体亮度值偏高（对于于相机过曝）情况下的图像增强效果明显。
	*/

	Mat imageGamma(image.size(), CV_32FC3);
	for (int i = 0; i < image.rows; i++)
	{
		for (int j = 0; j < image.cols; j++)
		{
			imageGamma.at<Vec3f>(i, j)[0] = (image.at<Vec3b>(i, j)[0])*(image.at<Vec3b>(i, j)[0])*(image.at<Vec3b>(i, j)[0]);
			imageGamma.at<Vec3f>(i, j)[1] = (image.at<Vec3b>(i, j)[1])*(image.at<Vec3b>(i, j)[1])*(image.at<Vec3b>(i, j)[1]);
			imageGamma.at<Vec3f>(i, j)[2] = (image.at<Vec3b>(i, j)[2])*(image.at<Vec3b>(i, j)[2])*(image.at<Vec3b>(i, j)[2]);
		}
	}
	//归一化到0~255
	normalize(imageGamma, imageGamma, 0, 255, NORM_MINMAX);
	//转换成8bit图像显示  
	convertScaleAbs(imageGamma, imageGamma);
	imshow("GammaChangeEnhence", imageGamma);

	waitKey(0);
	return 0;
}