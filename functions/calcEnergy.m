function energy = calcEnergy(I)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sum up the energy for each channel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dx = [-1 0 1; -1 0 1; -1 0 1];  % horizontal gradient filter
dy = dx';                       % vertical gradient filter

[h,w,ch] = size(I);

%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE:
%%%%%%%%%%%%%%%%%%
% x - gradient
Ix = imfilter(I, dx, 'conv');
Ix = sum(Ix, 3);

% y - gradient
Iy = imfilter(I, dy, 'conv');
Iy = sum(Iy, 3);

% energy
energy = abs(Ix) + abs(Iy);
%%%%%%%%%%%%%%%%%%
% END OF YOUR CODE
%%%%%%%%%%%%%%%%%%
end

