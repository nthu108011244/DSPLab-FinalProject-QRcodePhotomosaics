function tileClustering(work_dir, tile_dir, grid_size, lumin_base, sigma)
    %% show in terminal
    fprintf('<<< [Tile Clustering] start\n');

    %% parameter
    if grid_size > 32
        bin = 32;
    else
        bin = grid_size;
    end

    %% path
    tile_cluster_dir = sprintf('%s/tile_%d', work_dir, grid_size);
    tile_set_png = dir(fullfile(tile_cluster_dir, '*.png'));
    tile_set_jpg = dir(fullfile(tile_cluster_dir, '*.jpg'));
    tile_set_jpeg = dir(fullfile(tile_cluster_dir, '*.jpeg'));
    tile_set = [tile_set_png; tile_set_jpg; tile_set_jpeg];

    %% feature
    fprintf('<<< [Tile Clustering] feature extracting %s\n', tile_cluster_dir);
    n = length(tile_set);       % number of tiles
    
    tile_ftr = zeros(n, bin * 3);        % features of all images
    tile_ftr_brt = zeros(n, bin * 3);    % features of bright images
    tile_ftr_drk = zeros(n, bin * 3);    % features of dark images
    
    tile_idx_brt = zeros(n, 1, 'uint32');   % index of bright images
    tile_idx_drk = zeros(n, 1, 'uint32');   % index of dark images
    
    brt_num = 0;
    drk_num = 0;
    
    for t = 1 : n
        % claculate
        tile_path = fullfile(tile_set(t).folder, tile_set(t).name);
    
        I = imread(tile_path);  % image in RGB
        I_lab = rgb2lab(I);     % image in L*a*b*
    
        [R, xr] = imhist(I(:,:,1), bin);
        [G, xg] = imhist(I(:,:,2), bin);
        [B, xb] = imhist(I(:,:,3), bin);
        L = mean(I_lab(:, :, 1), 'all');
    
        % record
        tile_record(t).path = tile_path;    % absolute path
        tile_record(t).R = R;               % red
        tile_record(t).G = G;               % green
        tile_record(t).B = B;               % blue
        tile_record(t).L = L;               % luminance
        tile_record(t).cluster = -1;        % the cluter of all images (default: -1)
        tile_record(t).cluster_brt = -1;    % the cluter of bright images (default: -1)  
        tile_record(t).cluster_drk = -1;    % the cluter of dark images (default: -1)
    
        tile_ftr(t, 1:bin) = R;
        tile_ftr(t, bin+1:2*bin) = G;
        tile_ftr(t, 2*bin+1:3*bin) = B;
        
        if L > (lumin_base + sigma)
            brt_num = brt_num + 1;
            tile_idx_brt(brt_num) = t;
            tile_ftr_brt(brt_num, 1:bin) = R;
            tile_ftr_brt(brt_num, bin+1:2*bin) = G;
            tile_ftr_brt(brt_num, 2*bin+1:3*bin) = B;
        elseif L < (lumin_base - sigma)
            drk_num = drk_num + 1;
            tile_idx_drk(drk_num) = t;
            tile_ftr_drk(drk_num, 1:bin) = R;
            tile_ftr_drk(drk_num, bin+1:2*bin) = G;
            tile_ftr_drk(drk_num, 2*bin+1:3*bin) = B;       
        end
    end

    for i = 1 : 3 * bin
        if std(tile_ftr(:,i)) ~= 0
            tile_ftr(:,i) = normalize(tile_ftr(:,i));
        else
            tile_ftr(:,i) = zeros(n,1);
        end
        if std(tile_ftr_brt(:,i)) ~= 0
            tile_ftr_brt(1:brt_num,i) = normalize(tile_ftr_brt(1:brt_num,i));
        else
            tile_ftr_brt(1:brt_num,i) = zeros(brt_num,1);
        end   
        if std(tile_ftr_drk(:,i)) ~= 0
            tile_ftr_drk(1:drk_num,i) = normalize(tile_ftr_drk(1:drk_num,i));
        else
            tile_ftr_drk(1:drk_num,i) = zeros(drk_num,1);
        end         
    end

    tile_ftr_brt = tile_ftr_brt(1:brt_num,:);
    tile_ftr_drk = tile_ftr_drk(1:drk_num,:);
            
    
    %% cluster
    % calculate
    fprintf('<<< [Tile Clustering] clustering %s\n', tile_cluster_dir);
    
    k = round(n / 10);
    tile_clst = kmeans(tile_ftr, k);
    [clst_num, ~] = groupcounts(tile_clst);
    
    k_brt = max(round(brt_num / 10), 2);
    tile_clst_brt = kmeans(tile_ftr_brt, k_brt);
    [clst_brt_num, ~] = groupcounts(tile_clst_brt);
    
    k_drk = max(round(drk_num / 10), 2);
    tile_clst_drk = kmeans(tile_ftr_drk, k_drk);
    [clst_drk_num, ~] = groupcounts(tile_clst_drk);
    
    % record
    for i = 1 : k
        clst_record(i).num = clst_num(i);
        clst_record(i).tile = [];
    end
    
    all_brt_tile = []; 
    for i = 1 : k_brt
        clst_brt_record(i).num = clst_brt_num(i);
        clst_brt_record(i).tile = [];
    end
    
    all_drk_tile = [];
    for i = 1 : k_drk
        clst_drk_record(i).num = clst_drk_num(i);
        clst_drk_record(i).tile = [];
    end
    
    for t = 1 : n
        tile_record(t).cluster = tile_clst(t);
        clst_record(tile_clst(t)).tile = [clst_record(tile_clst(t)).tile t];
    end
    
    for t = 1 : brt_num
        idx = tile_idx_brt(t);
        clst = tile_clst_brt(t);
        tile_record(idx).cluster_brt = clst;
        clst_brt_record(clst).tile = [clst_brt_record(clst).tile idx];
        all_brt_tile = [all_brt_tile idx];
    end
    
    for t = 1 : drk_num
        idx = tile_idx_drk(t);
        clst = tile_clst_drk(t);
        tile_record(idx).cluster_drk = clst;
        clst_drk_record(clst).tile = [clst_drk_record(clst).tile idx];
        all_drk_tile = [all_drk_tile idx];
    end
    
    %% save
    fprintf('<<< [Tile Clustering] save result %s\n', tile_cluster_dir);
    filename = sprintf('%s/tile_record.mat', tile_cluster_dir);
    save (filename, 'tile_record', 'n');
    
    filename = sprintf('%s/cluster_record.mat', tile_cluster_dir);
    save (filename, 'clst_record', 'k');
    
    filename = sprintf('%s/cluster_bright_record.mat', tile_cluster_dir);
    save (filename, 'clst_brt_record', 'k_brt', 'brt_num', 'all_brt_tile');
    
    filename = sprintf('%s/cluster_dark_record.mat', tile_cluster_dir);
    save (filename, 'clst_drk_record', 'k_drk', 'drk_num', 'all_drk_tile');

    %%
    fprintf('<<< [Tile Clustering] done\n');
end