function calibrationPCP()
%Function that creates a parallel coordinate plot of multiple calibrated
%metrics

load('migrationCalibration_01.07.2025.mat')
calibrationTable = migCalibrationTable;
migMetrics = migCalibrationTable(:,{'sortedIndex', 'jointFracMigs_r2', 'overallMigRateError', 'DakarPropError','DakarInOutError'});

load('jobsCalibration_01.07.2025.mat')
jobMetrics = jobsCalibrationTable(:,{'sortedIndex', 'popWeightJobsError_r2'});

load('educationCalibration_01.07.2025.mat')
edMetrics = educationCalibrationTable(:,{'sortedIndex', 'fracDiplomas_r2'});

load('genderCalibration_01.07.2025.mat')
genderMetrics = genderCalibrationTable(:,{'sortedIndex', 'GenderError'});

%Merge tables
mergedTable = join(migMetrics, jobMetrics);
pcpTable = join(mergedTable,edMetrics);
pcpTable = join(pcpTable,genderMetrics);

%Re-normalize overallMigRateError: Recover RMSE, then divide by max
%modelled migration rate (so that 1 is the worst possible prediction), then
%subtract this quantity from 1 to reverse scale
%pcpTable.overallMigRateRMSE = pcpTable.overallMigRateError;
%pcpTable.modelMigRate = pcpTable.overallMigRateRMSE + 0.0402;
%maxMigRate = max(pcpTable.modelMigRate);
%pcpTable.overallMigRateError = 1 - (pcpTable.overallMigRateRMSE ./ maxMigRate);

%Subtracting RMSE from 1 so that higher numbers are better
pcpTable.overallMigRateError = 1 - pcpTable.overallMigRateError;
pcpTable.DakarPropError = 1 - pcpTable.DakarPropError;
pcpTable.DakarInOutError = 1 - pcpTable.DakarInOutError;
pcpTable.GenderError = 1 - pcpTable.GenderError;

%Normalize Indices to Max value in each for ease of visualization
pcpTable.jointFracMigs_r2 = normalizeIndex(pcpTable.jointFracMigs_r2);
pcpTable.overallMigRateError = normalizeIndex(pcpTable.overallMigRateError);
pcpTable.DakarPropError = normalizeIndex(pcpTable.DakarPropError);
pcpTable.DakarInOutError = normalizeIndex(pcpTable.DakarInOutError);
pcpTable.popWeightJobsError_r2 = normalizeIndex(pcpTable.popWeightJobsError_r2);
pcpTable.fracDiplomas_r2 = normalizeIndex(pcpTable.fracDiplomas_r2);
pcpTable.GenderError = normalizeIndex(pcpTable.GenderError);
pcpTable.SimpleAverage = mean(pcpTable{:,2:end},2);

dataToPlot = pcpTable{:,{'overallMigRateError', 'jointFracMigs_r2', 'GenderError', 'DakarPropError', 'popWeightJobsError_r2', 'fracDiplomas_r2'}};
%dataToPlot = pcpTable{:,{'overallMigRateError', 'DakarPropError', 'fracDiplomas_r2', 'popWeightJobsError_r2','jointFracMigs_r2'}};

%Quantile approach - set quantiles for each column
percentile = 65;
migsThreshold = prctile(pcpTable.jointFracMigs_r2,percentile);
migRateThreshold = prctile(pcpTable.overallMigRateError,percentile);
dakarPropThreshold = prctile(pcpTable.DakarPropError, percentile);
dakarInOutThreshold = prctile(pcpTable.DakarInOutError, percentile);
jobsThreshold = prctile(pcpTable.popWeightJobsError_r2,percentile);
edThreshold = prctile(pcpTable.fracDiplomas_r2,percentile);
genderThreshold =  prctile(pcpTable.GenderError,percentile);

topMigsIndices = pcpTable.sortedIndex(pcpTable.jointFracMigs_r2 >= migsThreshold);
topMigRateIndices = pcpTable.sortedIndex(pcpTable.overallMigRateError >= migRateThreshold);
topDakarPropIndices = pcpTable.sortedIndex(pcpTable.DakarPropError >= dakarPropThreshold);
topDakarInOutIndices = pcpTable.sortedIndex(pcpTable.DakarInOutError >= dakarInOutThreshold);
topJobsIndices = pcpTable.sortedIndex(pcpTable.popWeightJobsError_r2 >= jobsThreshold);
topEdIndices = pcpTable.sortedIndex(pcpTable.fracDiplomas_r2 >= edThreshold);
topGenderIndices = pcpTable.sortedIndex(pcpTable.GenderError >= genderThreshold);

commonIndices = intersect(intersect(intersect(intersect(intersect(topJobsIndices,topMigsIndices),topEdIndices),topMigRateIndices),topDakarPropIndices),topGenderIndices);
%commonIndices = topEdIndices;

highlightedRows = pcpTable(ismember(pcpTable.sortedIndex, commonIndices), :);
highlightedDataToPlot = highlightedRows{:,{'overallMigRateError', 'jointFracMigs_r2', 'GenderError', 'DakarPropError','popWeightJobsError_r2', 'fracDiplomas_r2'}};
%highlightedDataToPlot = highlightedRows{:,{'overallMigRateError', 'DakarPropError','fracDiplomas_r2', 'popWeightJobsError_r2', 'jointFracMigs_r2',}};

[~,meanIndex] = sort(pcpTable.SimpleAverage,'descend');
topMeans = meanIndex(1);
highlightedMeans = pcpTable(topMeans,:);
highlightedMeansToPlot = highlightedMeans{:,{'overallMigRateError', 'jointFracMigs_r2', 'GenderError', 'DakarPropError','popWeightJobsError_r2', 'fracDiplomas_r2'}};


%Make parallel coordinate plot
parallelcoords(dataToPlot,'Color', [0.8, 0.8, 0.8], 'Group', pcpTable.sortedIndex);
hold on

h2 = parallelcoords(highlightedDataToPlot,'Color', [0, 0, 1], 'LineWidth',2, 'Group', highlightedRows.sortedIndex);
%h2 = parallelcoords(highlightedMeansToPlot,'Color', [1, 0, 0], 'LineWidth',2, 'Group', highlightedMeans.sortedIndex);

ax = gca;
ax.FontSize = 16;
xlabel('Calibration Metrics','FontSize',16);
xticklabels({'5-Year Migration Rate', '5-Year Migration Flows', 'Proportion Female Migrants', 'Dakar Proportion of Migrants', 'Job Distribution', 'Tertiary Education'});
%xticklabels({'5-Year Migration Rate', 'Dakar Proportion of Migrants', 'Tertiary Education', 'Job Distribution', '5-Year Migration Flows',});

ylabel('R^2 Measures','FontSize',16);
ylabel('Normalized Error Measures','FontSize',16);
%legend(h2, ['Runs in Top ' num2str(percentile) ' Percentile for Each Dimension'],'Location', 'northwest')
lgd = findobj('type', 'legend');
delete(lgd)
hold off

topParameters = calibrationTable(ismember(calibrationTable.sortedIndex,commonIndices),9:end)
topMeans = calibrationTable(ismember(highlightedMeans.sortedIndex,calibrationTable.sortedIndex),9:end);
save multiObjectiveCalibrationParameters_01.14.2025.mat topParameters
saveas(gcf, 'multiObjectiveCalibration_01.14.2025.png')

end

function newColumn = normalizeIndex(tableColumn)

maxValue = max(tableColumn);
newColumn = tableColumn ./ maxValue;

end
