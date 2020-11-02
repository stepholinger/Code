function xFit = getFit(x_keep,paramsVaried,numBins,x0)
    
    % set xFit
    xFit = x0;

    % get matrix back from dscatter
    figure(2) 
    [~,~,col] = dscatter(x_keep(paramsVaried(1),:)',x_keep(paramsVaried(2),:)','BINS',[numBins numBins]);    
    close(gcf);
    
    % get index of highest density point
    [~,fitIdx] = max(col);
    
    % get values at that index
    xFit(paramsVaried(1)) = x_keep(paramsVaried(1),fitIdx);
    xFit(paramsVaried(2)) = x_keep(paramsVaried(2),fitIdx);
    
end