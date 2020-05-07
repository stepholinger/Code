%set station/component and some file parameters
stat = ["PIG2"];
chan = ["HHZ"];
numStat = length(stat);
numChan = length(chan);
fs = 100;
fileLength = 864000*fs;

% set path to data
path = "/media/Data/Data/PIG/SAC/noIR/";

% get the number of events
numWaveforms = length(detectionsToday);

% find the indices corresponding to each event start and end
day = datetime("2013-06-03");
detSec = seconds(detectionsToday-day);
detIndex = floor(detSec * fs);

% choose filter band and design filter
freq = [10,20];
[b,a] = butter(4,freq/(fs/2),'bandpass');

maxEventLength = max(detIndex(:,2)-detIndex(:,1));
trainingWaves = zeros(numWaveforms,maxEventLength+1);

% read in file
fname = path + stat + "/" + chan + "/" + string(day) + "." + stat + "." + chan + ".noIR.SAC";
data = readsac(fname);

% filter file
trace = data.trace;
trace = filtfilt(b,a,trace);

for n = 1:numWaveforms
   
    % pull out the individual waveform of interest
    waveform = trace(detIndex(n,1):detIndex(n,2));    
       
    trainingWaves(n,1:length(waveform)) = waveform';
      
end

h5create("classificationTrainingData.h5","/events",size(trainingWaves))
h5create("classificationTrainingData.h5","/labels",size(clusters))
h5write("classificationTrainingData.h5","/events",trainingWaves)
h5write("classificationTrainingData.h5","/labels",clusters)