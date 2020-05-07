testWaves = ones(1000,6000);

xcorrCoefs = zeros(size(testWaves,1));
lagTimes = zeros(size(testWaves,1));

poolobj = gcp;

% cross correlate all waveforms
parfor i = 1:size(testWaves,1)
    
    lagVect = zeros(size(testWaves,1),1);
    corrVect = zeros(size(testWaves,1),1);
    
    for j = i:size(testWaves,1)
    
        % compute the cross correlation
        [xcorrTrace,lag] = xcorr(testWaves(i,:),testWaves(j,:),"coef");

        [coef,lagIndex] = max(abs(xcorrTrace));

        % store lag value and correlation coefficient
        lagVect(j) = lag(lagIndex);
        corrVect(j) = coef;
    
    end
    
    xcorrCoefs(i,:) = corrVect;
    lagTimes(i,:) = lagVect;
            
    fprintf("Still running..\n");
    
end