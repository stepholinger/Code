function [B,rawB] = bCalc(magnitudes,range,step)
%
% calculates cumulative magnitude plot bins; slope of linear portion is
% b-value
%
% input parameters:
% magnitudes: vector of event magnitudes
% range: magnitude range over which calculation should be done [lo,hi]
% step: binning increment

i = range(1);
j = 1;

% go until current bin equals top end of range
while i < range(2)
    
    % count starts at 0
    rawB(j,1) = 0;
    
    %loop through each event and count it if it's greater than current bin
    for n = 1:length(magnitudes)
        if magnitudes(n,1) >= i
            rawB(j,1) = rawB(j,1) + 1;
        end
    end
    i = i + step;
    j = j + 1;
end

%take log to make raw counts into a true b-value
B = log10(rawB);

end