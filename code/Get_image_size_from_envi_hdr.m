function [nrow, ncol, bands_num] = Get_image_size_from_envi_hdr(hdr_filename)
    nrow = [];
    ncol = [];
    bands_num = [];
    fid = fopen(hdr_filename, 'r');
    if fid == -1
        error('Cannot open file: %s', hdr_filename);
    end
    while ~feof(fid)
        line = fgetl(fid);
        if contains(line, 'samples', 'IgnoreCase', true)
            ncol = str2double(regexp(line, '\d+', 'match', 'once'));
        elseif contains(line, 'lines', 'IgnoreCase', true)
            nrow = str2double(regexp(line, '\d+', 'match', 'once'));
        elseif contains(line, 'bands', 'IgnoreCase', true)
            bands_num = str2double(regexp(line, '\d+', 'match', 'once'));
        end
    end
    fclose(fid);
    if isempty(nrow) || isempty(ncol) || isempty(bands_num)
        error('Failed to read all required fields from %s', hdr_filename);
    end
end