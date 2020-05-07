% set basic parameters
fs = 100;

% make matrix of file names
fnameMat = ["/media/Data/Data/PIG/MSEED/noIR/PIG2/HHZ/2012-05-09.PIG2.HHZ.noIR.MSEED",
            "/media/Data/Data/PIG/MSEED/noIR/PIG2/HHZ/2013-11-17.PIG2.HHZ.noIR.MSEED",
            "/media/Data/Data/PIG/MSEED/noIR/PIG2/HHZ/2012-05-09.PIG2.HHZ.noIR.MSEED",
            "/media/Data/Data/PIG/MSEED/noIR/PIG2/HHZ/2013-11-17.PIG2.HHZ.noIR.MSEED"];

% set time limit for each event in hours
timeLims = [18,19;9,10;17,18;8,9];

% make empty figure
figure();

for f = 1:length(fnameMat)

    % load event
    data = rdmseed(fnameMat(f));
    trace = extractfield(data,'d');

    % select start and end times for fft
    startInd = timeLims(f,1) * 60 * 60 * fs;
    endInd = timeLims(f,2) * 60 * 60 * fs;
    eventTrace = trace(startInd:endInd);
    
    % taper the trace
    L = length(eventTrace);
    tukeyWin = tukeywin(L,0.25);
    eventTrace = eventTrace .* tukeyWin';
    
    % take fft of trace, calculate power and shift
    n = length(eventTrace);
    y = fft(eventTrace);
    y0 = fftshift(y);
    p0 = abs(y0)/sqrt(n);
   
    % make log frequency vector
    f0 = (-n/2:n/2-1)*(fs/n);
    logF = logspace(-4,log10(fs/2),200);
    logF0 = [fliplr(-logF),logF];
    
    % interpolate
    logP0 = interp1(f0,p0,logF0);
    
    % make plot of each spectra
    subplot(2,2,[1,3]);
    hold on;
    plot(logF0,logP0)
    set(gca,'YScale','log')
    set(gca,'XScale','log')
    grid on;
    grid minor;
    
    if f < 3
    
        % make plots of each trace
        subplot(2,2,f*2);
        hold on;
        plot(eventTrace);
        
    end
    
end