function targetResize(work_dir, trgt_path, grid_size)
    %% show in terminal
    fprintf('<<< [Target Resizing] start\n');
    
    %% process
    fprintf('<<< [Target Resizing] now process %s\n', trgt_path);

    trgt = imread(trgt_path);
    trgt = im2double(trgt);
    [h, w, ch] = size(trgt);
    
    h_nearest = floor(h / grid_size) * grid_size;
    w_nearest = floor(w / grid_size) * grid_size;
    
    if mod(h, w) == 0
        resize_ratio = h_nearest / h;
        trgt_processed = imresize(trgt, resize_ratio);
    elseif mod(w, h) == 0 
        resize_ratio = w_nearest / w;
        trgt_processed = imresize(trgt, resize_ratio);        
    else
        trgt_processed = seamCarvingReduce(trgt, h - h_nearest, 1);
        trgt_processed = seamCarvingReduce(trgt_processed, w - w_nearest, 0);
    end
    
    %% save
    fprintf('<<< [Target Resizing] save result\n');

    res_dir = fullfile(work_dir, '/target');
    if ~exist(res_dir, 'dir')
        mkdir(res_dir);
    end

    res_path = fullfile(work_dir, '/target/target.jpg');
    imwrite(trgt_processed, res_path);

    %%
    fprintf('<<< [Target Resizing] done\n');
end