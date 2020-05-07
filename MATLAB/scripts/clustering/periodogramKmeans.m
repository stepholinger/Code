% make frequency fingerprint for PCA then clustering

%set station/component and some file parameters
stat = ["PIG2","PIG3","PIG4"];
chan = ["HHZ","HHN","HHE"];
numStat = length(stat);
numChan = length(chan);
fs = 100;
maxLength = minutes(1);
fileLength = 86400*fs;
numBins = 20;
numClust = 50;

singleComponent = 1;
pulseWidth = 0;

% do some magic with station and channel vectors to facilitate parfor
comp = strings(numStat*numChan,2);
statVect = [];
for i = 1:numStat
   statVect = [statVect;stat];
end
comp(:,1) = reshape(statVect,numStat*numChan,1);

chanVect = [];
for i = 1:numChan
    chanVect = [chanVect,chan];
end
comp(:,2) = chanVect;

% set path to data
path = "/media/Data/Data/PIG/SAC/noIR/";
%outPath = "/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/crossCorrelation/PIG2HHZ/";

% load list of detection start and end times
load("/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/detections/ML/10-20Hz/2sGap/splitDetections2nd.mat")

% calculate event durations
durations = detections(:,2) - detections(:,1);

% remove detection windows over one minute in length and with no length
detections = detections(durations < maxLength & durations ~= duration(0,0,0),:);

% choose filter band and design filter
freq = [10,20];
[b,a] = butter(4,freq/(fs/2),'bandpass');

% make bins for periodogram
bins = zeros(numBins,1);
for n = 1:numBins
    bins(n) = freq(1) + n * (freq(2)-freq(1))/numBins;
end

% make a matrix to save correlation coefficients
allFreqPower = zeros(length(detections),numBins);

% set range of dates 
startDay = datetime("2013-06-03");
endDay = datetime("2013-06-03");

% make range of dates
dateRange = startDay:endDay+1;

%poolobj = gcp;
%addAttachedFiles(poolobj,'/home/setholinger/Documents/Code/MATLAB/packages/readsac.m')

%%

% loop through each day first to find which station and component has
% maximum amplitude
for d = 1:length(dateRange)-1
    
    % find all detections today and convert to index
    detectionsToday = detections(isbetween(detections(:,1),dateRange(d),dateRange(d+1)),:);

    amplitudes = zeros(length(detectionsToday),numStat*numChan);

    for s = 1:numChan*numStat
        
     %try

        detSec = seconds(detectionsToday-dateRange(d));
        detIndex = floor(detSec * fs);

        % read in file
        fname = path + comp(s,1) + "/" + comp(s,2) + "/" + string(dateRange(d)) + "." + comp(s,1) + "." + comp(s,2) + ".noIR.SAC";
        data = readsac(fname);

        % filter file
        trace = data.trace;
        trace = filtfilt(b,a,trace);

        for i = 1:length(detectionsToday)

            % get waveform
            wave = trace(detIndex(i,1):detIndex(i,2));    

            amplitudes(i,s) = max(abs(wave));
            
        end

        %catch        

        %    fprintf("Skipping " + comp(s,1) + " " + comp(s,2) + " on " + string(dateRange(d)) + "\n")

        %end        

        
    end
        
end

% find station/component with max amplitude
[~,maxIdx] = max(amplitudes,[],2);

%%

% loop through each day
for d = 1:length(dateRange)-1
    
    % find all detections today and convert to index
    detectionsToday = detections(isbetween(detections(:,1),dateRange(d),dateRange(d+1)),:);

    freqPowerToday = zeros(length(detectionsToday),numBins);

    for s = 1:numStat*numChan
        
     %try

        detSec = seconds(detectionsToday-dateRange(d));
        detIndex = floor(detSec * fs);

        % read in file
        fname = path + comp(s,1) + "/" + comp(s,2) + "/" + string(dateRange(d)) + "." + comp(s,1) + "." + comp(s,2) + ".noIR.SAC";
        data = readsac(fname);

        % filter file
        trace = data.trace;
        trace = filtfilt(b,a,trace);

        for i = 1:length(detectionsToday)

            if s == maxIdx(i)

                % get waveform
                wave = trace(detIndex(i,1):detIndex(i,2));    

                % normalize waveform
                wave = wave ./ max(abs(wave));

                if pulseWidth

                %THIS OPTION IS UNFINISHED
                    
                    %calculate envelope function
                    waveEnv = envelope(wave,100,'rms');

                    %find mean of envelope
                    envMean = zeros(length(wave),1) + mean(waveEnv);

                    %find maxima of envelope
                    [peakAmp, peakPos] = findpeaks(waveEnv,"NPeaks",1);

                end


                % compute power in each frequency bin using periodogram or
                freqPower = periodogram(wave,[],bins,fs);

                % normalize periodogram
                %freqPower = freqPower ./ max(freqPower);

                % store power in each frequency bin
                freqPowerToday(i,:) = freqPower;
            
            end

        end

        %catch        

        %    fprintf("Skipping " + comp(s,1) + " " + comp(s,2) + " on " + string(dateRange(d)) + "\n")

        %end        

    end
        
end

freqPowerToday = reshape(freqPowerToday,length(detectionsToday),numBins);
clustersK = kmeans(freqPowerToday,numClust);
    
histogram(clustersK,numClust)
    
%%

clustK = 1;
clustKMembers = find(clustersK == clustK);

for i = 1:length(clustKMembers)
    
    % read in file
    fname = path + comp(maxIdx(i),1) + "/" + comp(maxIdx(i),2) + "/" + string(dateRange(d)) + "." + comp(maxIdx(i),1) + "." + comp(maxIdx(i),2) + ".noIR.SAC";
    data = readsac(fname);

    % filter file
    trace = data.trace;
    trace = filtfilt(b,a,trace);
    
    wave = trace(detIndex(clustKMembers(i),1):detIndex(clustKMembers(i),2));
    plot(wave);
    pause;
end
