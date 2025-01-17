function plotEdHistogram()
%Function that plots cumulative education rate of agents over time

load ReferenceCase_01.14.2025.mat
multiObjectiveOutput = outputList;

load SenegalRiverDrought_01.14.2025.mat
droughtOutput = outputList;

load SaltwaterIntrusion_01.14.2025.mat
saltwaterOutput = outputList;

load GroundnutBasinDrought_01.14.2025.mat
groundnutOutput = outputList;

scenarios = [multiObjectiveOutput, droughtOutput, saltwaterOutput, groundnutOutput];
colors = {[0.6350 0.0780 0.1840]; [0, 0.4470, 0.7410]; [0.4660, 0.6740, 0.1880]; [0.4940, 0.1840, 0.5560]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]; [0.3010 0.7450 0.9330]};

runs = size(scenarios,1);
numScenarios = size(scenarios,2);
numSteps = size(scenarios(1).migrationMatrix,3);
numDiplomas = zeros(runs,numSteps);
meanDiplomas = zeros(numScenarios,numSteps);
%% 
%Calculate proportion of agents with diploma in each run/time step
for indexR = 1:runs
    rawDiplomas = [scenarios(indexR,1).diplomas{:}];
    numAgents = height(scenarios(indexR,1).diplomas);
    [GC,GR] = groupcounts(rawDiplomas');
    numDiplomas(indexR,GR) = GC' ./ numAgents;

end

meanDiplomas(1,:) = mean(numDiplomas,1);
stdDiplomas = std(numDiplomas,1);
y_low = meanDiplomas(1,:) - stdDiplomas(1,:);
y_high = meanDiplomas(1,:) + stdDiplomas(1,:);

time = [1:numSteps];
x = time ./ 4;
%plot(x,meanDiplomas)

X = [time, fliplr(time)] ./ 4;
Y = [y_low, fliplr(y_high)];
fill(X, Y, colors{1}, 'FaceAlpha', .4)

hold on
%Calculate proportion of agents with diploma in each run/time step
numDiplomas = zeros(runs,numSteps);
for indexS = 2:numScenarios
    test = indexS
    for indexR = 1:runs
        rawDiplomas = [scenarios(indexR,indexS).diplomas{:}];
        numAgents = height(scenarios(indexR,indexS).diplomas);
        [GC,GR] = groupcounts(rawDiplomas');
        numDiplomas(indexR,GR) = GC' ./ numAgents;

    end

    meanDiplomas(indexS,:) = mean(numDiplomas,1);
    stdDiplomas = std(numDiplomas,1);
    y_low = meanDiplomas(1,:) - stdDiplomas(1,:);
    y_high = meanDiplomas(1,:) + stdDiplomas(1,:);
    
    X = [time, fliplr(time)] ./ 4;
    Y = [y_low, fliplr(y_high)];
    fill(X, Y, colors{indexS}, 'FaceAlpha', .4)
    %plot(x,meanDiplomas)
end
hold off

ax = gca;
ax.FontSize = 16;
xlabel('Years','FontSize',16)
ylabel('Proportion of Agents with Diploma','FontSize',16)
xlim([11/4,numSteps/4])
legend({'Reference Case', 'Senegal River Drought', 'Saltwater Intrusion', 'Groundnut'},'FontSize',14)



end