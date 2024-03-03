function [] = reshapeData(modelParameters)
%Function that reshapes raw Data from Senegal analysis into a Matlab Table
%that has dimensions m x n, where m = number of locations and n = number of
%portfolio layers. Each value represents an average income for a given
%layer in a specified location.

%rawData = load([modelParameters.utilityDataPath '/epred_sum.csv']);
rawData = readtable('epred_sum_income.csv');
%rawData = readtable('epred_extract_100_income.csv');


%Pick random number from 1 to 100 for draw, or read from input parameters
%draw = randi(100);
%draw = modelParameters.incomeDraw

medianValues = rawData(:,{'sector', 'urban', 'admin2', 'pred_med'}); %For median values
%medianValues = rawData(:,{'sector', 'urban', 'admin2', ['draw_' num2str(draw)]});
ruralUrbanTable = unstack(medianValues,'pred_med','urban'); %For median values
%ruralUrbanTable = unstack(medianValues,['draw_' num2str(draw)],'urban');

sectorTable = unstack(ruralUrbanTable, {'rural','urban'}, 'sector');

%Fill missing values with 0 (to ensure agents won't select these
%location/sector options, which likely don't exist in real life)
sectorTable = fillmissing(sectorTable,'constant',0, 'DataVariables', @isnumeric);

sectorTable = sortrows(sectorTable,'admin2','ascend');
numColumns = size(sectorTable,2); %This calculates number of sectors (including both rural and urban sectors)
numSectors = (numColumns-1) ./ 2; 

orderedTable = [sectorTable(:,2) sectorTable(:,8)];
for indexC = 2:numSectors
    orderedTable = [orderedTable sectorTable(:,indexC+1) sectorTable(:,indexC+1+numSectors)];
end

save('Data/SenegalIncomeData.mat', 'orderedTable')



end