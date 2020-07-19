function arrivals = loc_func_mcmc(params,statLoc)

% this function is for use with P. Segall's MCMC code- instead of actually
% calling the Green's function model, it pulls already created Green's
% functions (spatial derivative has already been taken). Therefore, L, f_max, and t_max are fixed, and already set by
% this point. In general, they will be L = 1e7, f_max = 1, t_max = 1000

% get parameters from vector
lat = params(1);
lon = params(2);
origin = params(3);
vel = params(4);

% calculate distance from location to stations
[arclen,~] = distance(statLoc(:,1),statLoc(:,2),lat,lon,wgs84Ellipsoid);

% convert to km
dist = arclen./1000;

% calculate arrival times at each station
arrivals = origin + dist*(1/vel);

end