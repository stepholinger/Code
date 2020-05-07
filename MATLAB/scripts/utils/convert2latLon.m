function [latLon] = convert2latLon(refLoc,eventLoc)
%
% converts cartesian coordinates back to lat/lon

az = atand(eventLoc(:,1)./eventLoc(:,2));
eventDist = sqrt(eventLoc(:,1).^2 + eventLoc(:,2).^2)*1000;
[eventLat,eventLon] = reckon(refLoc(1),refLoc(2),eventDist,az,wgs84Ellipsoid);
latLon = [eventLat,eventLon];

end