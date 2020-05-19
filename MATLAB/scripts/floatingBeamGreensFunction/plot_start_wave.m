function plot_start_wave(t,eventAlign,sigma,L0,M_frac_0,G_0,x0,numIt,xStep,p)

% plot resulting waveform and starting waveform
plot(t,G_0);
hold on;
plot(t,eventAlign);
title("Data and Starting Waveform")
xlabel("Time (s)")
ylabel("Normalized Velocity")
[k,mk] = max(G_0);            
text(mk*4/3,k/1.5,string("Starting parameters" + newline + "----------------------------" + ...
                        newline + "h_i: " + x0(1) + " m     h_w: " ...
                        + x0(2) + " m" + newline + "X_{stat}: " + ...
                        x0(3)/1000 + " km" + "     t_0: " + x0(4) + ...
                        newline + "M/M_0: " + M_frac_0 + newline))
                    
text(mk*4/3,k/3,string("MCMC parameters" + newline + "----------------------------" + newline + ...                            
                       "h_i step: " + xStep(1) + " m    h_w step: " + xStep(2) + " m" + newline + ...
                       "X_{stat} step: " + xStep(3) + " m    t_0 step: " + xStep(4) + " s" + newline + ...
                       "Number of iterations: " + numIt + newline + "Sigma: " + sigma + newline + ...
                       "L_0: " + L0))                   
l = legend("MCMC starting model","Data");
set(l,'Location','southwest');
set(gcf,'Position',[10 10 1000 800])
hold off
saveas(gcf,"/home/setholinger/Documents/Projects/PIG/modeling/mcmc/run" + p + "_start_wave.png")
close(gcf)

end