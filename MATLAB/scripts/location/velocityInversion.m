function [v,stDev,G,d] = velocityInversion(arrivals,distances)
%
% performs a basic inversion for phase velocity using a priori event locations 
%
% input parameters:
% arrivals: matrix of arrival times
% distances: distances between stations 

%calculate arrival time distances to form d vector and reformat distances
%to form G vector
for m = 4:3:3*size(arrivals,1)
    d(m,1) = arrivals((m-1)/3,2)-arrivals((m-1)/3,1);
    d(m+1,1) = arrivals((m-1)/3,3)-arrivals((m-1)/3,1);
    d(m+2,1) = arrivals((m-1)/3,3)-arrivals((m-1)/3,2);
    G(m,1) = distances(1,1);
    G(m+1,1) = distances(2,1);
    G(m+2,1) = distances(3,1);
end

%compute inversion
M = (G.'*G)\G.';
m = M*d;
v = 1/m;

%get covariance matrix and calculate standard deviation
covM = d'*d/(size(d,1)-4)\(G'*G);
stDev = (diag(covM)).^0.5;

end