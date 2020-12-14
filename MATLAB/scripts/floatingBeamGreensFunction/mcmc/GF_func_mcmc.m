function [dGdt,data,M_frac] = GF_func_mcmc(params,data,freq)

% this function is for use with P. Segall's MCMC code- instead of actually
% calling the Green's function model, it pulls already created Green's
% functions (spatial derivative has already been taken). Therefore, L, f_max, and t_max are fixed, and already set by
% this point. In general, they will be L = 1e7, f_max = 1, t_max = 1000

% get parameters from vector
h_i = params(1);
h_w = params(2);
statDist = params(3);
t0 = params(4);
f_max = params(5);
t_max = params(6);
L = 1e7;

% make model object
model = loadParameters(L,f_max,t_max,h_i,h_w);

% run model
G = semiAnalyticGreenFunction(model);

% spatial derivative
[~,dGdx] = gradient(G,model.dx);

% scale by ice front bending moment
M_max =  916 * 9.8 * h_i^3 / 12 * 0.072;
dGdx = dGdx * M_max; 
        
% get green's function at desired position
[~,locIdx] = min(abs(model.x - statDist));
dGdx = dGdx(locIdx,:);

% make error function pulse
zeroThresh = 1e-2;
%zeroThresh = 1e-3;
try
    new_t = [-fliplr(model.t),model.t(2:end)];
    erfStf = (erf(new_t/t0)+1)/2;
    [~,offset_index] = max(find(erfStf < zeroThresh));
    erfOffset = -(max(new_t) + new_t(offset_index));
    erfStf = (erf((new_t-erfOffset)/t0)+1)/2;
    stf = erfStf;
catch
    error("Use a larger t_max for t0 = " + t0)
end
% convolve stf and green's function
G_pad = zeros(size(new_t));
G_pad(ceil(end/2):end) = dGdx;
G_stf = ifft(fft(G_pad).*fft(stf));
    
% take time derivative to get velocity seismogram
dGdt = gradient(G_stf,model.dt);

% filter to same band as data
[b,a] = butter(2,freq/(f_max*1.001),"bandpass");
dGdt = filtfilt(b,a,dGdt);

% get ratio of applied moment to max bending moment
M_frac = max(data)/max(dGdt);

% normalize and trim
dGdt = dGdt / max(dGdt);
dGdt = dGdt(ceil(end/2):end);

% normalize data
data = data/max(data);

% find index of max value
% [~,dataMaxIdx] = max(data);
% 
% % find index of max value
% [~,modelMaxIdx] = max(dGdt);
% 
% if modelMaxIdx > dataMaxIdx
%     slide = modelMaxIdx-dataMaxIdx;
%     data = [zeros(1,slide),data(1:end-slide)];
% else
%     slide = dataMaxIdx-modelMaxIdx;
%     dGdt = [zeros(1,slide),dGdt(1:end-slide)];
% end    

% cross correlate with data
[xcorrTrace,lag] = xcorr(data,dGdt,"coeff");
[corrCoef,lagIndex] = max(xcorrTrace);  
slide = lag(lagIndex);
if slide > 0
    dGdt = [zeros(1,abs(slide)),dGdt];
    dGdt = dGdt(1:length(data));
end
if slide < 0
    dGdt = [dGdt(abs(slide):end),zeros(1,abs(slide)-1)];
end

end