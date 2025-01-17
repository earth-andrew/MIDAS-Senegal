function plotPortfolios()
%Function that plots proportion of agents engaging in different portfolio
%activities
clear all
load SaltwaterEd05_05.10.2024.mat
output = outputList;
%% 

runs = size(output,1);
jobCategories = size(output(1).agentJobDistribution,2);
numLocations = size(output(1).agentJobDistribution,1);
numSteps = size(output(1).agentJobDistribution,3);

jobDistribution = zeros(numLocations,jobCategories,runs);
avgJobs = zeros(numLocations,jobCategories);

start_time = 70;
end_time = 90;

for indexL = 1:numLocations
    for indexJ = 1:jobCategories
        for indexR = 1:runs
            jobDistribution(indexL,indexJ,indexR) = mean(output(indexR).agentJobDistribution(indexL, indexJ,start_time:end_time));
        end
        avgJobs(indexL, indexJ) = mean(jobDistribution(indexL, indexJ,:));
    end
end

collapseRows = {
    [7 14 33 36],
    [3 32 45],
    [2 8 28],
    [6 17 19 24 25 27 34 35 37],
    [1 12 20 22 38 39 41],
    [4 9 10 11 15 16 18 23 26 31],
    [29 42 43],
    [5 13 21 30 40 44]};

regionNames = {'Dakar', 'Ziguinchor', 'Diourbel', 'Saint Louis, Louga, Matam', 'Tambacounda, Kedougou', 'Kaolack, Fatick, Kaffrine', 'Thies', 'Kolda, Sedhiou'};

livelihoodNames = {'Agriculture/Aquaculture', 'Livestock', 'Professional', 'Services', 'Small Business', 'Trades', 'Education'};

tempMat = avgJobs;

regionalJobs = [sum(tempMat(collapseRows{1},:),1);
                sum(tempMat(collapseRows{2},:),1);
                sum(tempMat(collapseRows{3},:),1);
                sum(tempMat(collapseRows{4},:),1);
                sum(tempMat(collapseRows{5},:),1);
                sum(tempMat(collapseRows{6},:),1);
                sum(tempMat(collapseRows{7},:),1);
                sum(tempMat(collapseRows{8},:),1);
                ];

uniqueJobs = round(jobCategories / 2);
ruralUrbanJobs = zeros(size(regionalJobs,1),uniqueJobs);
for indexU = 1:uniqueJobs
    start_index = (indexU - 1) * 2 + 1;
    ruralUrbanJobs(:,indexU) = sum(regionalJobs(:, start_index:start_index+1),2);
end


normRegionalJobs = ruralUrbanJobs ./ sum(ruralUrbanJobs,2);

jobTable = array2table(normRegionalJobs,'RowNames', regionNames, 'VariableNames',livelihoodNames)
%writetable(jobTable,'BaseCaseLivelihoods.csv')

end