function [gSparse,dr] = ddPrep(arrivals,calcArrivals,dtdx,dtdy,xEvent,yEvent,numEvents,numStat,lambda,tolerance)
%
% creates G matrix and dr vector for use in double difference

% compute dimensions to correctly initialize variables
h = 0;
for i = 1:numEvents-1    
    for j = 2:numEvents
        if j > i
            h = h + 1;
        end
    end
end
stations = zeros(h,numStat);

h = 1;
n = 0;
for i = 1:numEvents-1    
    for j = 2:numEvents
        if j > i
            stations(h,1:numStat) = arrivals(i,1:numStat) .* arrivals(j,1:numStat);
            for k = 1:numStat
                 dist = sqrt((xEvent(i,1)-xEvent(j,1))^2 + (yEvent(i,1)-yEvent(j,1))^2);
                 if stations(h,k) ~= 0 && dist < tolerance
                     n = n + 1;
                 end
            end
            h = h + 1;
        end
    end
end

%calculate block size
if ismac
    [~, bytes] = system('sysctl hw.memsize | awk ''{print $2}''');
    maxElements = double(string(bytes))/8;
    maxHeight = floor(maxElements/(3*numEvents));
    
elseif isunix
    [~,bytes] = system('vmstat -s -S M | grep "free memory"');
    bytes = sscanf(bytes,'%f free memory');
    maxElements = (bytes * 10e5)/8;
    maxHeight = floor(maxElements/(3*numEvents));
    
elseif ispc
    disp('Platform not supported')
    
else
    disp('Platform not supported')
end

if n < maxHeight
    blockSize = n;
    p = 0;
else    
    blockSize = maxHeight;
    p = 1;
end

%allocate memory for large G matrix and dr vector
gSparse = sparse(n+(3*numEvents),3*numEvents);
gSparse(n+1:end,:) = lambda * eye(3*numEvents);
dr = zeros(n+(3*numEvents),1);
numRows = n;

%deal with last block
last = floor(n/blockSize);

%set counting variable
h = 1;
n = 1;
b = 1;
c = 1;
m = 1;
G = zeros(blockSize,3*numEvents);
remaining = [];

%loop through each possible event pair to calculate double differences and
%fill G matrix
for i = 1:numEvents-1    
    for j = 2:numEvents    
        if j > i

            %generate list of stations to use for event pair
            for k = 1:numStat
                 
                dist = sqrt((xEvent(i,1)-xEvent(j,1))^2 + (yEvent(i,1)-yEvent(j,1))^2);
                if stations(h,k) ~= 0 && dist < tolerance

                    %calculate double difference for this event pair
                    dr(n,1) = (arrivals(i,k) - arrivals(j,k)) - (calcArrivals(i,k) - calcArrivals(j,k));
                    
                    %construct current row of G matrix
                    r = 1 + 3 * (i-1);
                    G(b,r) = dtdx(i,k);
                    G(b,r+1) = dtdy(i,k);
                    G(b,r+2) = 1;      
                    r = 1 + 3 * (j-1);
                    G(b,r) = -dtdx(j,k);
                    G(b,r+1) = -dtdy(j,k);
                    G(b,r+2) = -1;
                                        
                    %Fill G_sparse with G blocks when b equals block size
                    if b == blockSize
                        gSparse(c:blockSize*m,:) = G;
                        m = m + 1;
                        c = c + b;
                        %reset b and G for next block
                        b = 0;
                        G = zeros(blockSize,3*numEvents);
                        
                    end
                    
                    %prepare for last block if necessary
                    if m > last && p == 1
                        remaining = numRows - (last * blockSize);
                        G = zeros(remaining,3*numEvents);
                        m = 0;
                    end
                    
                    if b == remaining
                        gSparse(c:numRows,:) = G;
                    end
                    
                    n = n + 1;
                    b = b + 1;
                    
                 end
            end
        h = h + 1;
        end
    end
end

end

