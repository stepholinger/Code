% replaces stations with high residual arrivals with 0

for n = 1:length(arrivals)
    for m = 1:length(stat)
        if contains(highRes(n,1),stat(1,m)) == 1
           lowErrArrivals(n,m) = 0;
        end
    end
end
            