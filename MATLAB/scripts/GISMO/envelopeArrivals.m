function envelopeArrivals = envelopeArrivals(jTimes,stations,thresh)
%
% returns max envelope function times for a set of seismic events as a 
% proxy for Rayleigh arrivals 
%
% input parameters:
% jTimes: event times in time format YYYY:DDD:HH:MM:SS
% stations: string vector of stations 
% thresh: STA/LTA threshold

% specify number of events and stations
numEvent = height(jTimes);
numStat = numel(table(stations));
envelopeArrivals = zeros(numEvent,numStat);

% make datasource
ds = datasource('sac','/DB2/setholinger/ris-sac-files/combined/%s/%s.XH..%s.%04d.%03d.sac','station','station','channel','year','jday');

% make filter
f = filterobject('b',[1 3],4);

% convert to matlab time
mTimes = convert2matlab(jTimes,1);

% open file for results
fname = 'envelopeArrivals.txt';
fileID = fopen(fname,'a');
formatSpec = "%.4f   %.4f   %.4f   %.4f   %.4f   %.4f   %.4f   %.4f   %.4f\n";


% make and filter 30-second waveform for each station/event combo
for n = 1:numEvent
    for m = 1:numStat
       try
            start = mTimes(n,1) - 10/86400;
            endt = mTimes(n,1) + 60/86400;
            
            % make channeltag
            ctag = ChannelTag('',stations(m,1),'','HHZ');
            w = waveform(ds,ctag,start,endt);
            w = demean(w);
            w = detrend(w);
            w = filtfilt(f,w);
            
            % generate envelopes and find max
            d = get(w,'data');
            env = envelope(d);        
            [amp,i] = max(env);
            avg = mean(env);
            envelopeArrivals(n,m) = i/200 - 10;
            
            % remove autopicks before known origin time
            if envelopeArrivals(n,m) < 0
               envelopeArrivals(n,m) =  0;
            end
            
            % set STALTA ratio to remove autopicks that are not
            % significantly higher than waveform average amplitude
            ratio = amp / avg;
            if ratio > thresh
               envelopeArrivals(n,m) = 0; 
            end            

            if m > 1
                % remove picks more than 20 seconds after first pick
                if envelopeArrivals(n,m) > 0 && envelopeArrivals(n,m) - envelopeArrivals(n,1) > 20
                   envelopeArrivals(n,m) = 0;
                end
                
                % remove picks more than 10 seconds before or after prior pick            
                if envelopeArrivals(n,m-1) > 0 && abs(envelopeArrivals(n,m) - envelopeArrivals(n,m-1)) > 10
                   envelopeArrivals(n,m) = 0;
                end
            end
            
       % 0 if no data at that station
       catch
            envelopeArrivals(n,m) = 0;
       end
    end

fprintf(fileID,formatSpec,envelopeArrivals(n,:));
    
end

fclose(fileID);

end
