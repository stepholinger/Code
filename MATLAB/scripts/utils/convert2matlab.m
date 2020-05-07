function [matlabTimes] = convert2matlab(EventTimes)
% 
% convert2matlab: converts julian or unix time to matlab time for a table of times

n = 1;
h = height(EventTimes)+1;
EventTimes = table2array(EventTimes);
EventTimes = string(EventTimes);

while n < h    
    timeArray = strsplit(EventTimes(n,1),':');
    timeArray = double(timeArray);
    days = strcat('1-jan-',string(timeArray(1,1)));
    days = datenum(datetime(days));
    timeArray(1,3) = timeArray(1,3) / 24;
    timeArray(1,4) = timeArray(1,4) / 1440;
    timeArray(1,5) = timeArray(1,5) / 86400;        
    matlabTimes(n,1) = days + timeArray(1,2) + timeArray(1,3) + timeArray(1,4) + timeArray(1,5) - 1;
    n = n+1;
end


end

