%HHZ

%load waveform file
load("/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/detections/run2/waveforms.mat")

%get number for iteration
numDetections = size(waveforms,3);

%make empty matrix for storing the cross correlation coefficients
xcorrCoefs = zeros(numDetections,numDetections);
lagTimes = zeros(numDetections,numDetections);

%for each detection, loop through all detections
for i = 1:numDetections
    
    tic;
    
    for j = 1:numDetections        
        %compute cross correlation
        [xcorrTrace,lag] = xcorr(waveforms(:,1,i),waveforms(:,1,j),"coeff");
            
        %grab max or min value
        if max(xcorrTrace) < abs(min(xcorrTrace))
            [coef,lagIndex] = min(xcorrTrace);
        else
            [coef,lagIndex] = max(xcorrTrace);
        end
        
        %store lag value
        lagTimes(i,j) = lagIndex;
        
        %store cross correlation coefficient
        xcorrCoefs(i,j) = coef;
      
    end
          
    %estimate remaining run time
    runTime = toc;     
    totRunTime = runTime * numDetections;
    runTimeLeft = totRunTime - (runTime * i);
    runTimeLeft =  runTimeLeft/60/60;
    
    %print remaining run time
    fprintf("Estimated time remaining: " + runTimeLeft + " hrs.\n") 
    
end

save("/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/detections/run2/correlationsPIG2HHZ.mat")

clear;



%HHN

%load waveform file
load("/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/detections/run2/waveforms.mat")

%get number for iteration
numDetections = size(waveforms,3);

%make empty matrix for storing the cross correlation coefficients
xcorrCoefs = zeros(numDetections,numDetections);
lagTimes = zeros(numDetections,numDetections);

%for each detection, loop through all detections
for i = 1:numDetections
    
    tic;
    
    for j = 1:numDetections        
        %compute cross correlation
        [xcorrTrace,lag] = xcorr(waveforms(:,2,i),waveforms(:,2,j),"coeff");
            
        %grab max or min value
        if max(xcorrTrace) < abs(min(xcorrTrace))
            [coef,lagIndex] = min(xcorrTrace);
        else
            [coef,lagIndex] = max(xcorrTrace);
        end
        
        %store lag value
        lagTimes(i,j) = lagIndex;
        
        %store cross correlation coefficient
        xcorrCoefs(i,j) = coef;
      
    end
          
    %estimate remaining run time
    runTime = toc;     
    totRunTime = runTime * numDetections;
    runTimeLeft = totRunTime - (runTime * i);
    runTimeLeft =  runTimeLeft/60/60;
    
    %print remaining run time
    fprintf("Estimated time remaining: " + runTimeLeft + " hrs.\n") 
    
end

save("/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/detections/run2/correlationsPIG2HHN.mat")

clear;



%HHE

%load waveform file
load("/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/detections/run2/waveforms.mat")

%get number for iteration
numDetections = size(waveforms,3);

%make empty matrix for storing the cross correlation coefficients
xcorrCoefs = zeros(numDetections,numDetections);
lagTimes = zeros(numDetections,numDetections);

%for each detection, loop through all detections
for i = 1:numDetections
    
    tic;
    
    for j = 1:numDetections        
        %compute cross correlation
        [xcorrTrace,lag] = xcorr(waveforms(:,3,i),waveforms(:,3,j),"coeff");
            
        %grab max or min value
        if max(xcorrTrace) < abs(min(xcorrTrace))
            [coef,lagIndex] = min(xcorrTrace);
        else
            [coef,lagIndex] = max(xcorrTrace);
        end
        
        %store lag value
        lagTimes(i,j) = lagIndex;
        
        %store cross correlation coefficient
        xcorrCoefs(i,j) = coef;
      
    end
          
    %estimate remaining run time
    runTime = toc;     
    totRunTime = runTime * numDetections;
    runTimeLeft = totRunTime - (runTime * i);
    runTimeLeft =  runTimeLeft/60/60;
    
    %print remaining run time
    fprintf("Estimated time remaining: " + runTimeLeft + " hrs.\n") 
    
end

save("/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/detections/run2/correlationsPIG2HHE.mat")

clear;
