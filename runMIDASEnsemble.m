function runMIDASEnsemble()

clear functions
clear classes

cd /home/cloud-user/MIDAS-Senegal
%addpath('Application_Specific_MIDAS_Code/');
%addpath('Core_MIDAS_Code/');
%addpath('Calibration Testing/');
%addpath('./Override_Core_MIDAS_Code/');

rng('shuffle');


outputList = {};
series = 'SenegalEnsemble_NoAspirations_01.14.2025';
saveDirectory = 'Outputs/';

%number of runs
numExperiments = 25;
startingIndex = 1;
endIndex = startingIndex + numExperiments - 1;
runsPerExperiment = 1;
try load multiObjectiveCalibrationParameters_01.14.2025.mat
    % Get the parameter names (i.e., the column names)
    parameterNames = topParameters.Properties.VariableNames;

    % Extract all the values from the table (excluding the first row)
    values = topParameters{1:end,:}';  % Skip the first row since it seems to be headers or meta-data
    
    % Add a column with 'Parameter' as the label and each row corresponding to the parameter name
    mcParams = table(parameterNames', values, 'VariableNames', {'Name','Values'});
    
    %Add in Scenario Parameters in format 'VariableName', value
    mcParams = [mcParams; {'modelParameters.climateFlag',0}];
    mcParams = [mcParams; {'modelParameters.aspirationsFlag',0}];
    mcParams = [mcParams; {'modelParameters.medianValuesYN',1}];
    mcParams = [mcParams; {'modelParameters.agClimateEffect', 0.45}]; %Proportional income loss due to climate impact (0.45 drought; 0.9 saltwater)
    mcParams = [mcParams; {'modelParameters.nonAgClimateEffect', 0.138}]; %Proportional income loss due to climate impact in nonAg sectors (0.138 drought, 0.276 for saltwater)
    mcParams = [mcParams; {'modelParameters.climateStart', 30}]; %Time step at which climate effects start (30 for drought; 1 for saltwater)
    mcParams = [mcParams; {'modelParameters.climateLength', 20}]; %Duration of climate impact in timesteps
    mcParams = [mcParams; {'modelParameters.climateScenarioIndex', 1}]; %Specifies affected regions: 1 for Senegal River Drought, 2 for Saltwater Intrusion, 3 for Groundnut Basin
    mcParams = [mcParams; {'modelParameters.edExpansionFlag', 0}]; %1 to specify education expansion
    
    
catch
    test = 'Range Sequence'
    %define the levels and parameters you will explore, as below
    mcParams = table([],[],[],[],'VariableNames',{'Name','Lower','Upper','RoundYN'});
    
    %Scenario Settings
    mcParams = [mcParams; {'modelParameters.randomUtilitiesYN',0,0,1}];
    mcParams = [mcParams; {'modelParameters.climateFlag',0,0,1}];
    mcParams = [mcParams; {'modelParameters.aspirationsFlag',1,1,1}];
    mcParams = [mcParams; {'modelParameters.medianValuesYN',1,1,1}];
    mcParams = [mcParams; {'modelParameters.agClimateEffect', 0.9,0.9,0}]; %Proportional income loss due to climate impact (0.45 drought; 0.9 saltwater)
    mcParams = [mcParams; {'modelParameters.nonAgClimateEffect', 0.276, 0.276,0}]; %Proportional income loss due to climate impact in nonAg sectors (0.138 drought, 0.276 for saltwater)
    mcParams = [mcParams; {'modelParameters.climateStart', 1,1,1}]; %Time step at which climate effects start (30 for drought; 1 for saltwater)
    mcParams = [mcParams; {'modelParameters.climateLength', 80,80,1}]; %Duration of climate impact in timesteps
    mcParams = [mcParams; {'modelParameters.climateScenarioIndex', 2,2,1}]; %Specifies affected regions: 1 for Senegal River Drought, 2 for Saltwater Intrusion
    mcParams = [mcParams; {'modelParameters.edExpansionFlag', 0, 0, 1}]; %1 to specify education expansion
    
    
    %Parameter Settings
    mcParams = [mcParams; {'modelParameters.utility_k',1,10,0}];
    mcParams = [mcParams; {'modelParameters.utility_m',1,10,0}];
    mcParams = [mcParams; {'modelParameters.movingCostPerMile',0,5000,0}];
    mcParams = [mcParams; {'modelParameters.educationSlots4yr',0,500,1}];
    mcParams = [mcParams; {'modelParameters.educationSlotsVocational',0,2000,1}];
    mcParams = [mcParams; {'modelParameters.creditMultiplier',0,0.5,0}];
    mcParams = [mcParams; {'modelParameters.utility_iReturn',0,0.5,0}];
    mcParams = [mcParams; {'agentParameters.discountRateMean',0,0.5,0}];
    mcParams = [mcParams; {'agentParameters.incomeShareFractionMean',0,0.8,0}];
    mcParams = [mcParams; {'agentParameters.bestLocationMean',1,5,1}];
    mcParams = [mcParams; {'agentParameters.bestPortfolioMean',1,5,1}];
    mcParams = [mcParams; {'agentParameters.randomLocationMean',1,5,1}];
    mcParams = [mcParams; {'agentParameters.randomPortfolioMean',1,5,1}];
    mcParams = [mcParams; {'agentParameters.numPeriodsEvaluateMean',4,50,1}];
    mcParams = [mcParams; {'agentParameters.numPeriodsMemoryMean',4,50,1}];
    mcParams = [mcParams; {'agentParameters.prospectLossMean',1,4,0}];
    mcParams = [mcParams; {'networkParameters.connectionsMean',1,20,1}];
    
end


%make the full design

fprintf(['Building Experiment List.\n']);
for indexI = startingIndex:endIndex
	       
    experiment = table([],[],'VariableNames',{'parameterNames','parameterValues'});
    
    %If parameters are specified as a range, calculate a value. Else
        %pick one of the top paramater values
    if ismember('Lower', mcParams.Properties.VariableNames)
        for indexJ = 1:(height(mcParams))
            tempName = mcParams.Name{indexJ};
            tempMin = mcParams.Lower(indexJ);
            tempMax = mcParams.Upper(indexJ);
            tempValue = tempMin + (tempMax-tempMin) * rand();
            %tempValue = tempMin + (tempMax - tempMin) / numExperiments * indexI;
            if(mcParams.RoundYN(indexJ))
                tempValue = round(tempValue);
            end
            
            for indexK = 1:runsPerExperiment
                experiment = [experiment; {tempName, tempValue}];
            end
        end
        
    else
       
        %In case you have multiple sets of parameters to choose from
        numRuns = size(mcParams.Values,2);
        runIndex = randi([1,numRuns]);

        
        for indexJ = 1:(height(mcParams))
            tempName = mcParams.Name{indexJ};
            tempValue = mcParams.Values(indexJ, runIndex);

            for indexK = 1:runsPerExperiment
                experiment = [experiment; {tempName, tempValue}];
            end
        end
    end
    experimentList{indexI} = experiment;
    
end


fprintf(['Saving Experiment List.\n']);
save([saveDirectory 'experiment_' series '_input_summary_' num2str(startingIndex) '_' num2str(endIndex) '.mat'], 'experimentList', 'mcParams');

runList = zeros(length(experimentList),1);

%run the model as a batch job
%Setting up cluster
%clust = parcluster()
%job = createJob(clust)

parfor indexI = startingIndex:endIndex
    if(runList(indexI) == 0)
        input = experimentList{indexI};
        %this next line runs MIDAS as a batch job using the current experimental
        %parameters (comment out if running as a parallel job)
        %task = createTask(job,@midasMainLoop, 0, {input, ['Experiment ' num2str(indexI)]}, 'CaptureDiary', true);
        %Comment out the following line if running a batch job
        output = midasMainLoop(input, ['Experiment ' num2str(indexI)]);
            
        functionVersions = inmem('-completenames');
        functionVersions = functionVersions(strmatch(pwd,functionVersions));
        output.codeUsed = functionVersions;
        labelNumber = indexI;
        currentFile = [series 'Experiment_' num2str(indexI) '.mat'];
        currentFile = [saveDirectory currentFile];
        
        %make the filename compatible across Mac/PC
        currentFile = strrep(currentFile,':','-');
        currentFile = strrep(currentFile,' ','_');

        saveToFile(input, output, currentFile);
        %runList(indexI) = 1;
    end
	
end


fprintf(['Saving Experiment List.\n']);
save([saveDirectory 'experiment_' series '_input_summary_' num2str(startingIndex) '_' num2str(endIndex)], 'experimentList', 'mcParams');

end
function saveToFile(input, output, filename);
    save(filename,'input', 'output');
end
