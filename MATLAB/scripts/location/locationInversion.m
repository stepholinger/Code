function [newLoc,totalM,covM,sqrErr,stDev,xStat,yStat] = locationInversion(v,arrivals,eventLoc,statLoc,refLoc,numIter)
% 
% relocates a single seismic event by permorming a simple linearized inversion 
%
% input parameters:
% v: phase velocity
% arrivals: vector of arrival times at each station
% eventLoc: vector input location parameters [lat,lon,originTime,error]
% statLoc: matrix of station locations [lat,lon] 
% refLoc: location of reference point for new locations [lat,lon]
% numIter: desired number of iterations

% set useful variables
numStat = length(statLoc);

% make refLoc same size as statLoc
for n = 1:numStat
    refLoc(n,:) = refLoc(1,:);
end

% loop through arrival times to eliminate stations with no arrival
k = 1;
for n = 1:numStat
    if arrivals(n,:) ~= 0
        trimArrivals(k,:) = arrivals(n,:);
        trimEventLoc(k,:) = eventLoc(1,:);
        trimStatLoc(k,:) = statLoc(n,:);
        trimRefLoc(k,:) = refLoc(1,:);
        k = k + 1;
    end
end

% calculate distance between event and reference location
[xEvent,yEvent] = convert2grid(trimRefLoc,trimEventLoc(:,1:2));

% calculate distance between stations and reference location
[xStat,yStat] = convert2grid(trimRefLoc,trimStatLoc(:,1:2));

% calculate distance between event and each station
xTrav = xEvent - xStat;
yTrav = yEvent - yStat;
distTrav = sqrt(xTrav.^2 + yTrav.^2);

origins = trimEventLoc(:,3);
totalM = 0;

% begin iteration loop
for n = 1:numIter
    
% calculate travel time partial derivatives
    dtdx = xTrav ./ (v .* distTrav);
    dtdy = yTrav ./ (v .* distTrav);
    
% calculate expected arrival times
    calcArrivals = origins + (1 / v) .* distTrav;

% create data vector of travel time residual
    d = trimArrivals - calcArrivals;
    sqrErr = sum(d.^2);
    
% create G matrix of travel time partial derivatives
    G = [dtdx, dtdy, ones(length(dtdx),1)];

% compute inversion
    m = G\d;
    totalM = totalM + m;
    
% update lat, lon, and origin time for next iteration
    xTrav = xTrav + m(1,:);
    yTrav = yTrav + m(2,:);
    origins = origins + m(3,:);
    distTrav = sqrt(xTrav.^2 + yTrav.^2);
    
end

% use changes in model parameters to calculate locations
newLoc(1,1) = xEvent(1,:) + totalM(1,1);
newLoc(1,2) = yEvent(1,:) + totalM(2,1);
newLoc(1,3) = origins(1,:);

% calculate covariance matrix
covM = (d'*d)/(abs(diff(size(G))))*inv(G'*G);
stDev = real((diag(covM)).^0.5);

end