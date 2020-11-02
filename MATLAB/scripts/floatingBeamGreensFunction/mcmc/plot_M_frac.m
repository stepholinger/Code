function plot_M_frac(x_keep,M_frac,x0,numIt,p,paramsVaried,axisLabels,paramLabels,maxNumBins,path)

% make dscatter density plot of results
for i = 1:length(paramsVaried)

    % find best-fit parameters using 2D histogram
    numBins = length(unique(x_keep(paramsVaried(i),:)));
    if numBins > maxNumBins
        numBins = maxNumBins;
    end
    
    % get best fit parameters- use log if t0
    if paramsVaried(i) == 4
        xFit = getFitLog([x_keep;M_frac],[paramsVaried(i) 7],numBins,[x0 0],'both');
    else
        xFit = getFitLog([x_keep;M_frac],[paramsVaried(i) 7],numBins,[x0 0],'y');
    end
    
    % make a figure for each variable
    figure(i)
    
    % set subplot and position (tight layout) for first parameter
    ax1 = subplot(3,3,8:9);
    pos = get(ax1,'Position');
    pos(1) = .35;
    pos(2) = .1;
    set(ax1,'Position',pos)

    % make histogram- use log if t0
    if paramsVaried(i) == 4
        [~,edges] = histcounts(log10(x_keep(paramsVaried(i),:)),numBins);
        histogram(x_keep(paramsVaried(i),:),10.^edges);
        set(gca,'xscale','log');
        xticks([1e-2 0.05 1e-1 0.5 1e0 5 1e1 50 1e2]);
        xticklabels({'0.01','0.05','0.1','0.5','1','5','10','50','100'})
    else
        histogram(x_keep(paramsVaried(i),:),numBins);
    end

    % set axes limits based on range of values- supress scientific notation
    xlim([min(x_keep(paramsVaried(i),:)),max(x_keep(paramsVaried(i),:))]);
    xlabel(axisLabels(paramsVaried(i)))
    ax1.XRuler.Exponent = 0;
    ax1.YRuler.Exponent = 0;

    % plot red dashed line at best fit point
    xline(xFit(paramsVaried(i)),"r--");

    % set subplot and position (tight layout) for M_frac
    ax2 = subplot(3,3,[1 4]);
    pos = get(ax2,'Position');
    pos(1) = 0.1;
    pos(2) = 0.35;
    set(ax2,'Position',pos)

    % make log histogram
    [~,edges] = histcounts(log10(M_frac),numBins);
    histogram(M_frac,10.^edges);
    set(gca,'xscale','log');
    xticks([1e-2 0.05 1e-1 0.5 1e0 5 1e1 50 1e2]);
    xticklabels({'0.01','0.05','0.1','0.5','1','5','10','50','100'})

    % set axes limits based on range of values- supress scientific notation
    set(ax2,'view',[-90 90])
    xlim([min(M_frac),max(M_frac)]);
    xlabel("M_{obs}/M_0")
    ax2.XRuler.Exponent = 0;
    ax2.YRuler.Exponent = 0;

    % plot red dashed line at best fit point
    xline(xFit(7),"r--");

    % set position of scatter plot
    ax3 = subplot(3,3,[2,3,5,6]);
    pos = get(ax3,'Position');
    pos(1) = 0.35;
    pos(2) = 0.35;
    set(ax3,'Position',pos)

    % make dscatter plot- log if t0
    if paramsVaried(i) == 4
        dscatter(x_keep(paramsVaried(i),:)',M_frac','BINS',[numBins,numBins],'LOGX',true,'LOGY',true);
        xticks([1e-2 0.05 1e-1 0.5 1e0 5 1e1 50 1e2]);
    else
        dscatter(x_keep(paramsVaried(i),:)',M_frac','BINS',[numBins,numBins],'LOGY',true);
    end
    yticks([1e-2 0.05 1e-1 0.5 1e0 5 1e1 50 1e2]);

    % set axes limits
    xlim([min(x_keep(paramsVaried(i),:)),max(x_keep(paramsVaried(i),:))]);
    ylim([min(M_frac),max(M_frac)]);

    % add title
    title("Result of MCMC inversion after " + numIt + " iterations")
    hold on
    set(gcf,'Position',[10 10 1000 800])

    % plot crosshairs at best fit point
    xline(xFit(paramsVaried(i)),"r--");
    yline(xFit(7),"r--");

    % remove labels
    xticklabels(ax3,{})
    yticklabels(ax3,{})

    % save figure
    saveas(gcf,path + "run" + p + "_" + paramLabels(paramsVaried(i)) + ...
       "-" + "M_frac" + "_dscatter.png")
    close(gcf)
    
end

end