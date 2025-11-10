% split feature space into grids; for each grid, get number of points, mean band 1 (x) values, and mean band 2 (y) values
% note: a mean band 1 (x) value is similar to the correponding grid's center point, but is a more accurate estimate
% v3: use x or y range to determine an interval used for both axes
function [x_grid_values, y_grid_values, xy_grid_num, fill_value] = GetGridSamples_v3(x, y, x_min, x_max, y_min, y_max, bin)
    if x_max - x_min > y_max - y_min % x range > y range
        interval = (x_max - x_min)/bin;
        bin_x = bin;
        bin_y = ceil((y_max - y_min)/interval);
    else % y range > x range
        interval = (y_max - y_min)/bin;
        bin_y = bin;
        bin_x = ceil((x_max - x_min)/interval);
    end
    x_grid_values = zeros(bin_y+2, bin_x+2);
    y_grid_values = zeros(bin_y+2, bin_x+2);
    xy_grid_num = zeros(bin_y+2, bin_x+2);
    for i=1:length(x)
        x_i = x(i);
        y_i = y(i);
        col = ceil((x_i - x_min)/interval);
        row = ceil((y_i - y_min)/interval);
        if col < 1
            col = 0;
        end
        if col > bin_x
            col = bin_x+1;
        end
        if row < 1
            row = 0;
        end
        if row > bin_y
            row = bin_y + 1;
        end
        col = col + 1;
        row = row + 1;

        x_grid_values(row, col) = x_grid_values(row, col) + x_i;
        y_grid_values(row, col) = y_grid_values(row, col) + y_i;
        xy_grid_num(row, col) = xy_grid_num(row, col) + 1;
    end
    x_grid_values = x_grid_values./xy_grid_num;
    x_grid_values(xy_grid_num == 0) = -9999;
    y_grid_values = y_grid_values./xy_grid_num;
    y_grid_values(xy_grid_num == 0) = -9999;
    
    fill_value = -9999;
    
    return;
end

