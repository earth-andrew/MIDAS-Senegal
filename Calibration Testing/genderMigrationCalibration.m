    function genderMigrationCalibration()
%Function that calibrates MIDAS runs based on education data

clear all;
close all;
load migData_census2013.mat;

quantileMarker = 0.01;

%Model Result Parameters
income_levels = 3; %number of income levels per job category
agent_categories = 2; %Number of agent categories per job (e.g. male and female)
job_levels = income_levels * agent_categories;
averaging_period = 20;

%Education Data
migrationData = readtable('../Data/SEN_migr_gender.csv');
migrationTable = migrationData(:,{'gender','migr13_5y'}); %For useful columns

groupedMigration = groupsummary(migrationTable,'gender','sum','migr13_5y');

% Extract the sum for 'female' (assuming 'female' is one of the group values)
femaleSum = groupedMigration.sum_migr13_5y(strcmp(groupedMigration.gender, 'female'));

femaleProp = femaleSum / sum(groupedMigration.sum_migr13_5y);
%Read in simulated data and extract education rates
higherEdLayers = [37 38]; %Income Layers representing higher education (male, female)

try
    load evaluationOutputs2
    disp (evaluationOutputs)
catch
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
            
            fprintf(['Run ' num2str(indexI) ' of ' num2str(length(fileList)) '.\n'])
                   
            %New code for 5-year migration flows
            numAgents = height(currentRun.output.agentSummary);
            numLocations = size(currentRun.output.migrationMatrix,1);
            numSteps = size(currentRun.output.countAgentsPerLayer,3);
            tempMat = zeros(numLocations,numLocations);
            
            maleMigration = 0;
            femaleMigration = 0;
            
          
            for indexA = 1:numAgents
                moveMatrix = currentRun.output.agentSummary.moveHistory{indexA,1};
                currentLocation = moveMatrix(end,2);
                %Store the last destination of 
                previousID = find(moveMatrix(:,1) < (numSteps - averaging_period),1,'last');
                previousLocation = moveMatrix(previousID,2);
                
                if previousLocation ~= currentLocation
                    gender = currentRun.output.agentSummary.layerFlag{indexA};
                    if gender == 1
                        maleMigration = maleMigration + 1;
                    else
                        femaleMigration = femaleMigration + 1;
                    end
                end
            end
            
            modelFemaleProp = femaleMigration / (maleMigration + femaleMigration);
                     
            GenderError = ((modelFemaleProp - femaleProp) / femaleProp).^2;
            
            %runLevel
            currentInputRun = array2table([currentRun.input.parameterValues]','VariableNames',currentRun.input.parameterNames');

            %currentInputRun = array2table([currentRun.input.parameterValues]','VariableNames',strrep({currentRun.input.parameterNames},'.',''))

            currentOutputRun = table(GenderError, ...
                'VariableNames',{'GenderError'});
            inputListRun = [inputListRun; currentInputRun];
            outputListRun = [outputListRun; currentOutputRun];
            %inputListRun(indexI,:) = currentInputRun
            %outputListRun(indexI,:) = currentOutputRun
        
        catch
            skip(indexI) = true;
        end
        
    end
    
    skip = skip(1:height(inputListRun));
    inputListRun(skip,:) = [];
    outputListRun(skip,:) = [];
    fileList(skip) = [];
    
end


save evaluationOutputs inputListRun outputListRun fileList

minR2 = quantile(outputListRun.GenderError,[1 - quantileMarker]);
bestInputs = inputListRun(outputListRun.GenderError >= minR2,:);


%Sort runs by R2 metric and saves sorted inputs and outputs
[sortedOutput, sortedIndex] = sortrows(outputListRun, 'GenderError', 'ascend');
r2_metric = sortedOutput(:,'GenderError');
sortedInput = inputListRun(sortedIndex, :);
genderCalibrationTable = [table(sortedIndex, 'VariableNames', {'sortedIndex'}), r2_metric, sortedInput];
save genderCalibration_01.07.2025.mat genderCalibrationTable;

expList = dir('experiment_SenegalEnsemble_CalibrationTest_01.13.2025_input_summary_*.mat');
load(expList(1).name);


for indexI = 1:height(mcParams)
    %tempIndex = strmatch(strrep(mcParams.Name{indexI},'.',''),inputListRun.Properties.VariableNames)
    tempIndex = strcmp(mcParams.Name{indexI},inputListRun.Properties.VariableNames);
    mcParams.Lower(indexI) = min(table2array(bestInputs(:,tempIndex)));
    mcParams.Upper(indexI) = max(table2array(bestInputs(:,tempIndex)));
end

save updatedMCParams mcParams;


end

function rho_2 = weightedPearson(X, Y, w)

mX = sum(X .* w) / sum(w);
mY = sum(Y .* w) / sum(w);

covXY = sum (w .* (X - mX) .* (Y - mY)) / sum(w);
covXX = sum (w .* (X - mX) .* (X - mX)) / sum(w);
covYY = sum (w .* (Y - mY) .* (Y - mY)) / sum(w);

rho_w  = covXY / sqrt(covXX * covYY);
rho_2 = rho_w * rho_w;

end

function plotMigrations(matrix, r2, metricTitle)

load midasLocations;

figure;
imagesc(matrix);
set(gca,'YTick',1:64, 'XTick',1:64, 'YTickLabel',midasLocations.source_ADMIN_NAME, 'XTickLabel',midasLocations.source_ADMIN_NAME);
xtickangle(90);
colorbar;
title([metricTitle ' - Interdistrict moves (n = ' num2str(sum(sum(matrix))) '; Weighted r^2 = ' num2str(r2) ')']);
grid on;
colormap hot;
set(gca,'GridColor','white','FontSize',12);
temp = ylabel('ORIGIN','FontSize',16,'Position',[-5 30]);
xlabel('DESTINATION','FontSize',16);
%set(temp,'Position', [-.1 .5 0]);
set(gcf,'Position',[100 100 600 500]);
savefig('MigrationCalibration.png')
end