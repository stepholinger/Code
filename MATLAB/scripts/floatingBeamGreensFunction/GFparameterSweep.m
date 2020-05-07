% clear parameters
clear;

% set space and time parameters
L = 1e7;
f_max = 10;
t_max = 1000;
nt = f_max * t_max;

% set station distance in meters
statDist = 15e3;

% make vector of ice thicknesses
h_i_vect = 400:100:600;

% make vector of water depths
h_w_vect = 400:100:600;

% choose whether to reverse polarity when max model amplitude is negative
polarity = 0;

% choose whether to plot data or not
data = 1;

% choose whether to iterate through applied pressure / moment amplitude
amplitudeStep = 0;

% make big matrix of parameters
params = [];

for i = 1:length(h_i_vect)
    for j = 1:length(h_w_vect) 
        
            % estimate max pressure and moment
            P_max = 916 * 9.8 * h_i_vect(i);
            M_max =  916 * 9.8 * h_i_vect(i)^3 / 12 * 0.072;

            if amplitudeStep

                % if iterating through amplitudes, make vector of pressures and moments
                M_vect = M_max/10:M_max/10:M_max;
                P_vect = P_max/10:P_max/10:P_max;

                % make parameter matrix with all values of pressure and moment
                for k = 1:length(P_vect)
                    params = [params;[h_i_vect(i),h_w_vect(j),P_vect(k),0]];           
                    params = [params;[h_i_vect(i),h_w_vect(j),0,M_vect(k)]];      
                end
                
            % make parameter matrix with max pressure and max moment only  
            else
                params = [params;[h_i_vect(i),h_w_vect(j),P_max,0]];           
                params = [params;[h_i_vect(i),h_w_vect(j),0,M_max]];   
            end
    end
end

if data
    % read in real data
    fname = "/media/Data/Data/PIG/MSEED/noIR/PIG2/HHZ/2012-04-02.PIG2.HHZ.noIR.MSEED";
    dataStruct = rdmseed(fname);
    trace = extractfield(dataStruct,'d');
    fs = 100;

    % resample data to 1 Hz
    fsNew = f_max;
    trace = resample(trace,fsNew,100);

    % set event bounds
    startTime = ((15*60+18)*60+50)*fsNew;
    endTime = startTime + nt;
    
    % trim data to event bounds
    eventTrace = trace(startTime:endTime-1);

    % remove scalar offset using first value
    eventTrace = eventTrace - eventTrace(1);

    % find index of max value
    if abs(min(eventTrace)) > max(eventTrace)
        [dataMax,dataMaxIdx] = min(eventTrace);
    else
        [dataMax,dataMaxIdx] = max(eventTrace);
    end
        
end

% make matrix for waveforms
waveforms = zeros(length(params),nt);

% run model for each parameter combination
for i = 1:length(params)
        
    % get parameters for this run
    h_i = params(i,1);
    h_w = params(i,2);
    P = params(i,3);
    M = params(i,4);   

    % get max pressure and moment
    P_max = 916 * 9.8 * h_i;
    M_max =  916 * 9.8 * h_i^3 / 12 * 0.072;

    % run model on first iteration
    if i == 1
        % make model object
        model = loadParameters(L,f_max,t_max,h_i,h_w);
        
        % run model
        G = semiAnalyticGreenFunction(model);
    else
        % subsequently, only re-run model when h_i or h_w change
        if params(i,1) ~= params(i-1,1) || params(i,2) ~= params(i-1,2)

            % make model object
            model = loadParameters(L,f_max,t_max,h_i,h_w);

            % run model
            G = semiAnalyticGreenFunction(model);
            
        end
    end
    
    % nonzero M indicates moment
    if M
        % take spatial derivative
        [~,dGdx] = gradient(G,model.dx);
        
        % scale by ice front bending moment
        G_scaled = dGdx * M;  
            
        % make filename with parameters
        fname = "h_i=" + h_i + ";h_w=" + h_w + ";M=" + M/M_max + ".png";

    % zero M indicates point pressure
    else
        
        % scale by pressure magnitude
        G_scaled = G * P;  
                  
        % make filename with parameters
        fname = "h_i=" + h_i + ";h_w=" + h_w + ";P=" + P/P_max + ".png";

    end
       
    % take time derivative to get velocity seismogram
    [dGdt,~] = gradient(G_scaled,model.dt);
    
    % get trace closest seismometer location
    [~,locIdx] = min(abs(model.x - statDist));
    dGdt = dGdt(locIdx,:);
    
    % demean the trace
    dGdt = dGdt-mean(dGdt);
    
    % find index of max value
    if abs(min(dGdt)) > max(dGdt)
        [modelMax,modelMaxIdx] = min(dGdt);
    else
        [modelMax,modelMaxIdx] = max(dGdt);
    end
    
    if data
        % align maximum values by padding with zeros
        if modelMaxIdx > dataMaxIdx
            slide = modelMaxIdx-dataMaxIdx;
            eventTrace = [zeros(1,slide),eventTrace(1:end-slide)];
        else
            slide = dataMaxIdx-modelMaxIdx;
            dGdt = [zeros(1,slide),dGdt(1:end-slide)];
        end    

        % reverse polarity of model
        if polarity
            if modelMax < 0 && dataMax > 0
                dGdt = dGdt * -1;
            elseif modelMax > 0 && dataMax < 0
                dGdt = dGdt * -1;
            end
        end
    end
    
    % save waveforms
    waveforms(i,:) = dGdt;
    
    % make plot of real data and model output
    if data
        plot(model.t,eventTrace)
        hold on;
    end
    plot(model.t,dGdt)
    if M
        title("h_i: " + h_i + " m     h_w: " + h_w + " m     M: " + M/M_max + "*M_0")
    else
        title("h_i: " + h_i + " m     h_w: " + h_w + " m     P: " + P/P_max + "*\rho_igh_i")
    end
    xlabel('Time (s)'); ylabel('Vertical Velocity (m/s)');
    saveas(gcf,"/home/setholinger/Documents/Projects/PIG/modeling/paramSweep/param4/" + fname)
    hold off;
    clf
            
end