% this code runs a version of P. Segall's mcmc code adapted for fitting the beam deflection
% Green's function with observed seismic data

% set output path
path = "/home/setholinger/Documents/Projects/PIG/modeling/mcmc/";

% set some parameters
statDist = 1000;
t0 = 5.5;
f_max = 1;
t_max = 100;
h_i_avg = 400;
h_w_avg = 590;
freq = [0.05,1];

% construct some variables
t = 1/(2*f_max):1/(2*f_max):t_max;
nt = t_max*(2*f_max);

% set flag for toy problem
test = 0;

% get real data
centroid = 1;
numCluster = 14;
centroid_fs = 2;
if centroid
    %centroids = h5read(numCluster + "_cluster_predictions_0.05-1Hz.h5","/centroids");
    centroids = h5read(numCluster + "_cluster_predictions_0.05-1Hz.h5","/centroids");
    centroids = squeeze(centroids)';
    
    % get just vertical
    centroids = centroids(:,1:1001);
    %medAmps = h5read(numCluster + "_cluster_median_amplitudes.h5","/median_amplitudes");
    centroid_win = [400,900;1,500;100,600;150,350;200,700;200,700;400,900;0,500;0,500;400,900];
else
    
    fname = "/media/Data/Data/PIG/MSEED/noIR/PIG2/HHZ/2012-04-02.PIG2.HHZ.noIR.MSEED";
    dataStruct = rdmseed(fname);

    % extract trace
    trace = extractfield(dataStruct,'d');
    fs = 100;

    % resample data to 1 Hz
    fsNew = f_max*2;
    trace = resample(trace,fsNew,100);

    % set event bounds
    startTime = ((15*60+18)*60+50)*fsNew;
    endTime = startTime + nt;

    % trim data to event bounds
    eventTrace = trace(startTime:endTime-1);

    % remove scalar offset using first value
    eventTrace = eventTrace - eventTrace(1);
    
    % find index of max value
    [~,dataMaxIdx] = max(eventTrace);
end

% if toy problem mode, set waveform to recover
if test
    testParams = [450,600,statDist,t0,f_max,t_max];
    [eventTrace,~] = GF_func_mcmc(testParams,eventTrace);
    % find index of max value
    [~,dataMaxIdx] = max(eventTrace);
end

% set mcmc parameters
% x0 goes like this: [h_i,h_w,statDist,t0,f_max,t_max,dataMaxIdx]
% f_max, t_max, and dataMaxIdx MUST have 0 step size in xStep
% t0 is log now! so the value here is like 10^x
x0_vect = {[h_i_avg,h_w_avg,20000,1,f_max,t_max]};
xStepVect = {[0,0,1000,0.5,0,0]};

%             {[10,10,4,log10(1.1),0,0],...
%             [25,25,500,log10(1.1885),0,0],...
%             [100,100,2000,log10(1.9953),0,0],...
%             [400,400,8000,log10(15.8489),0,0]};

xBounds = [0,2000;
           0,2000;
           0,40000;
           0,20;
           0,f_max+1;
           0,t_max+1;];
sigmaVect = [5];
t_max_vect = [t_max];
numIt = 10000;
L_type_vect = ["modified"];
axisLabels = ["Ice thickness (m)", "Water depth (m)", "X_{stat} (km)","t_0 (s)"];
paramLabels = ["h_i","h_w","Xstat","t0"];
maxNumBins =  100;

%try
%    parpool;
%    poolobj = gcp;
%catch
%    fprintf("Using existing parpool...\n")
%end

tic;

%parfor p = 1:length(sigmaVect)
%for p = 1:length(sigmaVect) 
for p = 4:4
    
    % get parameters for run
    xStep = xStepVect{1};
    sigma = sigmaVect(1);
    L_type = L_type_vect(1);
    t_max = t_max_vect(1);
    x0 = x0_vect{1};

    % get current centroid and scale by median cluster amplitude
    if centroid
        
        eventTrace = centroids(p,centroid_win(p,1):centroid_win(p,2));
        eventTrace = eventTrace/max(abs(eventTrace));
        %eventTrace = eventTrace*medAmps(p);
        eventTrace = eventTrace*1e-5;

        % resample centroid
        if f_max < 1
            centroid_fs = centroid_fs/f_max;
            eventTrace = resample(eventTrace,2,centroid_fs);
        else
            eventTrace = resample(eventTrace,f_max*2,centroid_fs);
        end
        % find index of max value
        [~,dataMaxIdx] = max(eventTrace);
    end
    
    % trim data if needed
    t = 1/(2*f_max):1/(2*f_max):t_max;
    nt = t_max*(2*f_max);
    eventTraceTrim = eventTrace(1:nt);
    
    % record which two parameters will be varied this run
    paramInd = [1,2,3,4,5,6];
    paramsVaried = paramInd(xStep ~= 0);
    
    % deal with log t0
    %x0(4) = 10^(x0(4));
    
    % generate intial Green's function
    [G_0,eventAlign,M_frac_0] = GF_func_mcmc(x0,eventTraceTrim,freq);

    % deal with log t0
    %x0(4) = log10(x0(4));
    
    % calculate initial liklihood
    L0 = liklihood(G_0,eventAlign,sigma,L_type);
    
    % run mcmc
    [x_keep,L_keep,count,alpha_keep,accept,M_frac] = mcmc('GF_func_mcmc',eventTraceTrim,...
                                              x0,xStep,xBounds,sigma,numIt,M_frac_0,L0,L_type,freq);
                                          
    % give output
    fprintf("Accepted " + round((sum(accept)/numIt)*100) + " %% of proposals\n");
    
    % make plots for bivariate runs
    if length(paramsVaried) == 2

        % 'unlog' t0
        %x_keep(4,:) = 10.^x_keep(4,:);
        %x0(4) = 10^(x0(4));
       
        % get number of bins
        numBins = length(unique(x_keep(paramsVaried(1),:)));
        if numBins > maxNumBins
            numBins = maxNumBins;
        end

        % get best fit parameters- use log if t0
        %if paramsVaried(1) == 4
        %    xFit = getFitLog(x_keep,paramsVaried,numBins,x0,'x');
        %elseif paramsVaried(2) == 4
        %    xFit = getFitLog(x_keep,paramsVaried,numBins,x0,'y');
        %else
        %    xFit = getFit(x_keep,paramsVaried,numBins,x0);
        %end
        xFit = getFit(x_keep,paramsVaried,numBins,x0);

        % generate Green's function
        [G_fit,eventAlign,M_fit] = GF_func_mcmc(xFit,eventTraceTrim,freq);
        
        % calculate liklihood
        L_fit = liklihood(G_fit,eventAlign,sigma,L_type);

        % convert X_stat to km
        x_keep(3,:) = x_keep(3,:)/1000;
       
        % call plotting functions
        plot_bivar(x_keep,x0,numIt,p,paramsVaried,axisLabels,paramLabels,maxNumBins,path)
        plot_M_frac(x_keep,M_frac,x0,numIt,p,paramsVaried,axisLabels,paramLabels,maxNumBins,path)
        plot_start_wave(t,eventAlign,sigma,L0,M_frac_0,G_0,x0,numIt,xStep,p,path)
        plot_fit_wave(t,eventAlign,sigma,L_fit,M_fit,G_fit,xFit,numIt,xStep,p,accept,L_type,path)
        plot_multivar(sigma,accept,xStep,x_keep,M_frac,x0,numIt,....
              p,paramsVaried,axisLabels,maxNumBins,L_type,path,f_max,t_max)
    
        resultStruct = struct('xFit',xFit,'L_fit',L_fit,'G_fit',G_fit,'G_0',G_0,'L_keep',L_keep,...
                              'x_keep',x_keep,'x0',x0,'xStep',xStep,'M_frac',M_frac,'L_type',L_type,...
                              'xBounds',xBounds,'sigma',sigma,'numIt',numIt,'labels',paramLabels);
        if centroid
            parsave(path + "centroid" + string(p-1) + "_results.mat",resultStruct)
        else
            parsave(path + "run" + p + "_results.mat",resultStruct)
        end
        
    else

        % convert X_stat to km
        x_keep(3,:) = x_keep(3,:)/1000;
        
        % 'unlog' t0
        %x_keep(4,:) = 10.^x_keep(4,:);
        %x0(4) = 10^(x0(4));
            
        % call plotting functions
        plot_multivar(sigma,accept,xStep,x_keep,M_frac,x0,numIt,....
                      p,paramsVaried,axisLabels,maxNumBins,L_type,path,f_max,t_max)
        
        % save results
        resultStruct = struct('G_0',G_0,'L_keep',L_keep,'x_keep',x_keep,'x0',x0,...
                              'xStep',xStep,'M_frac',M_frac,'xBounds',xBounds,'L_type',L_type,...
                              'sigma',sigma,'numIt',numIt,'labels',paramLabels,'accept',accept,...
                              'f_max',f_max,'t_max',t_max);
        if centroid
            parsave(path + "centroid" + string(p-1) + "_results.mat",resultStruct)
        else
            parsave(path + "centroid" + p + "_results.mat",resultStruct)
        end
        
    end
    
end

runtime = toc;