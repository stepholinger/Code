% set parameters
h_c_initial = -0.5;
h_c_final = 0.5;
t0 = 10;
rho_i = 916;
rho_w = 1024;
h_i = 100;
g = 9.8;
fs = 10;

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
    m_crevasse_overburden = (1/3)*g*(rho_i)*(h_c^3) - (1/4)*g*(rho_i)*h_i*(h_c^2) + (1/48)*g*(rho_i)*(h_i^3);
   
    if h_c < h_w
        m_buoyancy = (1/2)*g*(h_c^2)*h_i*rho_i - (1/8)*g*(h_i^3)*rho_i - (1/3)*g*(h_c^3)*rho_w - (1/4)*g*(h_c^2)*h_i*rho_w + (1/48)*g*(h_i^3)*rho_w;
        m = m_overburden - m_crevasse_overburden - m_buoyancy;
    else
        m_buoyancy = (g*h_i^3*rho_i^3)/(6*rho_w^2) - (g*h_i^3*rho_i^2)/(4*rho_w);
        m = m_overburden - m_crevasse_overburden - m_buoyancy;
    end
    moments(c,1) = m;
    moments(c,2) = m_crevasse_overburden;
    moments(c,3) = m_buoyancy;
    moments(c,4) = m_overburden;

end

m_curve = moments';

