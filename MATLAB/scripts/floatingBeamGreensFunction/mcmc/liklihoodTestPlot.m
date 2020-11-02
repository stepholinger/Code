% get real data
fname = "/media/Data/Data/PIG/MSEED/noIR/PIG2/HHZ/2012-04-02.PIG2.HHZ.noIR.MSEED";
dataStruct = rdmseed(fname);

% extract trace
trace = extractfield(dataStruct,'d');
fs = 100;
f_max = 0.5;
fsNew = f_max*2;
nt = 10000*fsNew;

% deal with under 1 Hz resampling
if f_max < 0.5
    fs = fs/(f_max*2);
    trace = resample(trace,1,fs);
else
    trace = resample(trace,fsNew,fs);
end

% filter if desired
%[b,a] = butter(4,0.01/(fsNew/2),'low');
%trace = filtfilt(b,a,trace);

% set event bounds
startTime = ((15*60+18)*60+50)*fsNew;
endTime = startTime + nt;

% trim data to event bounds
eventTrace = trace(startTime:endTime-1);

% remove scalar offset using first value
eventTrace = eventTrace - eventTrace(1);

% set parameter combinations
x0 = [350,800,10000,5.5,f_max,nt];
xTest = [350,800,10000,5.5,f_max,nt];

% run model
[G_0,~,~] = GF_func_mcmc(x0,eventTrace);
[G_test,eventAlign,~] = GF_func_mcmc(xTest,eventTrace);

% set some stuff
sigma = 3;
frontInd = nt*f_max*2;

% calculate liklihoods
L_0_norm = liklihood(G_0(1:frontInd),eventAlign(1:frontInd),sigma,'standard');
L_test_norm = liklihood(G_test(1:frontInd),eventAlign(1:frontInd),sigma,'standard');
L_0 = liklihood(G_0(1:frontInd),eventAlign(1:frontInd),sigma,'modified');
L_test = liklihood(G_test(1:frontInd),eventAlign(1:frontInd),sigma,'modified');

% make plots
subplot(2,2,1)
plot(eventAlign(1:frontInd)); hold on;plot(G_0(1:frontInd));
l = legend("Data","MCMC starting model");
set(l,'Location','southwest');
xlabel("Time (s)")
ylabel("Normalized Velocity")
[k,mk] = max(eventAlign(1:frontInd));            
text(mk*2/3,k/1.5,string("Liklihood: " + L_0_norm));
title("Starting model liklihood (with normalization)")

subplot(2,2,2)
plot(eventAlign(1:frontInd)); hold on;plot(G_test(1:frontInd));
l = legend("Data","MCMC test model");
set(l,'Location','southwest');
xlabel("Time (s)")
ylabel("Normalized Velocity")
[k,mk] = max(eventAlign(1:frontInd));            
text(mk*2/3,k/1.5,string("Liklihood: " + L_test_norm));
set(gcf,'Position',[10 10 2000 800])
title("Test model liklihood (with normalization)")

subplot(2,2,3)
plot(eventAlign(1:frontInd)); hold on;plot(G_0(1:frontInd));
l = legend("Data","MCMC starting model");
set(l,'Location','southwest');
xlabel("Time (s)")
ylabel("Normalized Velocity")
[k,mk] = max(eventAlign(1:frontInd));            
text(mk*2/3,k/1.5,string("Liklihood: " + L_0));
title("Starting model liklihood (without normalization)")

subplot(2,2,4)
plot(eventAlign(1:frontInd)); hold on;plot(G_test(1:frontInd));
l = legend("Data","MCMC test model");
set(l,'Location','southwest');
xlabel("Time (s)")
ylabel("Normalized Velocity")
[k,mk] = max(eventAlign(1:frontInd));            
text(mk*2/3,k/1.5,string("Liklihood: " + L_test));
set(gcf,'Position',[10 10 2000 800])
title("Test model liklihood (without normalization)")
