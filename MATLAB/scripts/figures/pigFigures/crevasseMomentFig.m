% set parameters
rho_i = 916;
rho_w = 1024;
h_i = 100;
g = 9.8;

% make vector of crevasse height ratios from -0.5 to 0.5
c_ratio = -0.5:0.01:0.5;

% make storage vector
moments = zeros(length(c_ratio),4);

% calculate moment for each crevasse fraction
for c=1:length(c_ratio)
    h_c = c_ratio(c)*h_i;
    h_w = -h_i/2 + h_i * rho_i/rho_w;
    
    % calculate first part of moment expression
    m_overburden = -(1/12)*g*rho_i*h_i^3;
    m_buoyancy = (1/6)*(1/(rho_w^2))*g*(rho_i^3)*(h_i^3) - (1/4)*(1/(rho_w))*g*(rho_i^2)*(h_i^3);
    m0 = m_overburden - m_buoyancy;
    m_crevasse = (1/3)*g*(rho_i)*(h_c^3) - (1/4)*g*(rho_i)*h_i*(h_c^2) + (1/48)*g*(rho_i)*(h_i^3);
    m_correction = -(1/2)*g*(rho_i)*(h_c^2)*(h_i) + (1/8)*g*(rho_i)*(h_i^3) + (1/6)*(1/rho_w^2)*g*(rho_i^3)*(h_i^3) - ...
                   (1/4)*(1/rho_w)*g*(rho_i^2)*(h_i^3)+(1/3)*g*(rho_w)*(h_c^3) + (1/4)*g*(rho_w)*h_i*(h_c^2) - (1/48)*g*(rho_w)*(h_i^3);
    if h_c < h_w
        m = m0 - m_crevasse + m_correction;
    else
        m = m0 - m_crevasse;
        m_correction = 0;
    end
    moments(c,1) = m;
    moments(c,2) = m_overburden-1*m_crevasse;
    moments(c,3) = -1*m_buoyancy+m_correction;
end

sgtitle("Fraction of max bending moment m_0")
subplot(3,1,1)
plot(c_ratio,moments(:,1)/m0)
moment_curve = moments(:,1)/m0;
xlabel("h_c/h_i")
ylabel("Total")
save("moment_crevasse_height_curve.mat","moment_curve","c_ratio")

subplot(3,1,2)
plot(c_ratio,moments(:,2)/m0)
yline(m_overburden/m0)
xlabel("h_c/h_i")
ylabel("Ice overburden")

subplot(3,1,3)
plot(c_ratio,moments(:,3)/m0)
hold on
yline(-1*m_buoyancy/m0)
xlabel("h_c/h_i")
ylabel("Buoyancy")

% make second set of plots
delta_m_final_mat = zeros(length(c_ratio));
delta_m_transient_mat = zeros(length(c_ratio));

for c1 = 1:length(c_ratio)
    
   h_c1 = c_ratio(c1)*h_i;
   m1 = moments(c1,1)/m0;
   
   for c2 = c1:length(c_ratio) 
       
       h_c2 = c_ratio(c2)*h_i;
       m2 = moments(c2,1)/m0;

       delta_m_final_mat(c1,c2) = m2-m1;
       [max_m, max_ind] = max(abs(moments(c1:c2,1)));
       delta_m_transient_mat(c1,c2) = sign(moments(c1+max_ind-1,1))*max_m/m0-m1;
 
   end
end
figure(2)
pcolor(c_ratio,c_ratio,delta_m_final_mat)
shading interp
colorbar
title('Change in moment \Deltam_{final}')
xticks([-0.5,-0.25,0,0.25,0.5])
yticks([-0.5,-0.25,0,0.25,0.5])
ylabel('Initial crevasse height (normalized by ice thickness)')
xlabel('Final crevasse height (normalized by ice thickness)')

figure(3)
pcolor(c_ratio,c_ratio,delta_m_transient_mat)
shading interp
colorbar
title('Maximum change in moment during crevasse growth \Deltam_{transient}')
xticks([-0.5,-0.25,0,0.25,0.5])
yticks([-0.5,-0.25,0,0.25,0.5])
ylabel('Initial crevasse height (normalized by ice thickness)')
xlabel('Final crevasse height (normalized by ice thickness)')
