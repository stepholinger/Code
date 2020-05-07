% code to run hierarchical clustering to find clusters of events within a
% day of data, align and stack each cluster, and then cross correlate all
% stacked waveforms to find clusters within the entire dataset

%set station/component and some file parameters
stat = ["PIG2"];
chan = ["HHZ"];
numStat = length(stat);
numChan = length(chan);
fs = 100;
maxLength = minutes(1);
fileLength = 864000*fs;

% set path to cross correlation workspaces
xcorrPath = "/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/crossCorrelation/PIG2HHZ/singleDay/";

% set path to data
dataPath = "/media/Data/Data/PIG/SAC/noIR/";

% set clustering cutoff
cutoff = 0.835;

% choose filter band and design filter
freq = [10,20];
[b,a] = butter(4,freq/(fs/2),'bandpass');

% load list of detection start and end times
load("/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/detections/ML/10-20Hz/2sGap/splitDetections2nd.mat")

% only keep detection windows shorter than one minute and nonzero in length
durations = detections(:,2) - detections(:,1);
detections = detections(durations < maxLength & durations ~= duration(0,0,0),:);
durations = [];

% gotta keep careful track of indexing the whole time

%set range of dates 
startDay = datetime("2012-01-01");
endDay = datetime("2014-01-01");

%make range of dates
dateRange = startDay:endDay;

% make array to store all stacked waveforms
allStackedWaveforms = [];
eventsPerCluster = {};

totalClusters = 0;

for d = 1:length(dateRange)
    
    try

        % read in file
        fname = dataPath + stat + "/" + chan + "/" + string(dateRange(d)) + "." + stat + "." + chan + ".noIR.SAC";
        data = readsac(fname);

        % filter file
        trace = data.trace;
        trace = filtfilt(b,a,trace);

        % find all detections on the current day
        detectionsTodayIndex = find(isbetween(detections(:,1),dateRange(d),dateRange(d)+1));
        detectionsToday = detections(detectionsTodayIndex,:);
        detSec = seconds(detectionsToday-dateRange(d));
        detIndex = round(detSec * fs);
        detLength = detIndex(:,2) - detIndex(:,1);

        % load cross correlation workspace for the current day
        load(xcorrPath + string(dateRange(d)) + ".mat")

        % we have upper triangular xcorr and lag time matrices; fill in bottom half
        xcorrCoefs = xcorrCoefs + rot90(fliplr(xcorrCoefs)) - diag(diag(ones(length(lagTimes))));

        % remember lag time sign is reversed when order of correlation is reversed
        lagTimes = lagTimes + rot90(fliplr(lagTimes))*(-1);

        % use correlation matrix to get dissimilarity matrixfin
        dissimilarity = 1 - abs(xcorrCoefs);
        dissimilarity = dissimilarity - diag(diag(dissimilarity));
        dissimilarity(isnan(dissimilarity)) = 0;

        % convert to vector form and calculate linkages and clusters
        dissimilarityVector = squareform(dissimilarity);
        linkages = linkage(dissimilarityVector,'complete');
        clusters = cluster(linkages,'cutoff',cutoff,'criterion','distance');

        % clear variables
        xcorrCoefs = [];
        dissimilarity = [];
        dissimilarityVector = [];
        linkages = [];
        
        % find number of clusters
        numClust = length(unique(clusters));

        % make array to store stacked waveforms
        %stackedWaveforms = zeros(numClust,seconds(maxLength)*fs);

        % find index of events in each cluster
        for n = 1:numClust

            % keep track of total clusters
            totalClusters = totalClusters + 1;
            
            % get the start and end times for events in this cluster
            detectionsCluster = detectionsToday(clusters == n,:);
            absoluteIndex = detectionsTodayIndex(clusters == n);
            
            % store these in the cell array
            eventsPerCluster{totalClusters,1} = detectionsCluster;
            eventsPerCluster{totalClusters,2} = absoluteIndex;

            % get start and end indices for events in this cluster
            detIndexCluster = detIndex(clusters == n,:);

            % find start and end indices of all events in this cluster
            clusterEventIdx = find(clusters == n);

            % find index of longest event within this cluster
            [stackLength,maxLengthIdx] = max(detLength(clusterEventIdx));

            % find that event's index among the whole day
            maxLengthIdx = clusterEventIdx(maxLengthIdx);

            % pull out lag times in relation to that event
            clusterLags = lagTimes(maxLengthIdx,clusterEventIdx);

            % make zero vector to stack on
            stack = zeros(1,6000);
            
            % align and stack in relation to longest event
            for m = 1:length(clusterEventIdx)

                % pull out the individual waveform of interest
                waveform = trace(detIndexCluster(m,1):detIndexCluster(m,2));    

                slide = clusterLags(m);  

                if slide >= 0

                    % align the waveform by padding with zeros up front
                    waveTemp = [zeros(abs(slide),1);waveform]';

                    % trim or pad back end depending on length
                    if length(waveTemp) >= stackLength
                        waveTemp = waveTemp(1:stackLength);
                    else
                        waveTemp = [waveTemp,zeros(stackLength-length(waveTemp),1)'];
                    end                    

                else

                    % align the waveform by removing data up front
                    waveTemp = waveform(abs(slide):end)';

                    % pad back end
                    waveTemp = [waveTemp,zeros(stackLength-length(waveTemp),1)'];

                end

                %plot(waveTemp)
                %pause;

                % waveTemp is now aligned and the correct length so we can stack
                stack(1:stackLength) = stack(1:stackLength) + waveTemp;
                %stackedWaveforms(n,1:stackLength) = stackedWaveforms(n,1:stackLength) + waveTemp;
               
                %plot(stackedWaveforms(n,:))
                %pause;

            end

            % fill big matrix of waveforms
            allStackedWaveforms(totalClusters,:) = stack;
            
        end

        % save stacks into big matrix
        %allStackedWaveforms = [allStackedWaveforms;stackedWaveforms];
        
        fprintf("Finished clustering and stacking for " + string(dateRange(d)) + "\n")

    catch
       
        fprintf("Skipping " + string(dateRange(d)) + "\n")
        
    end

end

% save results so we don't lose progress
save("/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/clusterStackResults.mat","eventsPerCluster","allStackedWaveforms");

% clear variables to save memory
clear;

% load just the stacked waveforms from the last bit
load("/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/clusterStackResults.mat","allStackedWaveforms");

% make some storage variables
xcorrCoefs = zeros(size(allStackedWaveforms,1));
lagTimes = zeros(size(allStackedWaveforms,1));

%%

load("stackCorr.mat");

% start at a particular event in case of crash
start = 3936;

poolobj = gcp;

% cross correlate all waveforms
parfor i = start:size(allStackedWaveforms,1)
    tic; 
    
    lagVect = zeros(size(allStackedWaveforms,1),1);
    corrVect = zeros(size(allStackedWaveforms,1),1);
    
    for j = i:size(allStackedWaveforms,1)
    
        % compute the cross correlation
        [xcorrTrace,lag] = xcorr(allStackedWaveforms(i,:),allStackedWaveforms(j,:),"coef");

        [coef,lagIndex] = max(abs(xcorrTrace));

        % store lag value and correlation coefficient
        lagVect(j) = lag(lagIndex);
        corrVect(j) = coef;
    
    end
    
    xcorrCoefs(i,:) = corrVect;
    lagTimes(i,:) = lagVect;
    
    t = toc;
    
    fprintf("Estimated runtime left: " + t * (size(allStackedWaveforms,1)-i) + "\n");
    
end

save("/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/stackCorrelateResults.mat","lagTimes","xcorrCoefs");

% run heirarchical clustering for all stacked waveforms