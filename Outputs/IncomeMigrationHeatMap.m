
%Loading in Migration Data
load '../Calibration Testing/migData_census2013.mat'


migrationData = mig_1_region_overall(1:end-1,:)
sourcePopWeights = popData' * ones(1, 8);
destPopWeights = sourcePopWeights';
jointPopWeights = sourcePopWeights .* destPopWeights;

sourcePopSum = sum(sum(sourcePopWeights));
destPopSum = sum(sum(destPopWeights));
jointPopSum = sum(sum(jointPopWeights));

%one simple metric is the relative # of migrations per source-destination
%pair
fracMigsData = migrationData / sum(sum(migrationData))

%another is the migs per total population
%migRateData = migrationData / sum(popData)
migRateData = migrationData

%and another is the in/out ratio
inOutData = sum(migrationData) ./ (sum(migrationData'))'

regionNames = {"Dakar", "Ziguinchor", "Diourbel", "Saint Louis, Louga, Matam", ...
    "Tambacounda, Kedougou", "Kaolack, Fatick, Kaffrine", "Thiès", "Kolda, Sedhiou"};


%Plotting Function
metricTitle = 'Proportion of Total Migration: 1-year'
matrix = fracMigsData

locations = regionNames;
test = sum(sum(matrix))
figure;
imagesc(matrix);
set(gca,'YTick',1:64, 'XTick',1:64, 'YTickLabel',locations, 'XTickLabel',locations);
xtickangle(90);
colorbar;
%title([metricTitle ' - Interdistrict moves (n = ' num2str(sum(sum(matrix))) '; Weighted r^2 = ' num2str(r2) ')']);
title([metricTitle ' - Interdistrict moves Sum = ' num2str(sum(sum(matrix)))]);

grid on;
colormap hot;
set(gca,'GridColor','white','FontSize',16);
temp = ylabel('ORIGIN','FontSize',20,'Position',[-5 30]);
xlabel('DESTINATION','FontSize',20);
%set(temp,'Position', [-.1 .5 0]);
set(gcf,'Position',[100 100 600 500]);
clim([0,0.11])
savefig('MigrationMatrix_Data.fig')

%% 

%Calculating Model Output Migration Matrix
collapseColumns = { ...
    [7 14 33 36], ...
    [3 32 45], ...
    [2 8 28], ...
    [6 17 19 24 25 27 34 35 37], ...
    [1 12 20 22 38 39 41], ...
    [4 9 10 11 15 16 18 23 26 31], ...
    [29 42 43], ...
    [5 13 21 30 40 44], ...
    };

load Aspirations_SenegalTest_R1JobsCalibration0_07-Feb-2024_23-52-58.mat
currentRun = output;

tempMat = currentRun.migrationMatrix;
            tempMat = [sum(tempMat(:,collapseColumns{1},end),2) ...
                sum(tempMat(:,collapseColumns{2},end),2) ...
                sum(tempMat(:,collapseColumns{3},end),2) ...
                sum(tempMat(:,collapseColumns{4},end),2) ...
                sum(tempMat(:,collapseColumns{5},end),2) ...
                sum(tempMat(:,collapseColumns{6},end),2) ...
                sum(tempMat(:,collapseColumns{7},end),2) ...
                sum(tempMat(:,collapseColumns{8},end),2) ...
                ];
            tempMat = [sum(tempMat(collapseColumns{1},:)); ...
                sum(tempMat(collapseColumns{2},:)); ...
                sum(tempMat(collapseColumns{3},:)); ...
                sum(tempMat(collapseColumns{4},:)); ...
                sum(tempMat(collapseColumns{5},:)); ...
                sum(tempMat(collapseColumns{6},:)); ...
                sum(tempMat(collapseColumns{7},:)); ...
                sum(tempMat(collapseColumns{8},:)) ...
                ];

            fracMigsRun = tempMat / sum(sum(tempMat))
            migRateRun = tempMat / size(currentRun.agentSummary,1)  %(this data is 11 years)
            inOutRun = sum(tempMat) ./ (sum(tempMat'))'


%Plotting Function
metricTitle = 'Proportion of Total Migration: Model Output'
matrix = fracMigsRun

locations = regionNames;
figure;
imagesc(matrix);
set(gca,'YTick',1:64, 'XTick',1:64, 'YTickLabel',locations, 'XTickLabel',locations);
xtickangle(90);
colorbar;
%title([metricTitle ' - Interdistrict moves (n = ' num2str(sum(sum(matrix))) '; Weighted r^2 = ' num2str(r2) ')']);
title([metricTitle ' - Interdistrict moves Sum = ' num2str(sum(sum(matrix)))]);

grid on;
colormap hot;
set(gca,'GridColor','white','FontSize',16);
temp = ylabel('ORIGIN','FontSize',20,'Position',[-5 30]);
xlabel('DESTINATION','FontSize',20);
%set(temp,'Position', [-.1 .5 0]);
set(gcf,'Position',[100 100 600 500]);
clim([0,0.11])
savefig('MigrationMatrix_ModelRun.fig')

%% Plotting "Confusion Matrix" (difference between model and data flows)

metricTitle = 'Difference between Model and Data'
matrix = (fracMigsRun - fracMigsData)
locations = regionNames;
figure;
imagesc(matrix);
set(gca,'YTick',1:64, 'XTick',1:64, 'YTickLabel',locations, 'XTickLabel',locations);
xtickangle(90);
colorbar;
%title([metricTitle ' - Interdistrict moves (n = ' num2str(sum(sum(matrix))) '; Weighted r^2 = ' num2str(r2) ')']);
title([metricTitle ' - Interdistrict moves Sum = ' num2str(sum(sum(matrix)))]);

grid on;
colormap hot;
set(gca,'GridColor','white','FontSize',16);
temp = ylabel('ORIGIN','FontSize',20,'Position',[-5 30]);
xlabel('DESTINATION','FontSize',20);
%set(temp,'Position', [-.1 .5 0]);
set(gcf,'Position',[100 100 600 500]);
%clim([-0.11,0.11])
savefig('MigrationMatrix_Confusion.fig')




%% Calculating R^2

sourcePopWeights = popData' * ones(1, 8)
destPopWeights = sourcePopWeights'
jointPopWeights = sourcePopWeights .* destPopWeights

sourcePopSum = sum(sum(sourcePopWeights));
destPopSum = sum(sum(destPopWeights));
jointPopSum = sum(sum(jointPopWeights));

fracMigs_r2 = weightedPearson(fracMigsRun(:), fracMigsData(:), ones(numel(fracMigsRun),1))
sourceFracMigs_r2 = weightedPearson(fracMigsRun(:), fracMigsData(:), sourcePopWeights(:))
destFracMigs_r2 = weightedPearson(fracMigsRun(:), fracMigsData(:), destPopWeights(:))
jointFracMigs_r2 = weightedPearson(fracMigsRun(:), fracMigsData(:), jointPopWeights(:))


function rho_2 = weightedPearson(X, Y, w)

mX = sum(X .* w) / sum(w);
mY = sum(Y .* w) / sum(w);

covXY = sum (w .* (X - mX) .* (Y - mY)) / sum(w);
covXX = sum (w .* (X - mX) .* (X - mX)) / sum(w);
covYY = sum (w .* (Y - mY) .* (Y - mY)) / sum(w);

rho_w  = covXY / sqrt(covXX * covYY);
rho_2 = rho_w * rho_w;

end
