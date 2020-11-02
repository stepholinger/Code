% set parameters
L = 1e7;
f_max = 1;
t_max = 100;
h_i = 350;
h_w = 600;

% make model object to get needed values 
model = loadParameters(L,f_max,t_max,h_i,h_w);

sanityMatrix = zeros(3,2);

% check 1: 1/time step should be equal 2*f_max
sanityMatrix(1,1) = f_max*2;
sanityMatrix(1,2) = 1/model.dt;

% check 2: dx should equal 2*pi/maximum angular wavenumber
xi_max = max(model.xi);
sanityMatrix(2,1) = model.dx;
sanityMatrix(2,2) = pi/xi_max;

% check 3: maximum angular wavenumber should correspond to f_max via
% dispersion relation
gamma = coth(model.h_w*xi_max)./xi_max;
s = sqrt((model.D*xi_max.^4 + model.rho_w*model.g)./(model.rho_i*model.h_i + model.rho_w.*gamma));
sanityMatrix(3,1) = f_max;
sanityMatrix(3,2) = s/2/pi;