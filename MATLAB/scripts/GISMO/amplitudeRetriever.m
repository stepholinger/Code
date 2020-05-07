function amplitudeRetriever(eventTimes,station,channel)
%
% retrieves max amplitude of seismic events

%specify number of events
numEvent = height(eventTimes);

%make datasource
ds = datasource('sac','/DB2/setholinger/ris-sac-files/IR-removed/%s/%s.XH..%s.%04d.%03d.sac-noIR','station','station','channel','year','jday');

%make channeltag
ctag = ChannelTag('',station,'',channel);

%make filter
f = filterobject('b',[1 3],4);

%open fileID to save amplitudes
fname = [station 'Amplitudes.txt'];
fid = fopen(fname,'a');

%make and filter 30-second waveform for each station/event combo
for n = 1:numEvent
    
    try
        start = eventTimes(n,1) - 60/86400;
        endt = eventTimes(n,1) + 60/86400;

        w = waveform(ds,ctag,start,endt);
        w = filtfilt(f,w);           

        %compare and choose largest peak
        d = get(w, 'data'); 
        d = d(1000:24000,1);
        if abs(max(d)) > abs(min(d))            
            amp = abs(max(d));
        else
            amp = abs(min(d));
        end
       
        %record event time and amplitude
        fprintf(fid,'%17s     %10e \n',table2array(eventTimes(n,:)),amp);
    
    catch
        id = sprintf('%d',n);
        warning(['No data for event ' id]);
        fprintf(fid,'%17s     NaN\n',table2array(eventTimes(n,:)));

    end
    
end

fclose(fid);

end
