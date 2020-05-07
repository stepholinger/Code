function iceShelfSlope(frontLoc,groundLoc,tidalTimes,groundZ,frontZ,arrayZ,eventTimes)
% calculates slope of ice shelf for a duration of time and compares slope
% timeseries with seismic event times

% set useful variables
numEvents = length(eventTimes);
numSamples = length(tidalTimes);

% find times for high and low tides
[~,tideMaximaTimes]=findpeaks(arrayZ,tidalTimes,'MinPeakDistance',0.25);
[~,tideMinimaTimes]=findpeaks(arrayZ*-1,tidalTimes,'MinPeakDistance',0.25);

minOrMax = 'min';
if strncmp(minOrMax,'min',3)
    extremaTimes = tideMinimaTimes;
end
if strncmp(minOrMax,'max',3)
    extremaTimes = tideMaximaTimes;
end

% find amount of time between each event and nearest previous extrema
for m = 1:numEvents
    for i = 1:length(extremaTimes)-1
        if eventTimes(m) > extremaTimes(i) && eventTimes(m) < extremaTimes(i+1)
            timeAfterExtrema(m) = (eventTimes(m) - extremaTimes(i))/(extremaTimes(i+1) - extremaTimes(i));
        end
    end
end

% plot time after nearest maxima
figure(1);
histogram(timeAfterExtrema);
hold on;

% calculate ice shelf slope
deltaZ = groundZ - frontZ;
dist = distance(frontLoc,groundLoc);
dist = deg2km(dist);
shelfSlopes = deltaZ/(dist*1000);

% calculate each individual slope cycle in relation to tidal extrema
for i = 1:length(extremaTimes)-1
    j = 1;
    for m = 1:numSamples
        if tidalTimes(m) > extremaTimes(i) && tidalTimes(m) < extremaTimes(i+1)
            allSlopeCycles(i,j) = shelfSlopes(m);
            j = j + 1;
        end
    end
end

for i = 1:size(allSlopeCycles,1)
    for j = 1:size(allSlopeCycles,2)
        if allSlopeCycles(i,j) == 0
            allSlopeCycles(i,j) = NaN;
        end
    end 
end

% calculate each individual tidal cycle in relation to tidal extrema
for i = 1:length(extremaTimes)-1
    j = 1;
    for m = 1:numSamples
        if tidalTimes(m) > extremaTimes(i) && tidalTimes(m) < extremaTimes(i+1)
            allTideCycles(i,j) = arrayZ(m);
            j = j + 1;
        end
    end
end

for i = 1:size(allTideCycles,1)
    for j = 1:size(allTideCycles,2)
        if allTideCycles(i,j) == 0
            allTideCycles(i,j) = NaN;
        end
    end 
end


% plot slope cycles
plot(linspace(0,1,100),allSlopeCycles(:,1:100)')

% calculate slope
deltaZ = groundZ - frontZ;
dist = distance(frontLoc,groundLoc);
dist = deg2km(dist);
shelfSlopes = deltaZ/(dist*1000);

% find all slope cycle maxima
[slopeMaxima,slopeMaximaTimes]=findpeaks(shelfSlopes,tidalTimes,'MinPeakDistance',0.5);

% calculate slope at time of each event
for n = 1:numEvents
    [~,idx] = min(abs(tidalTimes-eventTimes(n)));
    eventSlopes(n) = shelfSlopes(idx);   
end

% find slope maxima
nearestMaxSlope = interp1(slopeMaximaTimes,slopeMaxima,eventTimes,'previous')';

% plot tidal phase,number of events, and slope
figure(1);
yyaxis left;
histogram(timeAfterExtrema,'FaceColor',[175/255,50/255,34/255]);
ylim([0 900]);
yyaxis right;
plot(linspace(0,1,100),allSlopeCycles(:,1:100),'-','Color',[40/255,25/255,130/255,.2]);
ylow = min(min(allSlopeCycles));
yhigh = max(max(allSlopeCycles));
ylim([ylow*2 yhigh]);

% plot tidal phase,number of events, and slope
figure(2);
yyaxis left;
histogram(timeAfterExtrema,'FaceColor',[175/255,50/255,34/255]);
ylim([0 900]);
yyaxis right;
plot(linspace(0,1,100),allTideCycles(:,1:100),'-','Color',[40/255,25/255,130/255,.2]);
ylow = min(min(allTideCycles));
yhigh = max(max(allTideCycles));
ylim([ylow*2 yhigh]);

% plot ratio between instantaneous slope and nearest slope maxima
figure(3);
histogram(eventSlopes./nearestMaxSlope);
histcounts(eventSlopes./nearestMaxSlope);



end