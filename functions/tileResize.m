function tileResize(work_dir, tile_dir, grid_size)
    %% show in terminal
    fprintf('<<< [Tile Resizing] start\n');

    %% path
    tile_set_png = dir(fullfile(tile_dir, '*.png'));
    tile_set_jpg = dir(fullfile(tile_dir, '*.jpg'));
    tile_set_jpeg = dir(fullfile(tile_dir, '*.jpeg'));
    tile_set = [tile_set_png; tile_set_jpg; tile_set_jpeg];
    
    % ensure that
    % (1) destination directory exsists
    % (2) destination directory is empty
    res_dir = sprintf('%s/tile_%d', work_dir, grid_size);
    if ~exist(res_dir, 'dir')
        mkdir(res_dir);
    else 
        K = ['.png', 'jpg', 'jpeg'];
        S = dir(fullfile(res_dir, '*.*'));
        S = S(~[S.isdir]);
        for k = 1:numel(S)
            F = S(k).name;
            [~,~,E] = fileparts(F);
            if ismember(E, K)
                try
                    delete(fullfile(res_dir, F));
                catch  
                    warning('[Warnning] Cannot delete %s', fullfile(res_dir, F));
                end
            end
        end
    end

    %% processing
    for t = 1 : length(tile_set)
        tile_path = fullfile(tile_set(t).folder, tile_set(t).name);
        fprintf('<<< [Tile Resizing] now processs %s\n', tile_path);
        
        tile = imread(tile_path);
        tile = im2double(tile);
        sz = size(tile);
        
        % resize to be smaller than square -> apply seam carving to
        % resize
        if sz(1) < sz(2)
            resize_ratio = grid_size / sz(1);
        else
            resize_ratio = grid_size / sz(2);
        end
        tile_resize = imresize(tile, resize_ratio);
        sz_resize = size(tile_resize);
        
        % seam carving
        tile_seamcarving = seamCarvingReduce(tile_resize, sz_resize(2) - grid_size, 0);
        tile_seamcarving = seamCarvingReduce(tile_seamcarving, sz_resize(1) - grid_size, 1);

        % store tile
        res_path = sprintf('%s/tile_%d/%d.jpg', work_dir, grid_size, t);
        imwrite(tile_seamcarving, res_path);
    end

    %%
    fprintf('<<< [Tile Resizing] done\n');
end


