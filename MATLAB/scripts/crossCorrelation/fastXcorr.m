% Seth's fast cross correlation code- takes two non-normalized traces of
% different lengths and cross correlates them

function [ck,td] = fastXcorr(wave1,wave2)

% normalize both waves manually
wave1 = wave1/max(abs(wave1));
wave2 = wave2/max(abs(wave2));

% pad with zeros
if length(wave2) > length(wave1)
wave1 = [wave1;zeros(length(wave2)-length(wave1),1)];
else
wave2 = [wave2;zeros(length(wave1)-length(wave2),1)];
end

a = wave2'; b = wave1';
len = length(a);

c = [ zeros(1,len-1) a ];
d = [ b zeros(1,len-1) ];

X1 = fft(c);
X2 = fft(d);

X = X1.*conj(X2);
ck = ifft((X));

[~,i] = max(ck);
td = i - len;
lags = [-(len-1):len-1];

end