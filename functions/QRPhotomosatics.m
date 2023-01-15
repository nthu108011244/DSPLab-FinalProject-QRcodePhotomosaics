function QRPhotomosatics(work_dir, bkgd_path, grid_size, visual_size, txt, ecc, max_iter, max_repeat, alpha)
    %% show in terminal
    fprintf('<<< [QR Photomosatics] start\n');

    %% QRcode information
    fprintf('<<< [QR Photomosatics] analyze QR code\n');
    addpath('../QRcode/');
    [qr_mk, qr_ver, qr_size] = genQR(txt, ecc);
    
    %% load target image
    fprintf('<<< [QR Photomosatics] process background\n');
    bkgd = imread(bkgd_path);
    bkgd = im2double(bkgd);
    bkgd = backgroundResize(bkgd, qr_size * grid_size);
    
    %% load cluster imformation
    tile_record_path = sprintf('%s/tile_%d/tile_record.mat', work_dir, grid_size);
    clst_record_path = sprintf('%s/tile_%d/cluster_record.mat', work_dir, grid_size);
    clst_brt_record_path = sprintf('%s/tile_%d/cluster_bright_record.mat', work_dir, grid_size);
    clst_drk_record_path = sprintf('%s/tile_%d/cluster_dark_record.mat', work_dir, grid_size);
    load(tile_record_path);
    load(clst_record_path);
    load(clst_brt_record_path);
    load(clst_drk_record_path);
    
    %% initialize 
    fprintf('<<< [QR Photomosatics] initialize\n');
    [h, w, ch] = size(bkgd);
    nr = h / grid_size;
    nc = w / grid_size;
    
    if (max_repeat * n) < (nr * nc)
        max_repeat = ceil(nr * nc / n);
        fprintf("[Warning] No enough tile. Reset max repeat to %d.", max_repeat);
    end
    
    trgt_block = zeros(grid_size, grid_size, 3, nr * nc);           % trgt_block(:, :, :, i) - each element is a block from target image
    tile_block = zeros(nr * nc, 1);                                 % tile_block(i) - each element means an idx of a tile
    trgt_mask = reshape(qr_mk, [nr * nc, 1]);                       % trgt_mask(i) - each element means the rule of a block
    
    tile_prob = ones(n, 1);
    brt_tile_prob = ones(brt_num, 1);
    drk_tile_prob = ones(drk_num, 1);
    
    all_tile = 1:n;
    use_time = zeros(n,1);
    brt_use_time = zeros(brt_num, 1);
    drk_use_time = zeros(drk_num, 1);    
    
    for i = 1 : nr * nc
        upper = floor((i - 1) / nc) * grid_size + 1;
        lower = upper + grid_size - 1;
        left = mod(i - 1, nc) * grid_size + 1;
        right = left + grid_size - 1;
    
        trgt_block(:, :, :, i) = bkgd(upper:lower, left:right, :);
    end
    
    for i = 1 : nr * nc
        if trgt_mask(i) == 1
            [tile_block(i), brt_idx] = datasample(all_brt_tile, 1, Replace = true, Weights = brt_tile_prob);
            brt_use_time(brt_idx) = brt_use_time(brt_idx) + 1;
            if brt_use_time(brt_idx) >= max_repeat
                brt_tile_prob(brt_idx) = 0;
            end
        elseif trgt_mask(i) == 0
            [tile_block(i), drk_idx] = datasample(all_drk_tile, 1, Replace = true, Weights = drk_tile_prob);
            drk_use_time(drk_idx) = drk_use_time(drk_idx) + 1;
            if drk_use_time(drk_idx) >= max_repeat
                drk_tile_prob(drk_idx) = 0;
            end
        else
            tile_block(i) = datasample(all_tile, 1, Replace = true, Weights = tile_prob);
            use_time(tile_block(i)) = use_time(tile_block(i)) + 1;
            if use_time(tile_block(i)) >= max_repeat
                tile_prob(tile_block(i)) = 0;
            end
        end
    end

    % calculate fitness
    fitness = zeros(1, nc * nr);
    
    for i = 1 : nr * nc
        tile_path = tile_record(tile_block(i)).path;
        fitness(i) = calcFitness(trgt_block(:, :, :, i), tile_path);
    end
    
    %% iteration
    fprintf('<<< [QR Photomosatics] iterate\n');
    
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
    
        if trgt_mask(block_idx) == 1
            clst_idx = tile_record(tile_idx).cluster_brt;  
            in_cluster = clst_brt_record(clst_idx).tile;
            out_cluster = setdiff(all_brt_tile, in_cluster);
        elseif trgt_mask(block_idx) == 0
            clst_idx = tile_record(tile_idx).cluster_drk;   
            in_cluster = clst_drk_record(clst_idx).tile;
            out_cluster = setdiff(all_drk_tile, in_cluster);
        else
            clst_idx = tile_record(tile_idx).cluster;
            in_cluster = clst_record(clst_idx).tile;
            out_cluster = setdiff(all_tile, in_cluster);
        end    
        
        if prob(block_idx) < th
            tile_idx_n = datasample(in_cluster, 1);
        else
            tile_idx_n = datasample(out_cluster, 1);
        end       

        if trgt_mask(block_idx) == 1
            brt_idx = find(all_brt_tile == tile_idx);
            brt_idx_n = find(all_brt_tile == tile_idx_n);
            if brt_use_time(brt_idx_n) < max_repeat
                tile_path = tile_record(tile_idx_n).path;
                fitness_n = calcFitness(trgt_block(:, :, :, block_idx), tile_path);
                if fitness_n < fitness(block_idx)
                    tile_block(block_idx) = tile_idx_n;
                    fitness(block_idx) = fitness_n;
                    brt_use_time(brt_idx) = brt_use_time(brt_idx) - 1;
                    brt_use_time(brt_idx_n) = brt_use_time(brt_idx_n) + 1;
                end
            end
        elseif trgt_mask(block_idx) == 0
            drk_idx = find(all_drk_tile == tile_idx);
            drk_idx_n = find(all_drk_tile == tile_idx_n);
            if drk_use_time(drk_idx_n) < max_repeat
                tile_path = tile_record(tile_idx_n).path;
                fitness_n = calcFitness(trgt_block(:, :, :, block_idx), tile_path);
                if fitness_n < fitness(block_idx)
                    tile_block(block_idx) = tile_idx_n;
                    fitness(block_idx) = fitness_n;
                    drk_use_time(drk_idx) = drk_use_time(drk_idx) - 1;
                    drk_use_time(drk_idx_n) = drk_use_time(drk_idx_n) + 1;
                end
            end
        else
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
        end   


        fprintf('mean fitness: %f\n', mean(fitness));
    end
    
    %% save
    fprintf('<<< [QR Photomosatics] generate photomosatics\n');

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
    
    % figure; imshow(bkgd);
    % figure; imshow(mosatic);

    res_dir = fullfile(work_dir, '/QRphotomosatics');
    if ~exist(res_dir, 'dir')
        mkdir(res_dir);
    end
    
    res_path = sprintf('%s/QRphotomosatics/QRphotomosatics.jpg', work_dir);
    imwrite(mosatic, res_path);

    %%
    fprintf('<<< [QR Photomosatics] done\n');
end