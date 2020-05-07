function templateScan(tempStart,tempEnd,scanStart,scanEnd,stat)
%
% scans continuous waveform data for snippets that match a template
%
% input parameters:
% tempStart: start time of template
% tempEnd: end time of template
% scanStart: start time of data 
% scanEnd: end time of data
% stat: string of station code to be used for template and scanning


%define time range of template (format: '7/20/2015 03:22:32')
tempStart = datenum(tempStart);
tempEnd = datenum(tempEnd);

%define date range for scanning (format: '7/20/2015')
scanStart = datenum(scanStart);
scanEnd = datenum(scanEnd);

%make datasource
ds = datasource('sac','/DB2/setholinger/ris-sac-files/serv-1/%s/%s.XH..%s.%04d.%03d.sac','station','station','channel','year','jday');

%make channeltag
ctag = ChannelTag.array('',{stat,stat,stat},'',{'HHZ','HHN','HHE'});

%make and filter template 
template = waveform(ds,ctag,tempStart,tempEnd);
filt = filterobject('B',[1 3],4);
template = filtfilt(filt,template);

%make counting variables
m = scanEnd - scanStart;

%loop until n = m
for n = 0:m

	%define first day to be scanned
	startTime = scanStart + n;
    endTime = scanStart + n + 1;

	%make and filter waveform object to be scanned
	wave = waveform(ds,ctag,startTime,endTime);
	wave = fillgaps(wave,0);
	wave = demean(wave);
	filt = filterobject('B',[1 3],4);
	wave = filtfilt(filt,wave);

	%scan waveform using template and extract detection times
	wave = mastercorr_scan(wave,template,0.65);
	list = mastercorr_extract(wave);
	list = datetime(list.trig,'convertfrom', 'datenum');
	detections = sort(list);
	detections = char(detections);
	n = n+1;
	s = datetime(startTime,'convertfrom', 'datenum');
	s = string(s);
	s = strtok(s);
	filename = strcat('detections',s,'.txt');
	dlmwrite(filename,detections,'');

end
end
