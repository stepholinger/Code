
% define basic parameters
statDist = 10000;
L = 1e7;
f_max = 1;
t_max = 500;
h_w = 250;
h_i = 250;
h_c_initial = -0.5;
h_c_final_vect = [-0.25,0,0.25,0.375,0.5];
t0 = 10;

% set some plot relevant stuff
spacing = 3;
numSteps = length(h_c_final_vect);
c = hot(floor(numSteps*2.5));

% get m curve for left panel and plot it
[model,dGdt,stf] = calcGF_crevasse_moment(L,f_max,t_max,h_i,h_w,statDist,t0,h_c_initial,h_c_final_vect(1));
[m_curve,c_ratio] = moment_curve(model,t_max,-0.5,0.5);
m_curve_norm = m_curve/m_curve(end);
figure(1)
subplot(1,4,1:2)
plot(c_ratio,m_curve_norm)
xticks([-0.5,-0.25,0,0.25,0.5])
xticklabels({'0%','25%','50%','75%','100%'})
ylim([min(m_curve_norm)-0.25,max(m_curve_norm)+0.25])
hold on
scatter(h_c_initial,m_curve_norm(1),50,'filled','k')
text(h_c_initial,m_curve_norm(1),{' Initial h_c',""})

for s = 1:numSteps  
    
    % step
    h_c_final = h_c_final_vect(s);
    
    % get waveform and stf
    [model,dGdt,stf] = calcGF_crevasse_moment(L,f_max,t_max,h_i,h_w,statDist,t0,h_c_initial,h_c_final);
    [~,h_c_final_idx] = min(abs(c_ratio - h_c_final));
    
    % get min and max values
    [min_value,min_idx] = min(dGdt);
    [max_value,max_idx] = max(dGdt);
    if abs(min_value) > max_value
        peak_value = min_value;
        peak_idx = min_idx;
    else
        peak_value = max_value;
        peak_idx = max_idx;
    end
    
    % plot the moment curve and crevasse heights
    subplot(1,4,1:2)
    scatter(h_c_final,m_curve_norm(h_c_final_idx),50,c(s+1,:),'filled')
    text(h_c_final,m_curve_norm(h_c_final_idx),{'Final h_c ',""},'Color',c(s+1,:),'HorizontalAlignment','right')
    ylabel("Fraction of max bending moment M_0") 
    xlabel("Crevasse height (% ice thickness)")

    % plot the waveform
    subplot(1,4,3:4)
    plot(model.t,dGdt/abs(peak_value)+spacing*s,'Color',c(s+1,:))
    hold on
    num = sprintf('A_{max}: %0.2e',peak_value);
    scatter(model.t(peak_idx),1*sign(peak_value)+spacing*s,50,c(s+1,:),'filled')
    text(model.t(peak_idx),1*sign(peak_value)+spacing*s,{num,""},'Color',c(s+1,:))
    yticklabels(gca,{})
    yticks({})
    xlabel("Time (s)")
    
end
ylim([0,spacing*(s+1)])
sgtitle("Influence of final crevasse height (0 initial crevasse height)")



% define basic parameters
statDist = 10000;
L = 1e7;
f_max = 1;
t_max = 500;
h_w = 250;
h_i = 250;
h_c_initial = -0.25;
h_c_final_vect = [0,0.25,0.375,0.5];
t0 = 10;

% set some plot relevant stuff
spacing = 3;
numSteps = length(h_c_final_vect);
c = hot(floor(numSteps*2.5));

% get m curve for left panel and plot it
[m_curve,c_ratio] = moment_curve(model,t_max,-0.5,0.5);
m_curve_norm = m_curve/m_curve(end);
figure(2)
subplot(1,4,1:2)
plot(c_ratio,m_curve_norm)
xticks([-0.5,-0.25,0,0.25,0.5])
xticklabels({'0%','25%','50%','75%','100%'})
ylim([min(m_curve_norm)-0.25,max(m_curve_norm)+0.25])
hold on
[~,h_c_initial_idx] = min(abs(c_ratio - h_c_initial));
scatter(h_c_initial,m_curve_norm(h_c_initial_idx),50,'filled','k')
text(h_c_initial,m_curve_norm(h_c_initial_idx),{' Initial h_c',""})

for s = 1:numSteps  
    
    % step
    h_c_final = h_c_final_vect(s);
    
    % get waveform and stf
    [model,dGdt,stf] = calcGF_crevasse_moment(L,f_max,t_max,h_i,h_w,statDist,t0,h_c_initial,h_c_final);
    [~,h_c_final_idx] = min(abs(c_ratio - h_c_final));
    
    % get min and max values
    [min_value,min_idx] = min(dGdt);
    [max_value,max_idx] = max(dGdt);
    if abs(min_value) > max_value
        peak_value = min_value;
        peak_idx = min_idx;
    else
        peak_value = max_value;
        peak_idx = max_idx;
    end
    
    % plot the moment curve and crevasse heights
    subplot(1,4,1:2)
    scatter(h_c_final,m_curve_norm(h_c_final_idx),50,c(s+1,:),'filled')
    text(h_c_final,m_curve_norm(h_c_final_idx),{'Final h_c ',""},'Color',c(s+1,:),'HorizontalAlignment','right')
    ylabel("Fraction of max bending moment M_0") 
    xlabel("Crevasse height (% ice thickness)")

    % plot the waveform
    subplot(1,4,3:4)
    plot(model.t,dGdt/abs(peak_value)+spacing*s,'Color',c(s+1,:))
    hold on
    num = sprintf('A_{max}: %0.2e',peak_value);
    scatter(model.t(peak_idx),1*sign(peak_value)+spacing*s,50,c(s+1,:),'filled')
    text(model.t(peak_idx),1*sign(peak_value)+spacing*s,{num,""},'Color',c(s+1,:))
    yticklabels(gca,{})
    yticks({})
    xlabel("Time (s)")
    
end
ylim([0,spacing*(s+1)])
sgtitle("Influence of final crevasse height (0.25h_i initial crevasse height)")



% define basic parameters
statDist = 10000;
L = 1e7;
f_max = 1;
t_max = 500;
h_w = 250;
h_i = 250;
h_c_initial = 0;
h_c_final_vect = [0.25,0.375,0.5];
t0 = 10;

% set some plot relevant stuff
spacing = 3;
numSteps = length(h_c_final_vect);
c = hot(floor(numSteps*3));

% get m curve for left panel and plot it
[m_curve,c_ratio] = moment_curve(model,t_max,-0.5,0.5);
m_curve_norm = m_curve/m_curve(end);
figure(3)
subplot(1,4,1:2)
plot(c_ratio,m_curve_norm)
xticks([-0.5,-0.25,0,0.25,0.5])
xticklabels({'0%','25%','50%','75%','100%'})
ylim([min(m_curve_norm)-0.25,max(m_curve_norm)+0.25])
hold on
[~,h_c_initial_idx] = min(abs(c_ratio - h_c_initial));
scatter(h_c_initial,m_curve_norm(h_c_initial_idx),50,'filled','k')
text(h_c_initial,m_curve_norm(h_c_initial_idx),{' Initial h_c',""})

for s = 1:numSteps  
    
    % step
    h_c_final = h_c_final_vect(s);
    
    % get waveform and stf
    [model,dGdt,stf] = calcGF_crevasse_moment(L,f_max,t_max,h_i,h_w,statDist,t0,h_c_initial,h_c_final);
    [~,h_c_final_idx] = min(abs(c_ratio - h_c_final));
    
    % get min and max values
    [min_value,min_idx] = min(dGdt);
    [max_value,max_idx] = max(dGdt);
    if abs(min_value) > max_value
        peak_value = min_value;
        peak_idx = min_idx;
    else
        peak_value = max_value;
        peak_idx = max_idx;
    end
    
    % plot the moment curve and crevasse heights
    subplot(1,4,1:2)
    scatter(h_c_final,m_curve_norm(h_c_final_idx),50,c(s+1,:),'filled')
    text(h_c_final,m_curve_norm(h_c_final_idx),{'Final h_c ',""},'Color',c(s+1,:),'HorizontalAlignment','right')
    ylabel("Fraction of max bending moment M_0") 
    xlabel("Crevasse height (% ice thickness)")

    % plot the waveform
    subplot(1,4,3:4)
    plot(model.t,dGdt/abs(peak_value)+spacing*s,'Color',c(s+1,:))
    hold on
    num = sprintf('A_{max}: %0.2e',peak_value);
    scatter(model.t(peak_idx),1*sign(peak_value)+spacing*s,50,c(s+1,:),'filled')
    text(model.t(peak_idx),1*sign(peak_value)+spacing*s,{num,""},'Color',c(s+1,:))
    yticklabels(gca,{})
    yticks({})
    xlabel("Time (s)")
    
end
ylim([0,spacing*(s+1)])
sgtitle("Influence of final crevasse height (0.5h_i initial crevasse height)")



% define basic parameters
statDist = 10000;
L = 1e7;
f_max = 1;
t_max = 500;
h_w = 250;
h_i = 250;
h_c_initial = 0.25;
h_c_final_vect = [0.375,0.5];
t0 = 10;

% set some plot relevant stuff
spacing = 3;
numSteps = length(h_c_final_vect);
c = hot(floor(numSteps*3));

% get m curve for left panel and plot it
[m_curve,c_ratio] = moment_curve(model,t_max,-0.5,0.5);
m_curve_norm = m_curve/m_curve(end);
figure(4)
subplot(1,4,1:2)
plot(c_ratio,m_curve_norm)
xticks([-0.5,-0.25,0,0.25,0.5])
xticklabels({'0%','25%','50%','75%','100%'})
ylim([min(m_curve_norm)-0.25,max(m_curve_norm)+0.25])
hold on
[~,h_c_initial_idx] = min(abs(c_ratio - h_c_initial));
scatter(h_c_initial,m_curve_norm(h_c_initial_idx),50,'filled','k')
text(h_c_initial,m_curve_norm(h_c_initial_idx),{' Initial h_c',""})

for s = 1:numSteps  
    
    % step
    h_c_final = h_c_final_vect(s);
    
    % get waveform and stf
    [model,dGdt,stf] = calcGF_crevasse_moment(L,f_max,t_max,h_i,h_w,statDist,t0,h_c_initial,h_c_final);
    [~,h_c_final_idx] = min(abs(c_ratio - h_c_final));
    
    % get min and max values
    [min_value,min_idx] = min(dGdt);
    [max_value,max_idx] = max(dGdt);
    if abs(min_value) > max_value
        peak_value = min_value;
        peak_idx = min_idx;
    else
        peak_value = max_value;
        peak_idx = max_idx;
    end
    
    % plot the moment curve and crevasse heights
    subplot(1,4,1:2)
    scatter(h_c_final,m_curve_norm(h_c_final_idx),50,c(s+1,:),'filled')
    text(h_c_final,m_curve_norm(h_c_final_idx),{'Final h_c ',""},'Color',c(s+1,:),'HorizontalAlignment','right')
    ylabel("Fraction of max bending moment M_0") 
    xlabel("Crevasse height (% ice thickness)")

    % plot the waveform
    subplot(1,4,3:4)
    plot(model.t,dGdt/abs(peak_value)+spacing*s,'Color',c(s+1,:))
    hold on
    num = sprintf('A_{max}: %0.2e',peak_value);
    scatter(model.t(peak_idx),1*sign(peak_value)+spacing*s,50,c(s+1,:),'filled')
    text(model.t(peak_idx),1*sign(peak_value)+spacing*s,{num,""},'Color',c(s+1,:))
    yticklabels(gca,{})
    yticks({})
    xlabel("Time (s)")
    
end
ylim([0,spacing*(s+1)])
sgtitle("Influence of final crevasse height (0.75h_i initial crevasse height)")




% define basic parameters
statDist = 10000;
L = 1e7;
f_max = 1;
t_max = 500;
h_w = 250;
h_i = 250;
h_c_initial = -0.5;
h_c_final = 0.5;
t0_vect = [1,10,20,100];

% set some plot relevant stuff
spacing = 3;
numSteps = length(t0_vect);
c = hot(floor(numSteps*3));

% get m curve for left panel and plot it
[m_curve,c_ratio] = moment_curve(model,t_max,-0.5,0.5);
m_curve_norm = m_curve/m_curve(end);
figure(5)
subplot(1,4,1:2)
plot(c_ratio,m_curve_norm)
xticks([-0.5,-0.25,0,0.25,0.5])
xticklabels({'0%','25%','50%','75%','100%'})
ylim([min(m_curve_norm)-0.25,max(m_curve_norm)+0.25])
hold on   
[~,h_c_final_idx] = min(abs(c_ratio - h_c_final));
scatter(h_c_initial,m_curve_norm(1),50,'filled','k')
text(h_c_initial,m_curve_norm(1),{' Initial h_c',""})
scatter(h_c_final,m_curve_norm(h_c_final_idx),50,c(s+1,:),'filled')
text(h_c_final,m_curve_norm(h_c_final_idx),{'Final h_c ',""},'Color',c(s+1,:),'HorizontalAlignment','right')
ylabel("Fraction of max bending moment M_0") 
xlabel("Crevasse height (% ice thickness)")

for s = 1:numSteps  
    
    % step
    t0 = t0_vect(s);
    
    % get waveform and stf
    [model,dGdt,stf] = calcGF_crevasse_moment(L,f_max,t_max,h_i,h_w,statDist,t0,h_c_initial,h_c_final);
    
    % get min and max values
    [min_value,min_idx] = min(dGdt);
    [max_value,max_idx] = max(dGdt);
    if abs(min_value) > max_value
        peak_value = min_value;
        peak_idx = min_idx;
    else
        peak_value = max_value;
        peak_idx = max_idx;
    end
    
    % plot the moment curve and crevasse heights
    subplot(1,4,1:2)

    % plot the waveform
    subplot(1,4,3:4)
    plot(model.t,dGdt/abs(peak_value)+spacing*s,'Color',c(s+1,:))
    hold on
    num = sprintf('A_{max}: %0.2e       t_0: %g',peak_value,t0);
    scatter(model.t(peak_idx),1*sign(peak_value)+spacing*s,50,c(s+1,:),'filled')
    text(model.t(peak_idx),1*sign(peak_value)+spacing*s,{num,""},'Color',c(s+1,:))
    yticklabels(gca,{})
    yticks({})
    xlabel("Time (s)")
    
end
ylim([0,spacing*(s+1)])
sgtitle("Influence of t_0 (0 initial crevasse height)")



% define basic parameters
statDist = 10000;
L = 1e7;
f_max = 1;
t_max = 500;
h_w = 250;
h_i = 250;
h_c_initial = 0;
h_c_final = 0.5;
t0_vect = [1,10,20,100];

% set some plot relevant stuff
spacing = 3;
numSteps = length(t0_vect);
c = hot(floor(numSteps*3));

% get m curve for left panel and plot it
[m_curve,c_ratio] = moment_curve(model,t_max,-0.5,0.5);
m_curve_norm = m_curve/m_curve(end);
figure(6)
subplot(1,4,1:2)
plot(c_ratio,m_curve_norm)
xticks([-0.5,-0.25,0,0.25,0.5])
xticklabels({'0%','25%','50%','75%','100%'})
ylim([min(m_curve_norm)-0.25,max(m_curve_norm)+0.25])
hold on   
[~,h_c_final_idx] = min(abs(c_ratio - h_c_final));
[~,h_c_initial_idx] = min(abs(c_ratio - h_c_initial));
scatter(h_c_initial,m_curve_norm(h_c_initial_idx),50,'filled','k')
text(h_c_initial,m_curve_norm(h_c_initial_idx),{' Initial h_c',""})
scatter(h_c_final,m_curve_norm(h_c_final_idx),50,c(s+1,:),'filled')
text(h_c_final,m_curve_norm(h_c_final_idx),{'Final h_c ',""},'Color',c(s+1,:),'HorizontalAlignment','right')
ylabel("Fraction of max bending moment M_0") 
xlabel("Crevasse height (% ice thickness)")

for s = 1:numSteps  
    
    % step
    t0 = t0_vect(s);
    
    % get waveform and stf
    [model,dGdt,stf] = calcGF_crevasse_moment(L,f_max,t_max,h_i,h_w,statDist,t0,h_c_initial,h_c_final);
    
    % get min and max values
    [min_value,min_idx] = min(dGdt);
    [max_value,max_idx] = max(dGdt);
    if abs(min_value) > max_value
        peak_value = min_value;
        peak_idx = min_idx;
    else
        peak_value = max_value;
        peak_idx = max_idx;
    end
    
    % plot the moment curve and crevasse heights
    subplot(1,4,1:2)

    % plot the waveform
    subplot(1,4,3:4)
    plot(model.t,dGdt/abs(peak_value)+spacing*s,'Color',c(s+1,:))
    hold on
    num = sprintf('A_{max}: %0.2e       t_0: %g',peak_value,t0);
    scatter(model.t(peak_idx),1*sign(peak_value)+spacing*s,50,c(s+1,:),'filled')
    text(model.t(peak_idx),1*sign(peak_value)+spacing*s,{num,""},'Color',c(s+1,:))
    yticklabels(gca,{})
    yticks({})
    xlabel("Time (s)")
    
end
ylim([0,spacing*(s+1)])
sgtitle("Influence of t_0 (0.5h_i initial crevasse height)")

