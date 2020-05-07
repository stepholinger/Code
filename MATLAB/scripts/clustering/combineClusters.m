for n = 1:length(unique(clusters))
    
    clustIdx = find(clusters == n);
    combinedClust = eventsPerCluster(clustIdx,:);
    
    clustDates = [];
    clustEventIdx = [];
        
    for m = 1:length(combinedClust)
    
        clustDates = [clustDates;combinedClust{m,1}(:,:)];
        clustEventIdx = [clustEventIdx;combinedClust{m,2}(:,:)];
    
    end

    allCombinedClust{n,1} = clustDates;
    allCombinedClust{n,2} = clustEventIdx;
    
end
    