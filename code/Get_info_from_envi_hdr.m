function [nrow, ncol, bands_num, band_names] = Get_info_from_envi_hdr(hdr_filename)
    nrow = [];
    ncol = [];
    bands_num = [];
    band_names = {};
    
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
    
    txt = fileread(hdr_filename);
    tok = regexp(txt, 'band names\s*=\s*{([^}]*)}', 'tokens', 'once');
    
    if ~isempty(tok)
        names_raw = regexp(tok{1}, '[,\n\r]+', 'split');
        names_raw = strtrim(names_raw);
        band_names = names_raw(~cellfun('isempty', names_raw));
    end
end