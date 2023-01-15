function [optSeamIndexArray, seamEnergy] = findOptSeam(energy, seamDirection)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Following paper by Avidan and Shamir `07
% Finds optimal seam by the given energy of an image
% Returns mask with 0 mean a pixel is in the seam
% You only need to implement vertical seam. For
% horizontal case, just using the same function by 
% giving energy for the transpose image I'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% seam_direction 0 => vertical
% seam_direction 1 => horzontal

if seamDirection == 0  % Find vertical seam
    % Find M for vertical seams
    
    M = energy; % Initialize M as energy

    % Add one column of padding in vertical dimension 
    % to avoid handling border elements
    M = padarray(M, [0 1], realmax('double'));

    % For all rows starting from second row, fill in the minimum 
    % energy for all possible seam for each (i,j) in M, which
    % M[i, j] = e[i, j] + min(M[i-1, j-1], M[i-1, j], M[i-1, j+1]).

    % Note that we initialize M as e, so it can be written as
    % M[i, j] = M[i, j] + min(M[i-1, j-1], M[i-1, j], M[i-1, j+1])
    [h, w] = size(M);
    for y = 2:h
        for x = 2:(w-1)
            M(y, x) = M(y, x) + min(M(y - 1, x - 1:x + 1));
        end
    end

    % Find the minimum element in the last row of M
    [val, idx] = min(M(h, :));
    seamEnergy = val;

    % Initial for optimal seam mask
    optSeamIndexArray = zeros(h, 1, 'uint32');

    % Traverse back the path of seam with minimum energy
    % and update optimal seam index array
    optSeamIndexArray(end) = idx; % Initialize
    y = h - 1;
    x = idx;
    while y > 0
        [val, src] = min(M(y, x - 1:x + 1));
        if src == 1
            optSeamIndexArray(y) = x - 1;
            y = y - 1;
            x = x - 1;
        elseif src == 2
            optSeamIndexArray(y) = x;
            y = y - 1;
        elseif src == 3
            optSeamIndexArray(y) = x + 1;
            y = y - 1;
            x = x + 1;
        end
    end

    % Minus 1 because we pad M previously
    optSeamIndexArray = optSeamIndexArray - 1;
    
else  % Find horizontal seam
    M = energy; % Initialize M as energy

    % Add one row of padding in horizontal dimension 
    % to avoid handling border elements
    M = padarray(M, [1 0], realmax('double'));

    % For all columns starting from second column, fill in the minimum 
    % energy for all possible seam for each (i,j) in M, which
    % M[i, j] = e[i, j] + min(M[i-1, j-1], M[i, j-1], M[i+1, j-1])

    % Note that we initialize M as e, so it can be written as
    % M[i, j] = M[i, j] + min(M[i-1, j-1], M[i, j-1], M[i+1, j-1])

    [h, w] = size(M);
    for x = 2:w
        for y = 2:(h-1)
            M(y, x) = M(y, x) + min(M(y - 1:y + 1, x - 1));
        end
    end

    % Find the minimum element in the last column of M
    [val, idx] = min(M(:, w));
    seamEnergy = val;

    % Initial for optimal seam mask
    optSeamIndexArray = zeros(1, w, 'uint32');

    % Traverse back the path of seam with minimum energy
    % and update optimal seam index array
    optSeamIndexArray(1, end) = idx; % Initialize

    y = idx;
    x = w - 1;
    while x > 0
        [val, src] = min(M(y - 1:y + 1, x));
        if src == 1
            optSeamIndexArray(x) = y - 1;
            y = y - 1;
            x = x - 1;
        elseif src == 2
            optSeamIndexArray(x) = y;
            x = x - 1;
        elseif src == 3
            optSeamIndexArray(x) = y + 1;
            y = y + 1;
            x = x - 1;
        end
    end

    % Minus 1 because we pad M previously
    optSeamIndexArray = optSeamIndexArray - 1;
end
end
