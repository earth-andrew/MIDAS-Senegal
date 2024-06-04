function [] = reshapeData(modelParameters)
%Function that reshapes raw Data from Senegal analysis into a Matlab Table
%that has dimensions m x n, where m = number of locations and n = number of
%portfolio layers. Each value represents an average income for a given
%layer in a specified location.

%Decide on median income values or random income draws, based on model
%specification
%test = 1;
%if test == 1

if modelParameters.medianValuesYN == 1


    rawData = readtable('epred_sum_income.csv');
    medianValues = rawData(:,{'sector', 'urban', 'admin2', 'pred_med'}); %For median values
    lowerBound = rawData(:,{'sector', 'urban', 'admin2', 'pred_80lb'}); 
    upperBound = rawData(:,{'sector', 'urban', 'admin2', 'pred_80ub'}); 
    combinedValues = rawData(:,{'sector','urban','admin2','pred_80lb','pred_med','pred_80ub'});
    
    ruralUrbanMedian = unstack(medianValues,'pred_med','urban'); %For median values
    ruralUrbanLower = unstack(lowerBound,'pred_80lb','urban'); %For median values
    ruralUrbanUpper = unstack(upperBound,'pred_80ub','urban'); %For median values
    ruralUrbanCombined = unstack(combinedValues,{'pred_80lb','pred_med','pred_80ub'},'sector');

else
    rawData = readtable('epred_extract_100_income.csv');
    draw = modelParameters.incomeDraw;
    drawValues = rawData(:,{'sector', 'urban', 'admin2', ['draw_' num2str(draw)]});
    ruralUrbanTable = unstack(drawValues,['draw_' num2str(draw)],'urban');
end

%Unstack by Sector
tables = {ruralUrbanLower; ruralUrbanMedian; ruralUrbanUpper};
sectorTable = [];

for indexT = 1:length(tables) 
    sectorTable = [sectorTable; unstack(tables{indexT}, {'rural','urban'}, 'sector')];
end

%Fill missing values with 0 (to ensure agents won't select these
%location/sector options, which likely don't exist in real life)
sectorTable = fillmissing(sectorTable,'constant',0, 'DataVariables', @isnumeric);
numLocations = height(sectorTable)/length(tables);
numColumns = size(sectorTable,2)-1; %This calculates number of sectors (including both rural and urban sectors)
numSectors = numColumns ./ 2;

%Re-split ordered table into lower/med/higher incomes
matrixLower = sectorTable(1:numLocations,:);
matrixMed = sectorTable(numLocations+1:numLocations*2,:);
matrixUpper = sectorTable(numLocations*2+1:end,:);

%Join tables
temp = join(matrixLower, matrixMed,'Keys','admin2');
temp2 = join(temp,matrixUpper,'Keys','admin2');

%Re-order columns so that low, medium, and high income estimates for each
%sector/location are adjacent
combinedTable = temp2(:,1);
for indexC = 1:numColumns
    test = temp2(:,indexC+1);
    test2 = temp2(:,numColumns+indexC+1);
    teest3 = temp2(:,2*numColumns+indexC+1);
    combinedTable = [combinedTable, temp2(:,indexC+1), temp2(:,(numColumns + indexC+1)), temp2(:,2*numColumns+indexC+1)];
end

sectorTable = sortrows(combinedTable,'admin2','ascend');

%Re-order so that rural/urban are adjacent
orderedTable = [sectorTable(:,1)];
for indexC = 1:numSectors
    orderedTable = [orderedTable, sectorTable(:,(3*(indexC-1)+2):(3*(indexC-1)+4)), sectorTable(:,(3*(numSectors+indexC-1)+2):(3*(numSectors+indexC-1)+4))];
end

save('Data/SenegalIncomeData.mat', 'orderedTable')



end