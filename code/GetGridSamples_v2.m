% split feature space into grids; for each grid, get number of points, mean band-1 (x) values, and mean band-2 (y) values
% note: a mean band-1 (x) value is similar to the correponding grid's center point, but is a more accurate estimate
% v2: for interval calculation (either x or y axis), just divide value range by bin number
function [x_grid_values, y_grid_values, xy_grid_num, fill_value] = GetGridSamples_v2(x, y, x_min, x_max, y_min, y_max, bin)
    x_interval = (x_max - x_min)/bin;
    y_interval = (y_max - y_min)/bin;
    
    x_grid_values = zeros(bin+2, bin+2);
    y_grid_values = zeros(bin+2, bin+2);
    xy_grid_num = zeros(bin+2, bin+2);
    for i=1:length(x)
        x_i = x(i);
        y_i = y(i);
        col = ceil((x_i - x_min)/x_interval);
        row = ceil((y_i - y_min)/y_interval);
        if col < 1
            col = 0;
        end
        if col > bin
            col = bin+1;
        end
        if row < 1
            row = 0;
        end
        if row > bin
            row = bin + 1;
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

