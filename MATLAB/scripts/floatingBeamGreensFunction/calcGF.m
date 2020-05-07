function [model,dGdt,stf] = calcGF(L,f_max,t_max,h_i,h_w,statDist,sourceType,t0,pulseType)

% get max pressure and moment
P_max = 916 * 9.8 * h_i;
M_max =  916 * 9.8 * h_i^3 / 12 * 0.072;

% make model object
model = loadParameters(L,f_max,t_max,h_i,h_w);

% get index of desired position
[~,locIdx] = min(abs(model.x - statDist));

% run model
G = semiAnalyticGreenFunction(model);

if strcmp(sourceType,"moment")
    % take spatial derivative
    [~,dGdx] = gradient(G,model.dx);

    % scale by ice front bending moment
    G_scaled = dGdx * M_max;  
    
else
    % scale by pressure magnitude
    G_scaled = G * P_max;    
end              

% get trace closest seismometer location
G_scaled = G_scaled(locIdx,:);

% convolve with gaussian stf of halfwidth t0 after time derivative
if t0 ~= 0 && pulseType ~= "none"

    % make half gaussian pulse
    gausStf = exp(((model.t/t0).^2)/-2)/t0/sqrt(2*pi);
    
    % normalize stf amplitude
    gausStf = gausStf./max(gausStf);
    
    % make error function pulse
    offset = floor(t_max/2);
    erfStf = (erf((model.t-offset)/t0)+1)/2;
    
    if pulseType == "half down"
        stf = fliplr(erfStf);
    elseif pulseType == "half up"
        stf = erfStf;
    elseif pulseType == "full"
        stf = [fliplr(gausStf),gausStf];
        stf = stf(1:2:end);
    end
    
    % convolve with Green's function
    G_stf = ifft(fft(G_scaled).*fft(stf));
    
    % take time derivative to get velocity seismogram
    dGdt = gradient(G_stf,model.dt);
    
else
    % take time derivative to get velocity seismogram
    stf = zeros(1,length(model.t));
    stf(floor(length(model.t)/2)) = 1;
    dGdt = gradient(G_scaled,model.dt);
end

end