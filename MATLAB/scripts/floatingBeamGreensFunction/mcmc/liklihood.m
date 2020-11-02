function L = liklihood(G,data,sigma,type)
if type == "standard"
    normArg = (data-G)./data;
elseif type == "modified"
    normArg = (data-G).*10;    
end
normArg(isnan(normArg)) = 1;
L = -0.5/sigma^2 * norm(normArg)^2;
end