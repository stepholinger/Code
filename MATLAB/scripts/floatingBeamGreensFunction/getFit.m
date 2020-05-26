function xFit = getFit(x_keep,paramsVaried,numBins,x0)
    
    % get matrix back from dscatter
    figure(2)
    [~,F] = dscatter(x_keep(paramsVaried(1),:)',x_keep(paramsVaried(2),:)','BINS',[numBins numBins]);
    close(gcf);
    
    % find indices of max value from dscatter
    [param2_ind,param1_ind] = ind2sub(size(F),find(F == max(F,[],'all')));
    ind = [param1_ind param2_ind];
    xFit = x0;
    
    % iterate through indices of varied parameters
    for i = 1:length(paramsVaried)
        
        % get max and min values of the current parameter
        var_min = min(x_keep(paramsVaried(i),:));
        var_max = max(x_keep(paramsVaried(i),:));
        var_range = var_max - var_min;
        var_step = var_range/numBins;
        
        % make axis of values 
        coords = var_min:var_step:var_max;
        
        % find value at index of max F
        xFit(paramsVaried(i)) = coords(ind(i));
    end
end