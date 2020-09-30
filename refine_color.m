function refined_map = refine_color(disparity_map,left_image)
threshold = Inf;
refined_map = disparity_map;
    row=size(disparity_map,1);
    col=size(disparity_map,2);
    for m = 4:col-2
       for n = 4:row-2
           window = zeros(5,5);
           window_previous = zeros(5,5);
           %find bad points with 0 disparity
           if refined_map(n,m) == 0 && refined_map(n,m-1) ~= 0 
               for i = 1:5
                   for j = 1:5
                       window(i,j) = left_image(n - 3 + i,m - 3 + j); 
                       window_previous(i,j) = left_image(n - 3 + i,m - 4 + j);
                   end
               end
               difference = euclidean_distance(window,window_previous);
               %have similar color, assign the disparity with its neighbor's disparity
               if difference < threshold 
                   refined_map(n,m) = refined_map(n,m-1);
               end
           end
       end    
    end
end

