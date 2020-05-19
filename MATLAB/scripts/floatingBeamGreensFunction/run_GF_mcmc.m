% set data parameters
statDist = 10000;
t0 = 6;
f_max = 0.5;
t_max = 125;
nt = t_max*(2*f_max);

% set flag for toy problem
test = 1;

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

% if toy problem mode, set waveform to recover
if test
    testParams = [450,600,statDist,t0,f_max,t_max];
    [eventTrace,~] = GF_func_mcmc(testParams,eventTrace);
end

% find index of max value
[~,dataMaxIdx] = max(eventTrace);

% set mcmc parameters
% x0 goes like this: [h_i,h_w,statDist,t0,f_max,t_max,dataMaxIdx]
% f_max, t_max, and dataMaxIdx MUST have 0 step size in xStep
x0 = [350,800,statDist,t0,f_max,t_max];
xStep = [50,50,0,0,0,0];
xBounds = [0,1000;
           0,1000;
           0,100000;
           0,10;
           0,f_max+1;
           0,t_max+1;];
sigma = 2;
numIt = 10000;

% generate intial Green's function
[G_0,eventTraceSlide,amp] = GF_func_mcmc(x0,eventTrace);

% calculate initial liklihood
normArg = (eventTraceSlide-G_0)./eventTraceSlide;
normArg(isnan(normArg)) = 1;
L0 = -0.5/sigma^2 * norm(normArg)^2;

[x_keep,L_keep,count,alpha_keep,accept,M_fracs] = mcmc('GF_func_mcmc',eventTrace,x0,xStep,xBounds,sigma,numIt,L0);

% give output
fprintf("Accepted " + round((sum(accept)/numIt)*100) + " percent of proposals\n");

% find best-fit parameters
xFit = zeros(length(x0),1);
for i = 1:length(x0)
    [counts,bins] = histcounts(x_keep(i,:));
    [~,ind] = max(counts);
    xFit(i) = (bins(ind)+bins(ind+1))/2;
end

% run model for best fit parameters
[G_fit,eventTraceSlide] = GF_func_mcmc(xFit,eventTrace);

% make density plot of results
figure(1)
dscatter(x_keep(1,:)',x_keep(2,:)','plottype','surf')
view(2)
title("Result of MCMC inversion after " + numIt + " iterations.")
xlabel("Ice thickness (m)")
ylabel("Water thickness (m)")
text(xFit(1),xFit(2),string("h_i: " + xFit(1) + "h_w: " + xFit(2)),'Color','k')

% plot resulting waveform and best-fit waveform
t = 1:1/(2*f_max):t_max;
figure(2)
plot(t,G_fit);
hold on;
plot(t,eventTraceSlide);
title("Data and MCMC best-fit waveform")
xlabel("Time (s)")
ylabel("Normalized Velocity")
[k,mk] = max(G_fit);
text(mk*4/3,k/2,string("Best-fit parameters" + newline + "h_i: " + xFit(1) + "    h_w: " + xFit(2)),'Color','k')
legend("MCMC best-fit model","Data")

% plot resulting waveform and starting waveform
figure(3)
plot(t,G_0);
hold on;
plot(t,eventTraceSlide);
title("Data and starting waveform")
xlabel("Time (s)")
ylabel("Normalized Velocity")
[k,mk] = max(G_0);
text(mk*4/3,k/2,string("Starting parameters" + newline + "h_i: " + x0(1) + "    h_w: " + x0(2)),'Color','k')
legend("MCMC starting model","Data")
