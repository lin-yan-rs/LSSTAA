% Select a subset of PIFs that are x-axis bin medians and y-axis bin medians 
function [x_rsp, y_rsp, rsq] = Select_PIF_subset(x, y, bin)
    b_equal_bin_number = true;

    % get x and y range values after excluding top and bottom 1% values
    quantile_threshold_for_value_range = 0.01;
    x_min = quantile(x, quantile_threshold_for_value_range);
    x_max = quantile(x, 1-quantile_threshold_for_value_range);
    y_min = quantile(y, quantile_threshold_for_value_range);
    y_max = quantile(y, 1-quantile_threshold_for_value_range);

    mask = x == 0 | y == 0;
    x(mask) = [];
    y(mask) = [];
    
    % split feature space into grids; get x and y, and number of points per grid
    if b_equal_bin_number == true 
        [x_grid_values, y_grid_values, xy_grid_num, ~] = GetGridSamples_v2(x, y, x_min, x_max, y_min, y_max, bin);
    else
        [x_grid_values, y_grid_values, xy_grid_num, ~] = GetGridSamples_v3(x, y, x_min, x_max, y_min, y_max, bin);
    end
    [nrow_grid, ncol_grid] = size(x_grid_values);
    rsp_len = max(nrow_grid, ncol_grid);
    x_rsp = zeros(rsp_len*2, 1);
    y_rsp = zeros(rsp_len*2, 1);
    
    n_rsp = 0;
    % for each x-axis vertical bin, get a median point 
    for i = 1:ncol_grid
        x_rsp_i = x_grid_values(:,i);
        y_rsp_i = y_grid_values(:,i);
        nums_rsp_i = xy_grid_num(:,i);
        num_mid = sum(nums_rsp_i)/2;
        num_count = 0;
        % scan the vertical bin space from bottom up
        for t=1:nrow_grid
            num_count = num_count + nums_rsp_i(t);
            if num_count > num_mid % over 50% points in the bin are traversed
                % median point is found
                x_rsp(n_rsp+1) = x_rsp_i(t);
                y_rsp(n_rsp+1) = y_rsp_i(t);
                n_rsp = n_rsp + 1;
                break;
            end
        end
    end
    % for each y-axis horizontal bin, get a median point
    for i = 1:nrow_grid
        x_rsp_i = x_grid_values(i,:);
        y_rsp_i = y_grid_values(i,:);
        nums_rsp_i = xy_grid_num(i,:);
        num_mid = sum(nums_rsp_i)/2;
        num_count = 0;
        % scan the horizontal bin space from left to right
        for t=1:ncol_grid
            num_count = num_count + nums_rsp_i(t);
            if num_count > num_mid % over 50% points in the bin are traversed
                % median point is found
                x_rsp(n_rsp+1) = x_rsp_i(t);
                y_rsp(n_rsp+1) = y_rsp_i(t);
                n_rsp = n_rsp + 1;
                break;
            end
        end
    end
    
    mask = x_rsp == 0 | y_rsp == 0;
    x_rsp(mask) = [];
    y_rsp(mask) = [];
    [rsq, ~, ~, ~] = GetRegressionR2_v2_2(x_rsp,y_rsp, 1);
end



