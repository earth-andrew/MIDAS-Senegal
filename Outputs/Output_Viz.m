
load MC_Run_0_16-Mar-2023_16-29-54.mat
norequirements = output;
load MC_Run_0_16-Mar-2023_16-35-27.mat
prerequisites = output;


scenariolist = [norequirements, prerequisites];
scenarios= length(scenariolist);
locations = 45;
jobcats = 6;
seasonalthresh = 4; %Number of cycles within which a "seasonal migrant" must migrate and make a return trip
numAgents = height(norequirements.agentSummary(:,1));
%Create time vector
steps = 170;
time = 1:steps;



%Plot total migrations by time
jobs = zeros(scenarios, jobcats, steps);

for indexK = 1:1:scenarios
    for indexJ = 1:1:jobcats
        for indexI = 1:1:steps
            jobs(indexK,indexJ,indexI) = sum(scenariolist(indexK).countAgentsPerLayer(:,indexJ,indexI));
        end
    end
end


%Seasonal Migration
seasonalmigration = zeros(scenarios,1);
seasonaltrips = zeros(scenarios, numAgents);
cyclicaltrips = zeros(scenarios, numAgents);

%Go through different scenarios
for indexS = 1:1:size(scenariolist)
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
        for indexI = shorttrips
            if indexI > 1 & indexI < height(movelength)
                if destinations(indexI - 1) == destinations(indexI + 1)
                    cyclicaltrips(indexS,indexA) = cyclicaltrips(indexS,indexA) + 1;
                end
            end
        end
        
    end
    seasonalmigration(indexS) = sum(seasonaltrips(indexS,:));
    cyclicalmigration(indexS) = sum(cyclicaltrips(indexS,:));
end


%%Line Plot of Migration Trips
scatter(time,norequirements.migrations, 'color', 'black')
hold on
for indexI = 2:1:scenarios
    plot(time,scenariolist(indexI).migrations)
end
hold off
xlabel('Time')
ylabel('Number of Migrants')
legend('No Requirements', 'Prerequisites')%% 


% Bar Graph of job distribution at terminal time
X = categorical({'Unskilled 1', 'Unskilled 2', 'Skilled', 'Ag1', 'Ag2', 'School'});
X = reordercats(X, {'Unskilled 1', 'Unskilled 2', 'Skilled', 'Ag1', 'Ag2', 'School'});
Y = [jobs(1,:,end); jobs(2,:,end)];
ylabel('Number of People')
bar(X,Y)
legend('No Requirements', 'Prerequisites')
%
%% 


%Line Plot of job distributions over time
plot(time,squeeze(jobs(1,1,:)))
hold on
for indexI = 2:1:jobcats
    plot(time, squeeze(jobs(1,indexI,:)))
end
hold off
xlabel('Time')
ylabel('Number of Jobs')
legend('Unskilled 1', 'Unskilled 2', 'Skilled', 'Ag1', 'Ag2', 'School')

%Bar Graph of seasonal migrants
X = categorical({'No Requirements', 'Prerequisites'});
X = reordercats(X, {'No Requirements', 'Prerequisites'});
Y = seasonalmigration;
bar(X,Y)
ylabel('Number of Quick Trips')


