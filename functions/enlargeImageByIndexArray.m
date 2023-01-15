function imageEnlarged = enlargeImageByIndexArray(image, seamIndexArray, seamDirection)
    [h,w,ch] = size(image);

    if seamDirection == 0
        imageEnlarged = zeros(h, w+1, ch);
        for y = 1:h
            imageEnlarged(y, 1:seamIndexArray(y), :) = image(y, 1:seamIndexArray(y), :);
    
            insertPoint = (image(y, seamIndexArray(y), :) + image(y, seamIndexArray(y) + 1, :)) / 2;
            % insertPoint = image(y, seamIndexArray(y), :);
            imageEnlarged(y, seamIndexArray(y) + 1, :) = insertPoint;
    
            imageEnlarged(y, seamIndexArray(y) + 2:end, :) = image(y, seamIndexArray(y) + 1:end, :);
        end
    else
        imageEnlarged = zeros(h+1, w, ch);
        for x = 1:w
            imageEnlarged(1:seamIndexArray(x), x, :) = image(1:seamIndexArray(x), x, :);
    
            insertPoint = (image(seamIndexArray(x), x, :) + image(seamIndexArray(x) + 1, x, :)) / 2;
            % insertPoint = image(y, seamIndexArray(y), :);
            imageEnlarged(seamIndexArray(x) + 1, x, :) = insertPoint;
    
            imageEnlarged(seamIndexArray(x) + 2:end, x, :) = image(seamIndexArray(x) + 1:end, x, :);
        end
    end

end
