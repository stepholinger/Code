% define test clusters
a = [1,3;2,3;1,2;3,2];
b = [-23,1;-23,2;-22,3;-23,3];

% calculate centroids
centroid_a = [mean(a(:,1)),mean(a(:,2))];
centroid_b = [mean(b(:,1)),mean(b(:,2))];

% plot test clusters
scatter(a(:,1),a(:,2),"r",".");
hold on;
scatter(centroid_a(1,1),centroid_a(1,2),"r","*")
scatter(b(:,1),b(:,2),"b",".")
scatter(centroid_b(1,1),centroid_b(1,2),"b","*")
title("Test Clusters and Centroids")
ylim([-3,7])

% consider point a_1; first, calculate average distance to each other point
% in cluster a
i = 1;
count = 0;
dist = 0;
for j = 2:4
    count = count + 1;
    dist = dist + sqrt((a(i,1) - a(j,1))^2+(a(i,2) - a(j,2))^2);
end
a_i = dist/count;

% now calculate average distance to each point in cluster b
count = 0;
dist = 0;
for j = 1:4
    count = count + 1;
    dist = dist + sqrt((a(i,1) - b(j,1))^2+(a(i,2) - b(j,2))^2);
end
b_i = dist/count;

% now check if b_i the same as the distance from a_1 to the centroid of b
centroid_dist = sqrt((a(i,1) - centroid_b(1,1))^2+(a(i,2) - centroid_b(1,2))^2);

% they are not, which means that you need to distances for every pair of
% points to properly compute silhouettes