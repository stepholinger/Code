function L = liklihood_loc(synthetic_arrivals,arrivals,sigma)

normArg = (arrivals-synthetic_arrivals)./arrivals;
normArg(isnan(normArg)) = 1;
L = -0.5/sigma^2 * norm(normArg)^2;

end