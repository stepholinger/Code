% set some parameters
fs = 100;

% make matrix of file names
fnameMat = ["/media/Data/Data/PIG/MSEED/noIR/PIG2/HHZ/2012-05-08.PIG2.HHZ.noIR.MSEED",
            "/media/Data/Data/PIG/MSEED/noIR/PIG2/HHZ/2012-05-09.PIG2.HHZ.noIR.MSEED",
            "/media/Data/Data/PIG/MSEED/noIR/PIG2/HHZ/2012-05-10.PIG2.HHZ.noIR.MSEED",
            "/media/Data/Data/PIG/MSEED/noIR/PIG2/HHZ/2012-05-11.PIG2.HHZ.noIR.MSEED"];

% make empty figure
figure();

% make empty arrays
longTrace = [];
longTraceTimes = [];

for f = 1:length(fnameMat)

    % load event
    data = rdmseed(fnameMat(f));
    trace = extractfield(data,'d');
    times = extractfield(data,'t');
    
    % append to combined trace
    longTrace = [longTrace,trace];
    longTraceTimes = [longTraceTimes,times];
    
end

% open imagery and plot
may8_image = imread('imagery/TDX-1_2012-05-08T04_04_199948.jpg');
may11_image = imread('imagery/TDX-1_2012-05-11T09_27_0787723.jpg');

% crop images to whole shelf with stations 
%may8_crop = imcrop(may8_image,[525 1200 1500 700]);
%may11_crop = imcrop(may11_image,[0 775 650 500]);

% crop images to just show rift
may8_crop = imcrop(may8_image,[650 1325 400 550]);
may11_crop = imcrop(may11_image,[100 825 500 400]);

% adjust contrast if needed
may8_crop_adj = imadjust(may8_crop,[0.2,1],[0,0.9]);
may8_crop_adj = adapthisteq(may8_crop_adj,'ClipLimit',0.005);

% plot imagery
subplot(5,2,[1,3])
imshow(rot90(may8_crop_adj))
title("TerraSAR-x image of PIG on May 8, 2012")
subplot(5,2,[2,4])
imshow(may11_crop)
title("TerraSAR-x image of PIG on May 11, 2012")

% load, filter, and plot may 9 event on 1st band
subplot(5,2,7:8)
freq = 0.001;
[b,a] = butter(2,freq/(fs/2),'high');
may9_data = rdmseed(fnameMat(2));
may9_trace = extractfield(may9_data,'d');
may9_times = extractfield(may9_data,'t');
may9_trace_filt = filtfilt(b,a,may9_trace);
startInd = ((17*60+45)*60)*fs;
endInd = startInd + 1*60*60*fs;
eventTrace = may9_trace_filt(startInd:endInd);
eventTimes = may9_times(startInd:endInd);
plot(eventTimes,eventTrace,'k')
xlim([may9_times(startInd),may9_times(endInd)])
datetick('x','keepLimits')
title("May 9 Event (filtered above " + freq + " Hz)")
ylabel('Velocity (m/s)')

% plot on another band
subplot(5,2,9:10)
freq = 1;
[b,a] = butter(2,freq/(fs/2),'high');
may9_trace_filt = filtfilt(b,a,may9_trace);
startInd = ((17*60+45)*60)*fs;
endInd = startInd + 1*60*60*fs;
eventTrace = may9_trace_filt(startInd:endInd);
eventTimes = may9_times(startInd:endInd);
plot(eventTimes,eventTrace,'k')
xlim([may9_times(startInd),may9_times(endInd)])
datetick('x','keepLimits')
title("May 9 Event (filtered above " + freq + " Hz)")
ylabel('Velocity (m/s)')
xlabel('Time')

% filter and plot long data
subplot(5,2,5:6)
freq = 0.001;
[b,a] = butter(2,freq/(fs/2),'high');
longTrace_filt = filtfilt(b,a,longTrace);
plot(longTraceTimes,longTrace_filt,'k')
hold on;
datetick('x')
title("May 8 - May 11 (filtered above " + freq + " Hz)")
ylabel('Velocity (m/s)')
ylim([min(longTrace_filt),max(longTrace_filt)])
patch([may9_times(startInd),may9_times(startInd),may9_times(endInd),...
    may9_times(endInd)],[min(longTrace_filt),max(longTrace_filt),...
    max(longTrace_filt),min(longTrace_filt)],'k','EdgeColor','none','FaceColor','red','FaceAlpha',0.2)