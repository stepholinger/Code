%load("/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/xcorrAndClusterTest.mat")

%load('/home/setholinger/Documents/Code/MATLAB/workspaces/PIG/crossCorrelation/PIG2HHZ/singleDay/2012-10-29.mat')

cutoff = 0.835;

% check for off-diagonal autocorrelations (double-counting)
%{
maxCoefs = max(abs(xcorrCoefs) - diag(diag(xcorrCoefs)));
isAuto = (maxCoefs > 0.99999999999);

% the below vector contains columns that can all be removed
autoIdx = find(isAuto);

% remove the row and column corresponding to that event
xcorrCoefs(autoIdx,:) = [];
xcorrCoefs(:,autoIdx) = [];
lagTimes(autoIdx,:) = [];
lagTimes(:,autoIdx) = [];
detectionsToday(autoIdx,:) = [];
%}

% if we have upper triangular xcorr matrix, fill in the bottom half
xcorrCoefs = xcorrCoefs + rot90(fliplr(xcorrCoefs)) - diag(diag(ones(length(lagTimes))));

% remember lag time sign is reversed when order of correlation is reversed
lagTimes = lagTimes + rot90(fliplr(lagTimes))*(-1);

dissimilarity = 1 - abs(xcorrCoefs);
dissimilarity = dissimilarity - diag(diag(dissimilarity));
dissimilarity(isnan(dissimilarity)) = 0;
dissimilarityVector = squareform(dissimilarity);
linkages = linkage(dissimilarityVector,'complete');
clusters = cluster(linkages,'cutoff',cutoff,'criterion','distance');
%clusters = cluster(linkages,'MaxClust',50,'criterion','distance');
dendrogram(linkages,0,'colorthreshold',cutoff)
