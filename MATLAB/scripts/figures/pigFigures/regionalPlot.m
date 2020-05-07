% set basic parameters
fs = [100,40,40,40,40];

% make matrix of file names
fnameMat = ["/media/Data/Data/PIG/MSEED/noIR/PIG2/HHN/2012-05-09.PIG2.HHN.noIR.MSEED",
            "/media/Data/Data/YT/MSEED/noIR/DNTW/BHN/2012-05-09.DNTW.BHN.noIR.MSEED",
            "/media/Data/Data/YT/MSEED/noIR/UPTW/BHN/2012-05-09.UPTW.BHN.noIR.MSEED",
            "/media/Data/Data/YT/MSEED/noIR/THUR/BHN/2012-05-09.THUR.BHN.noIR.MSEED",
            "/media/Data/Data/YT/MSEED/noIR/BEAR/BHN/2012-05-09.BEAR.BHN.noIR.MSEED"];

% set time limit for dispalyed seismogram
timeLims = [18,18.25];

% choose filter band and design filter
freq = [1,3];

% make empty figure
figure();

for f = 1:length(fnameMat)

    % load event
    data = rdmseed(fnameMat(f));
    trace = extractfield(data,'d');

    % select start and end times for fft
    startInd = timeLims(1) * 60 * 60 * fs(f);
    endInd = timeLims(2) * 60 * 60 * fs(f);
    eventTrace = trace(startInd:endInd);
    
    % filter trace
    [b,a] = butter(4,freq/(fs(f)/2),'bandpass');
    eventTrace = filtfilt(b,a,eventTrace);
    
    % plot filtered trace
    subplot(length(fnameMat),1,f);
    plot(eventTrace)
    
end