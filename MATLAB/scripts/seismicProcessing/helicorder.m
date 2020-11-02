% load detection file
%load("/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/may2012/detections01-1.mat")
%detections = detections(detectionQuality > 2); 
 % load("/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/detections/ML/10-20Hz/2sGap/splitDetections.mat");

% choose how we want to deal with stuff
ML = 1;
sac = 0;
mseed = 1;

% set path
if sac
    path = "/media/Data/Data/PIG/SAC/noIR/";
end
if mseed
    path = "/media/Data/Data/PIG/MSEED/noIR/";
end

% set station and components
stat = "PIG2";
chan = "HHZ";
fs = 100;


% set range of dates 
startDay = datetime("2012-05-09");
endDay = datetime("2014-05-10");

if ML
    thresh = 0.6;
else    
    buffLenInit = 2000;
    snipLenInit = 6000;
end
 
% make range of dates
dateRange = startDay:endDay;

% set spacing for helicorder
numLines = 24;

% choose filter band and design filter
freq = [1,10];
[b,a] = butter(2,freq/(fs/2),'bandpass');

% make default date format consistent with file naming convention
datetime.setDefaultFormats("defaultdate","yyyy-MM-dd")


% loop through all days
for d = 1:length(dateRange)
    
    %try

        if ML
            day = string(dateRange(d));
            detections = h5read("/home/setholinger/Documents/Projects/PIG/detections/ML/10-20Hz/2sGapResults.h5","/"+day);
            detections = detections';            
            detections = detections(:,detections(3,:) > thresh);
            events = detections(:,1:2);
            events = datetime(day) + seconds(events);
            
            % if using the .mat detection files, uncomment the below
            %load("/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/detections/ML/10-20Hz/2sGap/splitDetections2nd.mat");
            %events = detections;
            
            % find all the detections on the current day 
            detectionsToday = events(isbetween(events(:,1),dateRange(d),dateRange(d)+1),:);
            snipLen = floor(seconds(detectionsToday(:,2) - detectionsToday(:,1)))*100;
            
        else
            
           detectionsToday = detections(isbetween(detections,dateRange(d),dateRange(d)+1));
            
        end
        
        
        
        % find difference between start of day and detection
        detSec = floor(seconds(detectionsToday(:,1)-dateRange(d)));

        % convert to samples and add 2 seconds of buffer before
        detIndex = detSec * fs;

        % make filename and read data
        if sac
            fname = path + stat + "/" + chan + "/" + string(dateRange(d)) + "." + stat + "." + chan + ".noIR.SAC";
            data = readsac(fname);
    
            % only filter and plot if there's actually a file
            if numel(fieldnames(data)) > 1

                % filter to desired band
                trace = data.trace;
                trace = filtfilt(b,a,trace);

                % get offset based on trace amplitude
                offset = max(trace)/7.5;
                %offset = 1e-7/2;

                figure(1)
                for n = 0:numLines-1

                    hold on

                    % find start and end of each line of the plot
                    startSample = int32(1 + floor((length(trace)*n)/numLines));
                    endSample = startSample + int32(floor(length(trace)/numLines)) - 1;
                    lineTrace = trace(startSample:endSample);

                    % normalize and offset
                    % lineTrace = lineTrace/max(abs(lineTrace))-offset*n;
                    lineTrace = lineTrace-offset*n;

                    %find all detections that should be plotted on this line
                    detIndexLine = detIndex(detIndex > startSample & detIndex < endSample)-double(startSample);

                    if ML == 1
                        snipLenLine = snipLen(detIndex > startSample & detIndex < endSample);
                    end

                    % make vector with y-values for markers
                    markers = zeros(length(detIndexLine),1);
                    markers(:) = -offset*n;

                    % plot the current line of trace
                    plot(lineTrace,'color','k')

                    for i = 1:length(detIndexLine)

                        if ML == 0
                            %reset snippet and buffer lengths
                            snipLen = snipLenInit;  
                            buffLen = buffLenInit;

                            %adjust length of snippet if too close to start or end
                            if detIndexLine(i) - buffLen <= 0 
                                buffLen = detIndexLine(i)-1;
                            end

                            if length(lineTrace) - detIndexLine(i) < snipLen
                                snipLen = length(lineTrace)-detIndexLine(i);
                            end


                            %plot(detIndexLine(i)-buffLen:1:detIndexLine(i)+snipLen,lineTrace(detIndexLine(i)-buffLen:detIndexLine(i)+snipLen),'color','r')
                        end

                        if ML == 1

                            % adjust length of snippet if too close to start or end
                            if length(lineTrace) - detIndexLine(i) < snipLenLine(i) 
                                snipLenLine(i) = length(lineTrace)-detIndexLine(i);
                            end

                            % plot detections on top of the current line
                            %plot(detIndexLine(i):1:detIndexLine(i)+snipLenLine(i),lineTrace(detIndexLine(i):detIndexLine(i)+snipLenLine(i)),'color','r')

                        end

                    end
                end           

                yticks([-1*(numLines-1):0]*offset);
                yticklabels(flip(0:numLines-1));
                ylim([0-offset*(numLines+1),0+offset])

                xticks([0:4]*length(lineTrace)/4);
                xticklabels(string([0:4]*minutes(60)/4));
                xlim([0,length(lineTrace)]);
                %drawnow;

                % print the date and wait for enter to move to next day
                fprintf("Showing " + length(detectionsToday) + " detections on " + string(dateRange(d)) + ".\n")
                pause;

                % save figure if desired
                %saveas(gcf,"/home/setholinger/Documents/Projects/PIG/miscFigures/helicorders/may01-1Hz/manual/" + string(dateRange(d)) + ".png")

                % clear figure
                clf('reset');

            end
        end
        if mseed
            fname = path + stat + "/" + chan + "/" + string(dateRange(d)) + "." + stat + "." + chan + ".noIR.MSEED";
            data = rdmseed(fname);
            trace = extractfield(data,'d');    
            
            trace = filtfilt(b,a,trace);

            % get offset based on trace amplitude
            offset = max(trace)/7.5;
            %offset = 1e-7/2;

            figure(1)
            for n = 0:numLines-1

                hold on

                % find start and end of each line of the plot
                startSample = int32(1 + floor((length(trace)*n)/numLines));
                endSample = startSample + int32(floor(length(trace)/numLines)) - 1;
                lineTrace = trace(startSample:endSample);

                % normalize and offset
                % lineTrace = lineTrace/max(abs(lineTrace))-offset*n;
                lineTrace = lineTrace-offset*n;

                %find all detections that should be plotted on this line
                detIndexLine = detIndex(detIndex > startSample & detIndex < endSample)-double(startSample);

                if ML == 1
                    snipLenLine = snipLen(detIndex > startSample & detIndex < endSample);
                end

                % make vector with y-values for markers
                markers = zeros(length(detIndexLine),1);
                markers(:) = -offset*n;

                % plot the current line of trace
                plot(lineTrace,'color','k')

                for i = 1:length(detIndexLine)

                    if ML == 0
                        %reset snippet and buffer lengths
                        snipLen = snipLenInit;  
                        buffLen = buffLenInit;

                        %adjust length of snippet if too close to start or end
                        if detIndexLine(i) - buffLen <= 0 
                            buffLen = detIndexLine(i)-1;
                        end

                        if length(lineTrace) - detIndexLine(i) < snipLen
                            snipLen = length(lineTrace)-detIndexLine(i);
                        end


                        %plot(detIndexLine(i)-buffLen:1:detIndexLine(i)+snipLen,lineTrace(detIndexLine(i)-buffLen:detIndexLine(i)+snipLen),'color','r')
                    end

                    if ML == 1

                        % adjust length of snippet if too close to start or end
                        if length(lineTrace) - detIndexLine(i) < snipLenLine(i) 
                            snipLenLine(i) = length(lineTrace)-detIndexLine(i);
                        end

                        % plot detections on top of the current line
                        %plot(detIndexLine(i):1:detIndexLine(i)+snipLenLine(i),lineTrace(detIndexLine(i):detIndexLine(i)+snipLenLine(i)),'color','r')

                    end

                end
            end           

            yticks([-1*(numLines-1):0]*offset);
            yticklabels(flip(0:numLines-1));
            ylim([0-offset*(numLines+1),0+offset])

            xticks([0:4]*length(lineTrace)/4);
            xticklabels(string([0:4]*minutes(60)/4));
            xlim([0,length(lineTrace)]);
            %drawnow;

            % print the date and wait for enter to move to next day
            fprintf("Showing " + length(detectionsToday) + " detections on " + string(dateRange(d)) + ".\n")
            pause;

            % save figure if desired
            %saveas(gcf,"/home/setholinger/Documents/Projects/PIG/miscFigures/helicorders/may01-1Hz/manual/" + string(dateRange(d)) + ".png")

            % clear figure
            clf('reset');
            
        end
            
    %catch
       
     %   fprintf("No data on " + string(dateRange(d)) + "\n");
        
    %end
    
end

