clear("clusterWaveforms")
clear("clusterDatetimes")
clear("clusterLags")
clear("clusterCoefs")

i = 0;
for n = 1:size(waveforms,3)
   if clusters(n) == 8
       if i == 0
            first = n;
       end
       i = i + 1;
       clusterDatetimes(i) = detectionsDatetimePIG234(n);
       clusterWaveforms(i,:,:) = waveforms(:,:,n);
       clusterLags(i) = lagTimes(first,n);
       clusterCoefs(i) = xcorrCoefsAbs(first,n);
   end
end

%sort by waveform similarity
[sortedClusterCoefs,sortIndex] = sort(clusterCoefs,'descend');
sortedClusterDatetimes = clusterDatetimes(sortIndex);
sortedClusterWaveforms = clusterWaveforms(sortIndex,:,:);
sortedClusterLags = clusterLags(sortIndex);
sortedClusterDatetimes = clusterDatetimes(sortIndex);

numTrace = 20;


delay = sortedClusterLags-1000;

%for n = 1:numTrace
%    subplot(numTrace,1,n)
%    plot([delay(n)+1:1000+delay(n)],sortedClusterWaveforms(n,:))
%    xlim([0,1000])
%    set(gca,'xtick',[])
%    set(gca,'xticklabel',[])
%    set(gca,'ytick',[])
%    set(gca,'yticklabel',[])
    
%end


n = 70;

figure(1)
hold on
plot(sortedClusterWaveforms(n,:,1)+10e-9)
plot(sortedClusterWaveforms(n,:,2))
plot(sortedClusterWaveforms(n,:,3)-10e-9)

figure(2)
hold on
plot(sortedClusterWaveforms(n,:,4)+10e-9)
plot(sortedClusterWaveforms(n,:,5))
plot(sortedClusterWaveforms(n,:,6)-10e-9)

figure(3)
hold on
plot(sortedClusterWaveforms(n,:,7)+10e-9)
plot(sortedClusterWaveforms(n,:,8))
plot(sortedClusterWaveforms(n,:,9)-10e-9)