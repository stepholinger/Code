function plot_bivar(x_keep,xFit,numIt,p,paramsVaried,axisLabels,paramLabels,numBins,path)

% get max value for histogram plots
h1 = histcounts(x_keep(paramsVaried(1),:),numBins);
m1 = max(h1);
h2 = histcounts(x_keep(paramsVaried(2),:),numBins);
m2 = max(h2);
lim = max(m1,m2) + max(m1,m2)/10;

% make histogram for first variable
ax1 = subplot(3,3,8:9);
pos = get(ax1,'Position');
pos(1) = .35;
pos(2) = .1;
set(ax1,'Position',pos)
histogram(x_keep(paramsVaried(1),:),numBins);
ylim([0 lim]);
xlim([min(x_keep(paramsVaried(1),:)),max(x_keep(paramsVaried(1),:))]);
xlabel(axisLabels(paramsVaried(1)))
xline(xFit(paramsVaried(1)),"r--");
ax1.XRuler.Exponent = 0;
ax1.YRuler.Exponent = 0;

% make histogram for second variable
ax2 = subplot(3,3,[1 4]);
pos = get(ax2,'Position');
pos(1) = 0.1;
pos(2) = 0.35;
set(ax2,'Position',pos)
histogram(x_keep(paramsVaried(2),:),numBins)
ylim([0 lim]);
set(ax2,'view',[-90 90])
xlim([min(x_keep(paramsVaried(2),:)),max(x_keep(paramsVaried(2),:))]);
xlabel(axisLabels(paramsVaried(2)))
xline(xFit(paramsVaried(2)),"r--");
ax2.XRuler.Exponent = 0;
ax2.YRuler.Exponent = 0;

% make dscatter density plot of results
ax3 = subplot(3,3,[2,3,5,6]);
pos = get(ax3,'Position');
pos(1) = 0.35;
pos(2) = 0.35;
set(ax3,'Position',pos)
dscatter(x_keep(paramsVaried(1),:)',x_keep(paramsVaried(2),:)','BINS',[numBins,numBins]);
xlim([min(x_keep(paramsVaried(1),:)),max(x_keep(paramsVaried(1),:))]);
ylim([min(x_keep(paramsVaried(2),:)),max(x_keep(paramsVaried(2),:))]);
title("Result of MCMC inversion after " + numIt + " iterations")
hold on
set(gcf,'Position',[10 10 1000 800])
xline(xFit(paramsVaried(1)),"r--");
yline(xFit(paramsVaried(2)),"r--");
xticklabels(ax3,{})
yticklabels(ax3,{})

% save plots
%saveas(gcf,path + "run" + p + "_" + paramLabels(paramsVaried(1)) + ...
%       "-" + paramLabels(paramsVaried(2)) + "_dscatter.png")
%close(gcf)

end