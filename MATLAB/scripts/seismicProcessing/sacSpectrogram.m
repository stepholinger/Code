% reads sac file and makes spectrogram- run from location of data

maxFreq = 50;

multipleFiles = 'no';

filename = '/media/setholinger/Data/Data/PIG/SAC/noIR/PIG2/HHZ/2013-02-10.PIG2.HHZ.noIR.SAC';

if strcmp(multipleFiles,'yes')

    % get filenames
    files = dir();
 
    t0 = 0;
    
    % loop through directory
    for n = 1:length(files)

        % check if file actual contains data
        if files(n).bytes > 0 
            
            % call readsac to read sac
            sac = readsac(files(n).name);
            
            % make spectrogram
            [s,f,t,p] = spectrogram(sac.trace,10000,1000,[],1);
            % plot it with proper parameters
            figure(1);
            colormap jet;
            hold on

            %pcolor(t0 + t,log10(f),log10(abs(p)));
            
            shading interp;

            % update time axis counter
            t0 = t0 + t(end);

        end
    end
end

if strcmp(multipleFiles,'no')
    
    sac = readsac(filename);    
    
    [s,f,t,p] = spectrogram(sac.trace,10000,5000,[],1);
    [~,ind] = min(abs(f-maxFreq));
    [~,indIG] = min(abs(f-0.03));
    [~,indSwell] = min(abs(f-0.15));

    powerbandIG = sum(abs(p(1:indIG,:)))*mean(diff(f));
    powerbandSwell = sum(abs(p(indIG:indSwell,:)))*mean(diff(f));
    
    % convert t to datetime
    startDate = datenum(2013,02,10);
    tDays = t/86400;
    tDatenum = tDays + startDate;
    
    % plot it with proper parameters
    figure(1);
    colormap parula;
    
    pcolor(tDatenum,f(1:ind),log10(abs(p(1:ind,:))));
    colorbar; 
    %caxis([6 10])
    shading interp;
    
    figure(2)
    hold on
    plot(tDatenum,swellPowerband,'Color',[0,0.5,0],'LineWidth',1);
    plot(tDatenum,IGPowerband,'Color',[0.8,0,0],'LineWidth',1)
    ylim([-1e8 10e8]);

    
end





%periodogram:
%split day file into 50 windows
%FFT each window
%average them