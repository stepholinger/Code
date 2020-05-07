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
outPath = "/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/crossCorrelation/PIG2HHZ/";

% load list of detection start and end times
load("/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/detections/ML/10-20Hz/2sGap/splitDetections2nd.mat")

% calculate event durations
durations = detections(:,2) - detections(:,1);

% remove detection windows over one minute in length and with no length
detections = detections(durations < maxLength & durations ~= duration(0,0,0),:);

% choose filter band and design filter
freq = [10,20];
[b,a] = butter(4,freq/(fs/2),'bandpass');

% set range of dates 
startDay = datetime("2013-05-01");
endDay = datetime("2014-01-01");

% make range of dates
dateRange = startDay:endDay+1;

% check for already completed files from incomplete runs and remove from
% list of dates to iterate through
finFiles = dir(outPath);
finFilenames = [];
for f = 1:length(finFiles)
    if finFiles(f).isdir == 0
        name = strsplit(finFiles(f).name,".");
        finFilenames = [finFilenames;name{1}];
    end
end
finIdx = contains(string(dateRange),string(finFilenames));
%dateRange(finIdx) = [];

% set up parallel stuff
poolobj = gcp;
addAttachedFiles(poolobj,'/home/setholinger/Documents/Code/MATLAB/packages/readsac.m')
addAttachedFiles(poolobj,'/home/setholinger/Documents/Code/MATLAB/scripts/parsave.m')

% loop through range of days
parfor d = 1:length(dateRange)-1
    
    try
    
        % find all detections today and convert to index
        detectionsToday = detections(isbetween(detections(:,1),dateRange(d),dateRange(d+1)),:);
        
        detSec = seconds(detectionsToday-dateRange(d));
        detIndex = floor(detSec * fs);

        % read in file
        fname = path + stat + "/" + chan + "/" + string(dateRange(d)) + "." + stat + "." + chan + ".noIR.SAC";
        data = readsac(fname);

        % filter file
        trace = data.trace;
        trace = filtfilt(b,a,trace);

        % make some storage matrices
        lagTimes = zeros(length(detIndex));
        xcorrCoefs = zeros(length(detIndex));

        % start cross correlation loop
        for i = 1:length(detIndex)

            % start timer on first iteration
            % remove this from final version
            if i == 1
                tic;
            end

            for j = i:length(detIndex)   

                % pull out the waveforms
                wave1 = trace(detIndex(i,1):detIndex(i,2));
                wave2 = trace(detIndex(j,1):detIndex(j,2));

                % normalize both waves manually
                %wave1 = wave1/max(abs(wave1));
                %wave2 = wave2/max(abs(wave2));

                % pad with zeros
                if length(wave2) > length(wave1)
                    wave1 = [wave1;zeros(length(wave2)-length(wave1),1)];
                else
                    wave2 = [wave2;zeros(length(wave1)-length(wave2),1)];
                end

                % compute cross correlation
                [xcorrTrace,lag] = xcorr(wave1,wave2,"coef");

                if max(xcorrTrace) < abs(min(xcorrTrace))
                    [coef,lagIndex] = min(xcorrTrace);
                else
                    [coef,lagIndex] = max(xcorrTrace);
                end

                % store lag value and correlation coefficient
                lagTimes(i,j) = lag(lagIndex);
                xcorrCoefs(i,j) = coef;

            end

            % estimate remaining run time once we get a little bit underway
            % remove this from final version
            if i == 100

                runTime = toc;     
                totRunTime = runTime * length(detIndex)/100;
                runTimeLeft = totRunTime - runTime;
                runTimeLeft =  runTimeLeft/60/60;

                % print remaining run time
                fprintf("Estimated time remaining for " + string(dateRange(d)) + ": " + runTimeLeft + " hrs\n") 

            end

        end
    
        % save correlations from that day 
        parsave(string(dateRange(d)) + ".mat",detectionsToday,lagTimes,xcorrCoefs)
    
        fprintf("Finished cross correlations for " + string(dateRange(d)) + "\n")
        
    catch
        
        fprintf("Skipping " + string(dateRange(d)) + "\n")
        
    end
        
end