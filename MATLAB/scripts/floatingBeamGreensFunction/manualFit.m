% get real data
fname = "/media/Data/Data/PIG/MSEED/noIR/PIG2/HHZ/2012-05-09.PIG2.HHZ.noIR.MSEED";
dataStruct = rdmseed(fname);

% extract trace
trace = extractfield(dataStruct,'d');
fs = 100;
f_max = 1;
fsNew = f_max*2;
nt = 1000*fsNew;

% deal with under 1 Hz resampling
if f_max < 0.5
    fs = fs/(f_max*2);
    trace = resample(trace,1,fs);
else
    trace = resample(trace,fsNew,fs);
end

% filter if desired
[b,a] = butter(4,0.01/(fsNew/2),'low');
filtTrace = filtfilt(b,a,trace);

% set event bounds
startTime = ((18*60)*60)*fsNew;
endTime = startTime + nt;

% trim data to event bounds
eventTrace = filtTrace(startTime:endTime-1);

% remove scalar offset using first value
eventTrace = eventTrace - eventTrace(1);

% set parameter combinations
xTest = [50,500,10000,500,f_max,nt];

% run model
[G_test,eventAlign,~] = GF_func_mcmc(xTest,eventTrace);

% set some stuff
sigma = 3;
frontInd = nt*f_max*2;

L_test = liklihood(G_test(1:frontInd),eventAlign(1:frontInd),sigma,'modified');

plot(eventAlign(1:frontInd)); hold on;plot(G_test(1:frontInd));
l = legend("Data","MCMC test model");
set(l,'Location','southwest');
xlabel("Time (s)")
ylabel("Normalized Velocity")
[k,mk] = max(eventAlign(1:frontInd));            
text(mk*2/3,k/1.5,string("Liklihood: " + L_test));
set(gcf,'Position',[10 10 2000 800])
title("Test model liklihood (without normalization)")
