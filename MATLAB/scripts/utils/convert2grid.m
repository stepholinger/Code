function [xEvent,yEvent] = convert2grid(refLoc,eventLoc)
%
% converts lat/lon to cartesian coordinates in relation to a reference point

[distEvent, azEvent] = distance(refLoc,eventLoc,wgs84Ellipsoid);
xEvent = distEvent .* cosd(90 - azEvent)/1000;
yEvent = distEvent .* sind(90 - azEvent)/1000;
end