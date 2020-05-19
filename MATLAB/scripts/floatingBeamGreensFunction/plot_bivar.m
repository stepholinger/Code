function plot_bivar(x_keep,xFit,numIt,p,paramsVaried,axisLabels,paramLabels)

% make dscatter density plot of results
dscatter(x_keep(paramsVaried(1),:)',x_keep(paramsVaried(2),:)');
xlim([min(x_keep(paramsVaried(1),:)),max(x_keep(paramsVaried(1),:))]);
ylim([min(x_keep(paramsVaried(2),:)),max(x_keep(paramsVaried(2),:))]);
title("Result of MCMC inversion after " + numIt + " iterations")
xlabel(axisLabels(paramsVaried(1)))
ylabel(axisLabels(paramsVaried(2)))
hold on
set(gcf,'Position',[10 10 1000 800])
ax = gca;
ax.XRuler.Exponent = 0;
ax.YRuler.Exponent = 0;
xline(xFit(paramsVaried(1)),"r--");
yline(xFit(paramsVaried(2)),"r--");
saveas(gcf,"/home/setholinger/Documents/Projects/PIG/modeling/mcmc/run" + ...
           p + "_" + paramLabels(paramsVaried(1)) + "-" + paramLabels(paramsVaried(2)) + "_dscatter.png")
close(gcf)

end