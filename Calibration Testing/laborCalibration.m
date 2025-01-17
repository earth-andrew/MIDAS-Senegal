function laborCalibration()
clear all;
close all;

%Specify Population Weights
load migData_census2013.mat;
popWeights = popData';
popSum = sum(sum(popWeights));

quantileMarker = 0.1;

%Model Result Parameters
income_levels = 3; %number of income levels per job category
agent_categories = 2; %Number of agent categories per job (e.g. male and female)
job_levels = income_levels * agent_categories;

laborData = readtable('../Data/occupation_epred_sum.csv');
medianValues = laborData(:,{'sector', 'urban', 'admin1', 'pred_mean'}); %For median values
ruralUrbanTable = unstack(medianValues,'pred_mean','urban'); %For median values
%For now, take the mean of rural and urban proportions until we can get a
%pop-weighted average
ruralUrbanTable.Mean = mean([ruralUrbanTable.rural, ruralUrbanTable.urban], 2);
ruralUrbanTable.rural = [];
ruralUrbanTable.urban = [];
sectorTable = unstack(ruralUrbanTable, 'Mean', 'sector');
sectorTable = sortrows(sectorTable,'admin1','ascend');


%Combine regions lumped together
regionNames = {"Dakar", "Ziguinchor", "Diourbel", "Saint Louis, Louga, Matam", ...
    "Tambacounda, Kedougou", "Kaolack, Fatick, Kaffrine", "Thiès", "Kolda, Sedhiou"};

%Translating rows from epred sheet into order of regionNames
collapseRows = {
    1,
    14,
    2,
    [8 9 10],
    [6 12],
    [3 4 5],
    13,
    [7 11],
    };

%Note: Figure out weights by Admin 1 region for weighted mean
regionData = [mean(sectorTable{collapseRows{1},2:end},1); ...
                mean(sectorTable{collapseRows{2},2:end},1); ...
                mean(sectorTable{collapseRows{3},2:end},1); ...
                mean(sectorTable{collapseRows{4},2:end},1); ...
                mean(sectorTable{collapseRows{5},2:end},1); ...
                mean(sectorTable{collapseRows{6},2:end},1); ...
                mean(sectorTable{collapseRows{7},2:end},1); ...
                mean(sectorTable{collapseRows{8},2:end},1); ...
                ];



admin1Units = size(regionNames,2);


%Loading Model Runs
fileList = dir('SenegalEnsemble_Calibration_01.07.2025Experiment_*.mat');
    
inputListRun = [];
outputListRun = [];
skip = false(length(fileList),1);

for indexI = 1:length(fileList)
    try
        currentRun = load(fileList(indexI).name);
    
        if ismember('mapParameters.movingCostPerMile', currentRun.input.parameterNames)
            colIndex = find(strcmp(currentRun.input.parameterNames, 'mapParameters.movingCostPerMile'));
            currentRun.input.parameterNames{colIndex} = 'modelParameters.movingCostPerMile';
        end    
    
        simulatedResults = currentRun.output; 
        fprintf(['Run ' num2str(indexI) ' of ' num2str(length(fileList)) '.\n'])


    %Obtaining breakdown of agent distribution by admin 2 unit and job category
    jobcats = size(simulatedResults.countAgentsPerLayer,2);

    uniqueJobCats = round(jobcats / job_levels); %Every two job indices (e.g. 1 and 2) are the same type of work, but one is
    %rural and urban.

    admin2Units = height(simulatedResults.countAgentsPerLayer);
    jobs = zeros(admin2Units, uniqueJobCats);

    localPopulation = zeros(admin2Units,1);

    for indexL = 1:1:admin2Units
        localPopulation(indexL) = sum(simulatedResults.countAgentsPerLayer(indexL,:,end));
    
        for indexJ = 1:1:uniqueJobCats
            start_index = indexJ * (job_levels-1) + 1;
            end_index = indexJ * (job_levels);
        
            if end_index > jobcats
                end_index = jobcats;
            end
        
            jobs(indexL, indexJ) = sum(simulatedResults.countAgentsPerLayer(indexL, start_index:end_index, end));
        end
    end

    %Now combine totals for admin2Units that share an admin1unit
    collapseRows = { ...
        [7 14 33 36], ...
        [3 32 45], ...
        [2 8 28], ...
        [6 17 19 24 25 27 34 35 37], ...
        [1 12 20 22 38 39 41], ...
        [4 9 10 11 15 16 18 23 26 31], ...
        [29 42 43], ...
        [5 13 21 30 40 44], ...
        };

    regionJobs = [sum(jobs(collapseRows{1},:)); ...
                    sum(jobs(collapseRows{2},:)); ...
                    sum(jobs(collapseRows{3},:)); ...
                    sum(jobs(collapseRows{4},:)); ...
                    sum(jobs(collapseRows{5},:)); ...
                    sum(jobs(collapseRows{6},:)); ...
                    sum(jobs(collapseRows{7},:)); ...
                    sum(jobs(collapseRows{8},:)); ...
                    ];


    %Simulated Job Categories are:
    %Column 1: Ag-Aqua
    %Column 2: Livestock
    %Column 3: Professional
    %Column 4: Services
    %Column 5: Small Business
    %Column 6: Trades
    %Column 7: Education

    %Only keep job categories for which we have data (i.e. non-education)
    restrictedJobs = regionJobs(:,1:end-1);

    %Now normalize totals based on sub-population included in these restricted
    %categories
    simulatedProportion = diag(1./sum(restrictedJobs,2)) * restrictedJobs;

    %Now evaluate differences between simulated and data job distributions
    jobsError = sum(sum((simulatedProportion - regionData).^2));
    popWeightJobsError = sum(sum(((simulatedProportion - regionData).^2).*popWeights))/popSum;
    jobsError_r2 = weightedPearson(simulatedProportion(:), regionData(:), ones(numel(simulatedProportion),1));

    adjustedPopWeights = repmat(popWeights, size(simulatedProportion,2),1);
    popWeightJobsError_r2 = weightedPearson(simulatedProportion(:), regionData(:), adjustedPopWeights);


    %runLevel
    currentInputRun = array2table([currentRun.input.parameterValues]','VariableNames',currentRun.input.parameterNames');

    currentOutputRun = table(jobsError,popWeightJobsError, jobsError_r2, popWeightJobsError_r2, ...
                'VariableNames',{'jobsError', 'popWeightJobsError', 'jobsError_r2', 'popWeightJobsError_r2'});
                inputListRun = [inputListRun; currentInputRun];
                outputListRun = [outputListRun; currentOutputRun];
           
    catch
            skip(indexI) = true;
    end

end

save evaluationOutputs inputListRun outputListRun fileList

%Select top performing simulations based on popWeightJobsError
minR2 = quantile(outputListRun.popWeightJobsError_r2,[1 - quantileMarker]);
bestInputs = inputListRun(outputListRun.popWeightJobsError_r2 >= minR2,:);

%Sort runs by R2 metric and saves sorted inputs and outputs
[sortedOutput, sortedIndex] = sortrows(outputListRun, 'popWeightJobsError_r2', 'descend');
r2_metric = sortedOutput(:,'popWeightJobsError_r2');
sortedInput = inputListRun(sortedIndex, :);
jobsCalibrationTable = [table(sortedIndex, 'VariableNames', {'sortedIndex'}), r2_metric, sortedInput];
save jobsCalibration_01.07.2025.mat jobsCalibrationTable;

expList = dir('experiment_SenegalEnsemble_CalibrationTest_01.13.2025_input_summary_*.mat');
load(expList(1).name);


for indexI = 1:height(mcParams)
    %tempIndex = strmatch(strrep(mcParams.Name{indexI},'.',''),inputListRun.Properties.VariableNames)
    tempIndex = strcmp(mcParams.Name{indexI},inputListRun.Properties.VariableNames);
    mcParams.Lower(indexI) = min(table2array(bestInputs(:,tempIndex)));
    mcParams.Upper(indexI) = max(table2array(bestInputs(:,tempIndex)));
end

save updatedMCParams_Jobs01.07.2025 mcParams;
end

function rho_2 = weightedPearson(X, Y, w)

mX = sum(X .* w) / sum(w);
mY = sum(Y .* w) / sum(w);

covXY = sum (w .* (X - mX) .* (Y - mY)) / sum(w);
covXX = sum (w .* (X - mX) .* (X - mX)) / sum(w);
covYY = sum (w .* (Y - mY) .* (Y - mY)) / sum(w);

rho_w  = covXY / sqrt(covXX * covYY');
rho_2 = rho_w * rho_w';

end