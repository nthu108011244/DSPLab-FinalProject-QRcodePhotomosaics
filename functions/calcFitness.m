% ======================================================================= *
% input:
% - trgt_block: an image
% - tile_idx:   the index of a tile
% - grid_size:  the grid size
% (im1 and im2 must be in same shape)
% 
% output:
%  - fitness: the similarity between im1 and im2;
%             the lower the fitness is, the im1 and im2 looks more similar
% ======================================================================= *

function fitness = calcFitness(trgt_block, tile_path)
tile_block = imread(tile_path);

[h1, w1, ch1] = size(trgt_block);
[h2, w2, ch2] = size(tile_block);

if h1 ~= h2 || w1 ~= w2 || ch1 ~= ch2
    fprintf('[Error]: inequal size in calcFitness\n');
    fprintf('size of image 1 is: [%d, %d, %d]\n', h1, w1, ch1);
    fprintf('size of image 2 is: [%d, %d, %d]\n', h2, w2, ch2);

    fitness = nan;
else
    trgt_block = im2double(trgt_block);
    tile_block = im2double(tile_block);
    
    error = abs(trgt_block - tile_block);
    fitness = mean(error, 'all');
end

end