function incomeDistributionPlot()
%Script that plots income distribution of agents at specified time,for
%specified scenarios

%Note - consider adding column to each table with scenario name, then can
%fit multiple distributions on same dataset as in https://www.mathworks.com/help/stats/compare-multiple-distribution-fits.html

%Read in distribution of final incomes from each scenario
%load NoAspirations_06.23.2024.mat
%finalIncome = outputList.finalYearIncome;
%scenarioIndex = ones(height(finalIncome),1);
%nullTable = table(finalIncome,scenarioIndex);


load ReferenceCase_01.14.2025.mat
finalIncome = outputList.finalYearIncome;
scenarioIndex = ones(height(finalIncome),1);
multiObjectiveTable = table(finalIncome,scenarioIndex);

load SenegalRiverDrought_01.14.2025.mat
finalIncome = outputList.finalYearIncome;
scenarioIndex = 2 .* ones(height(finalIncome),1);
droughtTable = table(finalIncome,scenarioIndex);

load SaltwaterIntrusion_01.14.2025.mat
finalIncome = outputList.finalYearIncome;
scenarioIndex = 3 .* ones(height(finalIncome),1);
saltwaterTable = table(finalIncome,scenarioIndex);

load GroundnutBasinDrought_01.14.2025.mat
finalIncome = outputList.finalYearIncome;
scenarioIndex = 4 .* ones(height(finalIncome),1);
groundnutTable = table(finalIncome,scenarioIndex);

%load SaltwaterIntrusion_EdExpansion_MultiObjectiveCalibration_12.05.2024.mat
%finalIncome = outputList.finalYearIncome;
%scenarioIndex = 5 .* ones(height(finalIncome),1);
%saltwaterExpansionTable = table(finalIncome,scenarioIndex);

scenarios = [multiObjectiveTable; droughtTable; saltwaterTable; groundnutTable];

%Fit Distribution to scenario incomes
[pdca,gn,gl] = fitdist(scenarios.finalIncome,'ev','By', scenarios.scenarioIndex);
%noAspirations = pdca{1};
multiObjective = pdca{1};
drought = pdca{2};
saltwater = pdca{3};
groundnut = pdca{4};
%saltwaterExpansion = pdca{5};
numScenarios = size(gl,1);

%Prepare plot
min_income = min(scenarios.finalIncome);
max_income = max(scenarios.finalIncome);

xvalues = min_income:1:max_income;

%noaspirationspdf = pdf(noAspirations,xvalues);
multiObjectivepdf = pdf(multiObjective,xvalues);
droughtpdf = pdf(drought,xvalues);
saltwaterpdf = pdf(saltwater,xvalues);
groundnutpdf = pdf(groundnut,xvalues);
%saltwaterExpansionpdf = pdf(saltwaterExpansion,xvalues);


colors = {[0.6350 0.0780 0.1840]; [0, 0.4470, 0.7410]; [0.4660, 0.6740, 0.1880]; [0.4940, 0.1840, 0.5560]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]; [0.3010 0.7450 0.9330]};
%colors = {[0, 0.4470, 0.7410]; [0.4660, 0.6740, 0.1880]; [0.4940, 0.1840, 0.5560]};

dailyPovertyLine = 2.15; %USD/day
conversionUSDCFA = 600; %CFA per USD

%Print proportion of each distribution below poverty line
povertyThreshold = dailyPovertyLine * conversionUSDCFA * 365;
%noaspirationsPovertyRate = cdf(noAspirations, povertyThreshold)
multiObjectivePovertyRate = cdf(multiObjective,povertyThreshold)
droughtPovertyRate = cdf(drought, povertyThreshold)
saltwaterPovertyRate = cdf(saltwater, povertyThreshold)
groundnutPovertyRate = cdf(groundnut, povertyThreshold)
%saltwaterExpansionPovertyRate = cdf(saltwaterExpansion, povertyThreshold)

%Plot distributions
%plot(xvalues,noaspirationspdf, 'Color', colors{1},'LineWidth',2)
plot(xvalues, multiObjectivepdf, 'Color', colors{1},'LineWidth',2)

hold on
plot(xvalues, droughtpdf, 'Color', colors{2},'LineWidth',2)
plot(xvalues, saltwaterpdf, 'Color', colors{3},'LineWidth',2)
plot(xvalues, groundnutpdf,'Color',colors{4},'LineWidth',2)
%plot(xvalues, saltwaterExpansionpdf,'Color',colors{4},'LineWidth',2)

hold off

%Add legend 
xlabel('Annual Income (CFA)', 'FontSize', 24)
ylabel('Density', 'FontSize', 24)


%Poverty Line
xline(dailyPovertyLine * 365 * conversionUSDCFA, '--', 'Poverty Line', 'LineWidth',2,'FontSize',22, 'LabelVerticalAlignment','bottom')
ax = gca;
ax.FontSize = 16;
legend({'MultiObjective','Drought', 'Saltwater','Groundnut'}, 'FontSize',22)
saveas(gcf, 'IncomeDistribution_01.15.2025.png')

end