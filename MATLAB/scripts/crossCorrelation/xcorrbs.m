function t = xcorrbs;
tic;
x = gpuArray(rand(200000,1));
%x = rand(200000,1);
m = numel(x);
m2 = findTransformLength(m);
maxlag=500;
X = fft(x,m2,1);
for i = 1:10000
    y = gpuArray(rand(2000,1));
    %y = rand(200000,1);
    maxlagDefault = m-1;
    mxl = min(maxlag,maxlagDefault);
    Y = fft(y,m2,1);
    c1 = ifft(X.*conj(Y),[],1,'symmetric');
    % Keep only the lags we want and move negative lags before positive
    % lags.
    c = [c1(m2 - mxl + (1:mxl)); c1(1:mxl+1)];
end
t = toc;
%fprintf(string(t/i) + " seconds per correlation\n")