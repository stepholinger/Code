function plot_M_frac(x_keep,M_frac,M_fit,xFit,numIt,p,paramsVaried,axisLabels,paramLabels,numBins,path)

% make dscatter density plot of results
for i = 1:length(paramsVaried)

    % get max value for histogram plots
    h1 = histcounts(x_keep(paramsVaried(i),:),numBins);
    m1 = max(h1);
    h2 = histcounts(M_frac,numBins);
    m2 = max(h2);
    lim = max(m1,m2) + max(m1,m2)/10;

    % make histogram for first variable
    ax1 = subplot(3,3,8:9);
    pos = get(ax1,'Position');
    pos(1) = .35;
    pos(2) = .1;
    set(ax1,'Position',pos)
    histogram(x_keep(paramsVaried(i),:),numBins);
    ylim([0 lim]);
    xlim([min(x_keep(paramsVaried(i),:)),max(x_keep(paramsVaried(i),:))]);
    xlabel(axisLabels(paramsVaried(i)))
    xline(xFit(paramsVaried(i)),"r--");
    ax1.XRuler.Exponent = 0;
    ax1.YRuler.Exponent = 0;

    % make histogram for second variable
    ax2 = subplot(3,3,[1 4]);
    pos = get(ax2,'Position');
    pos(1) = 0.1;
    pos(2) = 0.35;
    set(ax2,'Position',pos)
    histogram(M_frac,numBins)
    ylim([0 lim]);
    set(ax2,'view',[-90 90])
    xlim([min(M_frac),max(M_frac)]);
    xlabel("M_{obs}/M_0")
    xline(M_fit,"r--");
    ax2.XRuler.Exponent = 0;
    ax2.YRuler.Exponent = 0;

    % make dscatter density plot of results
    ax3 = subplot(3,3,[2,3,5,6]);
    pos = get(ax3,'Position');
    pos(1) = 0.35;
    pos(2) = 0.35;
    set(ax3,'Position',pos)
    dscatter(x_keep(paramsVaried(i),:)',M_frac','BINS',[numBins,numBins]);
    xlim([min(x_keep(paramsVaried(i),:)),max(x_keep(paramsVaried(i),:))]);
    ylim([min(M_frac),max(M_frac)]);
    title("Result of MCMC inversion after " + numIt + " iterations")
    hold on
    set(gcf,'Position',[10 10 1000 800])
    xline(xFit(paramsVaried(i)),"r--");
    yline(M_fit,"r--");
    xticklabels(ax3,{})
    yticklabels(ax3,{})

    saveas(gcf,path + "run" + p + "_" + paramLabels(paramsVaried(i)) + ...
               "-" + "Mfrac" + "_dscatter.png")
    close(gcf)

end

end