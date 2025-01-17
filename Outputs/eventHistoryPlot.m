function eventHistoryPlot()
%Function that charts income, migration rate, etc. before and after key
%event (e.g. finishing education)

clear all;
close all;

%Load all simulations from an experiment
prefix = 'SenegalEnsemble_GroundnutBasinDrought_01.14.2025Experiment';
fileList = dir([prefix '*.mat']);

numSteps = 90;
numRuns = length(fileList);
window = 16; %time before and after education to examine

%Create outcome variables

agentIncomes = [];
moveIncomes = [];

%Loop through each run
for indexR = 1:numRuns
    currentRun = load(fileList(indexR).name);
    fprintf(['Run ' num2str(indexR) ' of ' num2str(length(fileList)) '.\n'])
    
    numAgents = height(currentRun.output.agentSummary.diploma);
    firstDiploma = NaN(numAgents);
    firstMigration = NaN(numAgents);
    
    for indexA = 1:numAgents
        agentTOD = currentRun.output.agentSummary.TOD(indexA);
        edHistory = currentRun.output.agentSummary.diploma{indexA,1};
        moveHistory = currentRun.output.agentSummary.moveHistory{indexA,1}(:,1)'; %Column array of all time steps in which agent A moved

        if ~isempty(edHistory)
            firstDiploma(indexA) = edHistory(:,1);
        end

        if max(moveHistory) > window
            firstMigration(indexA) = min(moveHistory(find(moveHistory > window, 1)));
        end

        if ~isnan(firstDiploma(indexA))
            timezero = firstDiploma(indexA);
            income = currentRun.output.agentSummary.incomeHistory{indexA,1};
            maxtime = length(income);
            if timezero+window < maxtime
                agentIncomes = [agentIncomes; income((timezero - window):(timezero+window))];
            end
        end

        if ~isnan(firstMigration(indexA))
            timezero = firstMigration(indexA);
            income = currentRun.output.agentSummary.incomeHistory{indexA,1};
            maxtime = length(income);
            if timezero+window < maxtime
                moveIncomes = [moveIncomes; income((timezero - window):(timezero+window))];
            end
        end
        
        
    end

end

lag = 4;

meanEdIncomes = mean(agentIncomes,1);
movavgEdIncomes = movavg(meanEdIncomes','simple',lag) .* lag;

meanMoveIncomes = mean(moveIncomes,1);
movavgMoveIncomes = movavg(meanMoveIncomes','simple',lag) .* lag;

save('GroundnutBasinDroughtEventHistory_01.15.2025.mat', 'movavgEdIncomes', 'movavgMoveIncomes')


%% Plot Income before and after timezero
%load ReferenceCaseEventHistory_12.06.2024.mat
%random = movavgIncomes;

load ReferenceEventHistory_01.15.2025.mat
baseCaseMove = movavgMoveIncomes;
baseCaseEd = movavgEdIncomes;


load SenegalRiverDroughtEventHistory_01.15.2025.mat
droughtMove = movavgMoveIncomes;
droughtEd = movavgEdIncomes;

load SaltwaterIntrusionEventHistory_01.15.2025.mat
saltwaterMove = movavgMoveIncomes;
saltwaterEd = movavgEdIncomes;

load GroundnutBasinDroughtEventHistory_01.15.2025.mat
groundnutMove = movavgMoveIncomes;
groundnutEd = movavgEdIncomes;

scenariosMove = [baseCaseMove, droughtMove, saltwaterMove, groundnutMove];
labels = ['Base Case', 'Senegal River Drought', 'Saltwater Intrusion', 'Groundnut Basin'];
scenariosEd = [baseCaseEd, droughtEd, saltwaterEd, groundnutEd];
colors = {[0.6350 0.0780 0.1840]; [0, 0.4470, 0.7410]; [0.4660, 0.6740, 0.1880]; [0.8500 0.3250 0.0980]};
numScenarios = size(scenariosMove,2);
numObs = size(baseCaseMove,1);
numSteps = floor(size(baseCaseMove,2) / 2);
numSteps = 16;
lag = 4;
time = [-numSteps:1:numSteps] ./ lag;

%meanIncomes = mean(avgIncomes,1); %Only keep in if creating a new variable
%movavgIncomes = movavg(scenarios(:,1),'simple',lag) .* lag
%stdIncomes = std(scenarios(:,1),1);
%movavgStdIncomes = movavg(stdIncomes', 'simple',lag) .* lag;

f1 = figure();
Ax(1) = axes(f1); 
migration_plots = gobjects(4, 1);  % Pre-allocate for migration plot handles
education_plots = gobjects(4, 1);  % Pre-allocate for migration plot handles
hold on
%For migration
%migration_plots(1) = plot(time,scenariosMove(:,1) ./ 1000, '--', 'Color', colors{1},'LineWidth',2, 'DisplayName', labels(1))




%For education
plot(time, scenariosEd(:,1) ./ 1000, '-', 'Color', colors{1},'LineWidth',2, 'DisplayName', labels(1))

for indexS = 1:numScenarios
    %meanIncomes = mean(scenarios(indexS),1);
    %movavgIncomes = movavg(scenarios(:,indexS), 'simple', lag) .* lag;
    %stdIncomes = std(scenarios(indexS),1);
    %movavgStdIncomes = movavg(stdIncomes', 'simple',lag) .* lag;
    
    %For migration
    %migration_plots(indexS) = plot(time, scenariosMove(:,indexS) ./ 1000 , '--', 'Color', colors{indexS},'LineWidth',3, 'DisplayName', labels(indexS))

    %For education
    education_plots(indexS) = plot(time, scenariosEd(:,indexS) ./ 1000, '-', 'Color', colors{indexS},'LineWidth',3, 'DisplayName', labels(indexS))

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
legend({'Base Case', 'Senegal River', 'Saltwater', 'Groudnut'},'FontSize', 18)

xlabel('Years before/after completing education','FontSize',22)
ylabel('Annual Average Income (1000 CFA)','FontSize',22)


%ylim([0, 700])
%save('EventHistoryIncomes_01.15.2025.mat', 'movavgIncomes')





end