function [localMags] = localMags(amps,statLoc,eventLoc)
%
% calculates local magnitude averaged over 5 stations
% 
% input parameters:
% amps: event max amplitudes at each station
% statLoc: station locations
% eventLoc: event locations

%calculate distance to each station
stat1Dist = distance(eventLoc(:,1),eventLoc(:,2),statLoc(:,1),statLoc(:,2));
stat1Dist = deg2km(stat1Dist);

stat2Dist = distance(eventLoc(:,1),eventLoc(:,2),statLoc(:,3),statLoc(:,4));
stat2Dist = deg2km(stat2Dist);

stat3Dist = distance(eventLoc(:,1),eventLoc(:,2),statLoc(:,5),statLoc(:,6));
stat3Dist = deg2km(stat3Dist);

stat4Dist = distance(eventLoc(:,1),eventLoc(:,2),statLoc(:,7),statLoc(:,8));
stat4Dist = deg2km(stat4Dist);

stat5Dist = distance(eventLoc(:,1),eventLoc(:,2),statLoc(:,9),statLoc(:,10));
stat5Dist = deg2km(stat5Dist);

%convert from m to micron - This was wrong but is corrected now
amps = amps * 1e6;

%specify frequency in Hz
f = 2;

%calculate magnitude for each station
stat1Mags = log10(amps(:,1) * f) + 2.76*log10(stat1Dist) - 2.48;
stat2Mags = log10(amps(:,2) * f) + 2.76*log10(stat2Dist) - 2.48;
stat3Mags = log10(amps(:,3) * f) + 2.76*log10(stat3Dist) - 2.48;
stat4Mags = log10(amps(:,4) * f) + 2.76*log10(stat4Dist) - 2.48;
stat5Mags = log10(amps(:,5) * f) + 2.76*log10(stat5Dist) - 2.48;

%average and print magnitudes for each event
localMags = stat1Mags + stat2Mags + stat3Mags + stat4Mags + stat5Mags;
localMags = localMags / 5;

end