function [DisparityMap] = disparityEstimation(ImageLeft,ImageRight)
%% transfer to grayscale
left_gray = rgb2gray(ImageLeft); 
right_gray = rgb2gray(ImageRight);

%% normalize image
left_normalize = im2double(left_gray);
right_normalize = im2double(right_gray);

%% calculate row and column
row=size(ImageLeft,1);
col=size(ImageLeft,2);

%% set templet size, penalty of occlusion and disparity range
%used for quarter size
templet_size = 2; 
occlusion_constant=0.3;
disparity_range = 50;
%if image is bigger than quarter size
if row > 375 && col > 450
    templet_size = templet_size*round(min(row/375, col/450));
    disparity_range = disparity_range*round(min(row/375, col/450));
end

%% create a 3 dimension disparity space image metrix
dsi = zeros(col, col, row); 

%% create a blank disparity image
DisparityMap = zeros(row, col);

%% initilize the max disparity value
max_disparity = 0;

%% generate disparity map using dynamic programaming
%for each scanline
for i = 1:row
    scanline = i;
    y_min= max(1, i - templet_size);
    y_max = min(i + templet_size, row);
    height = y_max - y_min + 1;
   
    %generate DSI
    %left scanline
    for j = 1:col
        x_min= max(1, j - templet_size);
        x_max = min(j + templet_size, col);
        width = x_max - x_min + 1;
        %get left patch
        left_patch = zeros(height, width);
        for m = 1:width
            for n = 1:height
                left_patch(n,m) = left_normalize(y_min + n -1, x_min + m - 1);
            end    
        end
        
        left_size = j - x_min; %number of pixels in the patch on the left side of the center pixel
        right_size = x_max - j;%number of pixels in the patch on the right side of the center pixel
        
        %right scanline
        for k = 1:col
            %suppose max disparity is 50, then matched templet in right image 
            %can not be more than 50 pixels left from the left templet
            %no need to compare right templet that the column index is more
            %than the left templet
            if k < j - disparity_range || k > j
                dsi(k,j,scanline) = 1;
                continue;
            end
            right_patch = zeros(height, width); 
            for m = 1:width
                for n = 1:height
                    x = k - left_size + m - 1;
                    y = y_min + n - 1;
                    if (x > 0) && (x <= col) %pixel is not outside picture
                         right_patch(n,m) = right_normalize(y, x);
                    end
                end    
            end
            %calculate similarity using zero-normalized cross-correlation
            dsi(k,j,scanline) = -zero_norm(left_patch, right_patch);
        end
    end
    
    cost = zeros(col,col);
    path = zeros(col,col); %1: match, 2:occluded from left 3:occluded from right
    for m = 1:col
        for n = 1: col
            if m == 1 %initilize costs in the first row
                cost(m,n) = (n-1)*occlusion_constant;
                path(m,n) = 3;
            elseif n == 1 %initilize costs in the first column
                cost(m,n) = (m-1)*occlusion_constant;
                path(m,n) = 2;
            else %calculate other costs using dynamic programming
                [cost(m,n), path(m,n)] = min([cost(m-1, n-1) + dsi(m,n,scanline), ...
                                              cost(m-1,n) + occlusion_constant, ...
                                              cost(m,n-1) + occlusion_constant]);
            end
        end      
    end
    
    %find the shortest path and calculate disparity
    p = col;
    q = col;
    index = col;
    disparity = 0;
    while(p > 0 && q > 0)     
        if path(p,q) == 1
            DisparityMap(scanline, index) = disparity;
            %move upper left
            p = p - 1;
            q = q - 1;
            index = index - 1;
        elseif path(p,q) == 2
            disparity = disparity + 1;
            %move up
            p = p - 1;
        elseif path(p,q) == 3
            disparity = disparity - 1;
            %move left
            q = q - 1;
            index = index - 1;
        end
        if disparity > max_disparity
            max_disparity = disparity;
        end
    end
end

DisparityMap = uint8(DisparityMap);

%% median filter
DisparityMap=medfilt2(DisparityMap,[3,3]);

%% leftmost side refinement
for m = max_disparity:-1:1
   for n = 1:row
       if DisparityMap(n,m) < max_disparity * 0.8
           if DisparityMap(n,m+1) ~= 0
               DisparityMap(n,m) = DisparityMap(n,m+1);
           else
               DisparityMap(n,m) = max_disparity;
           end
       end
   end
end

%% refinment by similar colors
DisparityMap = refine_color(DisparityMap,left_gray);
end

