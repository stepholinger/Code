startDay = datetime("2012-01-01");
endDay = datetime("2014-01-01");
dateRange = startDay:endDay;

numDetections = zeros(length(dateRange),1);
detectionProbs = [];
detectionWindows = [];

for d=1:length(dateRange)-1
    try
        det = h5read("/home/setholinger/Documents/Projects/PIG/detections/ML/10-20Hz/2sGapResults.h5","/" + string(dateRange(d)))';
        
        detStart = dateRange(d) + seconds(det(:,1));
        detEnd = dateRange(d) + seconds(det(:,2));
        detWin = [detStart,detEnd];
        detProb = det(:,3);

        detectionWindows = [detectionWindows;detWin];        
        detectionProbs = [detectionProbs;detProb];
        
        numDetections(d) = length(det);
                
    catch
    end
end

%%

% get duration of all detection windows
detectionLengths = detectionWindows(:,2) - detectionWindows(:,1);

% pull only events with less than 1 minute window length
shortDetectionWindows = detectionWindows(detectionLengths <  duration(minutes(1)),:);
shortDetectionProbs = detectionProbs(detectionLengths <  duration(minutes(1)));
shortDetectionLengths = shortDetectionWindows(:,2) - shortDetectionWindows(:,1);

% pull only events with 10 second durations
detections10Sec = shortDetectionWindows(shortDetectionLengths == duration(seconds(10)),1);
detectionProbs10Sec = shortDetectionProbs(shortDetectionLengths == duration(seconds(10)),1);

% pull only events with probabilities of over some threshold
highProbDetections10Sec = detections10Sec(detectionProbs10Sec > 0.975);

%%

detectionMatrix.m

%%

xcorrMatrix.m

%%

dissimilarity = 1 - abs(xcorrCoefs);
dissimilarity = dissimilarity - diag(diag(dissimilarity));
dissimilarity(isnan(dissimilarity)) = 0;
dissimilarityVector = squareform(dissimilarity);
linkages = linkage(dissimilarityVector,'complete');