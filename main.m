%% read Teddy images
ImageLeft = imread('imageLeft.png');
ImageRight = imread('imageRight.png');

%% generate disparity map
disparity_map = disparityEstimation(ImageLeft, ImageRight);
figure();
imshow(disparity_map*4)

%% evaluate performance
ground_truth = imread('dispLeft.png');
performance = 1 - percentage_of_bad_matching(disparity_map,ground_truth/4);
