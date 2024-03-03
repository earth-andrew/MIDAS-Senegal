function plotMigrationRates()
%% Plot Migration over Time
load SenegalBaseCase_MedianRun0_03-Mar-2024_16-49-32.mat
baseCaseOutput = output;

load SenegalRiverDrought_MedianRun0_02-Mar-2024_19-46-17.mat
droughtOutput = output;

load SenegalSaltwaterIntrusion_MedianRun0_03-Mar-2024_17-15-38.mat
saltwaterOutput = output;

scenarios = [baseCaseOutput, droughtOutput, saltwaterOutput];
numScenarios = size(scenarios,1);
colors = ['b', 'g', 'm'];
labels = [{'Random Utilities'}, {'Base Case'}, {'Senegal River Drought'}];
runs = size(scenarios,1);
steps = size(scenarios(1).migrations,1);
time = 1:steps;
numAgents = 2000;

%Calculate average migration at each time step
simMigrations = zeros(steps, runs);
avgMigration = zeros(numScenarios,steps);
stdMigration = zeros(numScenarios,steps);

for indexR = 1:runs
   simMigrations(:,indexR) = scenarios(indexR, 1).migrations / numAgents;
end

avgMigration(1,:) = mean(simMigrations,2);
    
%Calculate std using N-1 degrees of freedom
stdMigration(1,:) = std(simMigrations,0,2);
y_low = avgMigration(1,:) - stdMigration(1,:);
y_high = avgMigration(1,:) + stdMigration(1,:);

plot(time, avgMigration(1,:), 'LineWidth', 3, 'Color', 'blue')
%plot(time, y_low, 'LineWidth', 2, 'Color', colors(1), 'DisplayName', labels{1})
%plot(time, y_high, 'LineWidth', 2, 'Color', colors(1), 'DisplayName', labels{1})

X = [time, fliplr(time)];
Y = [y_low, fliplr(y_high)];
%fill(X, Y, colors(1), 'FaceAlpha', .25)

hold on
for indexS = 2:size(scenarios,2)
    runs = size(scenarios,1);
    steps = size(scenarios(indexS).migrations,1);
    time = 1:steps;

    %Calculate average migration at each time step
    simMigrations = zeros(steps, runs);
    %avgMigration(indexS,:) = zeros(steps,1);
    %stdMigration(indexS,:) = zeros(steps,1);

    for indexR = 1:runs
        simMigrations(:,indexR) = scenarios(indexR, indexS).migrations / numAgents;
    end

    avgMigration(indexS,:) = mean(simMigrations,2);
    %Calculate std using N-1 degrees of freedom
    stdMigration(indexS,:) = std(simMigrations,0,2);
    y_low = avgMigration(indexS,:) - stdMigration(indexS,:);
    y_high = avgMigration(indexS,:) + stdMigration(indexS,:);

    plot(time, avgMigration(indexS,:), 'LineWidth', 3, 'Color', colors(indexS))
    %plot(time, y_low, 'LineWidth', 2, 'Color', colors(indexS), 'DisplayName', labels{indexS})
    %plot(time, y_high, 'LineWidth', 2, 'Color', colors(indexS), 'DisplayName', labels{indexS})

    X = [time, fliplr(time)];
    Y = [y_low, fliplr(y_high)];
    %fill(X, Y, colors(indexS), 'FaceAlpha', .25)

end
hold off

writematrix(avgMigration,'MigrationProportion_avg.csv')
writematrix(stdMigration,'MigrationProportion_std.csv')

ax = gca;
ax.FontSize = 16;
xlabel('Time','FontSize',16)
ylabel('Proportion of Agents Migrating','FontSize',16)
xlim([11,steps])
legend({'Base Case', 'Senegal River Drought', 'SaltwaterIntrusion'},'FontSize',14)
%% %% %% Plot Migration Flow Chord Diagram
clear all
load SenegalSaltwaterIntrusion_MedianRun0_02-Mar-2024_20-12-06.mat
output = output;

runs = size(output,1);
steps = size(output(1).migrations,1);

popChange = zeros(runs,45);

%Specify start and end of time series slice to calculate migration flows
start_time = 60;
end_time = 80;

%Collapse matrix into 8 x 8 matrix of Admin 1 regions
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


for indexR = 1:runs

    %Select time period for migration matrix
    migMatrix = sum(output(indexR).migrationMatrix(:,:,start_time:end_time),3);
    tempMat = migMatrix;
    
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

    %Calculate proportional migration matrix for each run
    fracMigsRun = zeros(height(tempMat), height(tempMat),runs);

    fracMigs(:,:,indexR) = tempMat / sum(sum(tempMat));

    %Calculate net population change for each Admin 2 region
    for indexI = 1:size(migMatrix,1)
        popChange(indexR,indexI) = sum(migMatrix(:,indexI)) - sum(migMatrix(indexI,:));
    end


end
avgPopChange = mean(popChange,1)
avgFracMigs = mean(fracMigs,3);

save('JobCalibrationMigMatrix', "avgFracMigs")

BCC=biChordChart(avgFracMigs,'Label',regionNames,'Arrow','on');
BCC = BCC.draw();
BCC.tickState('off')
BCC.setFont('FontName', 'Cambria', 'FontSize', 17)
BCC.setLabelRadius(1.3);
BCC.tickLabelState('off')




end