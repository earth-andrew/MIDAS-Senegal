function plotMigrationMatrix()

%% Plot Migration Matrix

load ReferenceCase_07.06.2025.mat
baseCaseOutput = outputList;
numRuns = size(baseCaseOutput,1);
numSteps = size(baseCaseOutput(1).migrationMatrix,3);
numLocations = size(baseCaseOutput(1).migrationMatrix,1);

%Specify time slice
start_time = 40;
end_time = 60;
runMigrationMatrix = zeros(numLocations, numLocations,numRuns);

for indexR = 1:numRuns
    runMigrationMatrix(:,:,indexR) = mean(baseCaseOutput(indexR).migrationMatrix(:,:,start_time:end_time),3);
end

tempMat = mean(runMigrationMatrix,3);

%Collapse Admin2-level matrix into Admin1-level matrix
placeLabels = {"Dakar", "Ziguinchor", "Diourbel", "Saint Louis, Louga, Matam", ...
    "Tambacounda, Kedougou", "Kaolack, Fatick, Kaffrine", "Thiès", "Kolda, Sedhiou", ...
    "Abroad", "NIU"};


regionNames = {"Dakar", "Ziguinchor", "Diourbel", "Saint Louis, Louga, Matam", ...
    "Tambacounda, Kedougou", "Kaolack, Fatick, Kaffrine", "Thiès", "Kolda, Sedhiou"};

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

tempMat = [sum(tempMat(:,collapseColumns{1},:),2) ...
                sum(tempMat(:,collapseColumns{2},:),2) ...
                sum(tempMat(:,collapseColumns{3},:),2) ...
                sum(tempMat(:,collapseColumns{4},:),2) ...
                sum(tempMat(:,collapseColumns{5},:),2) ...
                sum(tempMat(:,collapseColumns{6},:),2) ...
                sum(tempMat(:,collapseColumns{7},:),2) ...
                sum(tempMat(:,collapseColumns{8},:),2) ...
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

%Remove diagonals to match data - ask Andrew why data did not have
%diagonals
tempMat = tempMat - diag(diag(tempMat));
tempMat = tempMat ./ sum(tempMat,'all')


regionNames = {"Dakar", "Ziguinchor", "Diourbel", "Saint Louis, Louga, Matam", "Tambacounda, Kedougou", "Kaolack, Fatick, Kaffrine", "Thiès", "Kolda, Sedhiou"};
locations = regionNames;
figure;
imagesc(tempMat);
set(gca,'YTick',1:64,'XTick',1:64, 'YTickLabel', locations, 'XTickLabel', locations);
xtickangle(90);
colorbar;

ax = gca;
ax.FontSize = 16;
%grid on;
colormap hot;
set(gca,'GridColor','white','FontSize',16);
xlabel('Destination', 'FontSize',20);
set(gcf,'Position',[100 100 600 500]);
clim([0,0.15])

%saveas(gcf, 'ReferenceCaseMigrationMatrix_07.06.2025.png')
%% Plot Data Migration Matrix
addpath('../Calibration Testing/');
load migData_census2013.mat;
%one simple metric is the relative # of migrations per source-destination
%pair
migrationData = mig_5_region_overall;
migrationData = migrationData(1:end-1,:);

sourcePopWeights = popData' * ones(1, 8);
destPopWeights = sourcePopWeights';
jointPopWeights = sourcePopWeights .* destPopWeights;

fracMigsData = migrationData / sum(sum(migrationData));


regionNames = {"Dakar", "Ziguinchor", "Diourbel", "Saint Louis, Louga, Matam", "Tambacounda, Kedougou", "Kaolack, Fatick, Kaffrine", "Thiès", "Kolda, Sedhiou"};
locations = regionNames;
figure;
imagesc(fracMigsData);
set(gca,'YTick',1:64,'XTick',1:64, 'YTickLabel', locations, 'XTickLabel', locations);
xtickangle(90);
colorbar;

ax = gca;
ax.FontSize = 16;
%grid on;
colormap hot;
set(gca,'GridColor','white','FontSize',16);
xlabel('Destination', 'FontSize',20);
set(gcf,'Position',[100 100 600 500]);
clim([0,0.15])

%saveas(gcf, 'DataMigrationMatrix_5yr.png')
%% Confusion Matrix
%Calculate and plot difference between model results and data

confusion = (tempMat - fracMigsData) ./ sum(fracMigsData,'all')
r2 = weightedPearson(tempMat, fracMigsData,jointPopWeights)
regionNames = {"Dakar", "Ziguinchor", "Diourbel", "Saint Louis, Louga, Matam", "Tambacounda, Kedougou", "Kaolack, Fatick, Kaffrine", "Thiès", "Kolda, Sedhiou"};
locations = regionNames;
figure;
imagesc(confusion);
set(gca,'YTick',1:64,'XTick',1:64, 'YTickLabel', locations, 'XTickLabel', locations);
xtickangle(90);
colorbar;

ax = gca;
ax.FontSize = 16;
%grid on;
colormap winter;
set(gca,'GridColor','white','FontSize',16);
xlabel('Destination', 'FontSize',20);
set(gcf,'Position',[100 100 600 500]);
%clim([0,0.15])


%saveas(gcf, 'ConfusionMatrix_5yr_07.06.2025.png')

function rho_2 = weightedPearson(X, Y, w)

mX = sum(X .* w) / sum(w);
mY = sum(Y .* w) / sum(w);

covXY = sum (w .* (X - mX) .* (Y - mY)) / sum(w);
covXX = sum (w .* (X - mX) .* (X - mX)) / sum(w);
covYY = sum (w .* (Y - mY) .* (Y - mY)) / sum(w);

rho_w  = covXY / sqrt(covXX * covYY);
rho_2 = rho_w * rho_w;

end

end