% read in high res thickness data
obj1 = Tiff('/home/setholinger/Documents/Projects/PIG/modeling/mcmc/blendmos_2012-tile-0-adj_masked_shpclip_freeboard_depth.tif');
depth = read(obj1);
obj2 = Tiff('/home/setholinger/Documents/Projects/PIG/modeling/mcmc/blendmos_2012-tile-0-adj_masked_shpclip_freeboard.tif');
thickness = read(obj2);
obj3 = Tiff('/home/setholinger/Documents/Projects/PIG/modeling/mcmc/blendmos_2012-tile-0-adj_masked_shpclip.tif');
elevation = read(obj3);

% make a mask
imshow(thickness)
roi = images.roi.AssistedFreehand;
draw(roi);
mask = createMask(roi);

% apply mask and replace -9999 and 0 with nans
masked_thickness = thickness .* mask;
masked_thickness(masked_thickness == -9999) = nan;
masked_thickness(masked_thickness == 0) = nan;
avg_hi = mean(masked_thickness,'all','omitnan');

% get bedmap2 data
lati = [-75.271719,-74.691876,-74.451250,-75.117229];
loni = [-102.070170,-103.588725,-101.731321,-100.307177];
z = bedmap2_data('bed',lati,loni);
z_neg = z;
z_neg(z_neg > 0) = nan;
avg_hw = mean(z_neg,'all','omitnan');