datetime.setDefaultFormats("defaultdate","yyyy-MM-dd HH:mm:SS")

numBins = 24;

fileType = "MSEED";

normEnergyMat = zeros(2,numBins);

c = 1;

detections = NaT;

for n = 1:24:length(energyMat)-24
       
    if isempty(find(energyMat(1,n:n+23))) ~= 1
    
        % normalize both series to max- only needed for plotting
        normEnergyMat(1,:) = energyMat(1,n:n+23)/max(energyMat(1,n:n+23));
        normEnergyMat(2,:) = energyMat(2,n:n+23)/max(energyMat(2,n:n+23));

        % find max of both series
        [~,i1] = max(normEnergyMat(1,:));
        [~,i2] = max(normEnergyMat(2,:));

        if abs(i1-i2) <= 2           
            detections(1,c) = t(n+i1-1);      
            detections(2,c) = t(n+i2-1);           

            c = c + 1;            
        end
%{
        plot(normEnergyMat(1,:));
        hold on;
        plot(normEnergyMat(2,:));
        legend("<0.1 Hz","1-10 Hz")
        title(string(dateRange(ceil(n/numBins))));
        pause;
        hold off;    
%}
    end
    
end

% set path
if fileType == "SAC"
    path = "/media/Data/Data/PIG/SAC/noIR/";
end
if fileType == "MSEED"
    path = "/media/Data/Data/PIG/MSEED/noIR/";
end

% set station and components
stat = "PIG2";
chan = "HHZ";
filtType1 = "low";
freq1 = 0.1;
filtType2 = "bandpass";
freq2 = [1,10];

% choose filter bands and design filter
[b,a] = butter(4,freq1/(fs/2),filtType1);
[b2,a2] = butter(4,freq2/(fs/2),filtType2);

% loop through all days
for d = 54:length(detections)

    dayForFname = datestr(detections(1,d),"yyyy-mm-dd");

    % make filename and read data
    if fileType == "SAC"
        fname = path + stat + "/" + chan + "/" + dayForFname + "." + stat + "." + chan + ".noIR.SAC";
        data = readsac(fname);
        trace = data.trace;
    end
    if fileType == "MSEED"
        fname = path + stat + "/" + chan + "/" + dayForFname + "." + stat + "." + chan + ".noIR.MSEED";
        data = rdmseed(fname);
        trace = extractfield(data,'d');
    end

    % filter to desired band
    traceLow = filtfilt(b,a,trace);
    traceHigh = filtfilt(b2,a2,trace);
    
    hour1 = hour(detections(1,d));
    hour2 = hour(detections(2,d));
    
    clf();
    set(gcf,'Visible','off');
    
    % plot correct snippet of data
    if hour1 < hour2
        
        snipLow = traceLow(hour1*60*60*fs+1:(hour2+1)*60*60*fs);
        snipHigh = traceHigh(hour1*60*60*fs+1:(hour2+1)*60*60*fs);

    elseif hour1 > hour2
        
        snipLow = traceLow(hour2*60*60*fs+1:(hour1+1)*60*60*fs);
        snipHigh = traceHigh(hour2*60*60*fs+1:(hour1+1)*60*60*fs);       

    elseif hour1 == hour2
        
        snipLow = traceLow(hour1*60*60*fs+1:(hour1+1)*60*60*fs);
        snipHigh = traceHigh(hour1*60*60*fs+1:(hour1+1)*60*60*fs);
        
    end
    
    maxValHigh = max(snipHigh);
    maxValLow = max(snipLow);

    yyaxis left;
    plot(snipLow-2*maxValLow);
    ylim([-3*maxValLow 0]); 

    hold on;

    yyaxis right
    plot(snipHigh+2*maxValHigh);
    ylim([0 3*maxValHigh]);
    
    legend("<0.1 Hz","1-10 Hz")
    title(string(detections(1,d)))
    
    %pause;
    
    saveas(gcf,"/home/setholinger/Documents/Projects/PIG/detectionPlots/" + stat + "/" + chan + "/" + datestr(detections(1,d),"yyyy-mm-dd HH:MM:SS") + ".png")

    hold off;
        
end
    
