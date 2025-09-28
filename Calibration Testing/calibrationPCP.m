function calibrationPCP()
%Function that creates a parallel coordinate plot of multiple calibrated
%metrics

load('migrationCalibration_07.10.2025.mat')
calibrationTable = migCalibrationTable;
migMetrics = migCalibrationTable(:,{'sortedIndex', 'jointFracRMSE', 'overallMigRateError', 'DakarPropError','DakarInOutError'});

load('jobsCalibration_07.10.2025.mat')
jobMetrics = jobsCalibrationTable(:,{'sortedIndex', 'popWeightJobsRMSE'});

load('educationCalibration_07.10.2025.mat')
edMetrics = educationCalibrationTable(:,{'sortedIndex', 'FracDiplomasError'});

load('genderCalibration_02.08.2025.mat')
genderMetrics = genderCalibrationTable(:,{'sortedIndex', 'GenderError'});

percentile = 70;

normalization = 1; %1 to normalize error, 0 to leave raw RMSE

%Merge tables
mergedTable = join(migMetrics, jobMetrics);
pcpTable = join(mergedTable,edMetrics);
pcpTable = join(pcpTable,genderMetrics);
pcpTable.FracDiplomasError = 1 - pcpTable.FracDiplomasError;
rawPcpTable = pcpTable;

%Subtracting RMSE from 1 so that higher numbers are better
pcpTable.jointFracRMSE = 1 - pcpTable.jointFracRMSE;
pcpTable.popWeightJobsRMSE = 1 - pcpTable.popWeightJobsRMSE;
pcpTable.overallMigRateError = 1 - pcpTable.overallMigRateError;
pcpTable.DakarPropError = 1 - pcpTable.DakarPropError;
pcpTable.DakarInOutError = 1 - pcpTable.DakarInOutError;
pcpTable.GenderError = 1 - pcpTable.GenderError;
pcpTable.FracDiplomasError = 1 - pcpTable.FracDiplomasError;

%Normalize Indices to Max value in each for ease of visualization
pcpTable.jointFracRMSE = normalizeIndex(pcpTable.jointFracRMSE);
pcpTable.overallMigRateError = normalizeIndex(pcpTable.overallMigRateError);
pcpTable.DakarPropError = normalizeIndex(pcpTable.DakarPropError);
pcpTable.DakarInOutError = normalizeIndex(pcpTable.DakarInOutError);
pcpTable.popWeightJobsRMSE = normalizeIndex(pcpTable.popWeightJobsRMSE);
pcpTable.FracDiplomasError = normalizeIndex(pcpTable.FracDiplomasError);
pcpTable.GenderError = normalizeIndex(pcpTable.GenderError);
pcpTable.SimpleAverage = mean(pcpTable{:,2:end},2);



%Subtracting RMSE from 1 so that higher numbers are better
%pcpTable.fracMigsMAPE = 1 - pcpTable.fracMigsMAPE;
%pcpTable.jointFracRMSE = 1 - pcpTable.jointFracRMSE;
%pcpTable.overallMigRateError = 1 - pcpTable.overallMigRateError;
%pcpTable.DakarPropError = 1 - pcpTable.DakarPropError;
%pcpTable.DakarInOutError = 1 - pcpTable.DakarInOutError;
%pcpTable.popWeightJobsRMSE = 1 - pcpTable.popWeightJobsRMSE;
%pcpTable.GenderRMSE = 1 - pcpTable.GenderRMSE;
%pcpTable.FracDiplomasError = 1 - pcpTable.FracDiplomasError;

%Normalize Indices to Max value in each for ease of visualization
%pcpTable.fracMigsMAPE = normalizeIndex(pcpTable.fracMigsMAPE);
%pcpTable.jointFracRMSE = normalizeIndex(pcpTable.jointFracRMSE);
%pcpTable.overallMigRateError = normalizeIndex(pcpTable.overallMigRateError);
%pcpTable.DakarPropError = normalizeIndex(pcpTable.DakarPropError);
%pcpTable.DakarInOutError = normalizeIndex(pcpTable.DakarInOutError);
%pcpTable.popWeightJobsRMSE = normalizeIndex(pcpTable.popWeightJobsRMSE);
%pcpTable.FracDiplomasError = normalizeIndex(pcpTable.FracDiplomasError);
%pcpTable.GenderRMSE = normalizeIndex(pcpTable.GenderRMSE);

pcpTable.SimpleAverage = mean(pcpTable{:,2:end},2);

if normalization == 1
    dataToPlot = pcpTable{:,{'overallMigRateError', 'jointFracRMSE', 'GenderError', 'DakarPropError', 'popWeightJobsRMSE', 'FracDiplomasError'}};
else
    dataToPlot = rawPcpTable{:,{'overallMigRateError', 'jointFracRMSE', 'GenderError', 'DakarPropError', 'popWeightJobsRMSE', 'FracDiplomasError'}};
end

%Quantile approach - set quantiles for each column
migsThreshold = prctile(pcpTable.jointFracRMSE,percentile);
migRateThreshold = prctile(pcpTable.overallMigRateError,percentile);
dakarPropThreshold = prctile(pcpTable.DakarPropError, percentile);
dakarInOutThreshold = prctile(pcpTable.DakarInOutError, percentile);
jobsThreshold = prctile(pcpTable.popWeightJobsRMSE,percentile);
edThreshold = prctile(pcpTable.FracDiplomasError,percentile);
genderThreshold =  prctile(pcpTable.GenderError,percentile);

topMigsIndices = pcpTable.sortedIndex(pcpTable.jointFracRMSE >= migsThreshold);
topMigRateIndices = pcpTable.sortedIndex(pcpTable.overallMigRateError >= migRateThreshold);
topDakarPropIndices = pcpTable.sortedIndex(pcpTable.DakarPropError >= dakarPropThreshold);
topDakarInOutIndices = pcpTable.sortedIndex(pcpTable.DakarInOutError >= dakarInOutThreshold);
topJobsIndices = pcpTable.sortedIndex(pcpTable.popWeightJobsRMSE >= jobsThreshold);
topEdIndices = pcpTable.sortedIndex(pcpTable.FracDiplomasError >= edThreshold);
topGenderIndices = pcpTable.sortedIndex(pcpTable.GenderError >= genderThreshold);

commonIndices = intersect(intersect(intersect(intersect(intersect(topJobsIndices,topMigsIndices),topEdIndices),topMigRateIndices),topDakarPropIndices),topGenderIndices);

%Highlight top job simulation
sortedJobs = sortrows(pcpTable,'popWeightJobsRMSE','descend');
jobIndex = sortedJobs.sortedIndex(1);

%Highlight top migration simulation
sortedMigration = sortrows(pcpTable,'jointFracRMSE','descend');
migrationIndex = sortedMigration.sortedIndex(1);

if normalization == 1
    highlightedRows = pcpTable(ismember(pcpTable.sortedIndex, commonIndices), :)
else
    highlightedRows = rawPcpTable(ismember(rawPcpTable.sortedIndex, commonIndices), :)
end

topParameters = calibrationTable(ismember(calibrationTable.sortedIndex,commonIndices),9:end)
highlightedDataToPlot = highlightedRows{:,{'overallMigRateError', 'jointFracRMSE', 'GenderError', 'DakarPropError','popWeightJobsRMSE', 'FracDiplomasError'}};
%highlightedDataToPlot = highlightedRows{:,{'overallMigRateError', 'DakarPropError','FracDiplomasError', 'popWeightJobsRMSE', 'jointFracRMSE',}};

if normalization == 1
    jobSimulation = pcpTable(ismember(pcpTable.sortedIndex,jobIndex),:)
else
    jobSimulation = rawPcpTable(ismember(rawPcpTable.sortedIndex,jobIndex),:)
end

highlightedJob = jobSimulation{:,{'overallMigRateError', 'jointFracRMSE', 'GenderError', 'DakarPropError','popWeightJobsRMSE', 'FracDiplomasError'}};
if normalization == 1
    migrationSimulation = pcpTable(ismember(pcpTable.sortedIndex,migrationIndex),:)
else
    migrationSimulation = rawPcpTable(ismember(rawPcpTable.sortedIndex,migrationIndex),:)
end

highlightedMigration = migrationSimulation{:,{'overallMigRateError', 'jointFracRMSE', 'GenderError', 'DakarPropError','popWeightJobsRMSE', 'FracDiplomasError'}};

[~,meanIndex] = sort(pcpTable.SimpleAverage,'descend');
topMeans = meanIndex(1);
highlightedMeans = pcpTable(topMeans,:);
highlightedMeansToPlot = highlightedMeans{:,{'overallMigRateError', 'jointFracRMSE', 'GenderError', 'DakarPropError','popWeightJobsRMSE', 'FracDiplomasError'}};

%Make parallel coordinate plot
parallelcoords(dataToPlot,'Color', [0.8, 0.8, 0.8], 'Group', pcpTable.sortedIndex);
hold on

h2 = parallelcoords(highlightedDataToPlot(1,:),'Color', [0, 0, 1], 'LineWidth',2, 'Group', highlightedRows.sortedIndex(1),'DisplayName', 'MultiObjective Calibration');
%h2 = parallelcoords(highlightedDataToPlot,'Color', [1, 0, 0], 'LineWidth',2, 'Group', highlightedMeans.sortedIndex);

h3 = parallelcoords(highlightedJob,'Color', [1,0,1], 'LineWidth',2,'Group',jobSimulation.sortedIndex,'DisplayName','Job Calibration');

h4 = parallelcoords(highlightedMigration,'Color',[0.4660 0.6740 0.1880], 'LineWidth',2,'Group',migrationSimulation.sortedIndex,'DisplayName','Migration Rate Calibration');

ax = gca;
ax.FontSize = 16;
xlabel('Calibration Metrics','FontSize',16);
xticklabels({'5-Year Migration Rate', '5-Year Migration Flows', 'Proportion Female Migrants', 'Dakar Proportion of Migrants', 'Job Distribution', 'Tertiary Education'});


if normalization == 1
    ylabel('Normalized Error Measures','FontSize',16);
else
    ylabel('Root Mean Square Error','FontSize',16);
end


legend([h2,h3,h4], {'MultiObjective Calibration','Job Calibration', 'Migration Flow Calibration'}, 'Location', 'best','FontSize',18)
%lgd = findobj('type', 'legend');
%delete(lgd)
hold off


topMeans = calibrationTable(ismember(highlightedMeans.sortedIndex,calibrationTable.sortedIndex),9:end);
%save multiObjectiveCalibrationParameters_07.04.2025.mat topParameters
%saveas(gcf, 'multiObjectiveCalibrationRaw_07.10.2025.png')

end

function newColumn = normalizeIndex(tableColumn)

maxValue = max(tableColumn);
newColumn = tableColumn ./ maxValue;

end
