function [m_curve,c_ratio] = moment_curve(model,t0,h_c_initial,h_c_final)

% set parameters
rho_i = model.rho_i;
rho_w = model.rho_w;
h_i = model.h_i;
g = 9.8;
fs = 1/model.dt;

% calculate c_ratio spacing to correspond to desired t0 and h_c range:
% we want the portion of the curve between h_c_initial and h_c_final to
% be t0*fs long
c_ratio_spacing = (h_c_final-h_c_initial)/(t0*fs);

% make vector of crevasse height ratios from -0.5 to 0.5
c_ratio = -0.5:c_ratio_spacing:0.5;

% make storage vector
moments = zeros(length(c_ratio),1);

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
    moments(c) = m;
    
end

m_curve = moments';

end
