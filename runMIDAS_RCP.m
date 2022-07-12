function runMIDASExperiment()

clear functions
clear classes

addpath('./Override_Core_MIDAS_Code');
addpath('./Application_Specific_MIDAS_Code');
addpath('./Core_MIDAS_Code');

rng('shuffle');

outputList = {};

series = 'RCP_Run_';
saveDirectory = './Outputs/';

%number of runs
modelRuns = 8;

load bestCalibrations;

%%we are going to add an additional experimental variable that was not part
%%of calibration, related to the flood that is now part of the projections
minFloodMult = 0;
maxFloodMult = 1.5;

fprintf(['Building Experiment List.\n']);
for indexI = 1:modelRuns   
    temp = bestInputCell{randperm(length(bestInputCell),1)};
    temp.parameterNames{end+1} = 'modelParameters.normalFloodMultiplier';
    temp.parameterValues(end) = minFloodMult + (maxFloodMult-minFloodMult).*rand();
    experimentList{indexI} = temp;
end

fprintf(['Saving Experiment List.\n']);
save([saveDirectory 'experiment_' date '_input_summary'], 'experimentList');

runList = zeros(length(experimentList),1);
%run the model
parfor indexI = 1:length(experimentList)
%for indexI = 1:length(experimentList)
    if(runList(indexI) == 0)
        input = experimentList{indexI};
        
        %this next line runs MIDAS using the current experimental
        %parameters
        output = midasMainLoop(input, ['Experiment Run ' num2str(indexI)]);
        
        
        functionVersions = inmem('-completenames');
        functionVersions = functionVersions(strmatch(pwd,functionVersions));
        output.codeUsed = functionVersions;
        currentFile = [series num2str(length(dir([series '*']))) '_' datestr(now) '.mat'];
        currentFile = [saveDirectory currentFile];
        
        %make the filename compatible across Mac/PC
        currentFile = strrep(currentFile,':','-');
        currentFile = strrep(currentFile,' ','_');

        saveToFile(input, output, currentFile);
        runList(indexI) = 1;
    end
end

end

function saveToFile(input, output, filename);
    save(filename,'input', 'output');
end
