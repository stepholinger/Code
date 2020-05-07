% set parameters which stay constant
sourceType = 'moment';
statDist = 10000;
L = 1e7;
f_max = 10;
t_max = 1000;
h_i = 100;
h_w = 1000;

% manually set parameters for each subplot
params = {{f_max,t_max,h_i,h_w,0,"none"},{f_max,t_max,h_i,h_w,100,"half up"},{f_max,t_max,h_i,h_w,100,"half down"},{f_max,t_max,h_i,h_w,100,"full"};...
         {f_max,t_max,h_i,h_w,0,"none"},{f_max,t_max,h_i,h_w,250,"half up"},{f_max,t_max,h_i,h_w,250,"half down"},{f_max,t_max,h_i,h_w,250,"full"};...
         {f_max,t_max,h_i,h_w,0,"none"},{f_max,t_max,h_i,h_w,500,"half up"},{f_max,t_max,h_i,h_w,500,"half down"},{f_max,t_max,h_i,h_w,500,"full"}};
     
% get dimensions of parameter matrix
paramDims = size(params);

% make counter for subplot number
p = 1;

% run the model for each parameter set
for i = 1:paramDims(1)
    for j = 1:paramDims(2)
        
        f_max = params{i,j}{1};        
        t_max = params{i,j}{2};
        h_i = params{i,j}{3};
        h_w = params{i,j}{4};
        t0 = params{i,j}{5};
        pulseType = params{i,j}{6};
        
        % call the model function
        [model,dGdt,stf] = calcGF(L,f_max,t_max,h_i,h_w,statDist,sourceType,t0,pulseType);
        t = model.t;
        
        % set the correct subplot
        figure(1)
        subplot(paramDims(1),paramDims(2),p)
        plot(t,detrend(dGdt))
        
        title({"f_{max}: " + f_max + " Hz     h_i: " + h_i + " m     h_w: " + h_w + " m     t_0 = " + t0 + " s",''})
        xlabel('Time (s)'); ylabel('Vertical Velocity (m/s)');
        xlim([0,t_max])
        
        figure(2)
        subplot(paramDims(1),paramDims(2),p)
        plot(t,stf)
        
        title({"f_{max}: " + f_max + " Hz     h_i: " + h_i + " m     h_w: " + h_w + " m     t_0 = " + t0 + " s",''})
        xlabel('Time (s)'); ylabel('Moment/m_0');
        xlim([0,t_max])
        
        clear('dGdt','t')
        
        % advance counter
        p = p + 1;
    end
end