function [newLoc,totalM,covM,sqrErr,stDev,xStat,yStat] = relocate(v,arrivals,eventLoc,statLoc,refLoc,numIter)
% 
% relocates set of seismic events by calling locationInversion.m to
% perform a linearized inversion for each event
%
% input parameters:
% v: phase velocity
% arrivals: vector of arrival times at each station
% eventLoc: vector input location parameters [lat,lon,originTime,error]
% statLoc: matrix of station locations [lat,lon] 
% refLoc: location of reference point for new locations [lat,lon]
% numIter: desired number of iterations

% set useful variables
numEvents = length(arrivals);

% initialize variable
newLoc = zeros(numEvents,3);
totalM = zeros(numEvents,3);
covM = cell(numEvents,1);
sqrErr = zeros(numEvents,1);
stDev = zeros(numEvents,3);

% call locationInversion.m for each event and load results into variables
for n = 1:numEvents
    [TempNewLoc,TempTotalM,TempCovM,TempSqrErr,TempStDev,xStat,yStat] = locationInversion(v,transpose(arrivals(n,:)),eventLoc(n,1:3),statLoc,refLoc,numIter);
    sqrErr(n) = TempSqrErr;
    stDev(n,:) = TempStDev;
    newLoc(n,:) = TempNewLoc;
    totalM(n,:) = TempTotalM;
    covM{n} = TempCovM;   
end

% reformat station locations
xStat = xStat';
yStat = yStat';

end