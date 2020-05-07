xcorrApprox = zeros(numWaveforms);

for i = 1:numWaveforms
    for j = 1:numWaveforms
   
    normWave1 = alignedWaveforms(i,:)/max(abs(alignedWaveforms(i,:)));
    normWave2 = alignedWaveforms(j,:)/max(abs(alignedWaveforms(j,:)));

    xcorrEst = max(normWave1.*normWave2);
    
    xcorrApprox(i,j) = xcorrEst;
    
    end
end