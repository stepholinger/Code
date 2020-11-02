% this code runs a version of P. Segall's mcmc code adapted for fitting the beam deflection
% Green's function with observed seismic data

% set output path
path = "/home/setholinger/Documents/Projects/PIG/modeling/mcmc/";

% set some parameters
statDist = 10000;
t0 = 2;
f_max = 0.5;
t_max = 150;

% set crevasse height stuff- these values range from -0.5 to 0.5
h_c_initial = -0.02;
h_c_final = 0.02;

% construct some variables
t = 1/(2*f_max):1/(2*f_max):t_max;
nt = t_max*(2*f_max);

% get real data
centroid = 0;
numCluster = 10;
centroid_fs = 2;
if centroid
    centroids = h5read(numCluster + "_cluster_predictions_0.05-1Hz.h5","/centroids");
    centroids = squeeze(centroids)';
    medAmps = h5read(numCluster + "_cluster_median_amplitudes.h5","/median_amplitudes");
    centroid_win = [400,900;1,500;100,600;100,300;200,700;200,700;400,900;0,500;0,500;400,900];
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

% set mcmc parameters
% x0 goes like this:
% [h_i,h_w,statDist,t0,h_c_initial,h_c_final,f_max,t_max]
% f_max and t_max MUST have 0 step size in xStep
% t0 is log now! so the value here is like 10^x
%ratio between step and bounds should be the same for each parameter (.025)
%x0_vect = {[350,600,statDist,log10(t0),h_c_initial,h_c_final,f_max,t_max]};
x0 = [350,600,statDist,log10(t0),h_c_initial,h_c_final,f_max,t_max];
x0 = [350,600,20000,log10(10),-0.08,0.1,f_max,t_max];
xStepVect = {[0,0,500,log10(1.1416),0.025,0.025,0,0]};

% calculate model dx (bound on station distance)
model = loadParameters(1e7,f_max,t_max,x0(1),x0(2));
dx = model.dx;

xBounds = [0,1000;
           0,1000;
           dx,30000;
           log10(f_max/2),2;
           -0.5,0.5;
           -0.5,0.5;
           0,f_max+1;
           0,t_max+1;];
sigmaVect = [100];
t_max_vect = [t_max];
numIt = 100000;
L_type_vect = ["xcorr"];
axisLabels = ["Ice thickness (m)", "Water depth (m)", "X_{stat} (km)",...
    "t_0 (s)","Initial h_c (% ice thickness)","Final h_c (% ice thickness)"];
paramLabels = ["h_i","h_w","Xstat","t0","h_c_initial","h_c_final"];
maxNumBins =  100;

tic;

%for p = 1:length(sigmaVect) 
for p = 1:1
    
    % get parameters for run
    xStep = xStepVect{1};
    sigma = sigmaVect(1);
    L_type = L_type_vect(1);
    t_max = t_max_vect(1);
    %x0 = x0_vect{1};

    % get current centroid and scale by median cluster amplitude
    if centroid
        
        eventTrace = centroids(p,centroid_win(p,1):centroid_win(p,2));
        eventTrace = eventTrace/max(abs(eventTrace));
        eventTrace = eventTrace*medAmps(p);
        
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
    paramInd = [1,2,3,4,5,6,7,8];
    paramsVaried = paramInd(xStep ~= 0);
    
    % deal with log t0
    x0(4) = 10^(x0(4));
    
    % generate intial Green's function
    [G_0,corrCoef] = GF_func_mcmc(x0,eventTraceTrim);

    % deal with log t0
    x0(4) = log10(x0(4));
    
    % calculate initial liklihood
    L0 = liklihood(G_0,eventTraceTrim,sigma,L_type,corrCoef);
    
    % run mcmc
    [x_keep,L_keep,count,alpha_keep,accept] = mcmc('GF_func_mcmc',eventTraceTrim,...
                                              x0,xStep,xBounds,sigma,numIt,L0,L_type);
                                          
    % give output
    fprintf("Accepted " + round((sum(accept)/numIt)*100) + " %% of proposals\n");

    % convert X_stat to km
    x_keep(3,:) = x_keep(3,:)/1000;

    % 'unlog' t0
    x_keep(4,:) = 10.^x_keep(4,:);
    x0(4) = 10^(x0(4));
    
    % convert crevasse heights to percentage
    x_keep(5:6,:) = 100*(0.5+x_keep(5:6,:));
    
    % call plotting functions
    plot_multivar(sigma,accept,xStep,x_keep,x0,numIt,....
                  p,paramsVaried,axisLabels,maxNumBins,L_type,path,f_max,t_max)

    % save results
    resultStruct = struct('G_0',G_0,'L_keep',L_keep,'x_keep',x_keep,'x0',x0,...
                          'xStep',xStep,'xBounds',xBounds,'L_type',L_type,...
                          'sigma',sigma,'numIt',numIt,'labels',paramLabels,'accept',accept,...
                          'f_max',f_max,'t_max',t_max);
    if centroid
        parsave(path + "centroid" + p + "_results.mat",resultStruct)
    else
        parsave(path + "centroid" + p + "_results.mat",resultStruct)
    end

end

runtime = toc;