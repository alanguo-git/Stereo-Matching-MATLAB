function performance = percentage_of_bad_matching(disparity_map,ground_truth)
row=size(disparity_map,1);
col=size(disparity_map,2);
threshold = 1; %disparity error tolerance
bad_pixels = 0;
if row ~= size(ground_truth,1) || col ~= size(ground_truth,2)
    performance = 1;
else
    for m = 1:col
       for n = 1:row
           %out of tolorance range
           if abs(single(disparity_map(n,m)) - single(ground_truth(n,m))) > threshold 
               bad_pixels = bad_pixels + 1;
           end
       end    
    end
    performance = bad_pixels / (row * col);
end
end

