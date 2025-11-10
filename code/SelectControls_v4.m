function controls = SelectControls_v4(rsqs_nn, p1_nn, p2_nn, obs_ratio_n, obs_overlapping_ratio_nn, rsq_threshold, p1_threshold, p2_threshold)
    rsqs_nn(rsqs_nn < rsq_threshold | abs(p1_nn-1) > p1_threshold | abs(p2_nn) > p2_threshold) = 0;
       
    % Find the image maximizes sum[R2(a,b)*overlapping_ratio(a,b)]
    nImg = length(obs_ratio_n);
    scores_n = zeros(1, nImg);
    for idx1 = 1:nImg
        for idx2 = 1:nImg
            if idx1 == idx2
                continue;
            end

            scores_n(idx1) = scores_n(idx1) + rsqs_nn(idx1, idx2)*obs_overlapping_ratio_nn(idx1, idx2);
        end
    end

    [~, idx] = max(scores_n);
    controls = zeros(1, nImg);
    controls(idx) = 2;
end

