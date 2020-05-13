% this script produces green's function matrices for a range of ice and
% water thicknesses- result is not scaled or convolved with a source time
% function
L = 1e7;
f_max = 1;
t_max = 1000;
h_i_vect = [50,100,150,200,250,300,350,400,450,500];
h_w_vect = [50,100,150,200,250,300,350,400,450,500,550,600,650,700,750,800,850,900,950,1000];
statDist = [1000,50000];

for i = 1:length(h_i_vect)
    for w = 1:length(h_w_vect)
        
        % set parameters
        h_i = h_i_vect(i);
        h_w = h_w_vect(w);

        % make model object
        model = loadParameters(L,f_max,t_max,h_i,h_w);
        
        % run model
        G = semiAnalyticGreenFunction(model);

        % take spatial derivative
        [~,dGdx] = gradient(G,model.dx);

        % scale by ice front bending moment
        M_max =  916 * 9.8 * h_i^3 / 12 * 0.072;
        G_scaled = dGdx * M_max;  
        
        % only save part of result within range of station distances we
        % care about
        [~,shortIdx] = min(abs(model.x - statDist(1)));
        [~,longIdx] = min(abs(model.x - statDist(2)));
        G_scaled = G_scaled(shortIdx:longIdx,:);
        
        % store result
        G_mat{i,w} = G_scaled;
        model_mat{i,w} = model;

    end
end