function WriteImageStack(I, filename, data_type)
    I = cast(I, data_type);
    bands_num_all = size(I, 3);
    fid = fopen(filename, 'wb');
    for i=1:bands_num_all
        Ii = I(:,:,i);
        Ii = ReformOutputImage_v1(Ii);
        fwrite(fid, Ii, data_type);
    end
    fclose(fid);
end