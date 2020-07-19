% script to automatically retrieve arrival times using cross correlation
% and 1 starting pick

% set datetime format
datetime.setDefaultFormats('default','yyyy-MM-dd hh:mm:ss.SSS')

% load station info workspace
load('stationInfo.mat')

% set path to data
dataPath = "/media/Data/Data/";

% set up station and file parameters
pickStat = "PIG2";
pickChan = "HHN";
statInd = [2,5,8,11,14];
stat = stat(statInd,:);
statLoc = statLoc(statInd,:);
fs = fs(statInd);
fsResamp =  min(fs);
fileLen = 86400*fsResamp;

% set event to be located
dayStr = "2012-05-09";
detection = datetime(2012,5,9,17,50,00,00);
detLen = 5*60;

% set filter parameters
filtType = "bandpass";
freq = [1,3];

% load data
eventData = zeros(size(stat,1),detLen*fsResamp);
for n = 1:size(stat,1)
    
    try
        % make filename
        fname = dataPath + stat(n,1) + "/MSEED/noIR/" + stat(n,2) + "/" + stat(n,3) +"/" + dayStr + "." + stat(n,2) + "." + stat(n,3) + ".noIR.MSEED";

        % read file and extract data
        dataStructure = rdmseed(fname);
        trace = extractfield(dataStructure,'d');
        %dataStructure = rdmseedfast(fname);
        %trace = extractfield(dataStructure,'data');

        % extract event data
        startInd = (hour(detection)*60*60+minute(detection)*60+second(detection))*fs(n);
        endInd = startInd+detLen*fs(n)-1;
        eventTrace = trace(startInd:endInd);
        
        % filter and resample the trace
        [b,a] = butter(4,freq/(fs(n)/2),filtType);
        eventTrace = filtfilt(b,a,eventTrace);
        if fs(n) ~= fsResamp
            eventTrace = resample(eventTrace,fsResamp,fs(n));
        end

        %eventTrace = detrend(trace(startInd:endInd));
        eventData(n,:) = eventTrace;

    catch
        fprintf("No data for station " + stat(n,2) + "!\n")
    end
end

% remove stations without data from station list and data matrix
availableEventData = [];
availableStat = [];
availableStatLoc = [];
for s = 1:length(stat)
    if sum(eventData(s,:)) ~= 0
        availableEventData = [availableEventData;eventData(s,:)];
        availableStat = [availableStat;stat(s,:)];
        availableStatLoc = [availableStatLoc;statLoc(s,:)];
    end
end
eventData = availableEventData;
stat = availableStat;
statLoc = availableStatLoc;

% record which index has channel to pick on
for s = 1:length(stat)
    if stat(s,2) == pickStat & stat(s,3) == pickChan
        pickInd = s; 
    end
end

% make first pick
plot(eventData(pickInd,:))
[x,~] = ginput;    
if isempty(x) == 0
    for k = 1:length(x)
        pick = detection + seconds(x(k)/fsResamp);
    end
end
close()

% get offset times with cross correlation
arrivalsDatetime = NaT(size(stat,1),1);
for n = 1:size(stat,1)
    [xcorrTrace,lag] = xcorr(eventData(pickInd,:),eventData(n,:),'coeff');
    [coef,lagIdx] = max(abs(xcorrTrace));
    offset = lag(lagIdx)*-1;
    arrivalsDatetime(n) = pick+seconds(offset/fsResamp);
end

% save variables and clear workspace
save("arrivals.mat",'arrivalsDatetime','statLoc')
%clear()

for n = 1:size(stat,1)
    subplot(size(stat,1),1,n)
    plot(eventData(n,:))
end
