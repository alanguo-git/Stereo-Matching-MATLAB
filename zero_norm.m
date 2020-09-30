function zeronorm_cross_correlation = zero_norm(left_patch,right_patch)
%calculate the similarity between left patch and right patch using zero-normalised cross-correlation
x1 = left_patch(:);
m1 = mean(x1);
x1 = x1 - m1;
n1 = sqrt(sum(x1.^2));  
x1 = x1/n1;
x2 = right_patch(:);
m2 = mean(x2);
x2 = x2 - m2;
n2 = sqrt(sum(x2.^2)); 
x2 = x2/n2;
if n1 == 0 && n2 == 0 %left patch and right patch are two single color patch
    if isequal(left_patch,right_patch) %same color
        zeronorm_cross_correlation = 1;
    else %not same color
        zeronorm_cross_correlation = (255 - abs(m1 - m2))/255;
    end
else
    multiply = x1.*x2;
    zeronorm_cross_correlation = sum(multiply);
end    
end 