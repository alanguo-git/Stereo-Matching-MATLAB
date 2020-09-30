# Stereo-Matching-MATLAB
The disparity estimation function is disparityEstimation.m.
This function is ready to be executed in the format as: [DisparityMap]=disparityEstimation (ImageLeft, ImageRight).
ImageLeft and ImageRight are the left and right images in RGB format.

There is also a main script called 'main.m' which can run directly.
However you need to put the images into the folder before running this script.
Also, you need to modify the file names if they are not the same as the names in the code.
The main function can output disparity map and the performace of my algorithm.
The main functinon is based on quarter-size images.
You need to change the constant value to 2 or 1 if you are using half-size images or full-size images.