function [model,dGdt,stf] = calcGF_crevasse_moment(L,f_max,t_max,h_i,h_w,statDist,t0,h_c_initial,h_c_final)

% get max pressure and moment
M_max =  916 * 9.8 * h_i^3 / 12 * 0.072;

% make model object
model = loadParameters(L,f_max,t_max,h_i,h_w);

% get index of desired position
[~,locIdx] = min(abs(model.x - statDist));

% in general, run the model unless a G_scaled variable is provided to the function
% (this is useful for convolving a single green's function with multiple
% soruce time functions

% run model
G = semiAnalyticGreenFunction(model);

% take spatial derivative
[~,dGdx] = gradient(G,model.dx);

% get trace closest seismometer location
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
    
end