function [] = reshapeData()
%Function that reshapes raw Data from Senegal analysis into a Matlab Table
%that has dimensions m x n, where m = number of locations and n = number of
%portfolio layers. Each value represents an average income for a given
%layer in a specified location.

%rawData = load([modelParameters.utilityDataPath '/epred_sum.csv']);
rawData = readtable('./epred_sum.csv');
medianValues = rawData(:,{'sector', 'urban', 'admin', 'pred_med'})
ruralUrbanTable = unstack(medianValues,'pred_med','urban')
sectorTable = unstack(ruralUrbanTable, {'rural','urban'}, 'sector');

sectorTable = sortrows(sectorTable,'admin','ascend');
numColumns = size(sectorTable,2); %This calculates number of sectors (including both rural and urban sectors)
numSectors = (numColumns-1) ./ 2; 

orderedTable = [sectorTable(:,2) sectorTable(:,8)];
for indexC = 2:numSectors
    orderedTable = [orderedTable sectorTable(:,indexC+1) sectorTable(:,indexC+1+numSectors)];
end



save('SenegalIncomeData.mat', 'orderedTable')



end