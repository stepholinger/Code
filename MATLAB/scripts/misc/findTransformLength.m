function m = findTransformLength(m)
m = 2*m;
while true
    r = m;
    for p = [2 3 5 7]
        while (r > 1) && (mod(r, p) == 0)
            r = r / p;
        end
    end
    if r == 1
        break;
    end
    m = m + 1;
end