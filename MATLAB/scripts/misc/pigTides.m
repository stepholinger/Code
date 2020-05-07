%clear;

latPIG = [-74.919320;-75.010696;-75.193442];
lonPIG = [-101.443566;-100.786598;-99.513937];

% Specific padman model
PadmanModel = '/home/setholinger/Documents/Code/MATLAB/packages/tmd_toolbox/DATA/Model_CATS2008a_opt';

% Make tide time series
sd1=datenum([2012 01 01 0 0 0]); %start time
sd2=datenum([2014 01 01 0 0 0]); %end time
freq=1/60/60; % 1/60 = minute resolution
SDtime=linspace(sd1,sd2,(sd2-sd1)*freq*86400+1);
fracyr=(SDtime-sd1)/365+2011;
tide_timeseries=tmd_tide_pred(PadmanModel,SDtime,latPIG(3),lonPIG(3),'z');

% Make the Plots
plot(SDtime,tide_timeseries,'-k');
datetick; axis tight;
ylabel('Tide Height at PIG (m)');
set(gca,'fontsize',18)