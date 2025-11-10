function Output_mosaics(I_all, I_all_adj, doys, outputDir, normalized_images)
    doy_diff_max = 366; % all images images are considered
    dataDir_out = sprintf('%s/mosaic', outputDir);
    mkdir(dataDir_out);
    [nrow, ncol, ~] = size(I_all);
    n_Img = length(doys);
    dims = size(I_all, 3)/n_Img;
    % output three mosaics, with target image defined on first day, last day, and mid day
    for idx_ = 1:(n_Img-1)/2:n_Img
        target_idx = floor(idx_);  
        if normalized_images(target_idx) == 0
            continue;
        end
        
        [I_mosaic, doys_mosaic] = GetMosaic_v2(I_all, dims, target_idx, doys, doy_diff_max, normalized_images, 1);
        [I_mosaic_adj, ~] = GetMosaic_v2(I_all_adj, dims, target_idx, doys, doy_diff_max, normalized_images, 1);
    
        NDVI = int16(GetNDVI_4bands(I_mosaic)*10000);
        NDVI_adj = int16(GetNDVI_4bands(I_mosaic_adj)*10000);
    
        % output mosaic
        filename = sprintf('%s/mosaic_doy_%d', dataDir_out, doys(target_idx));
        I = int16(I_mosaic);
        I(:,:,dims+1) = NDVI;
        I(:,:,dims+2) = int16(doys_mosaic);
        WriteImageStack(I, filename, 'int16');

        % output hdr file
        band_names = arrayfun(@(x) sprintf('band %d', x), 1:(size(I,3)-2), 'UniformOutput', false);
        band_names = [band_names, {'NDVI', 'DOY'}];
        OutputENVI_hdr(filename, nrow, ncol, dims+2, 2, 'bsq', band_names);
    
        filename = sprintf('%s/mosaic_doy_%d.adj', dataDir_out, doys(target_idx));
        I = int16(I_mosaic_adj);
        I(:,:,dims+1) = NDVI_adj;
        I(:,:,dims+2) = doys_mosaic;
        WriteImageStack(I, filename, 'int16');
    end
    return;
end