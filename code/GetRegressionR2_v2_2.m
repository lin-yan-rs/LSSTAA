function [rsq, rmse, p, y_resid] = GetRegressionR2_v2_2(x,y, order)
    mask = x == 0 | y == 0;
    x(mask) = [];
    y(mask) = [];
    
    if isempty(x) || isempty(y)
        rsq = 0;
        rmse = 0;
        if order == 1
            p = zeros(2,1);
        elseif order == 2
            p = zeros(3,1);
        end
        y_resid = 0;
        return;
    end
    
    p = polyfit(x,y,order);
    y_fit = polyval(p,x);
    y_resid = y - y_fit;
    SSresid = sum(y_resid.^2);
    SStotal = (length(y)-1) * var(y);
    rsq = 1 - SSresid/SStotal;
    
    rmse = sqrt(SSresid/(length(y)-1));
    rmse = rmse/mean(y)*100;
end

