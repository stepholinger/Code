load('stationInfo.mat')
statIdx = [1,4,7];
stat = stat(statIdx,:);
fs = fs(statIdx,:);
fsResamp =  min(fs);
statLat = statLat(ceil(statIdx/3));
statLon = statLon(ceil(statIdx/3));
dayStr = "2012-04-02";
detection = datetime(2012,4,2,15,18,00,00);
pick = datetime(2012,4,2,15,18,00,00)+seconds(6700/fsResamp);
detLen = 5*60*fsResamp;
freq = [0.1,10];
filtType = "bandpass";

% get arrival times from cross correlation
getArrivals

gridCornerLat = [-74,-74,-76,-76];
gridCornerLon = [-106,-98,-98,-106];
numLonStep = 100;
numLatStep = 100;
startTime = detection;
endTime = detection+minutes(5);
numTimeStep = 100;
velLow = 0.1;
velHigh = 4;
numVelStep = 40;

[errorMatFull,v,t,lat,lon,vels,times,latitudes,longitudes] = gridsearch(arrivalsDatetime,statLat,statLon,velLow,velHigh,numVelStep,gridCornerLat,numLatStep,gridCornerLon,numLonStep,startTime,endTime,numTimeStep);

[v,t,lat,lon] = ind2sub(size(errorMatFull),find(errorMatFull == min(errorMatFull,[],'all')));