function [portfolio, aspiration, highfidelityDuration] = createPortfolio(portfolio, layers, constraints, prereqs,pAdd, accesscodes, utilityCosts, utilityDuration, numPeriodsEvaluate, selectable)
%createPortfolio draws a random portfolio of utility layers that fit the current time constraint

%Steps:
%1. If a portfolio is not specified as part of argument, create one at random 
%2. Check if there are any aspirational elements to portfolio
%3. If there are aspirational elements in portfolio, fill out high-fidelity portfolio with prereqs that are selectable
%4. With time remaining, fill out remaining high-fidelity portfolio with other selectable layers
%5a. If there are prereqs set high-fidelity portfolio duration to max
%prereq duration or agent evaluation period, whichever is shorter
%5b. if there are no prereqs, set high-fidelity portfolio to max duration
%of portfolio layer or agent evaluation period, whichever is shorter
%6. Return high-fidelity portfoliio, duration, and aspiration (if applicable)


%start with all the time in the world
timeRemaining = ones(1, size(constraints,2)-1);  %will be as long as the cycle defined for layers
%indAspiration = 0;
aspiration = false(1,size(constraints,1)); %Initialize blank column array of aspirations
portfolioPrereqs = []; %Initialize blank array of potential prereqs for portfolio aspiration
highfidelityDuration = numPeriodsEvaluate; %Initialize duration of high-fidelity portion to be equal to agent's evaluation period

%First check if portfolio is specified. If not, create one at random (original code)
if isempty(portfolio)
    %initialize an empty portfolio
    portfolio = false(1,size(constraints,1));
    
    %while we still have time left and layers that fit
    while(sum(timeRemaining) > 0 && ~isempty(layers))
    
        %draw one of those layers at random and remove it from the set
        randomDraw = ceil(rand()*length(layers));
    
        nextElement = layers(randomDraw);
        layers(randomDraw) = [];
    
        if(~portfolio(nextElement))  %if this one isn't already in the portfolio (e.g., it got drawn in as a prereq in a previous iteration)
            %make a temporary portfolio for consideration

            tempPortfolio = portfolio | prereqs(nextElement,:); %This adds the nextElement plus all other prereqs to 1-dimensional portfolio
        
        
        end
        
            timeUse = sum(constraints(tempPortfolio,2:end),1);
            timeExceedance = sum(sum(timeUse > 1)) > 0;


            %test whether to add it to the portfolio, if it fits
            if(~timeExceedance & rand() < pAdd)
                portfolio = tempPortfolio;

                %remove any that are OBVIOUSLY over the limit, though this won't
                %catch any that have other time constraints tied to prereqs
                timeRemaining = 1 - timeUse;
                layers(sum(constraints(layers,2:end) > timeRemaining,2) > 0) = [];
            end
    end

end 


%Now check if portfolio (either pre-specified or created through this function) has any aspirational elements
samplePortfolio = portfolio';
aspirations = samplePortfolio & ~selectable;

    
%If any elements are aspirations, pick one at random and figure out prereqs
if any(aspirations)
    indAspiration = find(aspirations);
    samplePortfolio(indAspiration) = false;

    %Select one aspiration at random
    if length(indAspiration) > 1
        indAspiration = randsample(indAspiration,1);
    end
    aspiration(1,indAspiration) = true;
    
    
    %Add any selectable prereqs to portfolio
    [i,j,s] = find(prereqs); %Indices of layers that are prerequisite for indexA
    
    portfolioPrereqs = j(i==indAspiration); 
    portfolioPrereqs(portfolioPrereqs == indAspiration) = []; %remove own layer from aspiration's prereqs
           
    %Add check for selectable prereqs
    if any(portfolioPrereqs)
        samplePortfolio(portfolioPrereqs) = true;
        duration = utilityDuration(portfolioPrereqs); %Array of minimum time durations for pre-reqs
    end
        
    %If time is exceeded, remove layers one by one    
    timeRemaining = 1 - sum(constraints(samplePortfolio,2:end));    
    while sum(timeRemaining) < 0    
        tempLayers = find(samplePortfolio);    
        samplePortfolio(randsample(tempLayers,1)) = false;    
        timeRemaining = 1 - sum(constraints(samplePortfolio,2:end));    
    end
end

    
%Now, if time still remains and selectable layers are still available, keep filling portfolio    
selectableLayers = selectable & ~samplePortfolio;
    
while sum(timeRemaining) > 0 && any(selectableLayers)    
    indexS = randsample(find(selectableLayers,1),1);    
    samplePortfolio(indexS) = true;    
    timeRemaining = 1 - sum(constraints(samplePortfolio,2:end));    
    selectableLayers(indexS) = false;    
end

%Now, figure out duration
if any(portfolioPrereqs) && (max(duration) < numPeriodsEvaluate)
    highfidelityDuration = max(duration);
else
    highfidelityDuration = numPeriodsEvaluate;

end

end






