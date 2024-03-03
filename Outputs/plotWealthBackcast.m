function plotWealthBackcast()
%% Plotting Avg Wealth, Backcasting Proportion, and Education (?)

%load RandomUtilitiesOutputs.mat
%nullOutput = nullOutputList;

load SenegalBaseCase_MedianRun0_02-Mar-2024_20-37-03.mat
baseOutput = output;

load SenegalRiverDrought_MedianRun0_02-Mar-2024_19-46-17.mat
droughtOutput = output;

load SenegalSaltwaterIntrusion_MedianRun0_02-Mar-2024_20-12-06.mat
saltwaterOutput = output;

scenarios = [baseOutput, droughtOutput, saltwaterOutput];
numScenarios = size(scenarios,2)
colors = ['b', 'g', 'm'];

runs = size(scenarios,1);
steps = size(scenarios(1,1).migrations,1);
time = 1:steps;
communityWealth = zeros(runs,steps);
backCast = zeros(runs,steps);
avgWealth = zeros(steps,1);
stdWealth = zeros(steps,1);
avgBackcast = zeros(steps,1);
numAgents = 2000;

for indexR = 1:runs
    communityWealth(indexR,:) = scenarios(indexR,1).averageWealth ./ numAgents;
    %backCast(indexR,:) = scenarios(indexR,1).pBackcast;
end

for indexT = 1:steps
    avgWealth(indexT) = mean(communityWealth(:,indexT));
    stdWealth(indexT) = std(communityWealth(:,indexT));
    %avgBackcast(indexT) = mean(backCast(:,indexT));
end

y_low = avgWealth - stdWealth;
y_high = avgWealth + stdWealth;

X = [time, fliplr(time)];
Y = [y_high', fliplr(y_low')];

yyaxis left
%fill(X, Y, colors(1), 'LineStyle', '-', 'FaceAlpha', 0.1)
plot(time, avgWealth, 'LineWidth', 3, 'Color', colors(1))
%yyaxis right
%plot(time, avgBackcast, 'LineStyle', '--', 'Color', colors(1))
%ylabel('Proportion Backcasting (Dashed Line)')

hold on 
for indexS = 2:numScenarios
    runs = size(scenarios,1);
    steps = size(scenarios(1,indexS).migrations,1);
    time = 1:steps;

    communityWealth = zeros(runs,steps);
    backcast = zeros(runs,steps);
    avgWealth = zeros(steps,1);
    stdWealth = zeros(steps,1);
    %avgBackcast = zeros(steps,1);

    for indexR = 1:runs
        communityWealth(indexR,:) = scenarios(indexR,indexS).averageWealth ./ numAgents;
        %backcast(indexR,:) = scenarios(indexR,indexS).pBackcast;
    end

    for indexT = 1:steps
        avgWealth(indexT) = mean(communityWealth(:,indexT));
        stdWealth(indexT) = std(communityWealth(:,indexT));
        %avgBackcast(indexT) = mean(backcast(:,indexT));
    end

    y_low = avgWealth - stdWealth;
    y_high = avgWealth + stdWealth;


    X = [time, fliplr(time)];
    Y = [y_high', fliplr(y_low')];
    yyaxis left
    %fill(X, Y, colors(indexS), 'FaceAlpha', 0.25)
    plot(time, avgWealth, 'Color', colors(indexS))

    %yyaxis right
    %plot(time, avgBackcast, 'LineStyle','--', 'Color', colors(indexS))

end

hold off
ax = gca;
ax.FontSize=16;
xlabel('Time','FontSize',16);

yyaxis left
ylabel('Average per Capita Wealth (CFA)','FontSize',16);
xlim([11,steps]);
legend({'Base Case', 'Senegal River Drought', 'Saltwater Intrusion'}, 'FontSize',14)
end