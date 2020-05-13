% set data parameters
t_max = 125;
f_max = 0.5;
nt = t_max*(2*f_max);

% get real data
fname = "/media/Data/Data/PIG/MSEED/noIR/PIG2/HHZ/2012-04-02.PIG2.HHZ.noIR.MSEED";
dataStruct = rdmseed(fname);

% extract trace
trace = extractfield(dataStruct,'d');
fs = 100;

% resample data to 1 Hz
fsNew = f_max*2;
trace = resample(trace,fsNew,100);

% set event bounds
startTime = ((15*60+18)*60+50)*fsNew;
endTime = startTime + nt;

% trim data to event bounds
eventTrace = trace(startTime:endTime-1);

% remove scalar offset using first value
eventTrace = eventTrace - eventTrace(1);

% normalize data
eventTrace = eventTrace/max(eventTrace);

% find index of max value
[~,dataMaxIdx] = max(eventTrace);

% set mcmc parameters
% x0 goes like this: [h_i,h_w,statDist,t0,f_max,t_max,dataMaxIdx]
% f_max, t_max, and dataMaxIdx MUST have 0 step size in xStep
x0 = [350,800,10000,6,f_max,t_max];
xStep = [10,10,0,0,0,0];
xBounds = [0,1000;
           0,1000;
           0,100000;
           0,10;
           0,f_max+1;
           0,t_max+1;];
sigma = 0.75;
numIt = 5000;

% generate intial Green's function
[G_0,eventTraceSlide] = GF_func_mcmc(x0,eventTrace);

% calculate initial liklihood
normArg = (eventTraceSlide-G_0)./eventTraceSlide;
normArg(isnan(normArg)) = 1;
L0 = -0.5/sigma^2 * norm(normArg)^2;

[x_keep,L_keep,count,alpha_keep,accept] = mcmc('GF_func_mcmc',eventTrace,x0,xStep,xBounds,sigma,numIt,L0);

% plot results
dscatter(x_keep(1,:)',x_keep(2,:)','plottype','surf')
view(2)