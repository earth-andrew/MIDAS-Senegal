function aspUtility = aspirationalPortfolio(utilityLayers, numPortfolios, prereqs, constraints)
%Script that generates random portfolios with a specified layer and calculates average utility
%Main Steps:
%1. Identify utility layers that have prerequisites other than themselves (otherwise don't bother with next steps)
%2. For each layer, generate X number of random portfolios that include the layer (where X is a function argument), with random location
%3. Take average of utilities of all X portfolios involving specified layer
%4. Return an array of average utilities for each layer




aspUtility = zeros(size(utilityLayers,2),1); %Average utility of aspirational layers

for indexL = 1:size(utilityLayers,2)

    %Only generate random portfolios if layer indexL requires prereqs
    if (sum(prereqs(indexL,:)) > 1)
        utilities = zeros(numPortfolios,1);
    
        %Create numPortfolios number of random portfolios with layer indexL
        for indexP = 1:numPortfolios
            layers = ones(size(utilityLayers,2),1);
            %start with all the time in the world
            timeRemaining = ones(1, size(constraints,2)-1);  %will be as long as the cycle defined for layers

            %initialize an empty portfolio
            portfolio = false(length(constraints),1);

            %Add in layer of interest
            portfolio(indexL,1) = 1;
            layers(indexL,1) = 0;
        
            %Check if agent would have time remaining to add other layers
            timeUse = sum(constraints(portfolio,2:end),1);
            timeExceedance = sum(sum(timeUse > 1)) > 0;
            timeRemaining = 1 - timeUse;

            %while we still have time left and layers that fit
            while(sum(timeRemaining) > 0 &&  (sum(layers) > 0))

                %draw one of those layers at random and remove it from the set
                randomDraw = ceil(rand()* size(utilityLayers,2));
                nextElement = layers(randomDraw);
                layers(randomDraw) = 0; %Remove layer we just tested from those available to be pulled
                %from

                %if randomDraw is not already in our portfolio, add to
                %portfolio
                if (~portfolio(randomDraw))
                    portfolio(randomDraw,1) = 1;
                    timeUse = sum(constraints(portfolio,2:end),1);
                    timeExceedance = sum(sum(timeUse > 1)) > 0;
                end
            
                %If adding this layer exceeds our time available, remove it
                if (timeExceedance)
                    portfolio(randomDraw,1) = 0;
                end
        
                timeRemaining = 1 - timeUse;  
            end
            
            %Pick a location at random and calculate portfolio utility
            locIndex = ceil(rand() * size(utilityLayers,1));
            localLayers = utilityLayers(locIndex,:)';
            utilities(indexP,1) = sum(localLayers(portfolio,1),1);
        
        end
    
        aspUtility(indexL) = mean(utilities);
    end

end


end