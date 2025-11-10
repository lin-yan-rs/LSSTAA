% Least-squares adjustment to calculate normalization coefficients for each image in time series (a single spectral band)
%
% Parameters
% -I:    input NDVI time series
% -doys: DOYs of the time series
% -image_controls: logical array (same length as doys); elements set to 1 to indicate control (reference) images; can have multiple controls
% -doy_diff_threshold: if two images are temporally apart, with DOY diff greater than this threshold, their image pair is not considered
% -PIF_map: PIF map
% -ntie_threshold: if two images' overlapping area have too few PIFs smaller than this threshold, their image pair is not considered
% -b_show_scatterplots: whether to show pairwise scatterplots
% -band_idx: index of spectral band; only used in title of scatterplot figures
%
% Returns:
% -coefs_all_a: gain coefficients estimated for each image in time series
% -coefs_all_b: offset coefficients estimated for each image in time series
% -I_adj: adjusted (normalized) image data after applying normalization coefficients
% -valid_images: logical array indicating which images are successfully normalized (0 = not normalized, e.g., because it is not connected to other images).
function [coefs_all_a, coefs_all_b, I_adj, valid_images] = CalculateCoefsByLS_v2_4(data, doys, image_controls, doy_diff_threshold, PIF_map, b_show_scatterplots, band_idx)
    n_img = length(doys);
    piCoefsIndexes_all = zeros(n_img*2, 1);
    coefs_all = zeros(n_img*2, 1);
      
    bin_num = 100;
    ntie_threshold = 50;
       
    % get connection graph and number of connections per image (= 0 means the image is not connected with any others)
    [connection_graph, n_images_conn] = Get_connection_graph(data, doys, doy_diff_threshold, PIF_map, 0, ntie_threshold, bin_num);
    
    % mask unconnected images that will not be normalized
    valid_images = uint8(n_images_conn > 0);
    image_controls(~valid_images) = -1;

    % index all unknown coefs for target images that are connected and not controls
    CoefsIdx_idx = 1;
    n_unknown = 0;
    n_img = length(doys);
    for n = 1:n_img
        if image_controls(n) == 1 || image_controls(n) == -1 % 1 is contorl; -1 is unconnected
            piCoefsIndexes_all((n-1) * 2 + 1) = -1;
            piCoefsIndexes_all((n-1) * 2 + 2) = -1;
        else
            piCoefsIndexes_all((n-1) * 2 + 1) = CoefsIdx_idx;
            CoefsIdx_idx = CoefsIdx_idx + 1;
            piCoefsIndexes_all((n-1) * 2 + 2) = CoefsIdx_idx;
            CoefsIdx_idx = CoefsIdx_idx + 1;
            n_unknown = n_unknown + 2;
        end
    end
    
    % initialize coefs
    coefs_all(1:2:n_img*2) = 0;
    coefs_all(2:2:n_img*2) = 0;
    
    dCoefs = zeros(n_unknown, 1);
    CoefsIdx_idx = 1;
    for i = 1:n_img*2
        if piCoefsIndexes_all(i) >= 0
            dCoefs(CoefsIdx_idx) = coefs_all(i);
            CoefsIdx_idx = CoefsIdx_idx + 1;
        end
    end
    
    % least-squares adjustment
    n = n_unknown;
    N = zeros(n, n);
    U = zeros(n, 1);
    ntie_total = 0;
    rmse_ls = 0;
    for idx1 = 1:n_img-1
        if image_controls(idx1) == -1
            continue;
        end

        doy1 = doys(idx1);
        data1_org = data(:,:,idx1);
        for idx2 = idx1+1:n_img
            if image_controls(idx2) == -1
                continue;
            end
            if image_controls(idx1) == 1 && image_controls(idx2) == 1
                continue;
            end
            doy2 = doys(idx2);
            doy_diff = abs(doy1 - doy2);
            if doy_diff > doy_diff_threshold
                continue;
            end
            data2_org = data(:,:,idx2);

            % a connected target-target or target-reference image pair

            % get valid tie (PIF) points
            % note: if another PIF selection method is used, e.g., detect PIFs between the current two images,
            %  apply the detected PIFs here
            mask = data1_org ~= 0 & data2_org ~= 0 & PIF_map > 0;
            data1_ = data1_org(mask);
            data2_ = data2_org(mask);
            if length(data2_) < ntie_threshold
                continue;
            end
            
            % select a subset of PIFs
            [data1, data2, ~] = Select_PIF_subset(data1_, data2_, bin_num);

            ntie = length(data1);
            ntie_total = ntie_total + ntie;
            if image_controls(idx1) ~= 1
                idx_a1 = piCoefsIndexes_all((idx1-1)*2 + 1);
                idx_b1 = piCoefsIndexes_all((idx1-1)*2 + 2);
            end
            if image_controls(idx2) ~= 1
                idx_a2 = piCoefsIndexes_all((idx2-1)*2 + 1);
                idx_b2 = piCoefsIndexes_all((idx2-1)*2 + 2);
            end
            a1 = coefs_all((idx1-1)*2 + 1);
            b1 = coefs_all((idx1-1)*2 + 2);
            a2 = coefs_all((idx2-1)*2 + 1);
            b2 = coefs_all((idx2-1)*2 + 2);
            % form observation equation for each selected tie point (PIF)
            for i=1:ntie
                A = zeros(n, 1, 'single');
                if image_controls(idx1) ~= 1
                    % idx_a1 >= 0 && idx_b1 >= 0
                    A(idx_a1) = data1(i);
                    A(idx_b1) = 1;
                end
                if image_controls(idx2) ~= 1
                    % idx_a1 >= 0 && idx_b1 >= 0
                    A(idx_a2) = -data2(i);
                    A(idx_b2) = -1;
                end

                % obs. equation: L = g2*(1+a2) + b2 - (g1*(1+a1) + b1)
                L = data2(i)*(1+a2) + b2 - (data1(i)*(1+a1) + b1);

                % form normal equation
                N = N + A*A';
                U = U + A*L;

                rmse_ls = rmse_ls + L*L;
            end
        end
    end

    % solve normal equation N * x = U
    Delta_Paras = N \ U;
    dCoefs = dCoefs + Delta_Paras;

    rmse_before = sqrt(rmse_ls/(ntie_total - n_unknown));

    % update unknown coefficients in coefs_all
    CoefsIdx_idx = 1;
    for i = 1:n_img * 2
        if (piCoefsIndexes_all(i) >= 0)
            coefs_all(i) = dCoefs(CoefsIdx_idx);
            CoefsIdx_idx = CoefsIdx_idx + 1;
        end
    end

    % get normalization coefficients
    coefs_all(1:2:n_img*2) = coefs_all(1:2:n_img*2) + 1;
    coefs_all_a = coefs_all(1:2:n_img*2);
    coefs_all_b = coefs_all(2:2:n_img*2);
    % apply normalization
    I_adj = AdjustImageTimeSeries(data, coefs_all_a, coefs_all_b);

    if b_show_scatterplots > 0
        b_show_only_PIF = false;

        % show scatterplots of original images (a = 1, b = 0 for all images)
        figure_id = 11; figure(figure_id); clf;
        title_str = sprintf('Band %d before normalization', band_idx);
        sgtitle(title_str, 'Color', 'k', 'FontSize', 14, 'FontWeight', 'bold');
        Show_pairwise_scatterplots(data, doys, image_controls, ones(1, n_img), zeros(1, n_img), doy_diff_threshold, PIF_map, ntie_threshold, b_show_only_PIF, figure_id);
        
        % show scatterplots of normalized images
        figure_id = 12; figure(figure_id); clf;
        title_str = sprintf('Band %d after LSSTAA normalization', band_idx);
        sgtitle(title_str, 'Color', 'k', 'FontSize', 14, 'FontWeight', 'bold');
        Show_pairwise_scatterplots(data, doys, image_controls, coefs_all_a, coefs_all_b, doy_diff_threshold, PIF_map, ntie_threshold, b_show_only_PIF, figure_id);
        
        annotation('textbox',[0 0.01 1 0.05],'String','Press Space bar to continue','EdgeColor','none','HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',14,'FontWeight','bold','Color','k');
    end
end