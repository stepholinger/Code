function k = makeWavenumberVector(L,nx)

% calculate step size using length and number of grid points
dx = L/nx; 

% make zero vector
k = zeros(nx,1);

% fill first half with values from 0 to 1
k(1:nx/2+1) = 2*[0:nx/2]/nx;

% fill second half with values from -1 to 0
k(nx:-1:nx/2+2) = -k(2:nx/2);

% scale by maximum wavenumber (pi/dx)
k = k*pi/dx;

end