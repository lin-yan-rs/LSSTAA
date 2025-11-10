% Apply per-image bias-compensation to input NDVI time series; then use it to  
%  - generate ΔNDVI' map and per-pixel valid-observation number map, saved in "temporal_diff_map.ndvi"
%  - calcualte pairwise image correlations, results saved in "rsqs.mat"
%
% Return ΔNDVI' map and per-pixel valid-observation number map
%
% Note:
% - if temporal_diff_map.ndvi exists, it will be input without recalculation; if it needs recalculation, just delete the file
function [temporal_diff_map, obs_count_map] = Get_dNDVI_map_v1(I, doys, quantile_cut, doy_diff_threshold, outputDir)
    [nrow, ncol, n_images] = size(I);
    n_doy_diff_max = 31; % a hard threshold used in DOY weight calculation; see its usage below

    filename_temp_diff = sprintf('%s/temporal_diff_map.ndvi', outputDir);
    filename_rsqs = sprintf('%s/tmp_rsqs.mat', outputDir);
    if isfile(filename_temp_diff) && isfile(filename_rsqs)
        fprintf(' Input existing ΔNDVI image: %s\n', filename_temp_diff);
        fid = fopen(filename_temp_diff, 'rb');
        temporal_diff_map = fread(fid, nrow*ncol, 'int16');
        obs_count_map = fread(fid, nrow*ncol, 'int16');
        fclose(fid);
        temporal_diff_map = ReformInputImage_v1(temporal_diff_map, nrow, ncol);
        obs_count_map = ReformInputImage_v1(obs_count_map, nrow, ncol);

        return;
    end
      
    % get bias-conpensated time series
    I_new = Time_series_internal_bias_compensation_v1(I, doys, quantile_cut, doy_diff_threshold);
    
    % calculate ΔNDVI' map
    temporal_diff_map = zeros(nrow, ncol); % map of per-pixel mean NDVI difference,
    temporal_diff_map_weight = zeros(nrow, ncol);
    obs_count_map = zeros(nrow, ncol); % obs count per pixel
    for n1 = 1:n_images
        doy1 = doys(n1);
        I1 = I_new(:,:,n1);
        obs_count_map = obs_count_map + double(I1~=0);
        % clear top values to 0
        I1 = CleanImageByQuantile(I1, quantile_cut, false, true);
        for n2 = n1+1:n_images
            doy2 = doys(n2);
            doy_diff = abs(doy2-doy1);
            if doy_diff > doy_diff_threshold
                continue;
            end
            
            I2 = I_new(:,:,n2);
            I2 = CleanImageByQuantile(I2, quantile_cut, false, true);
            
            mask_i = I1 ~=0 & I2 ~= 0; % intersection of I1 and I2
            if nnz(mask_i) < 1000 % skip if number of overlapping pixels is too small 
                continue;
            end
            diff_i = abs(I1 - I2);
            diff_i(~mask_i) = 0;

            % if doy diff is larger than a threshold (e.g., 15 days), set it to 15 so its weight is 1/(15+1), and so it is not underemphasized 
            if doy_diff > n_doy_diff_max
                doy_diff = n_doy_diff_max;
            end
            obs_count_weighted = 1/(doy_diff+1);
            
            temporal_diff_map = temporal_diff_map + diff_i*obs_count_weighted;
            temporal_diff_map_weight = temporal_diff_map_weight + double(mask_i)*obs_count_weighted;
        end
    end
    
    temporal_diff_map = temporal_diff_map./temporal_diff_map_weight;
    temporal_diff_map(temporal_diff_map_weight == 0) = 0;
    temporal_diff_map = int16(temporal_diff_map);
    
    % matrix manipulation to enable direct matrix output
    temporal_diff_map_out = int16(ReformOutputImage_v1(temporal_diff_map));
    obs_count_map_out = int16(ReformOutputImage_v1(obs_count_map));
    
    % output dNDVI map and obs count map in one file "temporal_diff_map.ndvi"
    fprintf(' Output ΔNDVI image: %s\n', filename_temp_diff);
    fid = fopen(filename_temp_diff, 'wb');
    fwrite(fid, temporal_diff_map_out, 'int16');
    fwrite(fid, obs_count_map_out, 'int16');
    fclose(fid);
    OutputENVI_hdr(filename_temp_diff, nrow, ncol, 2, 2, 'bsq');
    
    % output pairwise correlation results to a .mat file
    [rsqs_mean, rsqs_median, rsqs_n, rsqs_nn, p1_nn, p2_nn, obs_ratio_n, obs_overlapping_ratio_nn] = GetMeanR2_images_v4(I_new, doys, 0.5, temporal_diff_map);
    save(filename_rsqs, 'rsqs_mean', 'rsqs_median', 'rsqs_n', 'rsqs_nn', 'p1_nn', 'p2_nn', 'obs_ratio_n', 'obs_overlapping_ratio_nn');

    return;
end

