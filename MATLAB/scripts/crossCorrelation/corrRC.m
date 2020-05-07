load("stackCorr.mat");

% start at a particular event in case of crash
start = 3936;

poolobj = gcp;

% cross correlate all waveforms
parfor i = start:size(allStackedWaveforms,1)
    tic; 
    
    lagVect = zeros(size(allStackedWaveforms,1),1);
    corrVect = zeros(size(allStackedWaveforms,1),1);
    
    for j = i:size(allStackedWaveforms,1)
    
        % compute the cross correlation
        [xcorrTrace,lag] = xcorr(allStackedWaveforms(i,:),allStackedWaveforms(j,:),"coef");

        [coef,lagIndex] = max(abs(xcorrTrace));

        % store lag value and correlation coefficient
        lagVect(j) = lag(lagIndex);
        corrVect(j) = coef;
    
    end
    
    xcorrCoefs(i,:) = corrVect;
    lagTimes(i,:) = lagVect;
    
    t = toc;
    
    fprintf("Estimated runtime left: " + t * (size(allStackedWaveforms,1)-i) + "\n");
    
end