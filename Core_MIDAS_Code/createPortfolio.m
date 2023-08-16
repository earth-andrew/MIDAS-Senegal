function [portfolioSets] = createPortfolio(portfolio, layers, constraints, prereqs,pAdd, agentTraining, agentExperience, utilityCosts, utilityDuration, numPeriodsEvaluate, selectable, currentUtilities, agentWealth, pBackCast, accesscodes)
%createPortfolio draws a random portfolio of utility layers that fit the current time constraint

%Steps:
%1. If a portfolio is not specified as part of argument, create one at
%random. This is done in one of two ways: backcasting (selecting portfolio
%layers at random and then filling in any pre-reqs for aspirations) or forecasting
%(selecting only selectable layers and then seeing what aspirations could
%be enabled by these). Which of these is followed depends on the parameter
%pBackCast and a random draw. The output is a n x 3 matrix that tracks
%different stages of portfolios over the evaluation periods. The first row
%represents the near-term high-fidelity portfolio, last row represents the
%long-term aspiration, and middle rows represent any intermediate
%portfolios. Columns represent (1) the selected portfolio layers, (2) the
%time duration for each, and (3) a flag of high- vs low-fidelity
%portfolios.

%Algorithm for backcasting:
%1. Build portfolio by selecting layers at random until time is filled up.
%2. Check if there are any aspirational elements to portfolio
%3. If there are aspirational elements in portfolio, fill out high-fidelity portfolio with prereqs that are selectable
%4. With time remaining, fill out remaining high-fidelity portfolio with other selectable layers
%5. If there are prereqs, set high-fidelity portfolio duration to max prereq duration or agent evaluation period, whichever is shorter
%6. Check if agent wealth + income accumulated during high-fidelity part would be enough to afford aspirational element
    %6a. If not enough resources, remove any layers that have "expired"
    %(e.g. school) and replace with other selectable income-generating
    %layers as a medium portfolio. Figure out how many time periods would
    %be required to accumulate sufficient resources to afford aspiration.
    %6b. If sufficient resources are accumulated before period evaluation ends,
    %set medium term duration to this time period (extra time to accumulate resources)
%7. if there are no prereqs, set high-fidelity portfolio to max duration
%of portfolio layer or agent evaluation period, whichever is shorter
%8. Return portfolio, duration, and aspiration flag


%Algorithm for forecasting:
%1a. Identify currently selectable layers, and build portfolio using only
%these layers until time is filled up or there are no more selectable
%layers.
%1b. Check if agent already has educational training, in which case, remove
%education.
%2. Check which aspirations are enabled by selectable layers
%3. If more than one aspiration, pick one at random to be the future
%aspiration associated with this portfolio.
%4. Figure out high-fidelity duration by taking the max prereq duration or
%agent evaluation period, whichever is shorter.
%5. Return portfolio layers, duration, and aspiration flag


%To-DO:
%1) Figure out whether to account for income constraints in both
%backcasting and forecasting
%2) Figure out how to add an intermediate portfolio

%start with all the time in the world
timeRemaining = ones(1, size(constraints,2)-1);  %will be as long as the cycle defined for layers
aspiration = false(1,size(constraints,1)); %Initialize blank column array of aspirations
portfolioPrereqs = []; %Initialize blank array of potential prereqs for portfolio aspiration
highfidelityDuration = numPeriodsEvaluate; %Initialize duration of high-fidelity portion to be equal to agent's evaluation period
accumulatingDuration = 0; %initialize time for an accumulating portfolio (i.e. to accumulate enough financial resources) 
[i,j,s] = find(prereqs); %Indices of layers that are prerequisites, where j are requirements
portfolioSets = [];

%First check if portfolio is specified. If not, create one at random (original code)
if isempty(portfolio)
   
    %initialize an empty portfolio
    portfolio = false(1,size(constraints,1));
    
    %BackCasting process (i.e. see if there are any aspirations then fill
    %in high-fidelity portion with pre-reqs)
    if rand() < pBackCast
        %while we still have time left and layers that fit, OR portfolio is
        %empty
        
        while(sum(timeRemaining) > 0 && ~isempty(layers))
    
            %draw one of those layers at random and remove it from the set
            randomDraw = ceil(rand()*length(layers));
    
            nextElement = layers(randomDraw);
            layers(randomDraw) = [];
            
            if(~portfolio(nextElement))  %if this one isn't already in the portfolio (e.g., it got drawn in as a prereq in a previous iteration)
            %make a temporary portfolio for consideration

                tempPortfolio = portfolio;
                tempPortfolio(nextElement) = true;
                timeUse = sum(constraints(tempPortfolio,2:end),1);
                timeExceedance = sum(sum(timeUse > 1)) > 0;

                %test whether to add it to the portfolio, if it fits
                if(~timeExceedance && rand() < pAdd)
                    portfolio = tempPortfolio;
                    %remove any that are OBVIOUSLY over the limit, though this won't
                    %catch any that have other time constraints tied to prereqs
                    timeRemaining = 1 - timeUse;
                    layers(sum(constraints(layers,2:end) > timeRemaining,2) > 0) = [];
                end
            end
            if ~any(portfolio)
                disp('Empty portfolio')
            end
        end

        %Now check if portfolio has any aspirational elements
        samplePortfolio = portfolio';
        aspirations = samplePortfolio & ~selectable;
    
        %If any elements are aspirations, pick one at random and figure out prereqs
        if any(aspirations)
            indAspiration = find(aspirations);
            samplePortfolio(aspirations) = false;

            %Select one aspiration at random
            if length(indAspiration) > 1
                indAspiration = randsample(indAspiration,1);
            end
            aspiration(1,indAspiration) = true;
            
    
            %Add any selectable prereqs to portfolio    
            portfolioPrereqs = j(i==indAspiration); 
            portfolioPrereqs(portfolioPrereqs == indAspiration) = []; %remove own layer from aspiration's prereqs
           
            %Check for any other selectable prereqs
            if any(portfolioPrereqs & selectable)
                samplePortfolio(portfolioPrereqs) = true;
                duration = max(utilityDuration(portfolioPrereqs,1) - agentExperience(portfolioPrereqs,1),0); %Minimum time durations for pre-reqs, accounting for any experience already accumulated. Note that some layers can be prereqs even if sufficient training is amassed (due to costs), hence max of training needed and 0
            end
            
            %If time is exceeded, remove layers one by one    
            timeRemaining = 1 - sum(constraints(samplePortfolio,2:end)); 

            while sum(timeRemaining) < 0    
                tempLayers = find(samplePortfolio);    
                samplePortfolio(randsample(tempLayers,1)) = false;    
                timeRemaining = 1 - sum(constraints(samplePortfolio,2:end));    
            end

            %Now, if time still remains and selectable layers are still available, keep filling portfolio    
            selectableLayers = selectable & ~samplePortfolio;
    
            while sum(timeRemaining) > 0 && any(selectableLayers)    
                indexS = randsample(find(selectableLayers,1),1);    
                samplePortfolio(indexS) = true;    
                timeRemaining = 1 - sum(constraints(samplePortfolio,2:end));    
                selectableLayers(indexS) = false;    
            end
        
        end
         
        %Now, figure out duration, based on time needed to get sufficiently trained
        if any(portfolioPrereqs) && (max(duration) < numPeriodsEvaluate)
            highfidelityDuration = max(duration);
        else
            %If no prereqs, set highFidelity duration to max time allowed
            %in portfolio
            highfidelityDuration = min(numPeriodsEvaluate, min(utilityDuration(portfolio,2) - agentTraining(portfolio)));
        end

        portfolioSets(1,:) = [samplePortfolio' highfidelityDuration 1];
        
        %If highfidelityDuration < numPeriodsEvaluate, check if agent can afford aspiration after completing prereqs
        newIncome = 0;
        %Average income across all seasons
        for indexT = 1:size(constraints(:,2:end),2)
            newIncome = newIncome + (samplePortfolio' * currentUtilities(:,:,indexT)') .* 1/size(constraints(:,2:end),2);
        end

        newTraining = samplePortfolio' .* highfidelityDuration;
        agentResources = agentWealth + newIncome * highfidelityDuration;
    
        if any(aspirations) && agentResources < utilityCosts(indAspiration)
            %Replace any expired layers with another selectable layer that can generate income
            tempPortfolio = samplePortfolio;
                
            %identify layers for which agent will have had sufficient training after high-fidelity duration and remove from portfolio
            %replaceLayers = ((agentExperience + newTraining') >= utilityDuration(:,2))
            %tempPortfolio(replaceLayers) = false
                
            %Re-assess which layers are selectable after high-fidelity duration
            selectableLayers = selectableFlag(prereqs, accesscodes, utilityCosts, agentTraining, newTraining, tempPortfolio, agentResources, utilityDuration(:,2));
            tempPortfolio(~selectableLayers) = false;
                
            %Re-iterate to identify any additional selectable layers that agent can deploy
            while sum(timeRemaining) > 0 && any(selectableLayers)    
                indexS = randsample(find(selectableLayers,1),1);    
                tempPortfolio(indexS) = true;   
                timeRemaining = 1 - sum(constraints(samplePortfolio,2:end));    
                selectableLayers(indexS) = false;    
            end
                
            %Set medium Duration as minimum of (i) time required to acquire enough resources for aspiration, or remaining time left that agent has in their time horizon
            accumulatingDuration = min(ceil((utilityCosts(indAspiration) - agentResources) / newIncome), (numPeriodsEvaluate - highfidelityDuration)); 
            portfolioSets = [portfolioSets; [tempPortfolio' accumulatingDuration 1]];
                
        end
        aspirationDuration = numPeriodsEvaluate - highfidelityDuration - accumulatingDuration; %Time left to dream about aspirations
        portfolioSets = [portfolioSets; [aspiration aspirationDuration 0]];
        
        
        
    %Forecasting process
    else
        %Find selectable layers. If there are none (e.g. agent is in debt),
        %choose least costly layer
        selectableLayers = find(selectable);
        if isempty(selectableLayers)
            test = 'No selectable layers'
            [minValue,selectableLayers] = min(utilityCosts)
        end

        %Build portfolio based on currently selectable layers
        while(sum(timeRemaining) > 0 && any(selectableLayers))
            selectableInd = ceil(rand()*length(selectableLayers));
            nextElement = selectableLayers(selectableInd);
            selectableLayers(selectableInd) = [];
            if(~portfolio(nextElement))  %if this one isn't already in the portfolio
            %make a temporary portfolio for consideration
                tempPortfolio = portfolio;
                tempPortfolio(nextElement) = true;
                
                timeUse = sum(constraints(tempPortfolio,2:end),1);
                timeExceedance = sum(sum(timeUse > 1)) > 0;

                %Add to portfolio if time is not exceeded
                if(~timeExceedance)
                    portfolio(nextElement) = true;
                    %remove any that are OBVIOUSLY over the limit, though this won't
                    %catch any that have other time constraints tied to prereqs
                    timeRemaining = 1 - timeUse;
                    layers(sum(constraints(layers,2:end) > timeRemaining,2) > 0) = [];
                end

            end
        end

        %Figure out high-fidelity duration based on maximum of the layers' minimum
        %durations
        duration = max((utilityDuration(portfolio',1) - agentExperience(portfolio,1)),0); %Array of minimum time durations for pre-reqs, accounting for experience accumulated
        highfidelityDuration = min([max(duration) numPeriodsEvaluate]);
        portfolioSets = [portfolio highfidelityDuration 1];
        %Now find a random aspiration (if any) that is enabled by selectable
        %portfolio
        potentialAspirations = false(1, size(constraints,1));
        selectedLayers = find(portfolio);
        numLayers = length(selectedLayers);
        for indexI = 1:1:numLayers
            potentialAspirations(find(prereqs(:,selectedLayers(indexI)),1)) = true;
        end

        indAspiration = find(potentialAspirations);
        
        %While there are still potential aspirations, but none has been
        %selected yet
        while ~isempty(indAspiration) && all(~(aspiration))
            %Select one aspiration at random
            indexA = ceil(rand() * length(indAspiration));
            nextAspiration = indAspiration(indexA);

            %Check for prereqs here
            portfolioPrereqs = j(i == nextAspiration);
            portfolioPrereqs(portfolioPrereqs== nextAspiration) = [];
            
            %If aspiration is not already in portfolio, but all prereqs are
            if ~portfolio(nextAspiration) && all(portfolio(portfolioPrereqs))
                aspiration(1, nextAspiration) = true;
            else
                indAspiration(indexA) = [];
            end
           
        end
        
        % If there are no aspirations to choose from (e.g. agent has
        % already achieved all the training they need), then set
        % high-fidelty duration to numPeriodsEvaluate
        if all(~aspiration)
            highfidelityDuration = numPeriodsEvaluate;
        end
        
        aspirationDuration = numPeriodsEvaluate - highfidelityDuration;
        portfolioSets = [portfolioSets; [aspiration aspirationDuration 0]];
    end 
  end
 
%Test for empty portfolios
if isempty(portfolio)
    test = 'empty portfolio in createPortfolio'
end
end










