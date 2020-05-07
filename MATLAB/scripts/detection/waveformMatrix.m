%load detection file
%load("/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/detections/staRun1/detections.mat")
detections = highProbDetections10Sec;

%set path
path = "/media/Data/Data/PIG/SAC/noIR/";

%set station and components
stat = ["PIG2"];
chan = ["HHZ"];

%choose filter band for output waveforms
freq = [10,20];

%restructure and make a couple useful variables
chans = [];
for n = 1:length(stat)
    chans = [chans;chan];
end
chans = chans';
numTrace = length(stat)*length(chan);
numDetections = length(detections);

%make default date format consistent with file naming convention
datetime.setDefaultFormats("defaultdate","yyyy-MM-dd")

%set range of dates 
startDay = "2012-01-01";
endDay = "2014-01-01";
dateRange = datetime(startDay):datetime(endDay);

%set samplerate and desired snippet length
fs = 100;
snippetLength = 10;
snippetLength = snippetLength * fs;
bufferLength = 0;
bufferLength = bufferLength * fs;

%make blank matrix to store waveforms
waveforms = zeros(bufferLength+snippetLength,numTrace,numDetections);

%initialize counter
c = 1;

%loop through all days
for d = 1:length(dateRange)-1

    %find all the detections on the current day 
    detectionsToday = detections(isbetween(detections,dateRange(d),dateRange(d+1)));
    
    %make 3D matrix for storing waveform snippets
    snippetMatrix = zeros(bufferLength+snippetLength,numTrace,length(detectionsToday));
    
    %make vector of filenames
    fnames = path + stat + "/" + chans + "/" + string(dateRange(d)) + "." + stat + "." + chans + ".noIR.SAC";
    fnames = reshape(fnames,length(stat)*length(chan),1);
    
    %design filter
    [b,a] = butter(4,freq/(fs/2),'bandpass');
    
    %loop through filename vector
    for f = 1:numTrace
        
        %read each file
        data = readsac(fnames(f));
        
        %only filter and extract snippet if there's actually a file
        if numel(fieldnames(data)) > 1
        
            %filter to desired band
            trace = filtfilt(b,a,data.trace);

            %pull out snippetLength samples after each detection
            for n = 1:length(detectionsToday)

                %reset these variables 
                snippetLength = 800;
                bufferLength = 200;
                
                %find difference between start of day and detection
                detSec = floor(seconds(detectionsToday(n)-dateRange(d)));

                %convert to samples and add 2 seconds of buffer before
                detIndex = detSec * fs;
 
                %only pull snippet if there's data- only an issue when one
                %trace is short for some reason
                if detIndex-bufferLength < data.npts && detIndex+snippetLength-1 < data.npts
                    
                    %remove pre-detection buffer if right at the beginning
                    %of the file
                    if detIndex-bufferLength < 0
                        bufferLength = 0;
                    end
                    
                    %if trigger is at 00:00:00, start at first sample
                    if detIndex == 0
                        detIndex = 1;
                        snippetLength = 1000;
                    end
                    
                    %use as index for start of snippet
                    snippet = trace(detIndex-bufferLength:detIndex+snippetLength-1);

                    %fill snippetMatrix with waveforms
                    snippetMatrix(:,f,n) = snippet;

                end
                
            end
            
        end
    
    end

    %fill big waveform matrix
    waveforms(:,:,c:c+length(detectionsToday)-1) = snippetMatrix;
    
    %advance counter
    c = c + length(detectionsToday);
    
    %give some output so we know the code is working
    fprintf("Successfully returned waveforms from detections on "+string(dateRange(d))+ ".\n")
    
end
    