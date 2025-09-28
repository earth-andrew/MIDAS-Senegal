function plotEdHistogram()
%Function that plots cumulative education rate of agents over time

load ReferenceCase_07.06.2025.mat
multiObjectiveOutput = outputList;

load NoAspirations_07.06.2025.mat
nullOutput = outputList;

load SenegalRiverDrought_07.06.2025.mat
droughtOutput = outputList;

load SaltwaterIntrusion_07.06.2025.mat
saltwaterOutput = outputList;

scenarios = [multiObjectiveOutput, nullOutput, droughtOutput, saltwaterOutput];
colors = {[0.6350 0.0780 0.1840]; [0, 0.4470, 0.7410]; [0.4660, 0.6740, 0.1880]; [0.4940, 0.1840, 0.5560]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]; [0.3010 0.7450 0.9330]};

runs = size(scenarios,1);
numScenarios = size(scenarios,2);
numSteps = size(scenarios(1).migrationMatrix,3);

%Set up variables to track diplomas (i.e. completing 4-year university) and
%vocational (completing 2-year post-secondary)
numDiplomas = zeros(runs,numSteps);
meanDiplomas = zeros(numScenarios,numSteps);
stdDiplomas = zeros(numScenarios,numSteps);

numVocational = zeros(runs,numSteps);
meanVocational = zeros(numScenarios,numSteps);
stdVocational = zeros(numScenarios,numSteps);

%% 
%Calculate proportion of agents with diploma and vocational in each run/time step
for indexR = 1:runs
    rawDiplomas = [scenarios(indexR,1).diplomas{:}];
    rawVocational = [scenarios(indexR,1).vocational{:}];
    
    numAgents = height(scenarios(indexR,1).diplomas);
    [GC,GR] = groupcounts(rawDiplomas');
    numDiplomas(indexR,GR) = GC' ./ numAgents;
    
    [VC,VR] = groupcounts(rawVocational');
    numVocational(indexR,VR) = VC' ./ numAgents;

end

meanDiplomas(1,:) = mean(numDiplomas,1);
stdDiplomas(1,:) = std(numDiplomas,1);
y_low = meanDiplomas(1,:) - stdDiplomas(1,:);
y_high = meanDiplomas(1,:) + stdDiplomas(1,:);

meanVocational(1,:) = mean(numVocational,1);
stdVocational(1,:) = std(numVocational,1);
v_low = meanVocational(1,:) - stdVocational(1,:);
v_high = meanVocational(1,:) + stdVocational(1,:);


time = [1:numSteps];
x = time ./ 4;
%plot(x,meanDiplomas)
test = meanDiplomas(1,end)
test2 = meanVocational(1,end)

X = [time, fliplr(time)] ./ 4;
Y = [y_low, fliplr(y_high)];
fill(X, Y, colors{1}, 'FaceAlpha', .4)

hold on

for indexS = 2:numScenarios
%Calculate proportion of agents with diploma in each run/time step
numDiplomas = zeros(runs,numSteps);
numVocational = zeros(runs,numSteps);

    for indexR = 1:runs
        rawDiplomas = [scenarios(indexR,indexS).diplomas{:}];
        rawVocational = [scenarios(indexR,indexS).vocational{:}];
        
        numAgents = height(scenarios(indexR,indexS).diplomas);
        [GC,GR] = groupcounts(rawDiplomas');
        numDiplomas(indexR,GR) = GC' ./ numAgents;
        
        [VC,VR] = groupcounts(rawVocational');
        numVocational(indexR,VR) = VC' ./ numAgents;

    end

    meanDiplomas(indexS,:) = mean(numDiplomas,1);
    stdDiplomas(indexS,:) = std(numDiplomas,1);
    y_low = meanDiplomas(indexS,:) - stdDiplomas(indexS,:);
    y_high = meanDiplomas(indexS,:) + stdDiplomas(indexS,:);
    
    meanVocational(indexS,:) = mean(numVocational,1);
    stdVocational(indexS,:) = std(numVocational,1);
    v_low = meanVocational(indexS,:) - stdVocational(indexS,:);
    v_high = meanVocational(indexS,:) + stdVocational(indexS,:);
    
    X = [time, fliplr(time)] ./ 4;
    Y = [y_low, fliplr(y_high)];
    fill(X, Y, colors{indexS}, 'FaceAlpha', .4)
    test = meanDiplomas(indexS,end)
    test2 = meanVocational(indexS,end)
    %plot(x,meanDiplomas)
end
hold off

ax = gca;
ax.FontSize = 16;
xlabel('Years','FontSize',16)
ylabel('Proportion of Agents with 4-Year Diploma','FontSize',16)
xlim([11/4,numSteps/4])
legend({'Reference Case', 'No Aspirations', 'Senegal River Drought', 'Saltwater Intrusion'},'FontSize',14,'Location','northwest')
%saveas(gcf, 'EducationRates_02.08.2025.png')

%% Dumbbell chart displaying differences between vocational and 4-year educational rates

%Specify reference timestep
timestep = 110;

plot([meanVocational(1,timestep), meanDiplomas(1,timestep)], [1,1], 'k-', 'LineWidth', 2);

hold on
h1 = plot(meanVocational(1,timestep), 1, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);
h2 = plot(meanDiplomas(1,timestep), 1, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 8);

for indexS = 2:numScenarios
    plot([meanVocational(indexS,timestep), meanDiplomas(indexS,timestep)], [indexS,indexS], 'k-', 'LineWidth', 2);
    plot(meanVocational(indexS,timestep), indexS, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);
    plot(meanDiplomas(indexS,timestep), indexS, 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 8);
end

xlim([0, 1]); % Adjust based on your data range
ylim([0.5, (indexS + 0.5)]); % Keep a small y-range for the dumbbell effect
set(gca, 'YTick', 1:length(scenarios)); % Set the y-ticks to correspond to each scenario
set(gca, 'YTickLabel', {'Reference', 'No Aspirations', 'SenegalRiver', 'Saltwater'}, 'FontSize',16); % Set the y-tick labels to the scenario names
xlabel('Mean Educational Rate', 'FontSize', 16);
legend([h1, h2], {'Vocational','4-Year'},'FontSize', 14, 'Location','Best');

grid on;


hold off;
%saveas(gcf, 'EducationCompare_02.08.2025.png')

%% Bar chart displaying university and vocational rates
%scenarios = [multiObjectiveOutput];

scenarios = [multiObjectiveOutput, nullOutput, droughtOutput, saltwaterOutput];

aggregateEdRates = zeros(numScenarios, 3); %Matrix with rows for each scenario and university, vocational, and both total

%Find agents with both vocational and university education in any given run
numUniversityGrads = zeros(numScenarios,runs);
numVocationalGrads = zeros(numScenarios,runs);
twoDiplomaGrads = zeros(numScenarios,runs);

for indexS = 1:numScenarios
    for indexR = 1:runs
        numAgents = height(scenarios(indexR,indexS).diplomas);
        universityGrads = find(~cellfun('isempty',scenarios(indexR,indexS).diplomas));
        numUniversityGrads(indexS,indexR) = numel(universityGrads) ./ numAgents;
        vocationalGrads = find(~cellfun('isempty',scenarios(indexR,indexS).vocational));
        numVocationalGrads(indexS,indexR) = numel(vocationalGrads) ./ numAgents;
        bothGrads = intersect(universityGrads, vocationalGrads);
        twoDiplomaGrads(indexS,indexR) = numel(bothGrads) ./ numAgents;
    end
end

universityOnlyGrads = numUniversityGrads - twoDiplomaGrads;
vocationalOnlyGrads = numVocationalGrads - twoDiplomaGrads;

aggregateEdRates(:,1) = mean(universityOnlyGrads,2);
aggregateEdRates(:,2) = mean(vocationalOnlyGrads,2);
aggregateEdRates(:,3) = mean(twoDiplomaGrads,2);

X = categorical({'Reference Case', 'No Aspirations', 'Senegal River', 'Saltwater'});
X = reordercats(X,{'Reference Case', 'No Aspirations', 'Senegal River', 'Saltwater'});

b = bar(X,aggregateEdRates,'stacked');
b(1).FaceColor = '#0072BD';
b(2).FaceColor = '#A2142F';
b(3).FaceColor =  '#7E2F8E';
ax = gca;
ax.FontSize = 16;


%xlabel({'Reference Case', 'No Aspirations', 'Senegal River', 'Saltwater', 'Groundnut'},'FontSize',16)
ylabel('Proportion of Agents','FontSize',16)

legend({'4-Year University', '2-Year Vocational', 'Both Diplomas'},'FontSize',14,'Location','north')
%saveas(gcf, 'EducationRates_07.06.2025.png')



end