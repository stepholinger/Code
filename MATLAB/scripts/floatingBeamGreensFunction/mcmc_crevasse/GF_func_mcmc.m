function [dGdt,corrCoef] = GF_func_mcmc(params,data)

% this function is for use with P. Segall's MCMC code- instead of actually
% calling the Green's function model, it pulls already created Green's
% functions (spatial derivative has already been taken). Therefore, L, f_max, and t_max are fixed, and already set by
% this point. In general, they will be L = 1e7, f_max = 1, t_max = 1000

% get parameters from vector
h_i = params(1);
h_w = params(2);
statDist = params(3);
t0 = params(4);
h_c_initial = params(5);
h_c_final = params(6);
f_max = params(7);
t_max = params(8);
L = 1e7;

% make model object
model = loadParameters(L,f_max,t_max,h_i,h_w);

% run model
G = semiAnalyticGreenFunction(model);

% spatial derivative
[~,dGdx] = gradient(G,model.dx);

% get green's function at desired position
[~,locIdx] = min(abs(model.x - statDist));
dGdx = dGdx(locIdx,:);

% call moment_curve function and get portion of moment curve corresponding to h_c_initial and h_c_final
[m_curve,c_ratio] = moment_curve(model,t0,h_c_initial,h_c_final);
[~,h_c_initial_idx] = min(abs(c_ratio - h_c_initial));
[~,h_c_final_idx] = min(abs(c_ratio - h_c_final));
m_curve = m_curve(h_c_initial_idx:h_c_final_idx);

% get delta m by subracting initial moment
delta_m_curve = m_curve - m_curve(1);

% get new time axis
new_t = [-fliplr(model.t),model.t(2:end)];

% extend delta m curve
padding = length(new_t)-length(delta_m_curve);
stf = [delta_m_curve,ones(1,padding)*delta_m_curve(end)];

% convolve with Green's function
dGdx_pad = zeros(size(new_t));
dGdx_pad(ceil(end/2):end) = dGdx;
G_stf = ifft(fft(dGdx_pad).*fft(stf));

% get rid of padding
G_stf = G_stf(ceil(end/2):end);
stf = stf(1:ceil(end/2));
        
% take time derivative to get velocity seismogram
dGdt = gradient(G_stf,model.dt);

% cross correlate with data
[xcorrTrace,lag] = xcorr(data,dGdt,"coeff");
[corrCoef,lagIndex] = max(xcorrTrace);  
%corrCoef = sum(abs(xcorrTrace));
slide = lag(lagIndex);
%fprintf(slide+"\n")
if slide > 0
    dGdt = [zeros(1,abs(slide)),dGdt];
    dGdt = dGdt(1:length(data));
end
if slide < 0
    dGdt = [dGdt(abs(slide):end),zeros(1,abs(slide)-1)];
end

% find index of max value
%[~,dataMaxIdx] = max(data);

% find index of max value
%[~,modelMaxIdx] = max(dGdt);

%if modelMaxIdx > dataMaxIdx
%    slide = modelMaxIdx-dataMaxIdx;
%    data = [zeros(1,slide),data(1:end-slide)];
%else
%    slide = dataMaxIdx-modelMaxIdx;
%    dGdt = [zeros(1,slide),dGdt(1:end-slide)];
%end

end