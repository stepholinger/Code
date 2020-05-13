% strategy is to match wave shape with amplitudes normalized to 1, then use
% scaling factor to match amplitude

% get real data
fname = "/media/Data/Data/PIG/MSEED/noIR/PIG2/HHZ/2012-04-02.PIG2.HHZ.noIR.MSEED";
dataStruct = rdmseed(fname);

% set model parameters
L = 1e7;
f_max = 1;
t_max = 1000;
h_i = 350;
h_w = 800;
statDist = 10000;

% run model
[model,dGdt,~,~] = calcGF(1e7,f_max,t_max,h_i,h_w,statDist,"moment",6,"half up",0.025);

% find index of max value
[modelMax,modelMaxIdx] = max(dGdt);

% extract trace
trace = extractfield(dataStruct,'d');
fs = 100;

% resample data to 1 Hz
fsNew = f_max*2;
trace = resample(trace,fsNew,100);

% set event bounds
startTime = ((15*60+18)*60+50)*fsNew;
endTime = startTime + model.nt;

% trim data to event bounds
eventTrace = trace(startTime:endTime-1);

% remove scalar offset using first value
eventTrace = eventTrace - eventTrace(1);

% find index of max value
[dataMax,dataMaxIdx] = max(eventTrace);

% align maximum values by padding with zeros
if modelMaxIdx > dataMaxIdx
    slide = modelMaxIdx-dataMaxIdx;
    eventTrace = [zeros(1,slide),eventTrace(1:end-slide)];
else
    slide = dataMaxIdx-modelMaxIdx;
    dGdt = [zeros(1,slide),dGdt(1:end-slide)];
end    

% make normalized plot
%plot(model.t(1:500),dGdt(1:500)/max(dGdt))
%hold on;
%plot(model.t(1:500),eventTrace(1:500)/max(eventTrace))
%ylim([-1,1])

% make plot
plot(model.t(1:500),dGdt(1:500))
hold on;
plot(model.t(1:500),eventTrace(1:500))
