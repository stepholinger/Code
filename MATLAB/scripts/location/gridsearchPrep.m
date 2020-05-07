function gridsearchPrep(arrivals,jTimes,statTemplate)
%
% creates gridsearch input files from automatically generated arrival times
%
% input parameters:
% arrivals: arrival times in relation to filename event time
% jTimes: event times as a string in format YYYY:DDD:HH:MM:SS
% statTemplate: vector containing the station name corresponding to each
% column in arrivals

% loop through each event
for n = 1:size(arrivals,1)

    % only make file if 5 or more arrivals
    if sum(arrivals(n,:)~= 0,2) > 4
        fname = strcat(table2array(jTimes(n,1)),'.in');
        fileID = fopen(fname,'wt');
        
        % print header
        fprintf(fileID,"0\n1.5529 1 1\n160 -79.2 0.00125\n600 178  0.005\n");
        for m = 1:size(arrivals,2)
            if arrivals(n,m) > 0
                formatSpec = "%s  %.4f  1\n";
                fprintf(fileID,formatSpec,statTemplate(1,m),arrivals(n,m));
            end
        end
    fclose(fileID);
    end
end

end
