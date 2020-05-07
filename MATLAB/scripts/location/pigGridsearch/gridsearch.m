function [errorMatFull,v,t,lat,lon,vels,times,latitudes,longitudes] = gridsearch(arrivals,statLat,statLon,velLow,velHigh,numVelStep,gridCornerLat,numLatStep,gridCornerLon,numLonStep,startTime,endTime,numTimeStep)

% define search grid
%gridCornerLat = [-71.5,-71.5,-78,-78];
%gridCornerLon = [-110,-94,-94,-110];
%startTime = "2012-05-09 18:00:00";
%endTime = "2012-05-09 18:05:00";

velStep = (velHigh-velLow)/numVelStep;
vels = velLow:velStep:velHigh;

latStep = diff(unique(gridCornerLat))/numLatStep;
latitudes = min(gridCornerLat) + (1:numLatStep)*latStep;
lonStep = diff(unique(gridCornerLon))/numLonStep;
longitudes = min(gridCornerLon) + (1:numLonStep)*lonStep;

startTime = datetime(startTime,'Format','yyyy-MM-dd HH:mm:ss.SSS');
endTime = datetime(endTime,'Format','yyyy-MM-dd HH:mm:ss.SSS');
timeStep = (endTime-startTime)/numTimeStep;
times = startTime:timeStep:endTime;

% make matrix for storing error maps
errorMatFull = zeros(length(vels),numTimeStep,length(latitudes),length(longitudes));

% determine number of events and stations
numStat = length(statLat);

% search through phase velocity
parfor v = 1:length(vels)
    errorMat = zeros(numTimeStep,length(latitudes),length(longitudes));
    
    % search through origin times
    for t = 0:numTimeStep-1

        origin = startTime + (t * timeStep);

        % search through latitudes
        for lat = 1:length(latitudes)

            % search through longitudes       
            for lon = 1:length(longitudes)           

                % calculate distance from location to stations
                [arclen,~] = distance(statLat,statLon,latitudes(lat),longitudes(lon),wgs84Ellipsoid);

                % convert to km
                dist = arclen./1000;

                % calculate arrival times at each station
                synthArrivals = origin + seconds(dist*(1/vels(v)));

                % find residual 
                res = seconds(arrivals - synthArrivals');

                % calculate mean squared error
                mse = sum(res .* res)/numStat;

                % save error
                errorMat(t+1,lat,lon) = mse;

            end

        end
         
    end
    
    fprintf(string(v/length(vels)*100) + " percent complete.\n");
    
    errorMatFull(v,:,:,:) = errorMat;
    
end

% use the below to extract lowest error solution
[v,t,lat,lon] = ind2sub(size(errorMatFull),find(errorMatFull == min(errorMatFull,[],'all')));


end
