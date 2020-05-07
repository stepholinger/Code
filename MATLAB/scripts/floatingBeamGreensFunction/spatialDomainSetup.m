function model = spatialDomainSetup(model,f_max)

% calculate xi_max using real part of dispersion relation
xi_step = 1/1000000;
xi_max = xi_step; 
f = 0;

% the iteration below may be slow if running the model repeatedly!
while f < f_max

    % calculate gamma parameter
    gamma = coth(model.h_w*xi_max)./xi_max;

    % calculate real part of dispersion relation
    s = sqrt((model.D*xi_max.^4 + model.rho_w*model.g)./(model.rho_i*model.h_i + model.rho_w.*gamma));
    f = s/2/pi;
    
    % advance xi_max until s exceeds f_max
    xi_max = xi_max + xi_step;

end

% get dx from xi_max (which in this case is the nyquist wavenumber) and
% divide by 2 to get dx corresponding to twice the nyquist wavenumber
model.dx = pi/xi_max;

% set up spatial domain
model.nx = round(model.L/model.dx);

% if odd number of x grid points, subtract 1 and update dx
if mod(model.nx,2) == 1
    model.nx = model.nx-1;
    model.dx = model.L/model.nx;
end

% get x axis in distance
model.x = [0:model.nx-1]' * model.dx - model.L/2;

% get wavenumber axis
model.xi = makeWavenumberVector(model.L,model.nx);

end