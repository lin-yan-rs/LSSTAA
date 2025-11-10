function temp_diff_threshold = GetTemporalDiff_threshold(temporal_diff_map)
    quantile_threshold = 0.005;
    values = temporal_diff_map(temporal_diff_map~=0);
    min_value = quantile(values, quantile_threshold);
    max_value = quantile(values, 1-quantile_threshold);
    
    values(values < min_value | values > max_value) = [];
    [a b] = hist(values, 50);
    [max_a, idx] = max(a);
    max_bin_b = b(idx);
    temp_diff_threshold = (min(b) + max_bin_b)/2;
  
    return;    
end

