% Estimate and apply a bias for each image in time series
% Paramters:
% - quantile_cut (e.g., = 0.01): in bias estimate, for a given image, its 1% top values are not be considered
% - doy_diff_threshold (e.g., = 31): in bias estimate, images with day difference > 31 days are not considered 
function I_bias_corr = Time_series_internal_bias_compensation_v1(I, doys, quantile_cut, doy_diff_threshold)
    % n x n matrix; value at (n1, n2) is the median of value differences between images n1 and n2 
    n_images = size(I, 3);
    diff_map = zeros(n_images, n_images);
    
    for n1 = 1:n_images
        doy1 = doys(n1);
        I1 = I(:,:,n1);

        % set very high image values (e.g., top 1%) to 0
        I1 = CleanImageByQuantile(I1, quantile_cut, false, true);
        
        for n2 = n1+1:n_images
            doy2 = doys(n2);
            doy_diff = abs(doy2-doy1);
            if doy_diff > doy_diff_threshold
                continue;
            end
            
            I2 = I(:,:,n2);
            % set very high image values to 0
            I2 = CleanImageByQuantile(I2, quantile_cut, false, true);
            
            mask_i = I1 ~=0 & I2 ~= 0; % intersection mask of I1 and I2
            if nnz(mask_i) < 1000
                continue;
            end
            diff_i = I1 - I2;
            diff_i(~mask_i) = 0;
            diff_map(n1, n2) = median(diff_i(diff_i~=0)); % median value difference of n1 w.r.t. n2
            diff_map(n2, n1) = -diff_map(n1, n2); % n2 w.r.t. n1
        end
    end

    % bias for image i: median of its medians diffs w.r.t. other images
    diff_medians_n = zeros(n_images, 1);
    for i=1:n_images
        medians_i = diff_map(i,:);
        diff_medians_n(i) = median(medians_i(medians_i~=0));
    end

    % apply bias to each image
    I_bias_corr = I*0; % bias corrected time series
    for i = 1:n_images
        Ii = I(:,:,i);
        Ii(Ii~=0) = Ii(Ii~=0) - diff_medians_n(i)/2;
        I_bias_corr(:,:,i) = Ii;
    end

    return
    