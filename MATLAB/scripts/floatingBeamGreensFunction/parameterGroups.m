% define basic parameters
statDist = 10000;
L = 1e7;
f_max = 2;
t_max = 25;
h_w = 200;

% set parameters that might get varied [h_i,h_w;...]
start = [200,h_w];
step = [200,0];
numSteps = 5;

% set up colored lines
c = hot(floor(numSteps*3));

 for s = 1:numSteps
     
    % set parameters
    h_i = start(1)+s*step(1);
    h_w = start(2)+s*step(2);
    
    % run model
    [model,dGdt,G_scaled,stf] = calcGF(L,f_max,t_max,h_i,h_w,statDist,"moment",0,'none',1);

    % flexural wavelength
    lambda = (model.D/(model.rho_w*model.g))^(1/4);
    
    % buoyancy oscillation
    N = ((model.rho_w*model.g)/(model.rho_i*model.h_i))^(1/2);

    % plot the parameter groups
    subplot(1,4,1:2)
    scatter(N,lambda,50,c(s,:),'filled')
    hold on
    
    % plot the waveform
    subplot(1,4,3:4)
    plot(dGdt/max(abs(dGdt))+2*s,'Color',c(s,:))
    legend;
    hold on;
    
    %pause(2);
    
 end