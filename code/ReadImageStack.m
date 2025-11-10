function I = ReadImageStack(filename, nrow, ncol, bands_num_all, data_type)
    fid = fopen(filename, 'rb');
    n_size = nrow*ncol;
    I = zeros(nrow, ncol, data_type);
    for i=1:bands_num_all
        Ii = fread(fid, n_size, data_type);
        Ii = ReformInputImage_v1(Ii, nrow, ncol);
        I(:,:,i) = Ii;
    end
    fclose(fid);
end