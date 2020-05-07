function spectrograms(fileType,stat,chan,fs,startDay,endDay,winLen,cLim)

% set path
if fileType == "SAC"
    path = "/media/Data/Data/PIG/SAC/noIR/";
end
if fileType == "MSEED"
    path = "/media/Data/Data/PIG/MSEED/noIR/";
end

% set range of dates 
startDay = datetime(startDay);
endDay = datetime(endDay);

% make range of dates
dateRange = startDay:endDay;

% make default date format consistent with file naming convention
datetime.setDefaultFormats("defaultdate","yyyy-MM-dd")

fMat = [];

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
            %fprintf(fname)
            data = rdmseed(fname);
            trace = extractfield(data,'d');
        end
        
        
        clf('reset');
        %figure()
        %set(gcf,'Visible','on');
        set(gcf,'Visible','off');
        
        [s,f,t,p] = spectrogram(trace,winLen,[],[],fs,'yaxis');
        pcolor(t,f,log10(p));
        shading flat;
        colormap jet;
        colorbar;
        caxis(cLim)
        
        % ONLY TURN THIS OPTION ON FOR LONG SPECTROGRAM
        %fMat = [fMat,p];
        
        % print the date and wait for enter to move to next day
        fprintf("Showing data on " + string(dateRange(d)) + ".\n")
        %pause;

        % save figure if desired
        saveas(gcf,"/home/setholinger/Documents/Projects/PIG/spectrograms/allDays/highFrequency/" + stat + "/" + chan + "/" + string(dateRange(d)) + ".png")
        %
        % clear figure
        clf('reset');
        close all;           
                       
    catch
      
       fprintf("No data on " + string(dateRange(d)) + "\n");
       
    end
    
end
end
