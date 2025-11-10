% type: 1 - consider all doys; 2 - only consider prevoius doys; 3 - only subsequent
function [I_mosaic, doys_mosaic] = GetMosaic_v2(I, dims, target_idx, doys, doy_diff_max, normalized_images, type)
    [nrow, ncol, bands_num_all] = size(I);
    n_Img = bands_num_all/dims;
    
    I_mosaic = zeros(nrow, ncol, dims);
    
    doys_mosaic = zeros(nrow, ncol, 1);

    doys_proc = doys;
    doy_target = doys(target_idx);
    n_used = 0;
    while (1)
        doys_diff = abs(doys_proc - doy_target);
        doys_diff(normalized_images == 0) = 999; % to exluce invalid non-normalized images
        if type == 2
            doys_diff(min(target_idx+1, n_Img):n_Img) = 999;
        elseif type == 3
            doys_diff(1:max(1:target_idx-1)) = 999;
        end
        
        [doy_diff_min, idx_min_doy] = min(doys_diff);
        if doy_diff_min > doy_diff_max
            break;
        end
        
        doy_fill = doys(idx_min_doy);
        doys_proc(idx_min_doy) = -999;
        n_used = n_used + 1;
        idx_used(n_used) = idx_min_doy;
        I_fill = I(:,:,(idx_min_doy-1)*dims+1:idx_min_doy*dims);
        mask = I_mosaic(:,:,1) == 0 & I_fill(:,:,1) ~= 0;
        for i = 1:dims
            Ii = I_mosaic(:,:,i);
            Ii_fill = I_fill(:,:,i);
            Ii(mask) = Ii_fill(mask);
            I_mosaic(:,:,i) = Ii;
        end
        doys_mosaic(mask) = doys(idx_min_doy);
    end
end

