function [energyMat,t] = riftEventDetect(fileType,chan,fs,freq1,freq2,filtType1,filtType2)

% set path
if fileType == "SAC"
    path = "/media/Data/Data/PIG/SAC/noIR/";
end
if fileType == "MSEED"
    path = "/media/Data/Data/PIG/MSEED/noIR/";
end

% set number of bins for energy calculation
numBins = 24;

% find correct length of signal
sigLength = fs*86400;

% set station and components
stat = "PIG2";

% set range of dates 
startDay = datetime("2012-01-01");
endDay = datetime("2014-01-01");

% make range of dates
dateRange = startDay:endDay;

% choose filter bands and design filter
[b,a] = butter(4,freq1/(fs/2),filtType1);
[b2,a2] = butter(4,freq2/(fs/2),filtType2);

% make default date format consistent with file naming convention
datetime.setDefaultFormats("defaultdate","yyyy-mm-dd")

% create matrix for storing results
energyMat = zeros(2,numBins*(length(dateRange)-1));

% loop through all days
for d = 1:length(dateRange)-1
    
    try

        % make filename and read data
        if fileType == "SAC"
            fname = path + stat + "/" + chan + "/" + string(dateRange(d)) + "." + stat + "." + chan + ".noIR.SAC";
            data = readsac(fname);
            trace = data.trace;
        end
        if fileType == "MSEED"
            fname = path + stat + "/" + chan + "/" + string(dateRange(d)) + "." + stat + "." + chan + ".noIR.MSEED";
            data = rdmseed(fname);
            trace = extractfield(data,'d');
        end
          
        % filter to desired band
        traceLow = filtfilt(b,a,trace);
        traceHigh = filtfilt(b2,a2,trace);

        % square trace
        sqrTraceLow = traceLow.*traceLow;
        sqrTraceHigh = traceHigh.*traceHigh;

        % bin into hours and add
        binSqrTraceLow = reshape(sqrTraceLow(1:sigLength),sigLength/numBins,numBins);
        binSumLow = sum(binSqrTraceLow,1);     
                       
        binSqrTraceHigh = reshape(sqrTraceHigh(1:sigLength),sigLength/numBins,numBins);
        binSumHigh = sum(binSqrTraceHigh,1);
        
        energyMat(:,1+((d-1)*24):d*24) = [binSumLow;binSumHigh];
        
        fprintf("Successfully returned energy in two bands on " + string(dateRange(d)) + "\n");
        
    catch
      
        fprintf("No data on " + string(dateRange(d)) + "\n");
       
    end
    
    
end

% return vector of times
datetime.setDefaultFormats("defaultdate","yyyy-MM-dd HH:mm:SS")
t = startDay:days(1)/numBins:endDay;

end
