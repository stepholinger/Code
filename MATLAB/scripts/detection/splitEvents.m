% code that tests the idea of splitting signal with many events into
% indiviual events using envelope and prominence

%set path
path = "/media/Data/Data/PIG/SAC/noIR/";

%set station and components
stat = ["PIG2","PIG3","PIG4"];
chan = ["HHZ","HHN","HHE"];
numStat = length(stat);
numChan = length(chan);
fs = 100;
thresh = 0.6;
ratio = 1;
dayLength = 86400 * fs;

%if you want to look at a particular event, use this
eventStart = 1;

%choose whether you're running the initial pass or the second pass
secondPass = 1;

%set range of dates 
startDay = datetime("2013-06-03");
endDay = datetime("2014-01-01");

%make range of dates
dateRange = startDay:endDay;

%choose filter band and design filter
freq = [8,20];
[b,a] = butter(4,freq/(fs/2),'bandpass');

%poolobj = gcp;
%addAttachedFiles(poolobj,'/home/setholinger/Documents/Code/MATLAB/packages/readsac.m')

events = [];
eventsPerDay = zeros(length(dateRange),1); 

%loop through all days
%parfor d = 1:length(dateRange)-1
for d = 1:length(dateRange)-1

    day = string(dateRange(d));
    dataMat = zeros(numStat*numChan,dayLength);
    
    try
        tic;
        
        if secondPass
            
            load("/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/detections/ML/10-20Hz/2sGap/splitDetections2nd.mat")
            detectionsToday = detections(isbetween(detections(:,1),dateRange(d),dateRange(d)+1),:);
            snipLen = round(seconds(detectionsToday(:,2) - detectionsToday(:,1))*fs);
            
        else
        
            results = h5read("/home/setholinger/Documents/Projects/PIG/detections/ML/10-20Hz/2sGapResults.h5","/"+day);
            results = results(:,results(3,:) > thresh);
            snipLen = (results(2,:)'-results(1,:)')*fs;
            pred = results(3,:)';
            detections = results(1,:)';
            detectionsToday = datetime(day) + seconds(detections);
        
        end
        
        %find difference between start of day and detection
        detSec = floor(seconds(detectionsToday(:,1)-dateRange(d)));

        %convert to samples
        detIndex = detSec * fs;
        
        comp = 0;
        for s = 1:numStat
            for c = 1:numChan
                try
                    %make filename and read data
                    fname = path + stat(s) + "/" + chan(c) + "/" + string(dateRange(d)) + "." + stat(s) + "." + chan(c) + ".noIR.SAC";
                    data = readsac(fname);

                    if numel(fieldnames(data)) > 1
                        %filter to desired band
                        trace = data.trace;
                        trace = filtfilt(b,a,trace);

                        %fill data storage matrix 
                        if length(trace) >= dayLength
                            dataMat(comp+1,:) = trace(1:dayLength);
                        end
                    end
                    comp = comp + 1;
                catch
                    fprintf("Missing data on " + day + " for " + stat(s) + " " + chan(c) + "\n")
                end        
            end
        end
             
        eventsToday = [];

        for i = eventStart:length(detectionsToday)
            
            %extract event containing window
            snipTrace = dataMat(:,detIndex(i):detIndex(i)+snipLen(i)-1);
            
            for n = 1:numStat*numChan
                
                %normalize to max amplitude of each component
                snipTrace(n,:) = snipTrace(n,:)/max(abs(snipTrace(n,:)));
                
            end
            
            if size(snipTrace,1) > 1
                %stack the traces
                stackTrace = nansum(snipTrace);
            else
                stackTrace = snipTrace;
            end
            
            %normalize the stack
            stackTrace = stackTrace/max(abs(stackTrace));
            
            %calculate envelope function
            snipEnv = envelope(stackTrace,250,'rms');
           
            %find mean of envelope
            envMean = zeros(snipLen(i),1) + mean(snipEnv);
            
            %find minima of envelope
            minPos = find(islocalmin(snipEnv,"MinProminence",0.025));
            minAmp = snipEnv(minPos);
       
            %only consider minima below envelope mean 
            minPos = minPos(minAmp < envMean(1));
            minAmp = minAmp(minAmp < envMean(1));
            
            %make vector of possible split locations (minima and endpoints)
            splitPos = [1,minPos,length(snipEnv)];
            splitInd = [];

            %find maxima of envelope
            [peakAmp, peakPos] = findpeaks(snipEnv,"MinPeakProminence",0.025);

            %only consider peaks that sufficiently exceed envelope mean
            %peakPos = peakPos(peakAmp/envMean(1) > ratio);
            %peakAmp = peakAmp(peakAmp/envMean(1) > ratio);
            
            %only proceed with splitting and counting events if peaks exist
            if isempty(peakPos) == 0
                
                %split along endpoints or minima if there's a peak between
                %a given pair of potential split points
                for m = 1:length(splitPos)-1
                    for n = 1:length(peakPos)
                        if peakPos(n) > splitPos(m) && peakPos(n) < splitPos(m+1)
                            splitInd = [splitInd,splitPos(m),splitPos(m+1)];                        
                        end

                    end
                end
            end                       
            
            %store results of event splitting routine
            splitInd = reshape(splitInd,2,length(splitInd)/2)';
            
            %remove duplicates caused by multiple peaks within split bounds
            splitInd = unique(splitInd,"rows");
            
            snipEvents = detIndex(i) + splitInd;
            eventsToday = [eventsToday;dateRange(d) + seconds(snipEvents/100)];
            
            %make some plots (for testing)

            %%{
            
            for n = 1:comp
                 subplot(comp+1,1,n)
                 plot(snipTrace(n,:))
            end  
                        
            subplot(comp+1,1,comp+1)

            hold on
            
            %shade event region
            for l = 1:size(splitInd,1)
                fill([splitInd(l,:),flip(splitInd(l,:))],[-1,-1,1,1], [0.75 0.75 0.75],'EdgeColor','r')
            end
            
            plot(stackTrace,'Color',[0 0 0.5])
            plot(snipEnv,'Color',[1 0.35 0])
            
            %scatter(minPos,minAmp,50,"black","filled")
            %scatter(peakPos,peakAmp,50,"red","filled")
            %plot(envMean)
            %if size(snipEvents,1) > 0
            %    for p = 1:size(snipEvents,1)
            %        fprintf(string((dateRange(d) + seconds(snipEvents(p,1)/100))) + "\n")
            %    end
            %else
            %    fprintf("No event. \n")
            %end
            %fprintf("Probability of Event: " + pred(i) + "\n")
            
            pause;
            clf('reset');
            
            %}

        end    
        
        eventsPerDay(d) = size(eventsToday,1);
        events = [events;eventsToday];
        
        t = toc;
        
        fprintf("Split " + length(detectionsToday) + " windows on " + day + " into " + length(eventsToday) + " events in " + t + " seconds.\n")
       
    catch
        fprintf("No data on " + day +"\n")
    end
end