%set station/component and some file parameters
stat = ["PIG2"];
chan = ["HHZ"];
numStat = length(stat);
numChan = length(chan);
fs = 100;
maxLength = minutes(1);
fileLength = 86400*fs;

% set path to data
path = "/media/Data/Data/PIG/SAC/noIR/";
outPath = "/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/crossCorrelation/PIG2HHZ/multiDay/";

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
startDay = datetime("2012-01-11");
endDay = datetime("2013-12-23");

% make range of dates
dateRange = startDay:endDay+1;

dayPairs = [];
for i = 1:length(dateRange)
    day1 = ones(length(dateRange) - i,1)*i;
    day2 = i+1:length(dateRange);
    dayPairs = [dayPairs;[day1,day2']];
end

% check for already completed files from incomplete runs and remove from
% list of dates to iterate through
finFiles = dir(outPath);
finDayPairs = [];
for f = 1:length(finFiles)
    if finFiles(f).isdir == 0
        name = strsplit(finFiles(f).name,".");
        nameDate = strsplit(name{1},"_");  
        idx1 = find(contains(string(dateRange),nameDate{1}));
        idx2 = find(contains(string(dateRange),nameDate{2}));       
        finDayPairs = [finDayPairs;[idx1,idx2]];        
    end
end

finIdx = find(ismember(dayPairs,finDayPairs,'rows'));
dayPairs(finIdx,:) = [];

% set up parallel stuff
poolobj = gcp;
addAttachedFiles(poolobj,'/home/setholinger/Documents/Code/MATLAB/packages/readsac.m')
addAttachedFiles(poolobj,'/home/setholinger/Documents/Code/MATLAB/scripts/parsave.m')

% loop through range of days
parfor d = 1:length(dayPairs)
    
    try
            
        % find all detections today and convert to index
        detections1 = detections(isbetween(detections(:,1),dateRange(dayPairs(d,1)),dateRange(dayPairs(d,1))+1),:);
        detections2 = detections(isbetween(detections(:,1),dateRange(dayPairs(d,2)),dateRange(dayPairs(d,2))+1),:);
        detectionsPair = [detections1;detections2];
        
        detSec1 = seconds(detections1-dateRange(dayPairs(d,1)));
        detIndex1 = floor(detSec1 * fs);
        detSec2 = seconds(detections2-dateRange(dayPairs(d,2)));
        detIndex2 = floor(detSec2 * fs);
        detIndex = [detIndex1;detIndex2];
        
        numEvents = length(detIndex);
        
        % read in files
        fname1 = path + stat + "/" + chan + "/" + string(dateRange(dayPairs(d,1))) + "." + stat + "." + chan + ".noIR.SAC";
        data1 = readsac(fname1);
        fname2 = path + stat + "/" + chan + "/" + string(dateRange(dayPairs(d,2))) + "." + stat + "." + chan + ".noIR.SAC";
        data2 = readsac(fname2);
        
        % filter files
        trace1 = data1.trace;
        trace1 = filtfilt(b,a,trace1);
        trace2 = data2.trace;
        trace2 = filtfilt(b,a,trace2);
        
        % make some storage matrices
        lagTimes = zeros(numEvents);
        xcorrCoefs = zeros(numEvents);

        % start cross correlation loop
        for i = 1:numEvents

            % start timer on first iteration
            % remove this from final version
            if i == 1
                tic;
            end

            for j = i:numEvents   

                 % pull out the waveforms
                 if detectionsPair(i) < dateRange(dayPairs(d,2))
                     %fprintf("BOOP\n")
                     wave1 = trace1(detIndex(i,1):detIndex(i,2));
                 else
                     %fprintf("DOOT\n")
                     wave1 = trace2(detIndex(i,1):detIndex(i,2));
                 end
                 
                 if detectionsPair(j,2) < dateRange(dayPairs(d,2))
                     %fprintf("SCHLOOP\n")
                     wave2 = trace1(detIndex(j,1):detIndex(j,2));
                 else
                     %fprintf("PRRRROOOOP\n")
                     wave2 = trace2(detIndex(j,1):detIndex(j,2));
                 end
                
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

                %fprintf(string(i) + " " + string(j) + "\n")
                
            end

            % estimate remaining run time once we get a little bit underway
            % remove this from final version

            if i == 100

                runTime = toc;     
                totRunTime = runTime * length(detIndex)/100;
                runTimeLeft = totRunTime - runTime;
                runTimeLeft =  runTimeLeft/60/60;

                % print remaining run time
                fprintf("Estimated time remaining for " + string(dateRange(dayPairs(d,1))) + " and " + string(dateRange(dayPairs(d,2))) + ": " + runTimeLeft + " hrs\n") 

            end
            

        end
    
        % save correlations from that day 
        parsave(outPath + string(dateRange(dayPairs(d,1))) + "_" + string(dateRange(dayPairs(d,2))) + ".mat",detectionsPair,lagTimes,xcorrCoefs)
    
        fprintf("Finished cross correlations for " + string(dateRange(dayPairs(d,1))) + " and " + string(dateRange(dayPairs(d,2))) + "\n")
        
    catch
        
        fprintf("Skipping " + string(dateRange(dayPairs(d,1))) + " and " + string(dateRange(dayPairs(d,2))) + "\n")
        
    end
        
end