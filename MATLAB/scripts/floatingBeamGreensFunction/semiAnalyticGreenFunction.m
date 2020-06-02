function G = semiAnalyticGreenFunction(model)

par = 1;

% set impulse magnitude to pressure magnitude (this should be -1)
Q = model.P;

% make matrix for storing output
G = zeros(model.nx,model.nt);

if par
    
    %parpool("local",str2num(getenv("SLURM_CPUS_PER_TASK")));
    %parpool;
    %poolobj = gcp;  
    
    % use wavenumber vector to calculate solution at each time step
    parfor i = 1:model.nt

        gamma = coth(model.h_w*model.xi)./model.xi;

        term1 = (model.D*model.xi.^4 + model.rho_w*model.g).^(1/2);

        term2 = (model.rho_i*model.h_i + model.rho_w*gamma).^(1/2);

        Ghat = Q .* sin(model.t(i) * term1./term2) ./ (term1.*term2);

        Ghat(1) = Q * model.t(i);

        % take inverse fourier transform
        G(:,i) = ifftshift(ifft(Ghat))/model.dx;    
    end
else 
     % use wavenumber vector to calculate solution at each time step
    for i = 1:model.nt

        gamma = coth(model.h_w*model.xi)./model.xi;

        term1 = (model.D*model.xi.^4 + model.rho_w*model.g).^(1/2);

        term2 = (model.rho_i*model.h_i + model.rho_w*gamma).^(1/2);

        Ghat = Q .* sin(model.t(i) * term1./term2) ./ (term1.*term2);

        Ghat(1) = Q * model.t(i);

        % take inverse fourier transform
        G(:,i) = ifftshift(ifft(Ghat))/model.dx;    
    end
end

