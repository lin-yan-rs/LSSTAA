function I_out = ReformOutputImage_v1(I)
    dtype = class(I);
    I_out = rot90(I);
    I_out = flipud(I_out);
    I_out = cast(I_out, dtype);
end