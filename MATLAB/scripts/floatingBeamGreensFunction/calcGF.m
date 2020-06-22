function [model,dGdt,G_scaled,stf] = calcGF(L,f_max,t_max,h_i,h_w,statDist,...
                                            sourceType,t0,pulseType,scale,varargin)

% get max pressure and moment
P_max = 916 * 9.8 * h_i;
M_max =  916 * 9.8 * h_i^3 / 12 * 0.072;

% make model object
model = loadParameters(L,f_max,t_max,h_i,h_w);

% get index of desired position
[~,locIdx] = min(abs(model.x - statDist));

% in general, run the model unless a G_scaled variable is provided to the function
% (this is useful for convolving a single green's function with multiple
% soruce time functions
if nargin < 11
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

% set G_scaled equal to input Green's function
else
    G_scaled = varargin{1};
end
    
% convolve with gaussian stf of halfwidth t0 after time derivative
if t0 ~= 0 && pulseType ~= "none"
   
    % if half pulse source type, use error function to make stf
    if pulseType == "half down" || pulseType == "half up"
        
        try
            % make error function pulse
            new_t = [-fliplr(model.t),model.t(2:end)];
            erfStf = (erf(new_t/t0)+1)/2;
            [~,offset_index] = max(find(erfStf < 1e-5));
            erfOffset = -(max(new_t) + new_t(offset_index));
            erfStf = (erf((new_t-erfOffset)/tpass0)+1)/2;
        catch
            error("Use a larger t_max for a pulse with t0 = " + string(t0))
        end
        
        % flip if necessary
        if pulseType == "half down"
            stf = fliplr(erfStf);
        elseif pulseType == "half up"
            stf = erfStf;
        end
        
        % scale if desired
        stf = stf*scale;
        
        % convolve with Green's function
        G_scaled_pad = zeros(size(new_t));
        G_scaled_pad(ceil(end/2):end) = G_scaled;
        G_stf = ifft(fft(G_scaled_pad).*fft(stf));
        
        % get rid of padding
        G_stf = G_stf(ceil(end/2):end);
        if pulseType == "half down"
            stf = stf(ceil(end/2):end);
        elseif pulseType == "half up"
            stf = stf(1:ceil(end/2));
        end
        
    elseif pulseType == "full"   
        
        % make half gaussian pulse      
        try
            gausStf = exp((((model.t-t_max/2)/t0).^2)/-2)/t0/sqrt(2*pi);
            gausStf = gausStf./max(gausStf);
            [~,offset_index] = max(find(gausStf(1:end/2) < 1e-5));
            gausStf = gausStf(offset_index:end-offset_index);
            stf = [zeros(1,offset_index),gausStf,zeros(1,offset_index-1)];            
                   
            % scale if desired
            stf = stf*scale;
            
            % convolve with Green's function
            G_stf = ifft(fft(G_scaled).*fft(stf));
        catch
            error("Use a larger t_max for a pulse with t0 = " + string(t0))
        end

    end
    
    % take time derivative to get velocity seismogram
    dGdt = gradient(G_stf,model.dt);
    
else
    % take time derivative to get velocity seismogram
    stf = zeros(1,length(model.t));
    stf(floor(length(model.t)/2)) = 1;
    dGdt = gradient(G_scaled,model.dt);
end

end