function weightedParameterAverage()
%Function that takes top-performing simulations from build next round and
%computes weighted averages for each parameter, based on R^2 values of each
%simulation

load evaluationOutputs.mat
calibrationInputs = inputListRun;
calibrationOutputs = outputListRun;

numRuns = height(calibrationOutputs);
quantileMarker = 0.2; %i.e. keep top X proportion of simulations for weighted Avg
cutoffRuns = round(quantileMarker * numRuns); %Number of top runs to keep

%Set output metric against which to sort runs
metric = calibrationOutputs.popWeightJobsError_r2;
[sortedRuns, indexRuns] = sort(metric, 'descend');

%Only keep top (quantileMarker) proportion of runs
topRuns = indexRuns(1:round(cutoffRuns));

%Loop across each input parameter and take average of values for
%top runs, weighted by r^2 value
numParameters = size(calibrationInputs,2);
parameterNames = calibrationInputs.Properties.VariableNames;

firstTopParameter = table2array(calibrationInputs(topRuns,1));
firstWeightedAvg = sum(firstTopParameter .* metric(topRuns)) / sum(metric(topRuns));
weightedAvgParameters = table(firstWeightedAvg, 'VariableNames', string(parameterNames{1}));

for indexP = 2:numParameters
    parameterName = parameterNames{indexP};
    topParameters = table2array(calibrationInputs(topRuns,indexP));
    weightedAvg = sum(topParameters .* metric(topRuns)) / sum(metric(topRuns));
    weightedAvgParameters.(parameterName) = weightedAvg;
end

save baseCaseParameters weightedAvgParameters

end