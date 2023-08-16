load Aspirations_UnitTest_AllPrereqs_10periodHorizon0_15-Aug-2023_19-27-13.mat
shortterm = output;

load Aspirations_UnitTest_AllPrereqs_Backcasting0_11-Aug-2023_15-57-46.mat
backcast = output;

load Aspirations_UnitTest_AllPrereqs_Forecasting0_15-Aug-2023_18-37-27.mat
forecast = output;

scenariolist = [shortterm, forecast, backcast];
scenarios= length(scenariolist);
locations = 45;
jobcats = 6;
seasonalthresh = 4; %Number of periods within which a "seasonal migrant" must migrate and make a return trip
numAgents = height(scenariolist(1).agentSummary(:,1));
%Create time vector
steps = 170;
time = 1:steps;

jobs = zeros(scenarios, jobcats, steps);

%Quantifying agents by job category over time
for indexK = 1:1:scenarios
    for indexJ = 1:1:jobcats
        for indexI = 1:1:steps
            jobs(indexK,indexJ,indexI) = sum(scenariolist(indexK).countAgentsPerLayer(:,indexJ,indexI)) ./ numAgents;
        end
    end
end
cm = colororder;

% Bar Graph of job distribution at terminal time
X = categorical({'Unskilled 1', 'Unskilled 2', 'Skilled', 'Ag1', 'Ag2', 'School'});
X = reordercats(X, {'Unskilled 1', 'Unskilled 2', 'Skilled', 'Ag1', 'Ag2', 'School'});
Y = [];
for indexC = 1:1:scenarios
    Y = [Y; jobs(indexC,:,end)];
end
%bar(X, Y(1,:), 'FaceColor', cm(1,:))
%hold on
%bar(X, Y(2,:), 'EdgeColor', cm(1,:), 'FaceColor', 'white')

%for indexI = 2:1:height(Y)
    %if mod(indexI,2) == 0
        %bar(X, Y(indexI,:), 'FaceColor', cm(ceil(indexI/2),:))
    %else
       % bar(X, Y(indexI,:), 'EdgeColor', cm(ceil(indexI/2),:), 'FaceColor', 'white')
   % end
%end
%hold off

bar(X,Y,1.0)
ax = gca;
ax.FontSize = 16;
ylabel('Proportion of Agents','FontSize',16)
xlabel('Income Layers', 'FontSize',16)
legend({'No Aspirations', 'Forecast', 'BackCast'},'FontSize',14)
%% Line Plot of job distributions over time
indexL = 6; %Layer of Comparison
categories = {'Unskilled 1', 'Unskilled 2', 'Skilled', 'Ag1', 'Ag2', 'School'};
plot(time,squeeze(jobs(1,indexL,:)),'LineWidth',3)
hold on
for indexS = 2:1:scenarios
    plot(time,squeeze(jobs(indexS,indexL,:)),'LineWidth',3)
end
hold off
ax = gca;
ax.FontSize = 16;
xlabel('Time','FontSize',16)
ylabel(['Proportion of Agents in ' categories(indexL)],'FontSize',16)
legend({'No Aspirations', 'Forecast', 'BackCast'},'FontSize',14)

%% Migration Trips over time
%%Line Plot of Migration Trips
simplemigration = zeros(scenarios,steps);
lag = 4;
for indexS = 1:scenarios
    simplemigration(indexS,:) = movavg(scenariolist(indexS).migrations,'simple',lag) ./numAgents;
end

plot(time,simplemigration(1,:), 'LineWidth',2)
hold on
for indexI = 2:1:scenarios
    plot(time,simplemigration(indexI,:),'LineWidth',2)
end
hold off
ax = gca;
ax.FontSize = 16;
xlabel('Time','FontSize',16)
ylabel('Migration Proportion','FontSize',16)
legend({'Short Time Horizon', 'Forecast', 'BackCast'},'FontSize',14)
%% Seasonal Migration
seasonalmigration = zeros(scenarios,1);
seasonaltrips = zeros(scenarios, numAgents);
cyclicaltrips = zeros(scenarios, numAgents);

%Go through different scenarios

for indexS = 1:1:scenarios
    simulation = scenariolist(indexS).agentSummary.moveHistory;

    %Go through each agent's history
    for indexA = 1:1:numAgents
        focalA = simulation{indexA,1};
        movelength = zeros(size(focalA,1),1);
        
        %Assess time between each trip
        for indexB = 1:1:(height(movelength)-1)
            movelength(indexB) = focalA(indexB+1,1) - focalA(indexB,1);
           
        end
        shorttrips = movelength < seasonalthresh; %Vector that returns 1 if time between two trips is less than seasonal threshold
        seasonaltrips(indexS,indexA) = sum(shorttrips);
        
        destinations = focalA(:,2);
        for indexI = 1:1:height(shorttrips)
            if indexI > 1 && indexI < height(movelength)
                if destinations(indexI - 1) == destinations(indexI + 1)
                    cyclicaltrips(indexS,indexA) = cyclicaltrips(indexS,indexA) + 1;
                end
            end
        end
        
    end
    seasonalmigration(indexS) = sum(seasonaltrips(indexS,:)) ./ numAgents;
    cyclicalmigration(indexS) = sum(cyclicaltrips(indexS,:)) ./ numAgents;
end


%Bar Graph of seasonal migrants
X = categorical({'Short Time Horizon', 'Forecast', 'BackCast'});
X = reordercats(X, {'Short Time Horizon', 'Forecast', 'BackCast'});
Y = cyclicalmigration;
bar(X,Y)
ax = gca;
ax.FontSize = 16;
ylabel('Number of Cyclical Trips  per Agent','FontSize',16)
%% Proportion Aspirations by Time
scenarios = length(scenariolist);
aspirationProp = zeros(scenarios,steps);
simpleaspiration = zeros(scenarios,steps);
categories = {'Unskilled 1', 'Unskilled 2', 'Skilled', 'Ag1', 'Ag2', 'School'};
lag = 4;

for indexS = 1:1:scenarios
    aspirationProp(indexS,:) = sum(scenariolist(indexS).aspirationHistory,1)/numAgents;
    test = aspirationProp(indexS,:)';
    simpleaspiration(indexS,:) = movavg(test, 'simple', lag);
end

plot(time,simpleaspiration,'LineWidth',2)
hold off

ax = gca;
ax.FontSize = 16;
xlabel('Time','FontSize',16)
ylabel('Proportion Agents with Unmet Aspirations' ,'FontSize',16)
legend({'Short Time Horizon (4 yrs)', 'Forecast', 'BackCast'},'FontSize',14)

%% Aspirations by Time
indexA = 5; %Income Layer for Focal Aspiration
time = 1:steps;
plot(time, scenariolist(1).aspirationHistory(indexA,:),'LineWidth',3)
hold on
for indexS = 2:1:scenarios
    plot(time, scenariolist(indexS).aspirationHistory(indexA,:),'LineWidth',3)
end

ax = gca;
ax.FontSize = 16;
xlabel('Time','FontSize',16)
ylabel(['Number of Agents Aspiring to ' categories{indexA}],'FontSize',16)
legend({'No Aspirations', 'Forecast', 'BackCast'},'FontSize',14)

%% Number of trapped agents

numberTrapped = zeros(scenarios,1);
for indexK = 1:1:scenarios
    numberTrapped(indexK) = sum(scenariolist(indexK).trappedHistory(:,end),1);
end

X = categorical({'No Aspirations', 'Forecast', 'BackCast'});
X = reordercats(X, {'No Aspirations', 'Forecast', 'BackCast'});
Y = numberTrapped';
test = X;
bar(X,Y)
ax = gca;
ax.FontSize = 16;
ylabel('Number of Trapped Agents','FontSize',16)
xlabel('Scenarios', 'FontSize',16)

%% Line Graph of proportion considering each layer over time

propConsidering = zeros(jobcats, steps);
time = 1:steps;

for indexA = 1:numAgents
    agentOptions = scenariolist(3).agentSummary.consideredHistory{indexA};
    for indexT = 1:steps
        yearPortfolio = agentOptions{indexT};
        if ~isempty(yearPortfolio)
            numPortfolios = height(yearPortfolio);
            for indexL = 1:numPortfolios
                tempPortfolio = yearPortfolio(indexL,:);
                propConsidering(:,indexT) = propConsidering(:,indexT) + tempPortfolio';
                
            end
        end         
     end
end

propConsidering = propConsidering ./ numAgents;

plot(time, propConsidering(1,:))
hold on
for indexS = 2:1:jobcats
    plot(time,propConsidering(indexS,:))
end
hold off

ax = gca;
ax.FontSize = 16;
ylabel('Number of Portfolios per Agent','FontSize',16)
xlabel('Time', 'FontSize',16)
legend({'Unskilled 1', 'Unskilled 2', 'Skilled', 'Ag1', 'Ag2', 'School'},'FontSize',16)

%% Heatmap of layers (rows) and portfolio size (columns)

communityPortfolios = [];
sizeArray = [];
correlationArray = [];
numLocations = height(output.portfolioHistory);
focalTime = 170;
jobCategories = ["Unskilled 1", "Unskilled 2", "Skilled", "Ag1", "Ag2", "School"];
sizeOne = zeros(jobcats,1);
sizeTwo = zeros(jobcats,1);

for indexL = 1:numLocations
    tempPortfolios = scenariolist(3).portfolioHistory{indexL,focalTime};
    communityPortfolios = [communityPortfolios; tempPortfolios'];
end

for indexP = 1:height(communityPortfolios)
    for indexJ = 1:jobcats
        tempPortfolio = communityPortfolios{indexP};
        correlationArray = [correlationArray; tempPortfolio];
        sizeArray = [sizeArray; tempPortfolio .* sum(tempPortfolio)];
    end
end

corrMatrix = corrcoef(correlationArray)

for indexJ = 1:jobcats
    [a,b] = hist(sizeArray(:,indexJ), unique(sizeArray(:,indexJ)));
    if ismember(1,b)
        sizeOne(indexJ) = a(b==1);
    end
     if ismember(2,b)
        sizeTwo(indexJ) = a(b==2);
    end    
end

frequencyData = [sizeOne,sizeTwo];

frequencyData = frequencyData ./ sum(frequencyData,2)

h = heatmap({"1", "2"}, jobCategories, frequencyData);

h.Title = ['Distribution of Portfolio Size based on Included Layers at time ' num2str(focalTime)];
h.XLabel = 'Number of Layers in Portfolio';
h.YLabel = 'Income Layers';
h.FontSize = 18;

%% Heatmap try 1

isupper = logical(triu(ones(size(corrMatrix)),1));
corrMatrix(isupper) = NaN;

h = heatmap(corrMatrix,'MissingDataColor','w');
labels = jobCategories;
h.XDisplayLabels = labels;
h.YDisplayLabels = labels;
h.FontSize = 18;


