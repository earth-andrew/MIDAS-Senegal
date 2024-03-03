function compileSimulations()
%Function that compiles key output from ensemble of simulations, for
%purposes of visualizing distributions of results

clear all;
close all;

%Load null output file
prefix = 'SenegalEnsemble_JobCalibration_SenegalRiverDroughtExperiment_';
fileList = dir([prefix '*.mat']);
climateOutputList = [];

%Loop through each run
for indexI = 1:length(fileList)
    currentRun = load(fileList(indexI).name);
    fprintf(['Run ' num2str(indexI) ' of ' num2str(length(fileList)) '.\n'])

    numAgents = size(currentRun.output.agentSummary.id,1);
    numSteps = size(currentRun.output.agentSummary.backCastProportion{1,1},1);

    backCastProportions = zeros(numAgents,numSteps);
    avgBackCastProportion = zeros(numSteps,1);
    
    %Calculating average backCastProportion across the population for each
    %time step
    for indexA = 1:numAgents
        backCastProportions(indexA,:) = currentRun.output.agentSummary.backCastProportion{indexA,1};
    end

    for indexT = 1:numSteps
        avgBackCastProportion(indexT) = mean(backCastProportions(:,indexT));
    end


    %Compile fields and values for all the key variables we want to track
    output = currentRun.output;   
    field1 = 'migrations'; value1 = currentRun.output.migrations;
    field2 = 'migrationMatrix'; value2 = currentRun.output.migrationMatrix;
    field3 = 'agentJobDistribution'; value3 = currentRun.output.countAgentsPerLayer;
    field4 = 'communityWealth'; value4 = currentRun.output.averageWealth;
    field5 = 'pBackcast'; value5 = avgBackCastProportion;
    field6 = 'TOD'; value6 = currentRun.output.agentSummary.TOD;
    

    %Put them into one struct for this run
    currentOutputValues = struct(field1, value1, field2, value2, field3, value3, field4, value4, field5, value5);
    
    %Add current run struct to running list
    climateOutputList = [climateOutputList; currentOutputValues];

end

save('SenegalRiverDroughtOutputs.mat', 'climateOutputList')

end