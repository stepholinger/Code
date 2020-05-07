function model = loadParameters(L,f_max,t_max,h_i,h_w)

% set material properties and geometry
model.rho_i = 916;					% Density of ice
model.rho_w = 1024;					% Density of water
model.h_i = h_i;                    % Ice thickness
model.h_w = h_w;					% Water depth
E = 8.7e9;							% Young's modulus
nu = 0.3;							% Poisson's Ratio
model.D = E * (h_i^3)/12/(1-nu^2);	% Flexural Rigidity
model.g = 9.8;						% Gravity
model.P = -1;						% Applied Pressure, negative down
phi0 = 0.072;

% calculate ice front bending moment
model.M = model.rho_i * model.g * model.h_i^3 /12 * phi0;

% set model time parameters using time length and desired max frequency
model.t_max = t_max;
model.dt = 1/f_max/2;
model.nt = model.t_max/model.dt;
model.t = linspace(0,model.t_max,model.nt);

% set up model space parameters
model.L = L;
model = spatialDomainSetup(model,f_max);

end
