function [filtTimes] = threshold(eventTimes,value,thresh)
%
% returns all times of events for whom some value exceeds a threshold

m = 1;

for n = 1:length(eventTimes)
    if value(n) >= thresh
        filtTimes(m) = eventTimes(n);
        m = m + 1;
    end
end

end