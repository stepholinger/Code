
% set path
path = "/media/Data/Data/PIG/MSEED/noIR/";

% set station and components
stat = ["PIG2"];
chan = ["HHZ","HHZ"];
fs = 100;
fileLen = 86400*fs;

% set range of dates 
startDay = datetime("2012-01-01");
endDay = datetime("2014-01-01");

% make range of dates
dateRange = startDay:endDay;

% set display length (hours)
dispLen = 24;
numLines = 24/dispLen;

% choose filter band and design filter
freq = [1,10];
[b,a] = butter(4,freq/(fs/2),'bandpass');

% make default date format consistent with file naming convention
datetime.setDefaultFormats("defaultdate","yyyy-MM-dd")

% make vector to store picks
pickList = [];

% loop through all days
for d = 1:length(dateRange)
    
    fprintf("Showing " + string(dateRange(d)) + ".\n")
    
    try

        for s = 1:length(stat)
            for c = 1:length(chan)
                % make filename and read data
                fname = path + stat(s) + "/" + chan(c) + "/" + string(dateRange(d)) + "." + stat(s) + "." + chan(c) + ".noIR.MSEED";
                %data = readsac(fname);
                
                data = rdmseedfast(fname);
                
                dataCell{s,c} = data;
            end
        end

        % only filter and plot if there's actually a file
        if numel(fieldnames(data)) > 1

            for s = 1:length(stat)
                for c = 1:length(chan)
                    if numel(fieldnames(dataCell{s,c})) > 1
                        trace = dataCell{s,c}.data;
                        if c == 1                        
                            trace = filtfilt(b,a,trace);
                            trace = trace.*tukeywin(length(trace),0.01);
                        end
                        traceCell{s,c} = trace(1:fileLen);   
                    else
                        traceCell{s,c} = zeros(fileLen,1);
                    end
                end
            end
            
            figure(1)
           
            for n = 0:numLines-1

                hold on

                % find start and end of each line of the plot
                startSample = int32(1 + floor((length(trace)*n)/numLines));
                endSample = startSample + int32(floor(length(trace)/numLines))-1 - 1;
                if endSample > fileLen
                    endSample = fileLen;
                end

                for j = 1:length(traceCell)
                
                    subplot(length(traceCell),1,j)
                    
                    lineTrace = traceCell{1,j}(startSample:endSample);
                    %lineTrace = lineTrace/max(abs(lineTrace));
                    
                    % plot the current line of trace
                    plot(lineTrace,'color',[0.2 0.2 0.7])
                       
                end

                fprintf("Press 'Return' twice to advance window.\n")
                
                [x,~] = ginput;                
                
                if isempty(x) == 0
                    for k = 1:length(x)
                        pick = startSample + x(k);               
                        pick = dateRange(d) + seconds(pick/fs);
                        pickList = [pickList;pick];
                    end
                end
                
                pause;

                % clear figure
                clf('reset');
                                               
            end
            
        end

    catch
        
        fprintf("No data on " + string(dateRange(d)) + "\n");
        
    end
    
end
