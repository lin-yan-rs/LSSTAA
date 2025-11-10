function Inew = ReformInputImage_v1(I, nrow, ncol)
    dtype = class(I);
    n = size(I, 3);
    I = reshape(I, [ncol, nrow, n]);
    I = flipud(I);
    Inew = rot90(I, -1);
    Inew = cast(Inew, dtype);
end