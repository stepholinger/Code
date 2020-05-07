%set station/component and some file parameters
stat = ["PIG2"];
chan = ["HHZ"];
numStat = length(stat);
numChan = length(chan);
fs = 100;
maxLength = minutes(1);
fileLength = 864000*fs;

% set path to data
path = "/media/Data/Data/PIG/SAC/noIR/";

% get the number of events
numWaveforms = length(detectionsToday);

% find the indices corresponding to each event start and end
day = datetime("2012-01-29");
detSec = seconds(detectionsToday-day);
detIndex = floor(detSec * fs);

% choose filter band and design filter
freq = [10,20];
[b,a] = butter(4,freq/(fs/2),'bandpass');

% find the event best correlated with the largest number of other events
%xcorrCoefs = xcorrCoefs + rot90(fliplr(xcorrCoefs)) - diag(diag(ones(length(lagTimes))));
corrSum = sum(abs(xcorrCoefs));
[maxEvent,eventIdx] = max(corrSum);

% sort events in order of correlation with the best correlated event
[~,sortIdx] = sort(abs(xcorrCoefs(:,eventIdx)),'descend');
sortDetIndex = detIndex(sortIdx,:);
sortLagTimes = lagTimes(sortIdx,eventIdx);

maxEventLength = max(sortDetIndex(:,2)-sortDetIndex(:,1));

alignedWaveforms = zeros(numWaveforms,maxEventLength+1);

% read in file
fname = path + stat + "/" + chan + "/" + string(day) + "." + stat + "." + chan + ".noIR.SAC";
data = readsac(fname);

% filter file
trace = data.trace;
trace = filtfilt(b,a,trace);


for n = 1:numWaveforms
   
    % pull out the individual waveform of interest
    waveform = trace(sortDetIndex(n,1):sortDetIndex(n,2));    
    
    slide = sortLagTimes(n);  
    
    if slide <= 0
        waveTemp = [zeros(abs(slide),1);waveform]';
        alignedWaveforms(n,1:length(waveTemp)) = waveTemp;
    end
    
    if slide > 0
        waveTemp = waveform(abs(slide):end)';
        alignedWaveforms(n,1:length(waveTemp)) = waveTemp;
    end
    
end