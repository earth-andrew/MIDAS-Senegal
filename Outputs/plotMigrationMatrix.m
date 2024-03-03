function plotMigrationMatrix()

%% Plot Migration Matrix
load RandomUtilitiesMigMatrix.mat
randomMatrix = avgFracMigs;

load BaseCaseMigMatrix.mat
baseCaseMatrix = avgFracMigs;

load JobCalibrationMigMatrix.mat
jobMatrix = avgFracMigs;

metricTitle = 'Job Calibration vs Mig Calibration'
matrix = jobMatrix - baseCaseMatrix
%matrix = jobMatrix;


locations = regionNames;
figure;
imagesc(matrix);
set(gca,'YTick',1:64,'XTick',1:64, 'YTickLabel', locations, 'XTickLabel', locations);
xtickangle(90);
colorbar;
title([metricTitle ' - Interdistrict Moves']);

grid on;
colormap hot;
set(gca,'GridColor','white','FontSize',16);
xlabel('Destination', 'FontSize',20);
set(gcf,'Position',[100 100 600 500]);
clim([0,0.11])


end