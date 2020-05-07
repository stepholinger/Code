%set station/component and some file parameters
stat = ["PIG2"];
chan = ["HHZ"];
numStat = length(stat);
numChan = length(chan);
fs = 100;
maxLength = minutes(1);
fileLength = 86400*fs;

% choose whether to do noise or master event approach
masterLogical = 1;

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

if masterLogical
    % choose master event
    master = detections(20000,:);

    % get date of master event
    [y,m,d] = ymd(master(1));
    if m < 10
        masterDate = string(y + "-0" + m + "-" + d);
    elseif d < 10
        masterDate = string(y + "-" + m + "-0" + d);
    elseif d < 10 && m < 10
        masterDate = string(y + "-0" + m + "-0" + d);
    else
        masterDate = string(y + "-" + m + "-" + d);
    end

    % get index of master event
    masterIdx = round(seconds(master - datetime(masterDate)))*fs;
else
    noise = rand(1000,1);
end

% make a matrix to save correlation coefficients
xcorrCoefs = zeros(length(detections),numChan*numStat);

% set range of dates 
startDay = datetime("2012-01-11");
endDay = datetime("2013-12-23");

% make range of dates
dateRange = startDay:endDay+1;

poolobj = gcp;
addAttachedFiles(poolobj,'/home/setholinger/Documents/Code/MATLAB/packages/readsac.m')

% loop through stations and components
parfor s = 1:numStat*numChan

    if masterLogical 
        % read in file for that day
        masterFname = path + comp(s,1) + "/" + comp(s,2) + "/" + masterDate + "." + comp(s,1) + "." + comp(s,2) + ".noIR.SAC";
        data = readsac(masterFname);

        % pull out the master event waveform
        trace = filtfilt(b,a,data.trace);
        masterWave = trace(masterIdx(1):masterIdx(2));
    else       
        masterWave = filtfilt(b,a,noise);
    end
    
    tempCoefs = zeros(length(detections),1);
    
    count = 1;
    
    % correlate with all other events
    for d = 1:length(dateRange)-1

        try

            % find all detections today and convert to index
            detectionsToday = detections(isbetween(detections(:,1),dateRange(d),dateRange(d+1)),:);

            detSec = seconds(detectionsToday-dateRange(d));
            detIndex = floor(detSec * fs);

            % read in file
            fname = path + comp(s,1) + "/" + comp(s,2) + "/" + string(dateRange(d)) + "." + comp(s,1) + "." + comp(s,2) + ".noIR.SAC";
            data = readsac(fname);

            % filter file
            trace = data.trace;
            trace = filtfilt(b,a,trace);

            for i = 1:length(detectionsToday)

                 wave = trace(detIndex(i,1):detIndex(i,2));

                % pad with zeros
                if length(masterWave) > length(wave)
                    wave = [wave;zeros(length(masterWave)-length(wave),1)];
                else
                    masterWave = [masterWave;zeros(length(wave)-length(masterWave),1)];
                end
                                
                % compute cross correlation
                [xcorrTrace,lag] = xcorr(wave,masterWave,"coef");

                [coef,lagIndex] = max(abs(xcorrTrace));

                % store correlation coefficient
                tempCoefs(count) = coef;

                count = count + 1;

            end
            
            if masterLogical
                fprintf("Finished correlating master event with all events on " + string(dateRange(d)) + " " + comp(s,1) + " " + comp(s,2) + "\n")           
            else
                fprintf("Finished correlating noise with all events on " + string(dateRange(d)) + " " + comp(s,1) + " " + comp(s,2) + "\n")           
            end
            
        catch        

            fprintf("Skipping " + comp(s,1) + " " + comp(s,2) + " on " + string(dateRange(d)) + "\n")

        end        
        
    end
    
    xcorrCoefs(:,s) = tempCoefs;
    
end