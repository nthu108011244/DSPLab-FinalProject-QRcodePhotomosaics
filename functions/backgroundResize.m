function bkgd_processed = backgroundResize(bkgd, qr_size)
    %% show in terminal 
    fprintf('<<< [Background Resizing] start\n');

    %% process
    [h, w, ch] = size(bkgd);
    
    if h ~= w
        fprintf('[Error]: the background should be a square.\n');
        bkgd_processed = zeros(qr_size, qr_size);
    else
        bkgd_processed = imresize(bkgd, [qr_size qr_size]);
    end

    %%
    fprintf('<<< [Background Resizing] done\n');
end







