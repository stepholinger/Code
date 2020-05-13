% set parameters which stay constant
statDist = 10000;
L = 1e7;
f_max = 1;
t_max = 500;
h_i = 350;
h_w = 800;
%t0 = 6;
sourceType = 'moment';
pulseType = 'half up';
scale = 0.025;

% manually set parameters for each subplot
params = {{f_max,t_max,h_i,h_w,statDist,1,pulseType,scale};{f_max,t_max,h_i,h_w,statDist,3,pulseType,scale};...
          {f_max,t_max,h_i,h_w,statDist,6,pulseType,scale};{f_max,t_max,h_i,h_w,statDist,10,pulseType,scale}};
        
% get dimensions of parameter matrix
paramDims = size(params);

% make counter for subplot number
p = 1;

% run the model for each parameter set
for i = 1:paramDims(1)
    for j = 1:paramDims(2)
        
        % for all iterations but the first, see if any key model parameters
        % changed since the last run
        if i + j ~= 2            
            if f_max == params{i,j}{1} && t_max == params{i,j}{2} &&...
               h_i == params{i,j}{3} && h_w == params{i,j}{4} && statDist == params{i,j}{5}
                % give output
                fprintf("Parameters unchanged- skipping model!\n")
                
                % set parameters
                t0 = params{i,j}{6};
                pulseType = params{i,j}{7};

                % run model
                [model,dGdt,G_scaled,stf] = calcGF(L,f_max,t_max,h_i,h_w,statDist,sourceType,t0,pulseType,scale,G_scaled);
            else
                % give output
                fprintf("Parameters updated- running model!\n")
                
                % set parameters
                f_max = params{i,j}{1};        
                t_max = params{i,j}{2};
                h_i = params{i,j}{3};
                h_w = params{i,j}{4};
                statDist = params{i,j}{5};
                t0 = params{i,j}{6};
                pulseType = params{i,j}{7};
                scale = params{i,j}{8};
                
                % run model
                [model,dGdt,G_scaled,stf] = calcGF(L,f_max,t_max,h_i,h_w,statDist,sourceType,t0,pulseType,scale);
            end
        else
            % give output
            fprintf("First iteration- running model!\n")
            
            f_max = params{i,j}{1};        
            t_max = params{i,j}{2};
            h_i = params{i,j}{3};
            h_w = params{i,j}{4};
            statDist = params{i,j}{5};
            t0 = params{i,j}{6};
            pulseType = params{i,j}{7};
            scale = params{i,j}{8};
            
            % run model
            [model,dGdt,G_scaled,stf] = calcGF(L,f_max,t_max,h_i,h_w,statDist,sourceType,t0,pulseType,scale);
        end
        
        % get model time axis
        t = model.t;
        
        % set the correct subplot
        figure(1)
        subplot(paramDims(1),paramDims(2),p)
        plot(t,detrend(dGdt))
        
        title({"Distance: " + round(statDist/1000) + " km     h_i: " + h_i + " m     h_w: " + h_w + " m     t_0 = " + t0 + " s"})
        xlabel('Time (s)'); ylabel('Vertical Velocity (m/s)');
        xlim([0,t_max])
        
        figure(2)
        subplot(paramDims(1),paramDims(2),p)
        plot(t,stf)
        
        title({"Distance: " + round(statDist/1000) + " km     h_i: " + h_i + " m     h_w: " + h_w + " m     t_0 = " + t0 + " s"})
        xlabel('Time (s)'); ylabel('Moment/m_0');
        xlim([0,t_max])
        
        clear('dGdt','t')
        
        % advance counter
        p = p + 1;
    end
end