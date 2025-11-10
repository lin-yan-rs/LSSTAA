function NDVI = GetNDVI_4bands(I)
    I4 = I(:,:,4);
    I3 = I(:,:,3);
    NDVI = (I4-I3)./(I4+I3);
    NDVI(I4+I3 == 0) = 0;
end

