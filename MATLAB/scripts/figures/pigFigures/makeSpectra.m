% set basic parameters
fs = 100;

% make matrix of file names
fnameMat = ["/media/Data/Data/PIG/MSEED/noIR/PIG2/HHZ/2012-05-09.PIG2.HHZ.noIR.MSEED",
            "/media/Data/Data/PIG/MSEED/noIR/PIG2/HHZ/2012-05-09.PIG2.HHZ.noIR.MSEED",
            "/media/Data/Data/PIG/MSEED/noIR/PIG2/HHZ/2013-11-17.PIG2.HHZ.noIR.MSEED",
            "/media/Data/Data/PIG/MSEED/noIR/PIG2/HHZ/2013-11-17.PIG2.HHZ.noIR.MSEED"];

colorVect = [[0, 0.4470, 0.7410];[0.4940, 0.1840, 0.5560];[0.9290, 0.6940, 0.1250];[0.8500, 0.3250, 0.0980]];
        
% set time limit for each event in hours
timeLims = [15.75,17.75;17.75,19.75;7,9;9,11];

% make empty figure
figure();

% make empty array
eventTrace = zeros(720001,length(fnameMat));

for f = 1:length(fnameMat)

    % load event
    data = rdmseed(fnameMat(f));
    trace = extractfield(data,'d');

    % select start and end times for fft
    startInd = timeLims(f,1) * 60 * 60 * fs;
    endInd = timeLims(f,2) * 60 * 60 * fs;
    eventTrace(:,f) = trace(startInd:endInd);
    
    % taper the trace
    L = length(eventTrace(:,f));
    tukeyWin = tukeywin(L,0.25);
    taperTrace = eventTrace(:,f) .* tukeyWin;
    
    % take fft of trace, calculate power and shift
    n = length(taperTrace);
    y = fft(taperTrace);
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
    plot(logF0,logP0,'color',colorVect(f,:))
    set(gca,'YScale','log')
    set(gca,'XScale','log')
    grid on;
    grid minor;
    
end

% make plots of each trace
subplot(2,2,2);
hold on;
plot(1:L,eventTrace(:,1),'color',colorVect(1,:));
plot(L+1:2*L,eventTrace(:,2),'color',colorVect(2,:));
subplot(2,2,4);
hold on;
plot(1:L,eventTrace(:,3),'color',colorVect(3,:));
plot(L+1:L*2,eventTrace(:,4),'color',colorVect(4,:));

% filtered trace figures
filtTrace = zeros(720001,length(fnameMat));
freq = 0.1;
[b,a] = butter(2,freq/(fs/2),'low');
for i=1:length(fnameMat)
    filtTrace(:,i) = filtfilt(b,a,eventTrace(:,i));
end
figure()
subplot(2,1,1);
hold on;
plot(1:L,filtTrace(:,1),'color',colorVect(1,:));
plot(L+1:2*L,filtTrace(:,2),'color',colorVect(2,:));
title("May 9 event filtered below 0.1 Hz")
subplot(2,1,2);
hold on;
plot(1:L,filtTrace(:,3),'color',colorVect(3,:));
plot(L+1:L*2,filtTrace(:,4),'color',colorVect(4,:));
title("Scotia plate teleseism filtered below 0.1 Hz")

filtTrace = zeros(720001,length(fnameMat));
freq = 1;
[b,a] = butter(2,freq/(fs/2),'high');
for i=1:length(fnameMat)
    filtTrace(:,i) = filtfilt(b,a,eventTrace(:,i));
end
figure()
subplot(2,1,1);
hold on;
plot(1:L,filtTrace(:,1),'color',colorVect(1,:));
plot(L+1:2*L,filtTrace(:,2),'color',colorVect(2,:));
title("May 9 event filtered above 1 Hz")
subplot(2,1,2);
hold on;
plot(1:L,filtTrace(:,3),'color',colorVect(3,:));
plot(L+1:L*2,filtTrace(:,4),'color',colorVect(4,:));
title("Scotia plate teleseism filtered above 1 Hz")

