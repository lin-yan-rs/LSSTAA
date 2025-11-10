function [connectionGraph, valid_images] = Get_connection_graph(data, doys, doy_diff_threshold, PIF_map, rsq_threshold, ntie_threshold, bin_num)
    n_img = length(doys);
    connectionGraph = zeros(n_img, n_img);
    valid_images = zeros(n_img, 1);
    for idx1 = 1:n_img-1       
        doy1 = doys(idx1);
        data1_org = data(:,:,idx1);
        for idx2 = idx1+1:n_img
            doy2 = doys(idx2);
            if abs(doy1 - doy2) > doy_diff_threshold
                continue;
            end
            data2_org = data(:,:,idx2);
            
            % get valid tie points
            mask = data1_org ~= 0 & data2_org ~= 0 & PIF_map>0;
            data1_ = data1_org(mask);
            data2_ = data2_org(mask);
            if length(data2_) < ntie_threshold
                continue;
            end
            [~, ~, rsq] = Select_PIF_subset(data1_, data2_, bin_num);
            
            if rsq < rsq_threshold 
                continue;
            end
            connectionGraph(idx1, idx2) = connectionGraph(idx1, idx2) + 1;
            valid_images(idx1) = valid_images(idx1) + 1;
            valid_images(idx2) = valid_images(idx2) + 1;
        end
    end

    return;
end