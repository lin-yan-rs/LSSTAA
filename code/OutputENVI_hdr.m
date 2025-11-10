function OutputENVI_hdr(hdr_file, nrow, ncol, bands, datatype, interleave, band_names)
    filename = sprintf('%s.hdr', hdr_file);
    fout = fopen(filename, 'w');
    fprintf(fout, 'ENVI\ndescription = {\n  File Imported into ENVI.}\n');
    fprintf(fout, 'samples = %d\n', ncol);
    fprintf(fout, 'lines   = %d\n', nrow);
    fprintf(fout, 'bands   = %d\n', bands);
    fprintf(fout, 'header offset = 0\n');
    fprintf(fout, 'file type = ENVI Standard\n');
    fprintf(fout, 'data type = %d\n', datatype);
    fprintf(fout, 'interleave = %s\n', interleave);
    fprintf(fout, 'sensor type = Unknown\n');
    fprintf(fout, 'byte order = 0\n');
    fprintf(fout, 'wavelength units = Unknown\n');
    
    if exist('band_names','var') && ~isempty(band_names)
        fprintf(fout, 'band names = {');
        for i = 1:length(band_names)
            if i < length(band_names)
                fprintf(fout, '%s, ', band_names{i});
            else
                fprintf(fout, '%s', band_names{i});
            end
        end
        fprintf(fout, '}\n');
    end
    
    fclose(fout);
end

