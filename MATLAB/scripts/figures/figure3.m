%makes multipanel histogram and timeseries figure for RIS paper
hold on

figure(1)

histColor = [0.95,0.50,0];
xLimit = [735930 736645];
set(1,'Position',[1 1 1200 1000]);
ticks = [735904,735935,735966,735994,736025,736055,736086,736116,736147,736178,736208,736239,736269,736300,736331,736360,736391,736421,736452,736482,736513,736544,736574,736605,736635];
set(1,'Renderer','painters');

subplot(4,1,1)
title('Temperature and Rift Seismicity')

yyaxis right;
histogram(eventTimesMatlab,720,'FaceColor',histColor,'EdgeColor',histColor,'FaceAlpha',1);
ylim([0 60]);
ylabel('Number of Events');
set(gca,'ycolor','k','TickDir','out');

yyaxis left;
plot(AWStimes,AWStemp,'LineWidth',1,'Color',[0 0 210/255]);
ylim([-100 20]);
ylabel('Temperature (^oC)');
datetick('x','m');
set(gca,'ycolor',[0 0 210/255],'TickDir','out');
set(gca,'FontSize',18,'FontName','Times New Roman');
set(gca,'xtick',ticks);
xlim(xLimit);

subplot(4,1,2)
title('Spectrogram of Swell and IG Waves')
set(gca,'FontSize',18,'FontName','Times New Roman');
%set(gca,'ycolor',[0.7 0 0]) 

yyaxis left
pcolor(tDatenum,f(1:ind),log10(abs(p(1:ind,:))));
xlim(xLimit);
ylim([0.015 0.2])
colormap spring
caxis([0 10])
colorbar
shading interp;
datetick('x','m');
set(gca,'ycolor',[180/255 0 0],'TickDir','out');
set(gca,'TickDir','out');
set(gca,'xtick',ticks);
xlim(xLimit);
ylabel('Frequency (Hz)');

yyaxis right;
ylabel('Power (nm^2/Hz)');

histogram(eventTimesMatlab,720,'FaceAlpha',1,'EdgeColor','w','FaceColor','w')
ylim([0 200]);
ylabel('Number of Events');
set(gca,'ycolor','k') 

subplot(4,1,3)
title('Swell Band Power and Rift Seismicity')

yyaxis right;
histogram(eventTimesMatlab,720,'FaceColor',histColor,'EdgeColor',histColor,'FaceAlpha',1);
ylim([0 200]);
ylabel('Number of Events');
set(gca,'ycolor','k','TickDir','out') 

yyaxis left;
plot(tDatenum,powerbandSwell,'LineWidth',1.5,'Color',[150/255 0 150/255]);
ylim([-2e7 11e7]);
ylabel('Power (nm^2)');
datetick('x','m');
set(gca,'ycolor',[150/255 0 150/255],'TickDir','out');
set(gca,'FontSize',18,'FontName','Times New Roman');
set(gca,'xtick',ticks);
xlim(xLimit);

subplot(4,1,4)
title('IG Band Power and Rift Seismicity')

yyaxis right;
histogram(eventTimesMatlab,720,'FaceColor',histColor,'EdgeColor',histColor,'FaceAlpha',1);
ylim([0 200]);
ylabel('Number of Events');
set(gca,'ycolor','k','TickDir','out') 

yyaxis left;
plot(tDatenum,powerbandIG,'LineWidth',1,'Color',[0 150/255 0]);
ylim([-1e9 4e9]);
ylabel('Power (nm^2)');
datetick('x','m');
set(gca,'ycolor',[0 150/255 0],'TickDir','out');
set(gca,'FontSize',18,'FontName','Times New Roman');
set(gca,'xtick',ticks);
xlim(xLimit);