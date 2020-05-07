eventNum = 1079184;

pulseLogical = 0;
corr = 1;

%set station/component and some file parameters
stat = ["PIG2","PIG3","PIG4"];
chan = ["HHZ","HHN","HHE"];
numStat = length(stat);
numChan = length(chan);
fs = 100;
maxLength = minutes(1);
fileLength = 86400*fs;

% set path to data
path = "/media/Data/Data/PIG/SAC/noIR/";

% load list of detection start and end times
load("/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/detections/ML/10-20Hz/2sGap/splitDetections2nd.mat")

det = detections;
%det = toss;
%det = keep;

% calculate event durations
durations = det(:,2) - det(:,1);

% remove detection windows over one minute in length and with no length
det = det(durations < maxLength & durations ~= duration(0,0,0),:);

% choose filter band and design filter
freq = [10,20];
[b,a] = butter(4,freq/(fs/2),'bandpass');

% choose master event
event = det(eventNum,:);

% get date of master event
[y,m,d] = ymd(event(1));
if m < 10 && d > 10
    eventDate = string(y + "-0" + m + "-" + d);
elseif m > 10 && d < 10
    eventDate = string(y + "-" + m + "-0" + d);
elseif d < 10 && m < 10
    eventDate = string(y + "-0" + m + "-0" + d);
else
    eventDate = string(y + "-" + m + "-" + d);
end

% get index of event bounds
eventIdx = round(seconds(event - datetime(eventDate)))*fs;
eventDuration = eventIdx(2) - eventIdx(1);

% make gaussian pulse of appropriate length
pulseDuration = 500;
t = 0:1/fs:pulseDuration/fs;
center =  pulseDuration/fs/2;
fc = mean(freq);
hw = 500;
pulse = gauspuls(t-center,fc,hw/pulseDuration)';

comp = 1;
sum = 0;
count = 0;

for s = 1:numStat
    
    for c = 1:numChan

        try

            % read in file for that day
            fname = path + stat(s) + "/" + chan(c) + "/" + eventDate + "." + stat(s) + "." + chan(c) + ".noIR.SAC";
            data = readsac(fname);

            % pull out the master event waveform
            trace = filtfilt(b,a,data.trace);
            wave = trace(eventIdx(1):eventIdx(2)-1);
            
            if corr
          
                if pulseLogical
                    % pad with zeros
                    if length(pulse) > length(wave)
                        wave = [wave;zeros(length(pulse)-length(wave),1)];
                    else
                        pulse = [pulse;zeros(length(wave)-length(pulse),1)];
                    end

                    % correlate with gaussian pulse for testing 
                    xcorrSeries = xcorr(pulse,wave,"coef");
                    xcorrCoef = max(abs(xcorrSeries));

                else
                    % correlate with noise for testing 
                    noise = rand(eventDuration,1);
                    noise = filtfilt(b,a,noise);
                    xcorrSeries = xcorr(noise,wave,"coef");
                    xcorrCoef = max(abs(xcorrSeries));
                end

                sum = sum + xcorrCoef;

                count = count + 1;

                fprintf(xcorrCoef + "\n")
          
            end
            
            hold on

            subplot(numStat*numChan,1,comp)
            plot(wave)
             
        catch
            
        end
        
        comp = comp + 1;
        
    end

end

if corr
    try
        fprintf("Mean: " + sum/count + "\n");
    catch
    end   
end

hold off

