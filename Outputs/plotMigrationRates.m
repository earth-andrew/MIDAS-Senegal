function plotMigrationRates()
%% Plot Migration over Time
%load NoAspirations_06.23.2024.mat
%nullOutput = outputList;

load ReferenceCase_01.14.2025.mat
multiObjectiveOutput = outputList;

%load Reference_MigrationFlowsCalibration_11.17.2024.mat
%migrationOutput = outputList;

%load Reference_JobDistributionCalibration_11.17.2024.mat
%jobOutput = outputList;

%load Reference_EducationCalibration_11.17.2024.mat
%edOutput = outputList;

load SenegalRiverDrought_01.14.2025.mat
droughtOutput = outputList;

load SaltwaterIntrusion_01.14.2025.mat
saltwaterOutput = outputList;

load GroundnutBasinDrought_01.14.2025.mat
groundwaterOutput = outputList;

load NoAspirations_01.14.2025.mat
nullOutput = outputList;


%load SaltwaterIntrusion_EdExpansion_MultiObjectiveCalibration_12.05.2024.mat
%saltwaterExpansionOutput = outputList;

droughtStart = 30/4; %Time step at which drought starts
droughtEnd = 50/4; %Time step at which drought ends

%Specify specific departments to analyze for regional rates
droughtDepartments = [1 6 17 27 35 37 39]; 

scenarios = [multiObjectiveOutput, droughtOutput, saltwaterOutput, groundwaterOutput, nullOutput];
scenarios = [multiObjectiveOutput, nullOutput];

numScenarios = size(scenarios,2);
%numExpansionScenarios = size(expansionScenarios,2);
colors = {[0.6350 0.0780 0.1840]; [0, 0.4470, 0.7410]; [0.4660, 0.6740, 0.1880]; [0.4940, 0.1840, 0.5560]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]; [0.3010 0.7450 0.9330]};
colors = {[0.6350 0.0780 0.1840]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]; [0.3010 0.7450 0.9330]};
lineStyles = {'-'; '--'; ':'};
runs = size(scenarios,1);
steps = size(scenarios(1).migrations,1);
time = 1:steps;
lag = 4; %Number of time steps over which to aggregate migration rates

%Calculate average migration at each time step
simMigrations = zeros(steps, runs);
movavgSimMigrations = zeros(steps, runs);
avgMigration = zeros(numScenarios,steps);
stdMigration = zeros(numScenarios,steps);

regionalInMigrations = zeros(steps, runs);
regionalOutMigrations = zeros(steps, runs);
regionalNetMigrations = zeros(steps, runs);
avgRegionalNetMigrations = zeros(numScenarios,steps);
stdRegionalNetMigrations = zeros(numScenarios,steps);

simExpansionMigrations = zeros(steps,runs);
%avgExpansionMigration = zeros(numExpansionScenarios,steps);
%stdExpansionMigration = zeros(numExpansionScenarios,steps);

%Calculate number of agents with diploma at each time step
simDiploma = zeros(steps,runs);
avgDiploma = zeros(numScenarios,steps);
stdDiploma = zeros(numScenarios,steps);

for indexR = 1:runs
   %Calculate Total Migration Rate
   numAgents = height(scenarios(indexR,1).diplomas);
   simMigrations(:,indexR) = scenarios(indexR,1).migrations / numAgents;
   
   movavgSimMigrations(:,indexR) = movavg(simMigrations(:,indexR),'simple',lag) .* lag;
   
   %Calculate Regional Net Migration Rate
   %regionalOutMigrations(:,indexR) = sum(scenarios(indexR,1).migrationMatrix(droughtDepartments,:,:),[1,2]);
   %regionalInMigrations(:,indexR) = sum(scenarios(indexR,1).migrationMatrix(:,droughtDepartments,:),[1,2]);
   %regionalNetMigrations = regionalOutMigrations / regionalInMigrations;
   
   %numExpansionAgents = height(expansionScenarios(indexR,1).diplomas);
   %simExpansionMigrations(:,indexR) = expansionScenarios(indexR,1).migrations / numExpansionAgents;
end



avgMigration(1,:) = mean(movavgSimMigrations,2);
test = avgMigration(1,end)
%avgExpansionMigration(1,:) = mean(simExpansionMigrations,2);
%avgRegionalNetMigrations(1,:) = mean(regionalNetMigrations,2);
    
%Calculate std using N-1 degrees of freedom
stdMigration(1,:) = std(movavgSimMigrations,0,2);
%stdExpansionMigration(1,:) = std(simExpansionMigrations,0,2);

y_low = avgMigration(1,:) - stdMigration(1,:);
y_high = avgMigration(1,:) + stdMigration(1,:);

%plot(time ./ 4, avgMigration(1,:), 'LineWidth', 2, 'Color', 'b')
%plot(time ./4, avgExpansionMigration(1,:),lineStyles{1}, 'LineWidth',2,'Color','black')

X = [time, fliplr(time)] ./ 4;
Y = [y_low, fliplr(y_high)];
fill(X, Y, colors{1}, 'FaceAlpha', .4)
hold on

for indexS = 2:numScenarios
    runs = size(scenarios,1);
    steps = size(scenarios(indexS).migrations,1);
    time = 1:steps;

    %Calculate average migration at each time step
    simMigrations = zeros(steps, runs);
    movavgSimMigrations = zeros(steps,runs);
    %simExpansionMigrations = zeros(steps,runs);
    %avgMigration(indexS,:) = zeros(steps,1);
    %stdMigration(indexS,:) = zeros(steps,1);

    for indexR = 1:runs
        numAgents = height(scenarios(indexR,indexS).diplomas);
        simMigrations(:,indexR) = scenarios(indexR,indexS).migrations / numAgents;
        movavgSimMigrations(:,indexR) = movavg(simMigrations(:,indexR),'simple',lag) .* lag;
       
        %numExpansionAgents = height(expansionScenarios(indexR,indexS).diplomas);
        %simExpansionMigrations(:,indexR) = expansionScenarios(indexR,indexS).migrations / numExpansionAgents;
        
    end

    avgMigration(indexS,:) = mean(movavgSimMigrations,2);
    test = avgMigration(indexS,end)
    %avgExpansionMigration(indexS,:) = mean(simExpansionMigrations,2);
    
    %Calculate std using N-1 degrees of freedom
    stdMigration(indexS,:) = std(movavgSimMigrations,0,2);
    y_low = avgMigration(indexS,:) - stdMigration(indexS,:);
    y_high = avgMigration(indexS,:) + stdMigration(indexS,:);
    %plot(time ./4 , avgMigration(indexS,:), 'LineWidth', 2, 'Color', colors{indexS})
    %plot(time ./4, avgExpansionMigration(indexS,:),lineStyles{indexS},'LineWidth',2,'Color','black')
    X = [time, fliplr(time)] ./ 4;
    Y = [y_low, fliplr(y_high)];
    fill(X, Y,colors{indexS}, 'FaceAlpha', .4)

end
%xline([droughtStart droughtEnd], '--',{'Start of Drought', 'End of Drought'},'LineWidth', 2, 'Color', '#A2142F','LabelVerticalAlignment', 'bottom', 'FontSize', 20);
yline(0.0237,'--','2013 1-Year Migration Rate','LineWidth',2,'Color','black','FontSize',20)
xl.LabelVerticalAlignment = 'middle';
xl.LabelHorizontalAlignment = 'center';
hold off


ax = gca;
ax.FontSize = 16;
xlabel('Years','FontSize',16)
ylabel('Proportion of Agents Migrating','FontSize',16)
xlim([9/4,steps/4])
%legend({'Reference Case', 'SenegalRiverDrought', 'Saltwater Intrusion', 'Groundnut Basin Drought', 'No Aspirations'},'FontSize',14,'Location','northwest')
legend({'Reference Case', 'No Aspirations'},'FontSize',14,'Location','northwest')

saveas(gcf, 'BaseCaseMigrationRates_01.15.2025.png')

%% 

%% %% %% Plot Migration Flow Chord Diagram
clear all
load SenegalReferenceCase_12.06.2024.mat
output = outputList;

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
avgFracMigs = mean(fracMigs,3)

%save('BaseCaseMigMatrix', "avgFracMigs")
    
BCC=biChordChart(avgFracMigs,'Label',regionNames,'Arrow','on');
BCC = BCC.draw();
BCC.tickState('off')
BCC.setFont('FontName', 'Cambria', 'FontSize', 17)
BCC.setLabelRadius(1.3);
BCC.tickLabelState('off')
%% Calculate Population Change for each location
load GroundnutBasinDrought_01.14.2025.mat
scenario = outputList;
numRuns = size(scenario,1);
numLocations = size(scenario(1).agentJobDistribution,1);
avgPopChange = zeros(numLocations,1);
startPop = zeros(numLocations,numRuns);
endPop = zeros(numLocations,numRuns);
propChange = zeros(numLocations,numRuns);
avgPropChange = zeros(numLocations,1);

%Calculate starting and ending populations by location
for indexR = 1:numRuns
    startPop(:,indexR) = sum(scenario(indexR).agentJobDistribution(:,:,1),2) ./ sum(scenario(indexR).agentJobDistribution(:,:,1),'all');
    endPop(:,indexR) = sum(scenario(indexR).agentJobDistribution(:,:,end),2) ./ sum(scenario(indexR).agentJobDistribution(:,:,end),'all');
end

%Calculate mean of differences between endPop and startPop across runs
avgPopChange = mean((endPop - startPop),2) .* 100;

%Create table with locationIndex
MatrixID = [1:numLocations]';
popChangeTable = table(MatrixID, avgPopChange);


%Merging with place codebook
codebook = readtable('../Data/PlaceIndexCodebook.csv');
joinedTable = join(popChangeTable, codebook)
writetable(joinedTable, 'GroundnutBasinDroughtPopChange_01.15.2025.csv')
%% Calculate difference in populations between two scenarios
load ReferenceCase_01.14.2025.mat
multiObjectiveOutput = outputList;

load SenegalRiverDrought_01.14.2025.mat
droughtOutput = outputList;

load SaltwaterIntrusion_01.14.2025.mat
saltwaterOutput = outputList;

load GroundnutBasinDrought_01.14.2025.mat
groundnutOutput = outputList;

scenario1 = multiObjectiveOutput;
scenario2 = groundnutOutput;

numRuns = size(scenario1,1);
numLocations = size(scenario1(1).agentJobDistribution,1);
scenario1Distribution = zeros(numLocations,numRuns);
scenario2Distribution = zeros(numLocations,numRuns);
avgPopDiff = zeros(numLocations,numRuns);

for indexR = 1:numRuns
    scenario1Distribution(:,indexR) = sum(scenario1(indexR).agentJobDistribution(:,:,end),2) ./ sum(scenario1(indexR).agentJobDistribution(:,:,end),'all');
    scenario2Distribution(:,indexR) = sum(scenario2(indexR).agentJobDistribution(:,:,end),2) ./ sum(scenario2(indexR).agentJobDistribution(:,:,end),'all');
end

%Calculate DMean Distributions and Difference between scenarios
meanDistribution1 = mean(scenario1Distribution,2)
meanDistribution2 = mean(scenario2Distribution,2)


%Calculate percentage point change in population distribution, relative to
%total pop
avgPopDiff = (meanDistribution2 - meanDistribution1) ./ meanDistribution1 .* 100 
MatrixID = [1:numLocations]';
popDiffTable = table(MatrixID,avgPopDiff)

codebook = readtable('../Data/PlaceIndexCodebook.csv');
joinedTable = join(popDiffTable,codebook);

writetable(joinedTable,'GroundnutBasinDroughtPopDiff_01.15.2025.csv')



end