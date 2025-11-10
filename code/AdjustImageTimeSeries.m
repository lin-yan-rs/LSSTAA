function I_adj = AdjustImageTimeSeries(I, dCoefs_all_a, dCoefs_all_b)
    I_adj = I*0;
    bandsNum = length(dCoefs_all_a);
    for i=1:bandsNum
        Ii = I(:,:,i);
        mask = Ii == 0;
        Ii = Ii*dCoefs_all_a(i) + dCoefs_all_b(i);
        Ii(mask) = 0;
        I_adj(:,:,i) = Ii;        
    end
end

