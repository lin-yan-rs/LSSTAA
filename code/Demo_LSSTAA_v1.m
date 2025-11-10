    warning('off', 'all');
    clear;
            
    show_scatterplots = 0; % whether to show pairwise scatterplots; not recommended for > 12 images because drawing is time consuming and subplots would be too small 

    % set data folder with three input files: "stack_rsp10", "stack_rsp10.hdr", and "doy.txt"; test images were resampled by 10
    dataDir = sprintf('G:/Lin/Planet/public_release/data1');

    % set file names
    filename_doy = sprintf('%s/doys.txt', dataDir);
    filename_hdr = sprintf('%s/stack_rsp10.hdr', dataDir);
    filename_data = sprintf('%s/stack_rsp10', dataDir);

    % default parameters
    quantile_cut = 0.01; % top 1% values in an image are not used in bias compensation estimate
    doy_diff_threshold_adj = 14; % DOY difference threshold for least-squares adjustment; recommended values >= 7
    dims = 4;   % 4 bands

    % start processing
    outputDir = sprintf('%s/output', dataDir);
    mkdir(outputDir);

    % input doy
    doys = readmatrix(filename_doy);
    % get data dimensions from stack_rsp10.hdr
    [nrow, ncol, bands_num, band_names] = Get_info_from_envi_hdr(filename_hdr);
    % input time series stack_rsp10 (with bsp interleave)
    I_all = single(ReadImageStack(filename_data, nrow, ncol, bands_num, 'int16'));

    [nrow, ncol, bands_num_all] = size(I_all);
    n_Img = bands_num_all/dims;

    I4 = I_all(:,:,4:dims:bands_num_all);
    I3 = I_all(:,:,3:dims:bands_num_all);
    NDVI = (I4-I3)./(I4+I3)*10000;
    NDVI(I4+I3==0)=0;

    fprintf(' Input data: %s\n', filename_data);
    fprintf(' %d (row) × %d (col) × %d (%d bands per image)\n', nrow, ncol, bands_num_all, dims);

    % 1. get PIF map
    % note: other PIF detection methods can be used; PIF can be detected between two images, not necessarily from time series
    PIF_map = Get_PIF_map_from_NDVI_time_sereis_v1(NDVI, doys, quantile_cut, outputDir);
    fprintf(' PIF image obtained\n');

    % 2. select the control (reference) image; controls can be set manually as 1 in 'controls'; multiple controls can be used
    filename_rsqs = sprintf('%s/tmp_rsqs.mat', outputDir); % file with pairwise correlation info, generated in Get_PIF_map_from_NDVI_time_sereis_v1()
    controls = SelectControl(filename_rsqs);
    controls_idx = find(controls == 1);
    for i=1:length(controls_idx)
        fprintf(' Control image: index = %d, doy = %d\n', controls_idx(i), doys(controls_idx(i)));
    end

    % 3. per-band normalization
    fprintf('\n Per-band normalization\n');
    if show_scatterplots > 0
        fprintf(' (scatterplot visualization enabled)\n');
    end

    I_all_adj = I_all*0;
    for band_idx = 1:4
        I = I_all(:,:,band_idx:dims:bands_num_all);

        [dCoefs_all_a, dCoefs_all_b, I_normalized, normalized_images] = CalculateCoefsByLS_v2_4(I, doys, controls, doy_diff_threshold_adj, PIF_map, show_scatterplots, band_idx);

        % put normalized time series of current band in I_all_adj
        I_all_adj(:,:,band_idx:dims:bands_num_all) = I_normalized;

        % output normalization coefficients of current band
        dCoefs_all(:,1) = dCoefs_all_a;
        dCoefs_all(:,2) = dCoefs_all_b;
        filename = sprintf('%s/band%d_coefs_ctrl_%d.txt', outputDir, band_idx, controls_idx);
        fid = fopen(filename, 'w');
        fprintf(fid, '%.3f \t%.3f\n', dCoefs_all');
        fclose(fid);

        fprintf('  band %d done\n', band_idx);
        if show_scatterplots > 0
            pause;
        end
    end

    % 4 output normalized time series
    I_all_adj = int16(I_all_adj);
    filename = sprintf('%s/stack_rsp10.adj_ctrl_%d', outputDir, controls_idx);
    WriteImageStack(I_all_adj, filename, 'int16');
    OutputENVI_hdr(filename, nrow, ncol, bands_num, 2, 'bsq', band_names);
    fprintf('\n Output \n  normalized data: %s\n', filename);

    % 5. output 3 mosaics for visual comparison
    Output_mosaics(I_all, I_all_adj, doys, outputDir, normalized_images);
    fprintf('  example mosaics: %s/mosaics\n', outputDir);
    a = 1;
    
   