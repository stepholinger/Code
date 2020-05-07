function viewData(fileType,network,stat,chan,fs,freq,filtType,offset)

% set path
if fileType == "SAC"
    path = "/media/Data/Data/"+ network + "/SAC/noIR/";
end
if fileType == "MSEED"
    path = "/media/Data/Data/" + network + "/MSEED/noIR/";
end

% set range of dates 
%startDay = datetime("2013-10-24");
%endDay = datetime("2013-10-25");
startDay = datetime("2012-01-01");
endDay = datetime("2014-01-01");

% make range of dates
dateRange = startDay:endDay;

% set spacing for helicorder
numLines = 24;

if filtType ~= "none"
	% choose filter band and design filter
    [b,a] = butter(4,freq/(fs/2),filtType);
end

% make default date format consistent with file naming convention
datetime.setDefaultFormats("defaultdate","yyyy-MM-dd")

% loop through all days
%parfor d = 1:length(dateRange)-1
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
        
        if filtType ~= "none"
            % filter to desired band
            trace = filtfilt(b,a,trace);
        end
        
        clf('reset');
        %figure()
        %set(gcf,'Visible','on');
        set(gcf,'Visible','off');
        
        for n = 0:numLines-1

            hold on

            % find start and end of each line of the plot
            startSample = int32(1 + floor((length(trace)*n)/numLines));
            endSample = startSample + int32(floor(length(trace)/numLines)) - 1;
            lineTrace = trace(startSample:endSample);

            % normalize and offset
            % lineTrace = lineTrace/max(abs(lineTrace))-offset*n;
            lineTrace = lineTrace-offset*n;

            % plot the current line of trace
            plot(lineTrace,'color','k')                          

        end

        yyaxis left
        yticks([-1*(numLines-1):0]*offset);
        yticklabels(flip(0:numLines-1));
        ylim([0-offset*(numLines),0+offset]);
        ylabel("Hour");

        yyaxis right            
        yticks((1-1/numLines)/numLines*[1:numLines]);
        yticks((1-1/(2*numLines))/(2*numLines)*[numLines*2-2:numLines*2]);
        yticklabels(string(round([offset/-2,0,offset/2],2,'significant')));
        set(ylabel("Amplitude (m/s)"),'Units','Normalized','Position',[1.025,0.75,0]);

        set(get(gca,'YAxis'),'FontSize',6)

        xticks([0:4]*length(lineTrace)/4);
        xticklabels(string([0:4]*minutes(60)/4));
        xlim([0,length(lineTrace)]);

        drawnow;

        % print the date and wait for enter to move to next day
        fprintf("Showing data on " + string(dateRange(d)) + ".\n")
        %pause;

        % save figure if desired
        if filtType == "bandpass"
            saveas(gcf,"/home/setholinger/Documents/Projects/PIG/helicorders/allDays/" + freq(1) + "-" + freq(2) + "Hz/" + stat + "/" + chan + "/" + string(dateRange(d)) + ".png")
        elseif filtType == "low"
            saveas(gcf,"/home/setholinger/Documents/Projects/PIG/helicorders/allDays/<" + freq + "Hz/" + stat + "/" + chan + "/" + string(dateRange(d)) + ".png")
        elseif filtType == "high"
            saveas(gcf,"/home/setholinger/Documents/Projects/PIG/helicorders/allDays/>" + freq + "Hz/" + stat + "/" + chan + "/" + string(dateRange(d)) + ".png")
        elseif filtType == "none"
            saveas(gcf,"/home/setholinger/Documents/Projects/PIG/helicorders/allDays/broadband/" + stat + "/" + chan + "/" + string(dateRange(d)) + ".png")
        end
        
        % clear figure
        clf('reset');
        close all;           
                       
    catch
      
        fprintf("No data on " + string(dateRange(d)) + "\n");
       
    end
    
end
end
