function incomeDistributionPlot()
%Script that plots income distribution of agents at specified time,for
%specified scenarios

%Note - consider adding column to each table with scenario name, then can
%fit multiple distributions on same dataset as in https://www.mathworks.com/help/stats/compare-multiple-distribution-fits.html

%Read in distribution of final incomes from each scenario
load ReferenceCase_07.06.2025.mat
outputList = outputList;
numRuns = size(outputList,1);
multiObjectiveGini = zeros(numRuns,1);
finalIncome = [];
for indexR = 1:numRuns
    runIncome = outputList(indexR).finalYearIncome;
    incomeData = rmmissing(runIncome);
    multiObjectiveGini(indexR) = calculateGini(incomeData);
    finalIncome = [finalIncome; incomeData];
end
avgMultiObjectiveGini = mean(multiObjectiveGini)
scenarioIndex = ones(height(finalIncome),1);
multiObjectiveTable = table(finalIncome,scenarioIndex);
refMedian = median(finalIncome,1)


load NoAspirations_07.06.2025.mat
outputList = outputList;
numRuns = size(outputList,1);
nullGini = zeros(numRuns,1);
finalIncome = [];
for indexR = 1:numRuns
    runIncome = outputList(indexR).finalYearIncome;
    incomeData = rmmissing(runIncome);
    nullGini(indexR) = calculateGini(incomeData);
    finalIncome = [finalIncome; incomeData];
end
avgNullGini = mean(nullGini)
nullMedian = median(finalIncome,1)
scenarioIndex = 2 .* ones(height(finalIncome),1);
nullTable = table(finalIncome,scenarioIndex);


load SenegalRiverDrought_07.06.2025.mat
outputList = outputList;

numRuns = size(outputList,1);
droughtGini = zeros(numRuns,1);
finalIncome = [];
for indexR = 1:numRuns
    runIncome = outputList(indexR).finalYearIncome;
    incomeData = rmmissing(runIncome);
    droughtGini(indexR) = calculateGini(incomeData);
    finalIncome = [finalIncome; incomeData];
end
avgDroughtGini = mean(droughtGini)
droughtMedian = median(finalIncome,1)
scenarioIndex = 3 .* ones(height(finalIncome),1);
droughtTable = table(finalIncome,scenarioIndex);


load SaltwaterIntrusion_07.06.2025.mat
outputList = outputList;
numRuns = size(outputList,1);
saltwaterGini = zeros(numRuns,1);
finalIncome = [];
for indexR = 1:numRuns
    runIncome = outputList(indexR).finalYearIncome;
    incomeData = rmmissing(runIncome);
    saltwaterGini(indexR) = calculateGini(incomeData);
    finalIncome = [finalIncome; incomeData];
end
avgSaltwaterGini = mean(saltwaterGini)
saltwaterMedian = median(finalIncome,1)
scenarioIndex = 4 .* ones(height(finalIncome),1);
saltwaterTable = table(finalIncome,scenarioIndex);
scenarios = [multiObjectiveTable; nullTable; droughtTable; saltwaterTable];

%Fit Distribution to scenario incomes
[pdca,gn,gl] = fitdist(scenarios.finalIncome,'ev','By', scenarios.scenarioIndex);
multiObjective = pdca{1};
noAspirations = pdca{2};
drought = pdca{3};
saltwater = pdca{4};
%groundnut = pdca{5};
numScenarios = size(gl,1);

%Prepare plot
min_income = min(scenarios.finalIncome);
max_income = max(scenarios.finalIncome);

xvalues = min_income:1:max_income;


multiObjectivepdf = pdf(multiObjective,xvalues);
noaspirationspdf = pdf(noAspirations,xvalues);
droughtpdf = pdf(drought,xvalues);
saltwaterpdf = pdf(saltwater,xvalues);
%groundnutpdf = pdf(groundnut,xvalues);
%saltwaterExpansionpdf = pdf(saltwaterExpansion,xvalues);


colors = {[0.6350 0.0780 0.1840]; [0, 0.4470, 0.7410]; [0.4660, 0.6740, 0.1880]; [0.4940, 0.1840, 0.5560]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]; [0.3010 0.7450 0.9330]};


dailyPovertyLine = 2.15; %USD/day
conversionUSDCFA = 600; %CFA per USD

%Print proportion of each distribution below poverty line
povertyThreshold = dailyPovertyLine * conversionUSDCFA * 365;

multiObjectivePovertyRate = cdf(multiObjective,povertyThreshold)
noaspirationsPovertyRate = cdf(noAspirations, povertyThreshold)
droughtPovertyRate = cdf(drought, povertyThreshold)
saltwaterPovertyRate = cdf(saltwater, povertyThreshold)
%groundnutPovertyRate = cdf(groundnut, povertyThreshold)
%saltwaterExpansionPovertyRate = cdf(saltwaterExpansion, povertyThreshold)

%Plot distributions
%plot(xvalues,noaspirationspdf, 'Color', colors{1},'LineWidth',2)
plot(xvalues, multiObjectivepdf, 'Color', colors{1},'LineWidth',2)

hold on
plot(xvalues, noaspirationspdf, 'Color', colors{2},'LineWidth',2)
plot(xvalues, droughtpdf, 'Color', colors{3},'LineWidth',2)
plot(xvalues, saltwaterpdf, 'Color', colors{4},'LineWidth',2)
%plot(xvalues, groundnutpdf,'Color',colors{5},'LineWidth',2)
%plot(xvalues, saltwaterExpansionpdf,'Color',colors{4},'LineWidth',2)

hold off

%Add legend 
xlabel('Annual Income (CFA)', 'FontSize', 24)
ylabel('Density', 'FontSize', 24)


%Poverty Line
xline(dailyPovertyLine * 365 * conversionUSDCFA, '--', 'Poverty Line', 'LineWidth',2,'FontSize',22, 'LabelVerticalAlignment','bottom')
%xline(840000,'--','2023 Observed Mean Income', 'LineWidth',2,'FontSize',22,'LabelVerticalAlignment','bottom')
ax = gca;
ax.FontSize = 16;
legend({'Reference Case','No Aspirations',  'Drought', 'Saltwater'}, 'FontSize',22)
saveas(gcf, 'IncomeDistribution_07.06.2025.png')

end

%% 
%GINI Calculation
function G = calculateGini(incomeData)
% Calculates the Gini coefficient for a given dataset.
% incomeData: A vector of income values (must be non-negative).

% Sort the income data in ascending order
sortedIncome = sort(incomeData);

n = length(sortedIncome);
if n < 2
    G = NaN; % Gini coefficient not meaningful for less than 2 elements
    warning('Gini coefficient requires at least 2 data points.');
    return;
end

% Ensure all values are non-negative
if any(sortedIncome < 0)
    G = NaN; % Gini coefficient typically for non-negative values
    warning('Gini coefficient is usually calculated for non-negative values.');
    return;
end

% Calculate cumulative sums
cumulativeSum = cumsum(sortedIncome);

% Calculate the Gini coefficient using the formula
numerator = sum( (2*(1:n)' - n - 1) .* sortedIncome );
denominator = n * sum(sortedIncome);

G = numerator / denominator;
end