x0_vect = [80,600,6500,6,0.5,250;...
         85,450,6000,6,0.5,250;...
         100,450,6500,7.5,0.5,250;...
         80,600,5750,6,0.5,250;...
         80,600,6500,6.75,0.5,250;...
         80,450,7000,6,0.5,250];
axisLabels = ["Ice thickness (m)", "Water depth (m)", "X_{stat} (km)","t_0 (s)"];
paramLabels = ["h_i","h_w","Xstat","t0"];
paramsVariedVect = [1,2;1,3;1,4;2,3;2,4;3,4];
stepVect = [10,100;10,400;10,0.5;100,400;-100,0.075;-700,0.5];
numSteps = 5;
maxNumBins = 100;

for n = 1:length(paramsVariedVect)

    paramsVaried = paramsVariedVect(n,:);
    step = [0,0,0,0,0,0];
    step(paramsVaried(1)) = stepVect(n,1);
    step(paramsVaried(2)) = stepVect(n,2);

    % get starting point from x0
    x0 = x0_vect(n,:);
    x_start = x0 - numSteps/2*step;

    % get number of bins
    numBins = length(unique(x_keep(paramsVaried(1),:)));
    if numBins > maxNumBins
        numBins = maxNumBins;
    end
    
    % make figure
    figure(n)
    subplot(1,4,1:2)
    hold on; 
    
    % make dscatter
    dscatter(x_keep(paramsVaried(1),:)',x_keep(paramsVaried(2),:)','BINS',[numBins,numBins]);

    % force full outlines
    box on;

    % remove x-axis labels if current subplot does not fall along
    % edge of plot grid
    xlabel(axisLabels(paramsVaried(1)));
    ylabel(axisLabels(paramsVaried(2)));

    for i = 1:numSteps

        % get point
        x = x_start + (i-1) * step;
        
        % generate Green's function
        [G,eventAlign,M_fit] = GF_func_mcmc(x,eventTraceTrim);
        
        % convert x_stat to km
        x(3) = x(3)/1000;
        
        % plot points on dscatter plot
        subplot(1,4,1:2)
        scatter(x(paramsVaried(1)),x(paramsVaried(2)))
        hold on;
        
        % make plot of all traces
        subplot(1,4,3:4)
        plot(G)
        legend;
        hold on;
        
    end
    
end