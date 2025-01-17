function plotWealthBackcast()
%% Plotting Avg Income, Backcasting Proportion, and Education (?)

clear all

load ReferenceCase_01.14.2025.mat
multiObjectiveOutput = outputList;

load SenegalRiverDrought_01.14.2025.mat
droughtOutput = outputList;

load SaltwaterIntrusion_01.14.2025.mat
saltwaterOutput = outputList;

load GroundnutBasinDrought_01.14.2025.mat
groundnutOutput = outputList;

%load SaltwaterIntrusion_EdExpansion_MultiObjectiveCalibration_12.05.2024.mat
%saltwaterExpansionOutput = outputList;

droughtStart = 30/4;
droughtEnd = 50/4;

scenarios = [multiObjectiveOutput, droughtOutput, saltwaterOutput, groundnutOutput];
%scenarios = nullOutput;
numScenarios = size(scenarios,2);

colors = {[0.6350 0.0780 0.1840]; [0, 0.4470, 0.7410]; [0.4660, 0.6740, 0.1880]; [0.4940, 0.1840, 0.5560]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]; [0.3010 0.7450 0.9330]};

runs = size(scenarios,1);
steps = size(scenarios(1,1).migrations,1);
time = 1:steps;
communityIncome = zeros(runs,steps);
richestIncome = zeros(runs,steps);
poorestIncome = zeros(runs,steps);
backCast = zeros(runs,steps);
avgIncome = zeros(steps,1);
stdIncome = zeros(steps,1);
avgRichest = zeros(steps,1);
avgPoorest = zeros(steps,1);

avgBackcast = zeros(steps,1);
numAgents = 2000;

lag = 4;
for indexR = 1:runs
    communityIncome(indexR,:) = movavg(scenarios(indexR,1).avgIncomes', 'simple',lag) .* lag;
    %communityIncome(indexR,:) = scenarios(indexR,1).avgIncomes';
    %richestIncome(indexR,:) = movavg(scenarios(indexR,1).richestIncome', 'simple',lag) .* lag;
    %poorestIncome(indexR,:) = movavg(scenarios(indexR,1).poorestIncome','simple',lag) .* lag;
    backCast(indexR,:) = scenarios(indexR,1).pBackcast;
end

for indexT = 1:steps
    avgIncome(indexT) = nanmean(communityIncome(:,indexT));
    stdIncome(indexT) = std(communityIncome(:,indexT));
    %avgRichest(indexT) = nanmean(richestIncome(:,indexT));
    %avgPoorest(indexT) = nanmean(poorestIncome(:,indexT));
    avgBackcast(indexT) = nanmean(backCast(:,indexT));
end
y_low = avgIncome - stdIncome;
y_high = avgIncome + stdIncome;

X = [time, fliplr(time)]./4;
Y = [y_high', fliplr(y_low')];

fill(X, Y, colors{1}, 'FaceAlpha', 0.4)

%plot(time, avgRichest','LineStyle', ':', 'LineWidth', 2,  'Color', colors(1))
%plot(time, avgPoorest', 'LineStyle', '--','LineWidth',2, 'Color',colors(1))
%plot(time ./ 4, avgIncome,'Color', colors{1})
hold on
%yyaxis right
%plot(time ./4, avgBackcast, 'LineStyle', '-', 'Color', colors{1})
%ylabel('Proportion Backcasting')

for indexS = 2:numScenarios
    runs = size(scenarios,1);
    steps = size(scenarios(1,indexS).migrations,1);
    time = 1:steps;

    communityIncome = zeros(runs,steps);
    backcast = zeros(runs,steps);
    avgIncome = zeros(steps,1);
    stdIncome = zeros(steps,1);
    avgBackcast = zeros(steps,1);
    richestIncome = zeros(runs,steps);
    poorestIncome = zeros(runs,steps);
    avgRichest = zeros(steps,1);
    avgPoorest = zeros(steps,1);
    
    lag = 4;
    for indexR = 1:runs
        communityIncome(indexR,:) = movavg(scenarios(indexR,indexS).avgIncomes','simple',lag) .* lag;
        %richestIncome(indexR,:) = movavg(scenarios(indexR,indexS).richestIncome','simple',lag) .* lag;
        %poorestIncome(indexR,:) = movavg(scenarios(indexR,indexS).poorestIncome','simple',lag) .* lag;
        backcast(indexR,:) = scenarios(indexR,indexS).pBackcast;
    end

    for indexT = 1:steps
        avgIncome(indexT) = mean(communityIncome(:,indexT));
        stdIncome(indexT) = std(communityIncome(:,indexT));
        %avgRichest(indexT) = nanmean(richestIncome(:,indexT));
        %avgPoorest(indexT) = nanmean(poorestIncome(:,indexT));
        avgBackcast(indexT) = mean(backcast(:,indexT));
    end
    
    y_low = avgIncome - stdIncome;
    y_high = avgIncome + stdIncome;


    X = [time, fliplr(time)] ./4;
    Y = [y_high', fliplr(y_low')];
    %yyaxis left
    fill(X, Y, colors{indexS}, 'FaceAlpha', 0.4)
    %plot(time ./ 4, avgIncome, 'Color', colors{indexS})
   % plot(time,avgRichest,'LineStyle', ':', 'LineWidth',2,'Color',colors(indexS))
    %plot(time, avgPoorest,'LineStyle', '--', 'LineWidth',2,'Color',colors(indexS))

    %yyaxis right
    %plot(time ./ 4, avgBackcast, 'LineStyle', '-','Color', colors{indexS})

end


hold off
ax = gca;
ax.FontSize=20;
xlabel('Years','FontSize',20);
%xline([droughtStart droughtEnd], '--',{'Start of Drought', 'End of Drought'},'LineWidth', 2, 'Color', '#A2142F','LabelVerticalAlignment', 'bottom', 'FontSize', 20);
%yyaxis left
ylabel('Average Annual Income (CFA)','FontSize',20);
xlim([11/4,steps/4])
%yyaxis right
%ylabel('Average Proportion Backcasting', 'FontSize',20);
legend({'MultiObjective', 'Drought', 'Saltwater', 'Groundnut'}, 'FontSize',22,'Location','northwest')
%saveas(gcf, 'CalibrationMeanIncome.png')

%% Print out average job distribution

start_time = 40;
end_time = 60;

numRegions = 8;

avgJobDistribution = zeros(numRegions, numCategories);

end