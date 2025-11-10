% Get PIF map from NDVI time series 
%
% Parameters
% -I:    input NDVI time series
% -doys: DOYs of the time series
% -quantile_cut: for each NDVI image, the top n% values are not used
function PIF_map = Get_PIF_map_from_NDVI_time_sereis_v1(I, doys, quantile_cut, outputDir)
    % hard threshold for bia compensation
    %  if two images are temporally apart, with DOY diff greater than this threshold, their image pair is not considered
    doy_diff_threshold = 31;

    % get dNDVI map and valid-obs count map
    [temporal_diff_map, obs_count_map] = Get_dNDVI_map_v1(I, doys, quantile_cut, doy_diff_threshold, outputDir);

    % exclude pixels with too small obs count (it is common that the obtained obs_threshold is 1, meaning it makes no difference)
    quantile_ratio_obs = 0.05;
    obs_threshold = quantile(obs_count_map(obs_count_map>0), quantile_ratio_obs);
    temporal_diff_map(obs_count_map<=obs_threshold) = 0;

    % estimate dNDVI threshold 
    temp_diff_threshold = GetTemporalDiff_threshold(single(temporal_diff_map));

    % apply threshold to dNDVI map to get the PIF image
    PIF_map = temporal_diff_map > 0 & temporal_diff_map < temp_diff_threshold; 
end

