function dispersionCurve(L,f_max,t_max,h_i,h_w)

% make model object to get needed values 
model = loadParameters(L,f_max,t_max,h_i,h_w);

% calculate gamma parameter
gamma = coth(model.h_w*model.xi)./model.xi;

% calculate real part of dispersion relation
s = sqrt((model.D*model.xi.^4 + model.rho_w*model.g)./(model.rho_i*model.h_i + model.rho_w.*gamma));

% calculate phase velocities
c_sw = ones(length(model.xi),1)*sqrt(model.g*model.h_w);
c_dw = sqrt(model.g./model.xi);
c_f = (model.D/(model.rho_i*model.h_i))^(1/2).*model.xi;
c = s./model.xi;

% convert from angular wavenumber and frequency
model.xi = model.xi/2/pi;
s = s/2/pi;

% plot dispersion relation for each wave type
%plot(model.xi(model.xi>0),c_sw(model.xi>0))
%plot(model.xi(model.xi>0),c_dw(model.xi>0))
%plot(model.xi(model.xi>0),c_f(model.xi>0))

% plot vanilla dispersion relation 
%plot(model.xi(model.xi>0),s(model.xi>0)./model.xi(model.xi>0))

% calculate flexural gravity wavelength
lambda = (model.D/(model.rho_w*model.g))^(1/4)*2*pi;

% nondimensionalize by flexural wavelength and plot
figure(1)
loglog(model.xi(model.xi>0)*lambda,c_sw(model.xi>0),'--','Color','r')
hold on;
loglog(model.xi(model.xi>0)*lambda,c_dw(model.xi>0),'--','Color','b')
loglog(model.xi(model.xi>0)*lambda,c_f(model.xi>0),'--','Color',[0,0.5,0])
loglog(model.xi(model.xi>0)*lambda,c(model.xi>0),'k','LineWidth',2)

% add legend, titles, etc...
l = legend('Shallow Water $\sqrt{gh}$','Deep Water $\sqrt{g/\xi}$',...
           'Simple Beam $\xi\sqrt{\frac{D}{\rho_i h_i}}$',...
           'Floating Beam $\sqrt{\frac{D \xi^4 + \rho_w g}{\rho_i h_i + \rho_w \gamma}}$');
set(l,'Interpreter','latex','Location','southeast');
title("Dispersion for h_i=" + h_i + " m and h_w=" + h_w + " m")
xlabel('Normalized Wavenumber, \xi \cdot \lambda'); 
ylabel('Phase Velocity, s/\xi');
unitLine = xline(1,'-','\xi = 1/\lambda                      ','LabelVerticalAlignment','middle');
set(get(get(unitLine,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
grid on 

% plot frequency as a function of wavenumber with physical units
figure(2)
plot(model.xi(1:model.nx/2),s(1:model.nx/2))
title("Dispersion for h_i=" + h_i + " m and h_w=" + h_w + " m")
xlabel('Wavenumber (m^{-1})'); 
ylabel('Frequency (Hz)');
xlim([0,max(model.xi)])

end