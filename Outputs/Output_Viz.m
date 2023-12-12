load Aspirations_SenegalTest_AllPrereqs_Shortterm0_11-Dec-2023_22-47-43.mat
shortterm = output;

load Aspirations_SenegalTest_AllPrereqs_Backcast0_12-Dec-2023_09-25-48.mat
backcast = output;

load Aspirations_SenegalTest_AllPrereqs_Forecast0_11-Dec-2023_23-33-25.mat
forecast = output;


scenariolist = [shortterm, backcast, forecast];
%scenariolist = shortterm;
scenarios= length(scenariolist);
locations = 45;

jobcats = 14;
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
X = categorical({'Ag-Aqua R', 'Ag-Aqua U', 'Livestock R', 'Livestock U', 'Professional R', 'Professional U', 'Services R','Services U', 'Trades R','Trades U', 'Small Business R', 'Small Business U', 'Education R', 'Education U'});
X = reordercats(X, {'Ag-Aqua R', 'Ag-Aqua U', 'Livestock R', 'Livestock U', 'Professional R', 'Professional U', 'Services R','Services U', 'Trades R','Trades U', 'Small Business R', 'Small Business U', 'Education R', 'Education U'});
Y = [];
for indexC = 1:1:scenarios
    Y = [Y; jobs(indexC,:,end)];
end
%bar(X, Y(1,:), 'FaceColor', cm(1,:))
hold on

%for indexI = 2:1:height(Y)
    %if mod(indexI,2) == 0
        %bar(X, Y(indexI,:), 'FaceColor', cm(ceil(indexI/2),:))
    %else
        %bar(X, Y(indexI,:), 'EdgeColor', cm(ceil(indexI/2),:), 'FaceColor', 'white')
    %end
%end
%hold off
%hold on
bar(X,Y,1.0)
hold off
ax = gca;
ax.FontSize = 16;
ylabel('Proportion of Agents','FontSize',16)
xlabel('Income Layers', 'FontSize',16)
legend({'ShortTerm', 'BackCast', 'Forecast'},'FontSize',14)

%% Plot of Total Population for Given Admin Region, across Scenarios
regionalPop = zeros(scenarios,locations,steps);
[sortedAdminUnits, sortedIndex] = sort(scenariolist(1).locations.matrixID);
placeNames = scenariolist(1).locations.source_ADM2_FR(sortedIndex)';

for indexK = 1:scenarios
    for indexA = 1:locations
        for indexT = 1:steps
            regionalPop(indexK,indexA,indexT) = sum(scenariolist(indexK).countAgentsPerLayer(indexA,:,indexT));
        end
    end
end

indexA = 7;

X = 1:steps;
Y = regionalPop(:,indexA,:);

plot(X,Y(1,:))
hold on
for indexK = 2:scenarios
    plot(X,Y(indexK,:))
end
hold off
ax = gca;
ax.FontSize = 16;
ylabel(['Population in ' placeNames(indexA)],'FontSize',16)
xlabel('Time Steps', 'FontSize',16)
legend({'ShortTerm', 'BackCast', 'Forecast'},'FontSize',14)

%% Plot of Average Wealth over Time

scenIndex = 2;
X = 1:steps;
lag = 4; %number of periods over which to average acrosss time

Y = []
for indexK = 1:scenarios
    avgWealth = scenariolist(indexK).averageWealth;
    movavgWealth = movavg(avgWealth, 'simple', lag);
    Y = [Y; movavgWealth'];
end

plot(X,Y,'LineWidth',3)

ax = gca;
ax.FontSize = 16;
ylabel('Average Wealth of Community','FontSize',16)
xlabel('Time', 'FontSize',16)
legend({'ShortTerm', 'BackCast', 'Forecast'},'FontSize',14)

%% Plot of Individual Agent Wealth over time
indexA = 200;
X = 1:steps;
Y = cell2mat(output.agentSummary.wealthHistory{indexA});

plot(X,Y,'LineWidth',3)
ax = gca;
ax.FontSize = 16;
ylabel('Individual Wealth','FontSize',16)
xlabel('Time', 'FontSize',16)

%% Inequality Plots - Average of wealth for top and bottom X% at end of spin-up time to end of model time

%NOTE - FIGURE OUT HOW TO INCORPORATE REAL TIME TOP X and BOTTOM X %
%SHOW SPATIALLY VIA GIS
percentile = 0.2; %cutoff of top and bottom X
cutoffNumber = floor(percentile * numAgents); %Number of agents in each bin
spinupTime = 10; %number of periods after which model has been initialized
wealth = zeros(numAgents,steps);
wealthPoorest = zeros(cutoffNumber,steps);
avgWealthPoorest = zeros(steps);
wealthRichest = zeros(cutoffNumber, steps);
avgWealthRichest = zeros(cutoffNumber,steps);
for indexA = 1:1:numAgents
    wealthHistory = cell2mat(output.agentSummary.wealthHistory{indexA});
    for indexT = 1:size(wealthHistory,2)
        wealth(indexA,indexT) = wealthHistory(:,indexT);
    end
end
startingWealth  = wealth(:,(spinupTime+1));
[sortedwealth, sortIndex] = sort(startingWealth,'ascend');

poorestAgents = sortIndex(1:cutoffNumber);
richestAgents = sortIndex(end-cutoffNumber:end);

for indexW = 1:cutoffNumber
    wealthPoor = cell2mat(output.agentSummary.wealthHistory{poorestAgents(indexW)});
    wealthRich = cell2mat(output.agentSummary.wealthHistory{richestAgents(indexW)});
    for indexP = 1:size(wealthPoor,2)
        wealthPoorest(indexW,indexP) = wealthPoor(:,indexP);
    end

    for indexR = 1:size(wealthRich,2)
        wealthRichest(indexW,indexR) = wealthRich(:,indexR);
    end
    
end

avgWealthPoorest = mean(wealthPoorest,1, 'omitnan')
avgWealthRichest = mean(wealthRichest,1, 'omitnan')

Y1 = avgWealthPoorest;
Y2 = avgWealthRichest;
plot(X,Y1,'LineWidth',3, 'DisplayName', ['Poorest ' num2str(round(percentile*100)) ' % of Agents'])
hold on
plot(X,Y2,'LineWidth',3, 'DisplayName', ['Richest ' num2str(round(percentile * 100)) ' % of Agents'])
hold off
ax = gca;
ax.FontSize = 16;
ylabel('Average Wealth','FontSize',16)
xlabel('Time', 'FontSize',16)
legend()
%% Breakdown of job distributions by educational status
ed_categories = 2; %Number of educational categories - no education, some education, full training
jobsxeducation = zeros(scenarios, ed_categories, jobcats);

termPortfolio = cell(length(scenarios));
ed_status = zeros(scenarios, numAgents);

for indexK = 1:1:scenarios
    for indexA = 1:1:numAgents
        termPortfolio{indexK}(indexA,1:jobcats) = [scenariolist(indexK).agentSummary.currentPortfolio{indexA}(1,1:jobcats)];
        ed_status(indexK, indexA) = scenariolist(indexK).agentSummary.training{indexA}(end);
    end
end



for indexK = 1:1:scenarios
    for indexE = 1:1:ed_categories
        test1 = indexE;
        selected = find(ed_status(indexK,:) == (indexE-1));
        jobsxeducation(indexK, indexE, :) = sum(termPortfolio{indexK}(selected,:),1) ./numAgents;
    end
end


%% Line Plot of job distributions over time
indexL = 13; %Layer of Comparison
categories = {'Ag-Aqua R', 'Ag-Aqua U', 'Livestock R', 'Livestock U', 'Professional R', 'Professional U', 'Services R','Services U', 'Trades R','Trades U', 'Small Business R', 'Small Business U', 'Education R', 'Education U'};
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
legend({'Short Term', 'Backcast', 'Forecast'},'FontSize',14)


%% %% Calculating Aspirations by time

aspirations = zeros(scenarios, jobcats, steps);

%Quantifying agents by aspirations category over time
for indexK = 1:1:scenarios
    numAgents = height(scenariolist(indexK).agentSummary(:,1));
    test1 = indexK
    for indexA = 1:1:numAgents
        lifeA = length(scenariolist(indexK).agentSummary(indexA,:).aspirationHistory{1,1});
        for indexI = 1:1:lifeA
                test1 = scenariolist(indexK).agentSummary(indexA,:).aspirationHistory{1,1}{1,indexI};
                %Figure out how to handle doubles when agent didn't exist
                aspIndex = find(scenariolist(indexK).agentSummary(indexA,:).aspirationHistory{1,1}{1,indexI});
                aspirations(indexK,aspIndex,indexI) = aspirations(indexK,aspIndex,indexI) + 1;
        end
    end
    aspirations(indexK,:,:) = aspirations(indexK,:,:) / numAgents;
end
%% Plotting Aspirations across Scenarios by Individual Layer

test = aspirations(2,:,end)
indexL = 5; %Layer of Comparison
categories = {'Ag-Aqua R', 'Ag-Aqua U', 'Livestock R', 'Livestock U', 'Professional R', 'Professional U', 'Services R','Services U', 'Trades R','Trades U', 'Small Business R', 'Small Business U', 'Education R', 'Education U'};
plot(time,squeeze(aspirations(1,indexL,:)),'LineWidth',3)
hold on
for indexS = 2:1:scenarios
    plot(time,squeeze(aspirations(indexS,indexL,:)),'LineWidth',3)
end
hold off
ax = gca;
ax.FontSize = 16;
xlabel('Time','FontSize',16)
ylabel(['Proportion of Agents Aspiring to ' categories(indexL)],'FontSize',16)
legend({'Short-Term Aspirations (1 Year)', 'Backcast', 'Forecast'},'FontSize',14)
%% Plotting Aspirations across Layers by Individual Scenario
indexS = 2; %Scenario of focus
categories = {'Ag-Aqua R', 'Ag-Aqua U', 'Livestock R', 'Livestock U', 'Professional R', 'Professional U', 'Services R','Services U', 'Trades R','Trades U', 'Small Business R', 'Small Business U', 'Education R', 'Education U'};
%top_categories = {'Livestock R', 'Livestock U','Professional R', 'Professional U','Trades R','Trades U'};
scenario_names = {'Short Term', 'Backcasting', 'Forecasting'};
%plot(time,squeeze(aspirations(indexS,3,:)),'LineWidth',3)
plot(time,squeeze(aspirations(indexS,1,:)),'LineWidth',3)
hold on
for indexL = 2:1:jobcats
    plot(time,squeeze(aspirations(indexS,indexL,:)),'LineWidth',3)
end
%for indexL = 4:1:6
    %plot(time,squeeze(aspirations(indexS,indexL,:)),'LineWidth',3)
%end

%for indexL = 9:1:10
    %plot(time,squeeze(aspirations(indexS,indexL,:)),'LineWidth',3)
%end
hold off

ax=gca;
ax.FontSize=16;
xlabel('Time','FontSize',16)
ylabel(['Proportion of Agents Aspiring to Indicated Layer for ' scenario_names(indexS)], 'FontSize',16)
legend(categories,'FontSize',14)

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
ylabel('Proportion of Agents Migrating','FontSize',16)
legend({'Short Time Horizon', 'Backcast', 'Forecast'},'FontSize',14)

%% Net Migration by Region over Model Run
cutoffIndex = 45; %i.e. show top X number of places on plot
cumulativeInMigration = zeros(locations);
cumulativeOutMigration = zeros(locations);
[sortedAdminUnits, sortedIndex] = sort(scenariolist(indexS).locations.matrixID);
placeNames = scenariolist(indexS).locations.source_ADM2_FR(sortedIndex)';
shortPlaceNames = placeNames(1:cutoffIndex);

netMigration = zeros(locations);
indexS = 1;
cumulativeInMigration = sum(scenariolist(indexS).inMigrations,2);
cumulativeOutMigration = sum(scenariolist(indexS).outMigrations,2);
netMigration = cumulativeInMigration - cumulativeOutMigration;
Y = netMigration';
shortY = Y(1:cutoffIndex);
X = categorical(shortPlaceNames);
X = reordercats(X,shortPlaceNames);

for indexS = 2:1:scenarios
    cumulativeInMigration = sum(scenariolist(indexS).inMigrations,2);
    cumulativeOutMigration = sum(scenariolist(indexS).outMigrations,2);
    netMigration = cumulativeInMigration - cumulativeOutMigration;
    Y = [Y; netMigration'];
    shortY = [shortY; netMigration(1:cutoffIndex)']
end

bar(X,shortY)
ax.FontSize = 16;
xlabel('Admin Regions','FontSize',16)
ylabel('Net Migration (persons)','FontSize',16)
legend({'Short Time Horizon', 'Backcast', 'Forecast'},'FontSize',14);
ax = gca;

%% %% Net Proportional Migration by Region over Model Run
cutoffIndex = 45; %i.e. show top X number of places on plot
cumulativeInMigration = zeros(locations);
cumulativeOutMigration = zeros(locations);
initialPopulation = zeros(locations);
[sortedAdminUnits, sortedIndex] = sort(scenariolist(indexS).locations.matrixID);
placeNames = scenariolist(indexS).locations.source_ADM2_FR(sortedIndex)';
shortPlaceNames = placeNames(1:cutoffIndex);
proportionalMigration = zeros(locations);

indexS = 1;
cumulativeInMigration = sum(scenariolist(indexS).inMigrations,2);
cumulativeOutMigration = sum(scenariolist(indexS).outMigrations,2);
initialPopulation = sum(scenariolist(indexS).countAgentsPerLayer(:,:,10),2)
proportionalMigration = (cumulativeInMigration - cumulativeOutMigration) ./ initialPopulation
Y = proportionalMigration';
shortY = Y(1:cutoffIndex)
X = categorical(shortPlaceNames);
X = reordercats(X,shortPlaceNames);

for indexS = 2:1:scenarios
    cumulativeInMigration = sum(scenariolist(indexS).inMigrations,2);
    cumulativeOutMigration = sum(scenariolist(indexS).outMigrations,2);
    proportionalMigration = (cumulativeInMigration - cumulativeOutMigration) ./ initialPopulation
    Y = [Y; proportionalMigration'];
    shortY = [shortY; proportionalMigration(1:cutoffIndex)']
end

bar(X,shortY)
xlabel('Admin Regions','FontSize',16)
ylabel('Proportional Migration (Fraction of Original Population)','FontSize',16)
legend({'Short Time Horizon', 'Backcast', 'Forecast'},'FontSize',14);
ax = gca;


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
categories = {'Ag-Aqua R', 'Ag-Aqua U', 'Livestock R', 'Livestock U', 'Professional R', 'Professional U', 'Services R','Services U', 'Trades R','Trades U', 'Small Business R', 'Small Business U', 'Education R', 'Education U'};

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
legend({'Short Term', 'Backcast', 'Forecast'},'FontSize',14)

%% Aspirations by Time
indexA = 3; %Income Layer for Focal Aspiration
time = 1:steps;
plot(time, scenariolist(1).aspirationHistory(indexA,:),'LineWidth',3)
hold on
for indexS = 2:1:scenarios
    plot(time, scenariolist(indexS).aspirationHistory(indexA,:),'LineWidth',3)
end
hold off
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


