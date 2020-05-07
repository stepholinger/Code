function [solution,totalM,covM,stDev]= ddRelocate(v,statLoc,eventLoc,arrivals,lambda,tolerance)
% matlab function that performs a weighted least-squares inversion to solve
% the double-difference location problem
%
% input parameters:
% v: phase velocity
% statLoc: matrix of station x-coordinates and y-coordinates
% eventLoc: matrix of event x-coordinates, y-coordinates, origin times
% arrivals: matrix of arrivals for each event at each station
% lambda: damping parameter
% tolerance: distance (km) under which event pairs will be considered

% check whether Parallel Computing Toolbox is installed; run on GPU if so
version = ver;
if sum(contains({version.Name},'Parallel')) > 0
    useGPU = 1;
else
    useGPU = 0;
end

% determine number of events and stations
numEvents = length(eventLoc);
numStat = length(statLoc);

% set useful variables
xStat = statLoc(:,1)';
yStat = statLoc(:,2)';
xEvent = eventLoc(:,1);
yEvent = eventLoc(:,2);
origins = eventLoc(:,3);

% calculate distance from each event to each station
xTrav = zeros(length(xEvent),1);
yTrav = zeros(length(xEvent),1);
for i = 1:length(xEvent)
    for j = 1:length(xStat)
        xTrav(i,j) = xEvent(i,:) - xStat(:,j);
        yTrav(i,j) = yEvent(i,:) - yStat(:,j);
    end
end

% set variables
totalM = zeros(3*length(xEvent),1);
solution = zeros(length(xEvent),3);

% solution iteration loop
for n = 1:5

    % calculate dicstance travelled
    distTrav = sqrt(xTrav.^2 + yTrav.^2);

    % calculate predicted arrival times
    calcArrivals = origins + (1 / v) .* distTrav;

    % calculate partial derivatives for inversion
    dtdx = xTrav ./ (v .* distTrav);
    dtdy = yTrav ./ (v .* distTrav);

    % call dd_prep
    [gSparse,dr] = ddPrep(arrivals,calcArrivals,dtdx,dtdy,xEvent,yEvent,numEvents,numStat,lambda,tolerance);
    
    if useGPU == 1
        % make sparse matrices into sparse gpuArray
        gSparse = gpuArray(gSparse);
        dr = gpuArray(dr);
        
        % solve least squares directly on GPU
        m = (gSparse'* gSparse)\(gSparse'*dr);
        
        % convert back to double from gpuArray
        totalM = gather(totalM);
        m = gather(m);
    else
        % solve least squares directly on CPU 
        m = gSparse\dr;
    end 
    
    % update total change in model parameters
    totalM = totalM + m;
    
    % update locations for next iteration
    xTrav = xTrav + m(1:3:end,:);
    yTrav = yTrav + m(2:3:end,:);
    origins = origins + m(3:3:end,:);
    solution(:,1) = xEvent(:,1) + totalM(1:3:end,:);
    solution(:,2) = yEvent(:,1) + totalM(2:3:end,:);
    solution(:,3) = origins;

end

if useGPU == 1
    % gather variables and calculate covariance matrix on CPU
    covM = (gather(dr')*gather(dr))/(abs(diff(size(gSparse))))*inv(gather(gSparse')*gather(gSparse));
else
    % calculate covariance matrix on CPU
covM = (dr'*dr)/(abs(diff(size(gSparse))))*inv(gSparse'*gSparse);
end

stDevTemp = real((diag(full(covM))).^0.5);
stDev(:,1) = stDevTemp(1:3:end);
stDev(:,2) = stDevTemp(2:3:end);
stDev(:,3) = stDevTemp(3:3:end);

end
