% this code runs a version of P. Segall's mcmc code adapted for fitting the beam deflection
% Green's function with observed seismic data

% set output path
path = "/home/setholinger/Documents/Projects/PIG/location/mcmc/";

% load arrival times
load("arrivals.mat")

% set mcmc parameters
% x0 goes like this: [lat,lon,origin (seconds after startTime),vel]
vel = 3.5;
startTime = "2012-05-09 17:50:00";
endTime = "2012-05-09 17:55:00";
startTime = datetime(startTime,'Format','yyyy-MM-dd HH:mm:ss.SSS');
endTime = datetime(endTime,'Format','yyyy-MM-dd HH:mm:ss.SSS');
arrivals = seconds(arrivalsDatetime-startTime);
arrivals(3) = arrivals(3) - 2;
x0 = [-75,-102,80,vel];
xStep = [0.1,0.1,1,0.1];
xBounds = [-75.5,-74.5; 
           -103,-99;
           0,seconds(endTime-startTime);
           3,4;];
sigma = 0.0075;
numIt = 100000;
axisLabels = ["Latitude", "Longitude", "Origin Time","Velocity (km/s)"];
paramLabels = ["lat","lon","origin","vel"];
maxNumBins =  100;

tic;

% record which two parameters will be varied this run
paramInd = [1,2,3,4];

paramsVaried = paramInd(xStep ~= 0);

c = 1;

% generate intial Green's function
synthetic_arrivals_0 = loc_func_mcmc(x0,statLoc);

% calculate initial liklihood
L0 = liklihood_loc(synthetic_arrivals_0,arrivals,sigma);

% run mcmc
[x_keep,L_keep,count,alpha_keep,accept] = mcmc_loc('loc_func_mcmc',arrivals,...
                                          x0,xStep,xBounds,sigma,numIt,L0,statLoc);

% give output
fprintf("Accepted " + round((sum(accept)/numIt)*100) + " %% of proposals\n");

% make plots for bivariate runs
if length(paramsVaried) == 2

    % get number of bins
    numBins = maxNumBins;

    xFit = getFit(x_keep,paramsVaried,numBins,x0);

    % generate Green's function
    synthetic_arrivals_fit = loc_func_mcmc(xFit,statLoc);

    % calculate liklihood
    L_fit = liklihood_loc(synthetic_arrivals_fit,arrivals,sigma);

    % call plotting functions
    plot_bivar_loc(x_keep,x0,numIt,p,paramsVaried,axisLabels,paramLabels,maxNumBins,path)
   
    % save results
    resultStruct = struct('xFit',xFit,'L_fit',L_fit,'synthetic_arrivals_fit',...
                          synthetic_arrivals_fit,'synthetic_arrivals_0',synthetic_arrivals_0,...
                          'L_keep',L_keep,'x_keep',x_keep,'x0',x0,'xStep',xStep,...
                          'xBounds',xBounds,'sigma',sigma,'numIt',numIt,'labels',paramLabels);
    parsave(path + "results.mat",resultStruct)   

else

    % call plotting functions
    plot_multivar_loc(sigma,accept,xStep,x_keep,x0,numIt,....
                  paramsVaried,axisLabels,maxNumBins,path)

    % save results
    resultStruct = struct('synthetic_arrivals_0',synthetic_arrivals_0,'L_keep',L_keep,...
                          'x_keep',x_keep,'x0',x0,'xStep',xStep,'xBounds',xBounds,...
                          'sigma',sigma,'numIt',numIt,'labels',paramLabels,'accept',accept);
    parsave(path + "results.mat",resultStruct)

end

runtime = toc;