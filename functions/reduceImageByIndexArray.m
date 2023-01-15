function imageReduced = reduceImageByIndexArray(image, seamIndexArray, seamDirection)

if seamDirection == 0
    [h,w,ch] = size(image);
    imageReduced = zeros(h, w-1, ch);
    %%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE:
    %%%%%%%%%%%%%%%%%%
    for y = 1:h
        imageReduced(y, :, :) = [image(y, 1:seamIndexArray(y) - 1, :) image(y, seamIndexArray(y) + 1:end, :)];
    end

    %%%%%%%%%%%%%%%%%%
    % END OF YOUR CODE
    %%%%%%%%%%%%%%%%%%
else
    %%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE:
    %%%%%%%%%%%%%%%%%%
    [h,w,ch] = size(image);
    imageReduced = zeros(h-1, w, ch);

    for x = 1:w
        imageReduced(:, x, :) = [image(1:seamIndexArray(x) - 1, x, :); image(seamIndexArray(x) + 1:end, x, :)];
    end

    %%%%%%%%%%%%%%%%%%
    % END OF YOUR CODE
    %%%%%%%%%%%%%%%%%%
end

end

