function dakarMigrationCalibration()

clear all;
close all;
load migData_census2013.mat;


quantileMarker = 0.1;
migrationData = mig_5_region_overall(1:end-1,:);
averaging_period = 19; %Number of time steps over which to average simulated migration flows (minus 1)

sourcePopWeights = popData' * ones(1, 8);
destPopWeights = sourcePopWeights';
jointPopWeights = sourcePopWeights .* destPopWeights;

sourcePopSum = sum(sum(sourcePopWeights));
destPopSum = sum(sum(destPopWeights));
jointPopSum = sum(sum(jointPopWeights));

%one simple metric is the relative # of migrations per source-destination
%pair
fracMigsData = migrationData / sum(sum(migrationData));

%another is the migs per total population
migRateData = migrationData / sum(popData);
migRateData = migrationData
overallMigRate = sum(migRateData,'all'); %Overall fraction of migrants
test1 = sum(popData)
test2 = migrationData

%and another is the in/out ratio
inOutData = sum(migrationData) ./ (sum(migrationData'))';

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

try
    load evaluationOutputs2
    disp (evaluationOutputs)
catch
    fileList = dir('SenegalEnsemble_CalibrationExperiment_20*.mat');
    
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
            
            tempMat = currentRun.output.migrationMatrix;
            tempMat = [sum(tempMat(:,collapseColumns{1},end-averaging_period:end),2) ...
                sum(tempMat(:,collapseColumns{2},end-averaging_period:end),2) ...
                sum(tempMat(:,collapseColumns{3},end-averaging_period:end),2) ...
                sum(tempMat(:,collapseColumns{4},end-averaging_period:end),2) ...
                sum(tempMat(:,collapseColumns{5},end-averaging_period:end),2) ...
                sum(tempMat(:,collapseColumns{6},end-averaging_period:end),2) ...
                sum(tempMat(:,collapseColumns{7},end-averaging_period:end),2) ...
                sum(tempMat(:,collapseColumns{8},end-averaging_period:end),2) ...
                ];
            
            tempMat = sum(tempMat,3);
             
            tempMat = [sum(tempMat(collapseColumns{1},:)); ...
                sum(tempMat(collapseColumns{2},:)); ...
                sum(tempMat(collapseColumns{3},:)); ...
                sum(tempMat(collapseColumns{4},:)); ...
                sum(tempMat(collapseColumns{5},:)); ...
                sum(tempMat(collapseColumns{6},:)); ...
                sum(tempMat(collapseColumns{7},:)); ...
                sum(tempMat(collapseColumns{8},:)) ...
                ];
          

            fracMigsRun = tempMat / sum(sum(tempMat));
            test = sum(sum(tempMat))
            migRateRun = tempMat / size(currentRun.output.agentSummary,1);  %(this data is 11 years)
            overallMigRateRun = sum(migRateRun,'all')
            test2 = size(currentRun.output.agentSummary,1)
            inOutRun = sum(tempMat) ./ (sum(tempMat'))';
            
            fracMigsError = sum(sum((fracMigsRun - fracMigsData).^2));
            sourceWeightFracMigsError = sum(sum(((fracMigsRun - fracMigsData).^2).*sourcePopWeights))/sourcePopSum;
            destWeightFracMigsError = sum(sum(((fracMigsRun - fracMigsData).^2).*destPopWeights))/destPopSum;
            jointWeightFracMigsError = sum(sum(((fracMigsRun - fracMigsData).^2).*jointPopWeights))/jointPopSum;
            
            migRateError = sum(sum((migRateRun - migRateData).^2));
            sourceWeightMigRateError = sum(sum(((migRateRun - migRateData).^2).*sourcePopWeights))/sourcePopSum;
            destWeightMigRateError = sum(sum(((migRateRun - migRateData).^2).*destPopWeights))/destPopSum;
            jointWeightMigRateError = sum(sum(((migRateRun - migRateData).^2).*jointPopWeights))/jointPopSum;
            
            fracMigs_r2 = weightedPearson(fracMigsRun(:), fracMigsData(:), ones(numel(fracMigsRun),1));
            sourceFracMigs_r2 = weightedPearson(fracMigsRun(:), fracMigsData(:), sourcePopWeights(:));
            destFracMigs_r2 = weightedPearson(fracMigsRun(:), fracMigsData(:), destPopWeights(:));
            jointFracMigs_r2 = weightedPearson(fracMigsRun(:), fracMigsData(:), jointPopWeights(:));
            
            migRate_r2 = weightedPearson(migRateRun(:), migRateData(:), ones(numel(migRateRun),1));
            sourceMigRate_r2 = weightedPearson(migRateRun(:), migRateData(:), sourcePopWeights(:));
            destMigRate_r2 = weightedPearson(migRateRun(:), migRateData(:), destPopWeights(:));
            jointMigRate_r2 = weightedPearson(migRateRun(:), migRateData(:), jointPopWeights(:));
            
            inOutError = sum(sum((inOutRun - inOutData).^2));
            popWeightInOutError = sum(sum(((inOutRun - inOutData).^2).*sourcePopWeights))/sourcePopSum;
            inOutError_r2 = weightedPearson(inOutRun(:), inOutData(:), ones(numel(inOutRun),1));
            popInOut_r2 = weightedPearson(inOutRun(:), inOutData(:), sourcePopWeights(:));
            
            %runLevel
            currentInputRun = array2table([currentRun.input.parameterValues]','VariableNames',currentRun.input.parameterNames');
            %currentInputRun = array2table([currentRun.input.parameterValues]','VariableNames',strrep({currentRun.input.parameterNames},'.',''))

            currentOutputRun = table(fracMigsError,sourceWeightFracMigsError, destWeightFracMigsError, jointWeightFracMigsError, ...
                migRateError,sourceWeightMigRateError, destWeightMigRateError, jointWeightMigRateError, ...
                fracMigs_r2, sourceFracMigs_r2, destFracMigs_r2, jointFracMigs_r2, ...
                migRate_r2, sourceMigRate_r2, destMigRate_r2, jointMigRate_r2, ...
                inOutError, popWeightInOutError, inOutError_r2, popInOut_r2, ...
                'VariableNames',{'FracMigsError', 'SourceWeightFracMigsError','DestWeightFracMigsError','JointWeightFracMigsError', ...
                'MigRateError', 'SourceWeightMigRateError','DestWeightMigRateError','JointWeightMigRateError', ...
                'fracMigs_r2', 'sourceFracMigs_r2', 'destFracMigs_r2', 'jointFracMigs_r2', ...
                'migRate_r2', 'sourceMigRate_r2', 'destMigRate_r2', 'jointMigRate_r2', ...
                'inOutError','popWeightInOutError','inOutError_r2','popInOut_r2'});
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

minR2 = quantile(outputListRun.jointFracMigs_r2,[1 - quantileMarker]);
bestInputs = inputListRun(outputListRun.jointFracMigs_r2 >= minR2,:);

%Sort runs by R2 metric and saves sorted inputs and outputs
[sortedOutput, sortedIndex] = sortrows(outputListRun, 'jointFracMigs_r2', 'descend');
r2_metric = sortedOutput(:,{'jointFracMigs_r2','jointMigRate_r2'});
sortedInput = inputListRun(sortedIndex, :);
migCalibrationTable = [table(sortedIndex, 'VariableNames', {'sortedIndex'}), r2_metric, sortedInput];
save migrationCalibration migCalibrationTable;

expList = dir('experiment_SenegalEnsemble_Calibration*');
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