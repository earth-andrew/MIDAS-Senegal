function eventHistoryPlot()
%Function that charts income, migration rate, etc. before and after key
%event (e.g. finishing education)

clear all;
close all;

%Load all simulations from an experiment
prefix = 'SenegalEnsemble_SaltwaterIntrusion_07.06.2025';
fileList = dir([prefix '*.mat']);

numRuns = length(fileList);
window = 24; %time before and after education to examine

%Create outcome variables

agentIncomes = [];
vocationalIncomes = [];
moveIncomes = [];
diplomaTime = [];
vocationalTime = [];

%Loop through each run
for indexR = 1:numRuns
    currentRun = load(fileList(indexR).name);
    fprintf(['Run ' num2str(indexR) ' of ' num2str(length(fileList)) '.\n'])
    
    %TEST CODE
    sumTrapped = sum(currentRun.output.trappedHistory,1);
    
    
    numAgents = height(currentRun.output.agentSummary.diploma);
    numSteps = size(currentRun.output.countAgentsPerLayer,3);
    firstDiploma = NaN(numAgents,1);
    diplomaStart = NaN(numAgents,1);
    diplomaCompletionTime = NaN(numAgents,1);
    postDiplomaPortfolio = zeros(1,39);
    firstVocational = NaN(numAgents,1);
    vocationalStart = NaN(numAgents,1);
    vocationalCompletionTime = NaN(numAgents,1);
    firstMigration = NaN(numAgents,1);
    
    for indexA = 1:numAgents
        agentTOD = currentRun.output.agentSummary.TOD(indexA);
        portfolioHistoryT = currentRun.output.agentSummary.portfolioHistory{indexA}';
        numRows = height(portfolioHistoryT);
        %Convert to a series of 1 x 39 logical arrays - consider making
        %this a separate function
        standardizedPortfolio = false(numSteps,39);

        for indexR = 1:numRows
            cellContents = portfolioHistoryT{indexR};

            if isempty(cellContents)
                continue;
            else
                standardizedPortfolio(indexR,:) = cellContents(1,1:39);
            end

        end

        %portfolioHistoryM = cell2mat(portfolioHistoryT);
        edHistory = currentRun.output.agentSummary.diploma{indexA,1};
        vocationalHistory = currentRun.output.agentSummary.vocational{indexA,1};
        moveHistory = currentRun.output.agentSummary.moveHistory{indexA,1}(:,1)'; %Column array of all time steps in which agent A moved

        if ~isempty(edHistory)
            firstDiploma(indexA) = edHistory(:,1);
            diplomaStart(indexA) = find(standardizedPortfolio(:,37) ~= 0,1,'first');
            if firstDiploma(indexA) < (numSteps - 3)
                postDiplomaPortfolio = postDiplomaPortfolio + mean(standardizedPortfolio(firstDiploma(indexA)+1:firstDiploma(indexA)+4,:));
                numEmployed = sum(postDiplomaPortfolio,'all');
                numDiplomas = sum(~isnan(firstDiploma));
            end
            
        end
        
        if ~isempty(vocationalHistory)
            firstVocational(indexA) = vocationalHistory(:,1);
            vocationalStart(indexA) = find(standardizedPortfolio(:,38) ~= 0,1,'first');
        end

        if max(moveHistory) > window
            firstMigration(indexA) = min(moveHistory(find(moveHistory > window, 1)));
        end

        if ~isnan(firstDiploma(indexA))
            timezero = firstDiploma(indexA);
            income = currentRun.output.agentSummary.incomeHistory{indexA,1};
            maxtime = length(income);
            if (timezero-window) > 0 && (timezero+window) < maxtime
                agentIncomes = [agentIncomes; income((timezero - window):(timezero+window))];
            end
        end
        
        if ~isnan(firstVocational(indexA))
            timezero = firstVocational(indexA);
            income = currentRun.output.agentSummary.incomeHistory{indexA,1};
            maxtime = length(income);
            if (timezero-window) > 0 && (timezero+window) < maxtime
                vocationalIncomes = [vocationalIncomes; income((timezero - window):(timezero+window))];
            end
        end
        
        if ~isnan(firstMigration(indexA))
            timezero = firstMigration(indexA);
            income = currentRun.output.agentSummary.incomeHistory{indexA,1};
            maxtime = length(income);
            if (timezero-window) > 0 && (timezero+window) < maxtime
                moveIncomes = [moveIncomes; income((timezero - window):(timezero+window))];
            end
        end
        
        
    end

    %Consolidate Diploma and Vocational Time
    diplomaCompletionTime = (firstDiploma - diplomaStart) ./ 4;
    diplomaTime = [diplomaTime; diplomaCompletionTime];
    vocationalCompletionTime = (firstVocational - vocationalStart) ./ 4;
    vocationalTime = [vocationalTime; vocationalCompletionTime];



end



lag = 4;

meanEdIncomes = mean(agentIncomes,1);
movavgEdIncomes = movavg(meanEdIncomes','simple',lag) .* lag;

meanVocationalIncomes = mean(vocationalIncomes,1);
if ~isempty(meanVocationalIncomes)
    movavgVocationalIncomes = movavg(meanVocationalIncomes', 'simple', lag) .* lag;
else
    movavgVocationalIncomes = zeros(2*window,1);
end

meanMoveIncomes = mean(moveIncomes,1);
movavgMoveIncomes = movavg(meanMoveIncomes','simple',lag) .* lag;

save('SaltwaterIntrusionEventHistory_07.06.2025.mat', 'movavgEdIncomes', 'movavgVocationalIncomes', 'movavgMoveIncomes', 'diplomaTime', 'vocationalTime')


%% Plot Income before and after timezero
%load ReferenceCaseEventHistory_12.06.2024.mat
%random = movavgIncomes;

load ReferenceCaseEventHistory_07.06.2025.mat
baseCaseMove = movavgMoveIncomes;
baseCaseEd = movavgEdIncomes;
baseCaseVocational = movavgVocationalIncomes;


load SenegalRiverDroughtEventHistory_07.06.2025.mat
droughtMove = movavgMoveIncomes;
droughtEd = movavgEdIncomes;
droughtVocational = movavgVocationalIncomes;

load SaltwaterIntrusionEventHistory_07.06.2025.mat
saltwaterMove = movavgMoveIncomes;
saltwaterEd = movavgEdIncomes;
saltwaterVocational = movavgVocationalIncomes;
%diplomaTime = diplomaTime;
%vocationalTime = vocationalTime;

%load GroundnutEventHistory_02.08.2025.mat
%groundnutMove = movavgMoveIncomes;
%groundnutEd = movavgEdIncomes;
%groundnutVocational = movavgVocationalIncomes;

scenariosMove = [baseCaseMove, droughtMove, saltwaterMove];
scenariosEd = [baseCaseEd, droughtEd, saltwaterEd];
scenariosVocational = [baseCaseVocational, droughtVocational, saltwaterVocational];
labels = ['Reference Case', 'Senegal River Drought', 'Saltwater Intrusion'];


colors = {[0.6350 0.0780 0.1840];  [0.4660, 0.6740, 0.1880]; [0.4940, 0.1840, 0.5560]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]; [0.3010 0.7450 0.9330]};
numScenarios = size(scenariosMove,2);
numObs = size(baseCaseMove,1);
numSteps = floor(size(baseCaseMove,2) / 2);
numSteps = 24;
lag = 4;
time = [-numSteps:1:numSteps] ./ lag;

%meanIncomes = mean(avgIncomes,1); %Only keep in if creating a new variable
%movavgIncomes = movavg(scenarios(:,1),'simple',lag) .* lag
%stdIncomes = std(scenarios(:,1),1);
%movavgStdIncomes = movavg(stdIncomes', 'simple',lag) .* lag;

f1 = figure();
Ax(1) = axes(f1); 
migration_plots = gobjects(3, 1);  % Pre-allocate for migration plot handles
education_plots = gobjects(3, 1);  % Pre-allocate for 4-year education plot handles
vocational_plots = gobjects(3, 1);  % Pre-allocate for vocational plot handles

hold on
%For migration
%migration_plots(1) = plot(time,scenariosMove(:,1) ./ 1000, '--', 'Color', colors{1},'LineWidth',2, 'DisplayName', labels(1))

%For education
%education_plots(1) = plot(time, scenariosEd(:,1) ./ 1000, '-', 'Color', colors{1},'LineWidth',2, 'DisplayName', labels(1))

%For vocation
vocational_plots(1) = plot(time, scenariosVocational(:,1) ./ 1000, '-', 'Color', colors{1},'LineWidth',2, 'DisplayName', labels(1))

for indexS = 2:numScenarios    
    %For migration
    %migration_plots(indexS) = plot(time, scenariosMove(:,indexS) ./ 1000 , '--', 'Color', colors{indexS},'LineWidth',3, 'DisplayName', labels(indexS))

    %For 4-year education
    %education_plots(indexS) = plot(time, scenariosEd(:,indexS) ./ 1000, '-', 'Color', colors{indexS},'LineWidth',3, 'DisplayName', labels(indexS))
    
    %For vocational
    vocational_plots(indexS) = plot(time, scenariosVocational(:,indexS) ./ 1000, '-', 'Color', colors{indexS},'LineWidth',3, 'DisplayName', labels(indexS))

end

%set(Ax(1), 'Box','off')

%legend(Ax(1), education_plots, {'Base Case', 'Senegal River', 'Saltwater', 'Groudnut'},'FontSize', 18, 'Location', 'NorthWest');
%Ax(2) = copyobj(Ax(1),gcf);
%delete(get(Ax(2), 'Children') )
hold on

% Create the second legend (for the 2 sets, distinguished by line style)
%h1 = plot(NaN, NaN, '--', 'LineWidth', 2, 'Color', [0, 0, 0], 'Parent', Ax(2),'Visible', 'off');  % Dummy for Migration Income
%h2 = plot(NaN, NaN, '-', 'LineWidth', 2, 'Color', [0, 0, 0], 'Parent', Ax(2),'Visible', 'off');   % Dummy for Education Income
hold off
%set(Ax(2), 'Color', 'none', 'XTick', [], 'YAxisLocation', 'right', 'Box', 'Off', 'Visible', 'off')

%lgd2 = legend([h1, h2], {'Migration', 'Education'}, 'FontSize',18, 'Location', 'NorthEast');
%set(lgd2,'color','none')

xline(0, '--','Year of Event', 'LineWidth', 3, 'FontSize', 18, 'LabelVerticalAlignment', 'top', 'LabelHorizontalAlignment','left')
xlim([-numSteps/4, numSteps/4])

ax=gca;
ax.FontSize=22;
legend({'Base Case', 'Senegal River', 'Saltwater'},'FontSize', 18,'Location','northwest')

xlabel('Years before/after obtaining university diploma','FontSize',22)
ylabel('Annual Average Income (1000 CFA)','FontSize',22)
ylim([100, 800])

%saveas(gcf, 'EventHistoryUniversity_07.06.2025.png')

%save('EventHistoryIncomes_01.15.2025.mat', 'movavgIncomes')

%% Plot histogram of time to university completion
load ReferenceCaseEventHistory_07.06.2025.mat
referenceUniversity = diplomaTime;
referenceVocational = vocationalTime;
test = ~isnan(referenceUniversity);
meanReference = mean(referenceUniversity, 'omitnan')
meanReference = mean(referenceVocational, 'omitnan')

load SenegalRiverDroughtEventHistory_07.06.2025.mat
droughtUniversity = diplomaTime;
droughtVocational = vocationalTime;
test2 = ~isnan(droughtUniversity);
meanDrought = mean(droughtUniversity, 'omitnan')
meanDrought = mean(droughtVocational, 'omitnan')

load SaltwaterIntrusionEventHistory_07.06.2025.mat
saltwaterUniversity = diplomaTime;
saltwaterVocational = vocationalTime;
test3 = ~isnan(saltwaterUniversity);
meanSaltwater = mean(saltwaterUniversity,'omitnan')
meanSaltwater = mean(saltwaterVocational,'omitnan')



scenarios = {referenceUniversity; droughtUniversity; saltwaterUniversity};
numScenarios = size(scenarios,1);
histogram_plots = gobjects(numScenarios, 1);  % Pre-allocate for 4-year education plot handles
edges = [0:4:24];
colors = {[0.6350 0.0780 0.1840]; [0, 0.4470, 0.7410]; [0.4660, 0.6740, 0.1880]; [0.4940, 0.1840, 0.5560]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]; [0.3010 0.7450 0.9330]};
%colors = {'r','g','b'};

currentScenario = scenarios{1,1};
histogram_plots(1) = histogram(currentScenario(~isnan(currentScenario)),edges,'Normalization','probability', 'FaceColor',colors{1},'FaceAlpha',0.25);
hold on

for indexS = 2:numScenarios
    currentScenario = scenarios{indexS,1};
    histogram_plots(indexS) = histogram(currentScenario(~isnan(currentScenario)),edges,'Normalization','probability', 'FaceColor',colors{indexS}, 'FaceAlpha', 0.25);
    histogram_plots(indexS).BinEdges = histogram_plots(indexS).BinEdges - 0.1 * (indexS-1);
  
end

hold off

ax=gca;
ax.XTick = edges;
ax.FontSize=22;
xlabel('Years to Completion')
ylabel('Proportion of University Graduates')
legend({'Reference Case', 'Senegal River Drought', 'Saltwater'},'FontSize', 18,'Location','best')

saveas(gcf, 'UniversityTimeHistogram_07.06.2025.png')



%% Plot histogram of time to vocational completion

edges = [0:2:24];
scenarios = {referenceVocational; droughtVocational; saltwaterVocational};
numScenarios = size(scenarios,1);
histogram_plots = gobjects(numScenarios, 1);  % Pre-allocate for 4-year education plot handles
colors = {[0.6350 0.0780 0.1840]; [0, 0.4470, 0.7410]; [0.4660, 0.6740, 0.1880]; [0.4940, 0.1840, 0.5560]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]; [0.3010 0.7450 0.9330]};

currentScenario = scenarios{1};
histogram_plots(1) = histogram(currentScenario(~isnan(currentScenario)),edges,'Normalization','probability', 'FaceColor',colors{1}, 'FaceAlpha',0.25);

hold on

for indexS = 2:numScenarios
    currentScenario = scenarios{indexS};
    histogram_plots(indexS) = histogram(currentScenario(~isnan(currentScenario)),edges,'Normalization','probability','FaceColor', colors{indexS}, 'FaceAlpha',0.25);
    histogram_plots(indexS).BinEdges = histogram_plots(indexS).BinEdges - 0.1 * (indexS-1);
end

hold off

ax=gca;
ax.XTick = edges;
ax.FontSize=22;
xlabel('Years to Completion - Vocational School')
ylabel('Proportion of Vocational Graduates')
legend({'Reference Case', 'Senegal River Drought', 'Saltwater Intrusion'},'FontSize', 18,'Location','best')

saveas(gcf, 'VocationalTimeHistogram_07.06.2025.png')

%% %% Dumbbell Chart summarizing mean pre- and post-income for each type of investment
VocationalIncome = zeros(numScenarios,2);
UniversityIncome = zeros(numScenarios,2);
MigrationIncome = zeros(numScenarios,2);
 
meanReferenceIncome = 414.380; %From WealthBackast Plot, for Reference Income from timesteps 40-60 (in 1000 CFA)
 
for indexS = 1:numScenarios
    VocationalIncome(indexS,1) = mean(scenariosVocational(9:16,indexS)) ./ 1000;
    UniversityIncome(indexS,1) = mean(scenariosEd(1:8,indexS)) ./ 1000;
    MigrationIncome(indexS,1) = mean(scenariosMove(17:24,indexS)) ./ 1000;
    
    VocationalIncome(indexS,2) = mean(scenariosVocational(end-8:end,indexS)) ./ 1000;
    UniversityIncome(indexS,2) = mean(scenariosEd(end-8:end,indexS)) ./ 1000;
    MigrationIncome(indexS,2) = mean(scenariosMove(end-8:end,indexS)) ./ 1000;
end
 
nonZeroVocational = VocationalIncome(:,1) ~= 0;
meanVocational = mean(VocationalIncome(nonZeroVocational,:),1);
 
nonZeroUniversity = UniversityIncome(:,1) ~= 0;
meanUniversity = mean(UniversityIncome(nonZeroUniversity,:),1);
 
nonZeroMigration = MigrationIncome(:,1) ~= 0;
meanMigration = mean(MigrationIncome(nonZeroMigration,:),1);
 
plot([meanVocational(1), meanVocational(2)], [1,1], 'k-', 'LineWidth', 2);
 
hold on
h1 = plot(meanVocational(1), 1, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);
h2 = plot(meanVocational(2), 1, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 8);
 
plot([meanUniversity(1), meanUniversity(2)], [2,2], 'k-', 'LineWidth', 2);
plot(meanUniversity(1), 2, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);
plot(meanUniversity(2), 2, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 8);
 
plot([meanMigration(1), meanMigration(2)], [3,3], 'k-', 'LineWidth', 2);
plot(meanMigration(1), 3, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);
plot(meanMigration(2), 3, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 8);
 
%xlim([0, 1]); % Adjust based on your data range
ylim([0.5, (3.5)]); % Keep a small y-range for the dumbbell effect
xline(meanReferenceIncome, '--','Mean Reference Income', 'LineWidth', 3, 'FontSize', 18, 'LabelVerticalAlignment', 'bottom', 'LabelHorizontalAlignment','left')
 
set(gca, 'YTick', 1:3); % Set the y-ticks to correspond to each scenario
set(gca, 'YTickLabel', {'Vocational', 'University', 'Migration'}, 'FontSize',16); % Set the y-tick labels to the scenario names
xlabel('Mean Income (1000 CFA/yr)', 'FontSize', 18);
ylabel('Human Capital Investment Type', 'FontSize', 18);
legend([h1, h2], {'Pre-Investment','Post-Investment'},'FontSize', 14, 'Location','northeast');
 
grid on;
 
hold off
 
saveas(gcf, 'HumanCapitalInvestmentCompare_07.06.2025.png')


end