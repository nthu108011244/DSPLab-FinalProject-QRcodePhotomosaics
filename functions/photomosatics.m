function photomosatics(work_dir, grid_size, visual_size, max_iter, max_repeat, alpha)
    %% show in terminal
    fprintf('<<< [Photomosatics] start\n');

    %% load cluster imformation
    tile_record_path = sprintf('%s/tile_%d/tile_record.mat', work_dir, grid_size);
    clst_record_path = sprintf('%s/tile_%d/cluster_record.mat', work_dir, grid_size);
    load(tile_record_path);
    load(clst_record_path);
    
    %% load target image
    trgt_path = sprintf('%s/target/target.jpg', work_dir);
    trgt = imread(trgt_path);
    trgt = im2double(trgt);
    
    %% initialize
    fprintf('<<< [Photomosatics] initialize\n');

    [h, w, ch] = size(trgt);
    nr = h / grid_size;
    nc = w / grid_size;
    
    if (max_repeat * n) < (nr * nc)
        max_repeat = ceil(nr * nc / n);
        fprintf("[Warning] No enough tile. Reset max repeat to %d.", max_repeat);
    end
    
    trgt_block = zeros(grid_size, grid_size, 3, nr * nc);             % trgt_block(:, :, :, i) - each element is a block from target image
    
    tile_prob = ones(n, 1);
    tile_block = zeros(nr * nc, 1);
    
    all_tile = 1:n;
    use_time = zeros(n,1);
    
    for i = 1 : nr * nc
        tile_block(i) = datasample(all_tile, 1, Replace = true, Weights = tile_prob);     % tile_block(i) - each element represent the index of a tile
        use_time(tile_block(i)) = use_time(tile_block(i)) + 1;
        if use_time(tile_block(i)) >= max_repeat
            tile_prob(tile_block(i)) = 0;
        end
    end
    
    for i = 1 : nr * nc
        upper = floor((i - 1) / nc) * grid_size + 1;
        lower = upper + grid_size - 1;
        left = mod(i - 1, nc) * grid_size + 1;
        right = left + grid_size - 1;
    
        trgt_block(:, :, :, i) = trgt(upper:lower, left:right, :);
    end
    
    %% iteration
    fprintf('<<< [Photomosatics] iterate\n');

    % calculate fitness
    fitness = zeros(1, nc * nr);
    history = zeros(floor(max_iter / 100), 1);

    for i = 1 : nr * nc
        tile_path = tile_record(tile_block(i)).path;
        fitness(i) = calcFitness(trgt_block(:, :, :, i), tile_path);
    end
    
    for iter = 1 : max_iter
        fprintf('==================== epoch: %d ====================\n', iter);
    
        % calculate selected probability of each block
        prob = fitness;
        
        % random select a block
        block_idx = datasample(1:nc * nr, 1, Replace = true, Weights = prob);
    
        if fitness(block_idx) < mean(fitness)
            th = alpha;
        else
            th = 1 - alpha;
        end
    
        tile_idx = tile_block(block_idx);
        clst_idx = tile_record(tile_idx).cluster;
        
        in_cluster = clst_record(clst_idx).tile;
        out_cluster = setdiff(all_tile, in_cluster);
    
        if prob(block_idx) < th
            tile_idx_n = datasample(in_cluster, 1);
        else
            tile_idx_n = datasample(out_cluster, 1);
        end
        
        if use_time(tile_idx_n) < max_repeat
            tile_path = tile_record(tile_idx_n).path;
            fitness_n = calcFitness(trgt_block(:, :, :, block_idx), tile_path);    
            if fitness_n < fitness(block_idx)
                tile_block(block_idx) = tile_idx_n;
                fitness(block_idx) = fitness_n;
                use_time(tile_idx) = use_time(tile_idx) - 1;
                use_time(tile_idx_n) = use_time(tile_idx_n) + 1;
            end
        end
    
        fprintf('mean fitness: %f\n', mean(fitness));
        if mod(iter, 100) == 0
            history(int32(iter / 100)) = mean(fitness);
        end
    end
    
    %% save
    fprintf('<<< [Photomosatics] generate photomosatics\n');

    tile_record_path = sprintf('%s/tile_%d/tile_record.mat', work_dir, visual_size);
    load(tile_record_path);
    mosatic = zeros(nr * visual_size, nc * visual_size, ch);
    
    for i  = 1 : nr * nc
        tile_path = tile_record(tile_block(i)).path;
        tile = imread(tile_path);
        tile = im2double(tile);
    
        upper = floor((i - 1) / nc) * visual_size + 1;
        lower = upper + visual_size - 1;
        left = mod(i - 1, nc) * visual_size + 1;
        right = left + visual_size - 1;
    
        mosatic(upper:lower, left:right, :) = tile;
    end    
    
%     figure; imshow(trgt);
%     figure; imshow(mosatic);

    res_dir = fullfile(work_dir, '/photomosatics');
    if ~exist(res_dir, 'dir')
        mkdir(res_dir);
    end
    
    res_path = sprintf('%s/photomosatics/photomosatics.jpg', work_dir);
    imwrite(mosatic, res_path);

    his_path = sprintf('%s/photomosatics/history_grid%d.csv', work_dir, grid_size);
    writematrix(history, his_path);

    %%
    fprintf('<<< [Photomosatics] done\n');
end