
load Aspirations_UnitTest_NoPrereqs_Forecast0_20-Apr-2023_10-52-26.mat
norequirements = output;
load Aspirations_UnitTest_EducationPrereq_Forecast0_20-Apr-2023_11-05-55.mat
education = output;
load Aspirations_UnitTest_FarmPrereq_Forecast0_20-Apr-2023_11-26-25.mat
farm = output;
load Aspirations_UnitTest_UnskilledPrereq_Forecast0_20-Apr-2023_11-33-04.mat
unskill = output;
load Aspirations_UnitTest_AllPrereqs_Forecast0_21-Apr-2023_14-29-43.mat
all = output;

load Aspirations_UnitTest_NoPrereqs_Backcast0_20-Apr-2023_10-59-13.mat
norequirements_back = output;
load Aspirations_UnitTest_EducationPrereq_Backcast0_20-Apr-2023_11-13-08.mat
education_back = output;
load Aspirations_UnitTest_FarmPrereq_Backcast0_20-Apr-2023_11-20-07.mat
farm_back = output;
load Aspirations_UnitTest_UnskilledPrereq_Backcast0_20-Apr-2023_11-39-50.mat
unskill_back = output;
load Aspirations_UnitTest_AllPrereqs_Backcast0_20-Apr-2023_11-49-25.mat
all_back = output;


scenariolist = [norequirements,norequirements_back, education, education_back, farm, farm_back, all, all_back];
scenarios= length(scenariolist);
locations = 45;
jobcats = 6;
seasonalthresh = 4; %Number of periods within which a "seasonal migrant" must migrate and make a return trip
numAgents = height(norequirements.agentSummary(:,1));
%Create time vector
steps = 170;
time = 1:steps;

jobs = zeros(scenarios, jobcats, steps);

%Quantifying agents by job category over time
for indexK = 1:1:scenarios
    for indexJ = 1:1:jobcats
        for indexI = 1:1:steps
            jobs(indexK,indexJ,indexI) = sum(scenariolist(indexK).countAgentsPerLayer(:,indexJ,indexI));
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
ylabel('Number of Agents','FontSize',16)
xlabel('Income Layers', 'FontSize',16)
legend({'No Prereqs', 'No Prereqs Back', 'Education Prereq', 'Education Back', 'Farm Prereq', 'Farm Back', 'All Prereqs', 'All Back'},'FontSize',14)
%% Line Plot of job distributions over time
indexL = 6; %Layer of Comparison
categories = {'Unskilled 1', 'Unskilled 2', 'Skilled', 'Ag1', 'Ag2', 'School'};
plot(time,squeeze(jobs(1,indexL,:)))
hold on
for indexS = 2:1:scenarios
    plot(time,squeeze(jobs(indexS,indexL,:)))
end
hold off
ax = gca;
ax.FontSize = 16;
xlabel('Time','FontSize',16)
ylabel(['Number of Agents in ' categories(indexL)],'FontSize',16)
legend({'No Prereqs', 'Education Prereq', 'Farm Prereq', 'Unskilled Prereq', 'All Prereqs'},'FontSize',14)

%% Migration Trips over time
%%Line Plot of Migration Trips
scatter(time,scenariolist(1).migrations, 'color', 'black')
hold on
for indexI = 2:1:scenarios
    plot(time,scenariolist(indexI).migrations)
end
hold off
ax = gca;
ax.FontSize = 16;
xlabel('Time','FontSize',16)
ylabel('Migration Trips','FontSize',16)
legend({'No Prereqs', 'NP Back', 'Education Prereq','Ed Back', 'Farm Prereq', 'F Back', 'Unskilled Prereq', 'Uns Back', 'All Prereqs', 'All Back'},'FontSize',14)

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
    seasonalmigration(indexS) = sum(seasonaltrips(indexS,:));
    cyclicalmigration(indexS) = sum(cyclicaltrips(indexS,:));
end


%Bar Graph of seasonal migrants
X = categorical({'No Prereqs', 'Education Prereq', 'Farm Prereq', 'Unskilled Prereq', 'All Prereqs'});
X = reordercats(X, {'No Prereqs', 'Education Prereq', 'Farm Prereq', 'Unskilled Prereq', 'All Prereqs'});
Y = cyclicalmigration;
bar(X,Y)
ax = gca;
ax.FontSize = 16;
ylabel('Number of Cyclical Trips','FontSize',16)
%% Proportion Aspirations by Time
scenarios = length(scenariolist);
aspirationProp = zeros(scenarios,steps);
categories = {'Unskilled 1', 'Unskilled 2', 'Skilled', 'Ag1', 'Ag2', 'School'};

for indexS = 1:1:scenarios
    aspirationProp(indexS,:) = sum(scenariolist(indexS).aspirationHistory,1)/numAgents;
end

plot(time,aspirationProp)
hold off

ax = gca;
ax.FontSize = 16;
xlabel('Time','FontSize',16)
ylabel('Proportion Agents with Unmet Aspirations' ,'FontSize',16)
legend({'No Prereqs', 'NP Back', 'Education Prereq', 'Ed Back', 'Farm Prereq', 'Farm Back', 'Unskilled Prereq', 'Uns Back', 'All Prereqs', 'All Back'},'FontSize',14)


%% Aspirations by Time
indexA = 5; %Income Layer for Focal Aspiration
plot(time, scenariolist(1).aspirationHistory(indexA,:))
hold on
for indexS = 2:1:scenarios
    plot(time, scenariolist(indexS).aspirationHistory(indexA,:))
end

ax = gca;
ax.FontSize = 16;
xlabel('Time','FontSize',16)
ylabel(['Number of Agents Aspiring to ' categories{indexA}],'FontSize',16)
legend({'No Prereqs', 'Education Prereq', 'Farm Prereq', 'Unskilled Prereq', 'All Prereqs'},'FontSize',14)


