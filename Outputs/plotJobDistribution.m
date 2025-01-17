function plotJobDistribution()
%% Plot Average Job Distribution across Simulations


load SaltwaterIntrusion_12.06.2024.mat
output = outputList;

scenarios = output;
indexL = 4;
runs = size(scenarios,1);
steps = size(scenarios(1).migrations,1);
time = 1:steps;
numAgents = height(output(1,1).diplomas);
locations = size(scenarios(1).agentJobDistribution,1);
jobCats = size(scenarios(1).agentJobDistribution,2) - 3;
income_layers = 3;

uniqueJobCats = jobCats / (2 * income_layers);

%Specify slice of time series over which to average results
start_time = 60;
end_time = 80;

%Collapse matrix into 8 x 8 matrix of Admin 1 regions
placeLabels = {"Dakar", "Ziguinchor", "Diourbel", "Saint Louis, Louga, Matam", ...
    "Tambacounda, Kedougou", "Kaolack, Fatick, Kaffrine", "Thiès", "Kolda, Sedhiou", ...
    "Abroad", "NIU"};


regionNames = {"Dakar", "Ziguinchor", "Diourbel", "Saint Louis, Louga, Matam", ...
    "Tambacounda, Kedougou", "Kaolack, Fatick, Kaffrine", "Thiès", "Kolda, Sedhiou"};

collapseColumns = { ...
    [7 14 33 36], ...
    [3 32 45], ...
    [2 8 28], ...
    [6 17 19 24 25 27 34 35 37], ...
    [1 12 20 22 38 39 41], ...
    [4 9 10 11 15 16 18 23 26 31], ...
    [29 42 43], ...
    [5 13 21 30 40 44], ...
    };

avgJobDistribution = zeros(jobCats,1);
aggIncomeLayerJobDistribution = zeros(jobCats/income_layers,1);
avgRuralUrbanJobDistribution = zeros(uniqueJobCats,1);
jobDistributions = zeros(jobCats,steps);
stepJobDistributions = zeros(jobCats,steps,runs);

%Average across runs
for indexR = 1:runs
    for indexC = 1:jobCats
        for indexT = 1:steps
            stepJobDistributions(indexC,indexT,indexR) = sum(scenarios(indexR).agentJobDistribution(collapseColumns{indexL},indexC,indexT),1);
            %stepJobDistributions(indexC,indexT,indexR) = sum(scenarios(indexR).agentJobDistribution(:,indexC,indexT),1);
        end
    end
end

jobDistributions = mean(stepJobDistributions,3);

%Average across specified time slice
for indexC = 1:jobCats
    avgJobDistribution(indexC) = mean(jobDistributions(indexC,start_time:end_time));
end

%Aggregate across income layers, then average acrossrural-urban divide
for indexI = 1:(jobCats/income_layers)
  aggIncomeLayerJobDistribution(indexI) = sum(avgJobDistribution(((indexI-1) * income_layers + 1):(indexI-1) * income_layers + income_layers));  
end

for indexU = 1:uniqueJobCats
    avgRuralUrbanJobDistribution(indexU) =sum(avgJobDistribution(((indexU-1) * 2 + 1):((indexU-1) * 2 + 2)));
end

propJobDistribution = avgRuralUrbanJobDistribution / sum(avgRuralUrbanJobDistribution)

jobNames = categorical({'Ag-Aqua', 'Livestock', 'Professional', 'Services', 'Small Business', 'Trades'});
jobNames = reordercats(jobNames, {'Ag-Aqua', 'Livestock', 'Professional', 'Services', 'Small Business', 'Trades'});

bar(jobNames,propJobDistribution,1.0)
hold off
ax=gca;
ax.FontSize=16;
ylabel(['Proportion of Agents in ' regionNames{indexL}],'FontSize',16)
xlabel('Job Categories','FontSize',16)
end