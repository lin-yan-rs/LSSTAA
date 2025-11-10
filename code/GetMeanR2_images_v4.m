function [rsqs_mean, rsqs_median, rsqs_n, rsqs, p1_all, p2_all, obs_ratio_n, obs_overlapping_ratio_nn] = GetMeanR2_images_v4(data, doys, r2_threshold, temporal_diff_map)
    n_img = length(doys);
    rsqs = zeros(n_img, 1);
    [nrow, ncol, n_img] = size(data);
    obs_overlapping_ratio_nn = zeros(n_img, n_img);
    for idx1 = 1:n_img-1
        doy1 = doys(idx1);
        data1_org = data(:,:,idx1);
        for idx2 = idx1+1:n_img
            doy2 = doys(idx2);
            
            % get valid tie points
            data2_org = data(:,:,idx2);
            mask = data1_org ~= 0 & data2_org ~= 0 & temporal_diff_map>0;
            ntie = nnz(mask);
            
            if ntie < 100
                continue;
            end
            
            ntie_all = nnz(data1_org ~= 0 & data2_org ~= 0);
            obs_overlapping_ratio_nn(idx1, idx2) = ntie_all/nrow/ncol;
            obs_overlapping_ratio_nn(idx2, idx1) = ntie_all/nrow/ncol;
            
            data1 = data1_org(mask);
            data2 = data2_org(mask);
            
            [rsq, rmse, p, residuals] = GetRegressionR2_v2_2(data1,data2, 1);
            if rsq < r2_threshold
                continue;
            end
            rsqs(idx1, idx2) = rsq;
            rsqs(idx2, idx1) = rsq;
            p1_all(idx1, idx2) = p(1);
            p1_all(idx2, idx1) = p(1);
            p2_all(idx1, idx2) = p(2);
            p2_all(idx2, idx1) = p(2);
        end
        
    end
    
    for idx1 = 1:n_img
        rsqs_i = rsqs(idx1, :);
        rsqs_i = rsqs_i(rsqs_i > 0);
        rsqs_n(idx1) = nnz(rsqs_i);
        if rsqs_n(idx1) > 0
            rsqs_mean(idx1) = mean(rsqs_i);
            rsqs_median(idx1) = median(rsqs_i);
        end
        data1_org = data(:,:,idx1);
        obs_ratio_n(idx1) = nnz(data1_org)/nrow/ncol;
    end
    return;
end

