function plot_M_frac(x_keep,M_frac,xFit,numIt,p,paramsVaried,axisLabels,paramLabels)

% make dscatter density plot of results
    for i = 1:length(paramsVaried)

        dscatter(x_keep(paramsVaried(i),:)',M_frac');
        xlim([min(x_keep(paramsVaried(i),:)),max(x_keep(paramsVaried(i),:))]);
        ylim([min(M_frac),max(M_frac)]);
        title("Result of MCMC inversion after " + numIt + " iterations")
        xlabel(axisLabels(paramsVaried(i)))
        ylabel("M/M_0")
        hold on
        set(gcf,'Position',[10 10 1000 800])
        ax = gca;
        ax.XRuler.Exponent = 0;
        ax.YRuler.Exponent = 0;
        xline(xFit(paramsVaried(i)),"r--");
        saveas(gcf,"/home/setholinger/Documents/Projects/PIG/modeling/mcmc/run" + ... 
                   p + "_" + paramLabels(paramsVaried(i)) + "-" + "Mfrac" + "_dscatter.png")
        close(gcf)

    end
     
end