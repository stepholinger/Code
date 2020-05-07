function [sortedTimes,sortedAmps] = timeSort(timeStart,timeEnd,eventTimes,amps)
%
% sorts a set of seismic events by season
%
% input parameters:
% timeStart: start of time period
% timeEnd: end of time period
% eventTimes: matlab-format event times

% set useful variables
numEvents = length(eventTimes);
i = 1;

for m = 1:numEvents  
% check first season
    if eventTimes(m,:) < timeEnd && eventTimes(m,:) > timeStart
        sortedTimes(i,1) = eventTimes(m,1);
        sortedAmps(i,1) = amps(m,1);
        i = i+1;
    end

end