function L = liklihood(G,data,sigma,type,corrCoef)
if type == "standard" || type == "xcorr"
    normArg = (data-G)./data;

elseif type == "modified"
    normArg = (data-G);    
end

normArg(isnan(normArg)) = 0;
L = -0.5/sigma^2 * norm(normArg)^2;

if type == "xcorr" && nargin > 4
    L = L/corrCoef;
end

end