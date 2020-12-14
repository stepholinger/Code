function  [x_keep,L_keep,count,alpha_keep,accept,M_fracs] = mcmc(func,data,x0,xStep,xBounds,...
                 sigma,numIt,M_frac_0,L0,liklihoodType,freq)

% [x_keep, L_keep, count] = mcmc(func,data,x0,xstep,sigma,Niter,varargin)
%
% subroutine for MCMC sampling using Metropolis-Hasting w/ normal
% distribution.
%
% Inputs:
%       func  = function name eg:   mcmc('travel_time',....)
%               parameter required for function in varargin
%       data  = vector of observations
%       x0    = initial estimate of parameter vector
%       xStep = step size in all parameter directions
%       xBnds = bounds (
%       sigma = sigma of normal distribution 
%       numIt = number of iterations
%
% Outputs:
%       x_keep = array of samples
%       L_keep = likelihood of samples
%       count  = number of accepted. Acceptance ratio is count/Niter
%
%  P Segall: 2012
% TODO? Should I add something to seed rand? Better if this is done in
% calling program
% rng('shuffle');

% check to make sure input is a function
fun  = fcnchk(func);

%number of elements in x
numParams = length(x0);

% check dimensions of bounds
if( size(xBounds,1) ~= numParams || size(xBounds,2) ~= 2)
    disp('Dimension of xBounds is not valid')
    return
end

% make empty arrays for storing results
x_keep = zeros(numParams,numIt); 
L_keep = zeros(1,numIt); 
alpha_keep = zeros(1,numIt); 
accept = zeros(1,numIt);
M_fracs = zeros(1,numIt);

% set a few parameters
x = x0;
L = L0;
M = M_frac_0;
H = NaN;

% make counter and start iteration
count = 0;
for k = 1:numIt
disp(' ');
disp(['Starting iteration ' num2str(k) ' of ' num2str(numIt)]);
    
    % generate proposal
    xProp = x + xStep.* 2 .* (rand(1,numParams)-0.5);
    
    % check bounds
    if (min(xProp' > xBounds(:,1)) & min(xProp' < xBounds(:,2)))

        % deal with log t0
        %xProp(4) = 10^(xProp(4));
        
        % generate prediction for proposal
        [dProp,dataAligned,M_frac] = fun(xProp,data,freq);
        
        % deal with log t0
        %xProp(4) = log10(xProp(4));
              
        % calculate likelihood      
        Lprop = liklihood(dProp,dataAligned,sigma,liklihoodType);
        %fprintf("Lprop: " + Lprop + ", " + "L0: " + L0 + "\n")
        % make random number to compare to ratio of likelihoods
        u = rand;
        
        % compute hastings ratio
        H = exp(Lprop-L);
        
        % accept proposal 
        if (L == 0 || u <= min([H,1])) && M_frac < 1
             fprintf("Accepted proposal ( " + u + " < " + min([H,1]) +")\n")
             fprintf("Cumulative acceptance: " + string(round((sum(accept(1:k))/k)*100))+ "%%\n")
             count = count+1;
             x = xProp;
             L = Lprop;
             M = M_frac;
             accept(k) = 1;
        end 
    end
    
    % save results
    M_fracs(k) = M;
    x_keep(:,k) = x;
    L_keep(k) = L;
    alpha_keep(k) = H;
    
end

end