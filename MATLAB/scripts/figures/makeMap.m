%outline grounded portion
bedmap2 patchgl
%outline floating portion
bedmap2('patchshelves','frame','on')
%color map for surface elevation
%bedmap2 surfacew
%add grid; use --> (...,'OceanColor','b') to color ocean
antmap('graticule','color','k','OceanColor',[0,0,0.4])
%antmap('graticule','color','k')
%label features
%scarlabel({'South Pole'})
%outline Ross
outlineashelf('ross ice shelf','linewidth',2,'color',[0.7,0.15,0.1]) 
%plot station locations
scatterm(statLat,statLon,'k^','filled','linewidth',20)
fig = gcf;
fig.Renderer = 'Painters';