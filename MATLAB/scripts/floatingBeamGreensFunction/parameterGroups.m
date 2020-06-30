% define basic parameters
statDist = 10000;
L = 1e7;
f_max = 2;
t_max = 100;
h_w = 250;
h_i = 10;

% set parameters that might get varied [h_i,h_w;...]
start = [h_i,h_w];
step = [100,0];
numSteps = 5;

% set up colored lines
c = hot(floor(numSteps*3));

for s = 1:numSteps
     
    % set parameters
    h_i = start(1)+s*step(1);
    h_w = start(2)+s*step(2);
    
    % get max pressure and moment
    M_max =  916 * 9.8 * h_i^3 / 12 * 0.072;

    % make model object
    model = loadParameters(L,f_max,t_max,h_i,h_w);

    % get index of desired position
    [~,locIdx] = min(abs(model.x - statDist));

    % flexural wavelength    
    model.E = model.E/(model.h_i)^3; 
    model.D = model.E * (model.h_i^3)/12/(1-model.nu^2);	% Flexural Rigidity
    model.D = model.D^1.75;
    lambda = (model.D/(model.rho_w*model.g))^(1/4);
    
    % run model
    G = semiAnalyticGreenFunction(model);

    % take spatial derivative
    [~,dGdx] = gradient(G,model.dx);

    % scale by ice front bending moment
    G_scaled = dGdx * M_max;         

    % get trace closest seismometer location
    G_scaled = G_scaled(locIdx,:);
    
    % take time derivative to get velocity seismogram
    dGdt = gradient(G_scaled,model.dt);
    
    % buoyancy oscillation
    N = ((model.rho_w*model.g)/(model.rho_i*model.h_i))^(1/2);

    % shallow water wave speed
    c_w = sqrt(model.g*model.h_w);
    
    % buoyancy oscillation only
    figure(1)
    % plot the parameter groups
    subplot(1,4,1:2)
    scatter(lambda,N,50,c(s,:),'filled')
    text(lambda-1,N+0.005,'A_{max}: '+ string(max(abs(dGdt))),'Color',c(s,:))
    ylabel("N (Hz)") 
    xlabel("\lambda (m)") 
    hold on
    % plot the waveform
    subplot(1,4,3:4)
    plot(model.t,dGdt/max(abs(dGdt))-2*s,'Color',c(s,:))
    yticklabels(gca,{})   
    yticks({}) 
    xlabel("Time (s)")
    hold on;
 
end
figure(1)
sgtitle({"Influence of Buoyancy Oscillation Frequency N"})

% define basic parameters
statDist = 10000;
L = 1e7;
f_max = 2;
t_max = 100;
h_w = 250;
h_i = 100;

% set parameters that might get varied [h_i,h_w;...]
start = [h_i,h_w];
step = [0,0];
E_step = 1e9;
numSteps = 5;
 
for s = 1:numSteps
   
    % set parameters
    h_i = start(1)+s*step(1);
    h_w = start(2)+s*step(2);
    
    % get max pressure and moment
    M_max =  916 * 9.8 * h_i^3 / 12 * 0.072;

    % make model object
    model = loadParameters(L,f_max,t_max,h_i,h_w);

    % get index of desired position
    [~,locIdx] = min(abs(model.x - statDist));
    
    % flexural wavelength
    model.E = model.E*s*s; 
    model.D = model.E * (model.h_i^3)/12/(1-model.nu^2);	% Flexural Rigidity
    lambda = (model.D/(model.rho_w*model.g))^(1/4);
    
    % run model
    G = semiAnalyticGreenFunction(model);

    % take spatial derivative
    [~,dGdx] = gradient(G,model.dx);

    % scale by ice front bending moment
    G_scaled = dGdx * M_max;         

    % get trace closest seismometer location
    G_scaled = G_scaled(locIdx,:);
    
    % take time derivative to get velocity seismogram
    dGdt = gradient(G_scaled,model.dt);
    
    % buoyancy oscillation
    N = ((model.rho_w*model.g)/(model.rho_i*model.h_i))^(1/2);

    % shallow water wave speed
    c_w = sqrt(model.g*model.h_w);
     
    % flexural length only
    figure(2)
    % plot the parameter groups
    subplot(1,4,1:2)
    scatter(N,lambda,50,c(s,:),'filled')
    text(-0.5,lambda+20,'A_{max}: '+ string(max(abs(dGdt))),'Color',c(s,:))
    ylabel("\lambda (m)") 
    xlabel("N (Hz)") 
    hold on
    % plot the waveform
    subplot(1,4,3:4)
    plot(model.t,dGdt/max(abs(dGdt))+2*s,'Color',c(s,:))
    yticklabels(gca,{})
    yticks({})
    xlabel("Time (s)")
    hold on;
    
end
figure(2)
sgtitle("{Influence of Flexural Gravity Length \lambda}")

 
% define basic parameters
statDist = 10000;
L = 1e7;
f_max = 2;
t_max = 100;
h_w = 1;
h_i = 250;

% set parameters that might get varied [h_i,h_w;...]
start = [h_i,h_w];
step = [0,50];
numSteps = 5;
 
for s = 0:numSteps    
    
    % set parameters
    h_i = start(1)+s*step(1);
    h_w = start(2)+s*step(2);
    
    % get max pressure and moment
    M_max =  916 * 9.8 * h_i^3 / 12 * 0.072;

    % make model object
    model = loadParameters(L,f_max,t_max,h_i,h_w);

    % get index of desired position
    [~,locIdx] = min(abs(model.x - statDist));

    % run model
    G = semiAnalyticGreenFunction(model);

    % take spatial derivative
    [~,dGdx] = gradient(G,model.dx);

    % scale by ice front bending moment
    G_scaled = dGdx * M_max;         

    % get trace closest seismometer location
    G_scaled = G_scaled(locIdx,:);
    
    % take time derivative to get velocity seismogram
    dGdt = gradient(G_scaled,model.dt);
    
    % flexural wavelength
    lambda = (model.D/(model.rho_w*model.g))^(1/4);
    
    % buoyancy oscillation
    N = ((model.rho_w*model.g)/(model.rho_i*model.h_i))^(1/2);

    % shallow water wave speed
    c_w = sqrt(model.g*model.h_w);
    
    % shallow water wave speed only
    figure(3)
    % plot the parameter groups
    subplot(1,4,1:2)
    scatter(N,h_w,50,c(s+1,:),'filled')
    text(-0.5,h_w+10,'A_{max}: '+ string(max(abs(dGdt))),'Color',c(s+1,:))
    ylabel("h_w (m)") 
    xlabel("N (Hz)")
    hold on
    % plot the waveform
    subplot(1,4,3:4)
    plot(model.t,dGdt/max(abs(dGdt))+2*s,'Color',c(s+1,:))
    yticklabels(gca,{})
    yticks({})
    xlabel("Time (s)")
    hold on;
    
end
figure(3)
sgtitle("Influence of Water Depth h_w")