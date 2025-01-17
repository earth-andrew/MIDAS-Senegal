function samplePortfolio = fillPortfolio(samplePortfolio, constraints, selectable, portfolioPrereqs, modelParameters)
%This function returns a filled portfolio based on an agent's existing portfolio, selectable layers and
%time constraints of each layer

%Sum rows in constraints for active portfolio layers (starting from index 2, as index 1 represents the index of the layer)
timeUse = sum(constraints(samplePortfolio,2:end),1); 
timeRemaining = 1 - timeUse;

%Identify remaining selectable layers that could be added
selectableLayers = selectable & ~samplePortfolio;

%neededTraining = portfolioPrereqs - eye(portfolioLayers)
%[~,achievedPrereqs] = find(neededTraining(selectableLayers,:))
%selectableLayers(achievedPrereqs) = false


%Add one selectableLayer at random
while (sum(timeRemaining) > 0 && any(selectableLayers))
    tempLayers = find(selectableLayers);
    if length(tempLayers) > 1    
        indexS = datasample(tempLayers,1); 
    else
        indexS = tempLayers;
    end

  
    samplePortfolio(indexS) = true;    
    timeUse = sum(constraints(samplePortfolio,2:end),1);              
    timeRemaining = 1 - timeUse;    
    selectableLayers(indexS) = false;        
end

%Consider doing this outside of while loop

  %If higher-income layer in same activity is already in portfolio,
    %disregard this layer
    %highestLayer = ceil(indexS / modelParameters.income_levels) * modelParameters.income_levels;
    %lowestLayer = floor(indexS / modelParameters.income_levels) * modelParameters.income_levels + 1;
    %if any(samplePortfolio(lowestLayer:highestLayer))
        %existingLayers = find(samplePortfolio(lowestLayer:highestLayer)) + lowestLayer - 1;
        %indexS = max([existingLayers indexS]);
        %samplePortfolio(lowestLayer:indexS) = false;
    %end


%Check if time constraints are exceeded in any time step. If so, remove
%layers at random until all periods fit under constraints
while any(timeRemaining < 0)  
    tempLayers = find(samplePortfolio);

    %Keep any prereqs in portfolio (i.e. remove from tempLayers to be
    %considered for removal)
    tempLayers(ismember(tempLayers,portfolioPrereqs)) = [];
                
    if length(tempLayers) > 1
        samplePortfolio(datasample(tempLayers,1)) = false;
    else
        samplePortfolio(tempLayers) = false;
    end
                
    timeUse = sum(constraints(samplePortfolio,2:end),1);
    timeRemaining = 1 - timeUse;    
end

end