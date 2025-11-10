function controls = SelectControl(filename_rsqs)
    load(filename_rsqs);

    % parameters used in SelectControls_v3_0()
    %  set as hard thresholds because the values are conservative and safe
    rsq_threshold_ctrl = 0.8; % two images with R2 < 0.8 won't be considered 
    p1_threshold = 0.3; % threshold corresponding to linear regression gain coefficient; if |1-gain| > 0.3, won't be considered
    p2_threshold = 600; % threshold corresponding to linear regression bias coefficient; if |bias| > 600, won't be considered

    controls_0 = SelectControls_v4(rsqs_nn, p1_nn, p2_nn, obs_ratio_n, obs_overlapping_ratio_nn, rsq_threshold_ctrl, p1_threshold, p2_threshold);
    
    controls = controls_0 == 2;
end