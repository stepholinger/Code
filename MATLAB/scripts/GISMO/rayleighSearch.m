
% finds rayleigh arrival times for a set of seismic events

% set initial parameters
numStat = 7;
numEvent = 263;

% make datasource
ds = datasource('sac','/DB2/setholinger/ris-sac-files/serv-1/%s/%s.XH..%s.%04d.%03d.sac','station','station','channel','year','jday');

% make channeltag
ctag = ChannelTag.array('',{'DR14','DR13','DR12','DR10','DR09','DR08','RS04'},'','HHZ');

% make blank waveform array with width = # stations and height = # events
w(numEvent,numStat) = waveform();

% make blank Rayleigh string array with width = 1 + (# stations) and height = # events
rayleighArray(numEvent,numStat + 1) = string();

% make filter
f = filterobject('b',[1 3],4);

% make and filter 30-second waveform for each station/event combo
for n = 1:numEvent
    for m = 1:numStat
        startT = StartTimes(n,1) - 5/86400;
        endT = StartTimes(n,1) + 25/86400;     
        w(n,m) = waveform(ds,ctag(1,m),startT,endT);
        w(n,m) = filtfilt(f,w(n,m));
    end
end

% iterate through w to search for Rayleigh wave in each snippet
for n = 1:numEvent
    for m = 1:numStat
        
%       extract start time information
        s = {get(w(n,m),'start_str')};
        yr = {s{1}(1:4)};
        mth = {s{1}(6:7)};
        day = {s{1}(9:10)};
        hr = {s{1}(12:13)};
        mn = str2double({s{1}(15:16)});  
        sec = str2double({s{1}(18:end)});
        sec = round(sec);
        
%       calculate julian day and pad with 0s to 3-digits
        date = strcat(yr,'-',mth,'-',day);
        date2 = '2015-01-00';
        jday = datenum(date) - datenum(date2);
        jday = string(jday);
        jday = char(jday);
        if length(jday) == 1
            jday = strcat('0','0',jday);
        elseif length(jday) == 2
            jday = strcat('0',jday); 
        else
        end            
    
%       find index of max/min of waveform and convert to seconds
        d = get(w(n,m), 'data');       
        [maxAmp,maxTime] = max(d);
    	maxTime = maxTime/200;
        [minAmp,minTime] = min(d);
        minTime = minTime/200;

%       compare and choose soonest one
        if minTime > maxTime            
            
%           use max amplitude time                     
            rayleighTime = string(maxTime); 
            sec = sec + rayleighTime;
            
        else   
            
%           use min amplitude time
            rayleighTime = string(minTime); 
            sec = sec + rayleighTime;

        end  
        
%       fix second overflow                      
        if sec >= 60            
            sec = sec - 60;       
            mn = mn + 1;           
        end
        
%   record rayleigh times
    rayleighArray(n,m) = strcat(string(yr),':',string(jday),':',string(hr),':',string(mn),':',string(sec));

    end
           
end

% save results
filename = 'rayleighResults.mat';
save(filename,'rayleighArray');
