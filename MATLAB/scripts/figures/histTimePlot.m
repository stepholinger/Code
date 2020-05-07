function histTimePlot(indepVar,depVar,histData,numBins)
%
% Plots 4 sets of timeseries data and one histogram
% 
% input parameters:
% depVar: timeseries dependent variable
% indepVar: timeseries independent variable
% histData: data for histogram
% numBins: number of bins for histogram

% determine limits for timeseries axis
if min(depVar) < 0
    lim1 = min(depVar) - abs(nanmedian(depVar));
    lim2 = max(depVar) + abs(nanmedian(depVar));
    seriesLim =  [lim1,lim2];
else 
    lim2 = max(depVar) + abs(nanmedian(depVar));
    seriesLim =  [0,lim2];
end

% determine limits for histogram axis
 if min(histData) < 0
     lim1 = min(histcounts(depVar,numBins)) - abs(nanmedian(histcounts(depVar,numBins)));
     lim2 = max(histcounts(depVar,numBins)) + abs(nanmedian(histcounts(depVar,numBins)));
     histLim =  [lim1, lim2];
 else
     lim2 = max(histcounts(depVar,numBins)) + abs(nanmedian(histcounts(depVar,numBins)));
     histLim =  [0,lim2];
 end

% make plot
yyaxis left;
plot(indepVar,depVar);
ylim(seriesLim);
yyaxis right;
hist(histData,numBins);
ylim(histLim);

end