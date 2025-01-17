function plotMigrationMatrix()

%% Plot Migration Matrix
load BaseCaseMigMatrix.mat
baseCaseMatrix = avgFracMigs;

load SenegalSaltwaterIntrusionMigMatrix.mat
saltwaterMatrix = avgFracMigs;

metricTitle = 'Saltwater Intrusion Migration Flows'
matrix = saltwaterMatrix
%matrix = jobMatrix;

regionNames = {"Dakar", "Ziguinchor", "Diourbel", "Saint Louis, Louga, Matam", "Tambacounda, Kedougou", "Kaolack, Fatick, Kaffrine", "Thiès", "Kolda, Sedhiou"};
locations = regionNames;
figure;
imagesc(matrix);
set(gca,'YTick',1:64,'XTick',1:64, 'YTickLabel', locations, 'XTickLabel', locations);
xtickangle(90);
colorbar;
title([metricTitle]);

grid on;
colormap hot;
set(gca,'GridColor','white','FontSize',16);
xlabel('Destination', 'FontSize',20);
set(gcf,'Position',[100 100 600 500]);
clim([0,0.2])


end