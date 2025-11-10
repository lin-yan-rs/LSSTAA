function I = CleanImageByQuantile(I, quantile_ratio, cut_low, cut_top)
    if nargin < 3
        cut_low = true;
    end
    if nargin < 4
        cut_top = true;
    end
    I_1D = I(I~=0);
    min_quantile = quantile(I_1D, quantile_ratio);
    max_quantile = quantile(I_1D, 1-quantile_ratio);
    if cut_low == true
        I(I<min_quantile) = 0;
    end
    if cut_top == true
        I(I > max_quantile) = 0;
    end
end

