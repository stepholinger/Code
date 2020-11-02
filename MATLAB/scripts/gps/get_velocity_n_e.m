load('sow2_data.mat')

% convert times to datetime
dateVect = datetime(2012,1,9,0,0,0,'Format','yyyy-MM-dd HH:mm:SS') + days(daysSinceJan9);

% resample to uniform 5-minute sample rate
fs = 1/(5*60);
[n_even, ~] = resample(n,dateVect,fs);
[e_even, dateVect] = resample(e,dateVect,fs);

% get horizontal distance
horizontal_dist = sqrt(e_even.^2 + n_even.^2);

% get daily averages
daily_avg_distance = [];
distance_today = [];
dayVect = [];
for t = 2:length(dateVect)
   [y,m,d] = ymd(dateVect(t-1));
   dateMat = [y m d];
   [y2,m2,d2] = ymd(dateVect(t));
   dateMat2 = [y2 m2 d2];
   if sum(dateMat2 == dateMat) == 3
       distance_today = [distance_today,horizontal_dist(t-1)];
   else
       distance_today = [distance_today,horizontal_dist(t-1)];
       daily_avg_distance = [daily_avg_distance,mean(distance_today)];
       distance_today = [];
       dayVect = [dayVect,datetime(dateMat)];
   end
end

% remove crap at beginning
daily_avg_distance = daily_avg_distance(3:end);
dayVect = dayVect(3:end);

% differentiate to get velocity in m/s
daily_avg_velocity = gradient(daily_avg_distance,86400);

% filter to remove high frequency oscillation
freq = 1/(7*86400);
fs = 1/86400;
[b,a] = butter(4,freq/(fs/2),'low');
filt_velocity = filter(b,a,[daily_avg_velocity(1)*ones(1,100),daily_avg_velocity]);
filt_velocity = filt_velocity(101:end);

% get unix time
unixDayVect = posixtime(dayVect);

% save to hdf5
h5create('gps_velocity.h5','/velocity',[length(filt_velocity) 1])
h5write('gps_velocity.h5','/velocity',filt_velocity')
h5create('gps_velocity.h5','/time',[length(unixDayVect) 1])
h5write('gps_velocity.h5','/time',unixDayVect')

% smooth data- window length in hours
%winLen = duration(24,0,0);
%smooth_e = smoothdata(e_2012_2013,'movmean',winLen,'SamplePoints',dateVect_2012_2013);
%smooth_n = smoothdata(n_2012_2013,'movmean',winLen,'SamplePoints',dateVect_2012_2013);

% sample rates
%fs_new = 1/86400;
%r = round(fs/fs_new);

% decimate data
%dec_e = decimate(e_even,r);
%dec_n = decimate(n_even,r);