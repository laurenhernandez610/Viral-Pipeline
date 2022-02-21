%% Government Mask Orders
% Includes all 9 counties
% Cases, hospitalizations, and fatalities

cases = [7/9 2/9];
hospitalizations = [6/9 3/9];
fatalities = [7/9 1/9 1/9];

t = tiledlayout(3,1);
ax1 = nexttile;
pie(ax1,cases)
legend('Decrease in Cases','Increase in Cases','Location','southeastoutside')
title('COVID-19 Cases Per-Day After Local & State Mask Order Implementation','FontSize',8)
set(gca,'Units','normalized')
titleHandle = get( gca , 'Title' );
pos = get(titleHandle, 'position');
pos1 = pos + [0 .25 0];
set(titleHandle ,'position', pos1)


ax2 = nexttile;
pie(ax2,hospitalizations)
legend('Dramatic Decrease in Hospitalizations','Mild Decrease in Hospitalizations','Location','southeastoutside')
title('COVID-19 Hospitalizations Per-Day After Local & State Mask Order Implementation','FontSize',8)
set(gca,'Units','normalized')
titleHandle = get( gca , 'Title' );
pos = get(titleHandle, 'position');
pos1 = pos + [0 .25 0];
set(titleHandle ,'position', pos1)

ax3 = nexttile;
pie(ax3,fatalities)
legend('Decrease in Fatalities','Increase in Fatalities','Inconclusive: Not enough Data','Location','southeastoutside')
title('COVID-19 Fatalities Per-Day After Mask Order Implementation','FontSize',8)
set(gca,'Units','normalized')
titleHandle = get( gca , 'Title' );
pos = get(titleHandle, 'position');
pos1 = pos + [0 .25 0];
set(titleHandle ,'position', pos1)

z = gcf;
exportgraphics(z,'mask_orders.png','Resolution',300)


%% School Openings & Closings 
% Includes all 9 counties
% Cases, hospitalizations, and fatalities 

cases = [7/9 1/9 1/9];
hospitalizations = [6/9 3/9];
fatalities = [7/9 2/9];

t = tiledlayout(3,1);
ax1 = nexttile;
pie(ax1,cases)
legend('Decrease in Cases','Increase in Cases','Location','southeastoutside')
title('COVID-19 Cases Per-Day After Local & State Mask Order Implementation','FontSize',8)
set(gca,'Units','normalized')
titleHandle = get( gca , 'Title' );
pos = get(titleHandle, 'position');
pos1 = pos + [0 .25 0];
set(titleHandle ,'position', pos1)


ax2 = nexttile;
pie(ax2,hospitalizations)
legend('Dramatic Decrease in Hospitalizations','Mild Decrease in Hospitalizations','Location','southeastoutside')
title('COVID-19 Hospitalizations Per-Day After Local & State Mask Order Implementation','FontSize',8)
set(gca,'Units','normalized')
titleHandle = get( gca , 'Title' );
pos = get(titleHandle, 'position');
pos1 = pos + [0 .25 0];
set(titleHandle ,'position', pos1)

ax3 = nexttile;
pie(ax3,fatalities)
legend('Decrease in Fatalities','Increase in Fatalities','Inconclusive: Not enough Data','Location','southeastoutside')
title('COVID-19 Fatalities Per-Day After Mask Order Implementation','FontSize',8)
set(gca,'Units','normalized')
titleHandle = get( gca , 'Title' );
pos = get(titleHandle, 'position');
pos1 = pos + [0 .25 0];
set(titleHandle ,'position', pos1)

z = gcf;
exportgraphics(z,'mask_orders.png','Resolution',300)
