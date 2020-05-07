
% creates a text file to insert phase arrivals into Antelope

% create output file 
fname = 'antelopeRayleighArrivals.txt';
fid = fopen(fname,'wt');

% set useful variables
numEvents = 262;

for n = 1:numEvents       
        fprintf(fid,'DR14,%s,LR,HHZ\n',rayleigh_array(n,1));          
        fprintf(fid,'DR13,%s,LR,HHZ\n',rayleigh_array(n,2));        
        fprintf(fid,'DR12,%s,LR,HHZ\n',rayleigh_array(n,3));         
        fprintf(fid,'DR10,%s,LR,HHZ\n',rayleigh_array(n,4));          
        fprintf(fid,'DR09,%s,LR,HHZ\n',rayleigh_array(n,5));          
        fprintf(fid,'DR08,%s,LR,HHZ\n',rayleigh_array(n,6));          
        fprintf(fid,'RS04,%s,LR,HHZ\n',rayleigh_array(n,7));           
end

fclose(fid);