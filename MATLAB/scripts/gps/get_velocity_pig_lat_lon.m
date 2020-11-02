% correct lon format
lon = lon-360;

% convert times to datetime
dateVect = datetime(2012,1,9,0,0,0,'Format','yyyy-MM-dd HH:mm:SS') + days(daysSinceJan9);

% get vector of all days in the dataset
dayVect = datetime(dateVect(1).Year,dateVect(1).Month,dateVect(1).Day);
for d = 2:length(dateVect)
    if dateVect(d-1).Day ~= dateVect(d).Day
        dayVect = [dayVect;datetime(dateVect(d).Year,dateVect(d).Month,dateVect(d).Day)];
    end
end

% make some empty arrays
dailyAvgLat = zeros(length(dayVect),1);
dailyAvgLon = zeros(length(dayVect),1);
i = 1;

% iterate through days in the data
for d = 1:length(dayVect)
    
    % calculate average daily position from all data points on current day
    n = 0;
    lat_sum = 0;
    lon_sum = 0;
    while dayVect(d).Day == dateVect(i).Day && i < length(dateVect)-1 
        lat_sum = lat_sum + lat(i);
        lon_sum = lon_sum + lon(i);
        i = i + 1;
        n = n + 1;
    end
    dailyAvgLat(d) = lat_sum/n;
    dailyAvgLon(d) = lon_sum/n;
    
end

% get distances traveled from initial position
dailyAvgDistance = zeros(length(dailyAvgLon),1);
for d = 1:length(dailyAvgLat)-1
    dailyAvgDistance(d) = deg2km(distance(dailyAvgLat(d),dailyAvgLon(d),dailyAvgLat(d+1),dailyAvgLon(d+1)))*1000;
end

% differentiate to get velocity in m/s
dailyAvgVelocity = diff(dailyAvgDistance)/86400;