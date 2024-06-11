function [ currentAgent, backCastNum] = trainingTracker(currentAgent, utilityVariables, modelParameters, backCastNum, indexT)
%This function tracks how many periods of "training" an agent has received in
%any given layer. To make this generalizable, we track the periods of
%experience in each layer, even though not all layers may have formal
%training.

%Algorithm
%1. (For agent experience vector) Based on agent's current Portfolio, add 1 period experience for each
%layer in which agent is currently engaged.
% 2.(For agent certification vector) Based on experience vector, adjust any
% certifications from "false" to "true" if agent has reached minimum
% experience needed for certification.
%3. Test if agent aspiration is now selectable. If so, generate random portfolio with this aspiration and set this as the
%agent's current bestPortfolio.
%4. If aspiration is still not selectable, update duration of high-fidelity
%portions of currentPortfolio and other bestPortfolios based on extra
%period of training.

[i,j,s] = find(utilityVariables.utilityPrereqs);
%Add increment of 1 period experience for each layer in agent's current
%Portfolio
numLayers = size(utilityVariables.utilityLayerFunctions,1);
currentPortfolio = currentAgent.currentPortfolio(1,1:numLayers)';
currentAspiration = find(currentAgent.currentAspiration);
currentAgent.experience = currentAgent.experience + currentPortfolio;
%Check whether agent has achieved any new certifications
minLength = utilityVariables.utilityDuration(:,1);
newCerts = find(currentAgent.experience >= minLength);
currentAgent.training(newCerts) = true;

%If one of those new certifications is education related, note this in the
%agent's diploma tracker
if ismember(modelParameters.educationLayer, newCerts)
    currentAgent.diploma = [currentAgent.diploma indexT];
end

%Test if agent aspiration is now selectable (if aspirations are turned on)
if modelParameters.aspirationsFlag == 1

    selectableLayers = selectableFlag(utilityVariables.utilityPrereqs, utilityVariables.utilityAccessCodesMat, utilityVariables.utilityAccessCosts, currentAgent.training, currentAgent.experience, [], [], utilityVariables.utilityDuration(:,2));

    if any(selectableLayers' & currentAgent.currentAspiration)
        [currentAgent.currentPortfolio, backCastNum] = createPortfolio(currentAgent.currentAspiration, [],utilityVariables.utilityTimeConstraints, utilityVariables.utilityPrereqs, currentAgent.pAddFitElement, currentAgent.training, currentAgent.experience, utilityVariables.utilityAccessCosts, utilityVariables.utilityDuration, currentAgent.numPeriodsEvaluate, selectableLayers, [], currentAgent.wealth, backCastNum, utilityVariables.utilityAccessCodesMat, modelParameters);

    %Adjust time of high-fidelity duration if new experience helps fulfill prereq
    else
        %Ensure portfolio is not empty
        if any(currentPortfolio)
            %Identify any layers in currentPortfolio that are prereqs for
            %aspiration
            prereqs = j(i==currentAspiration);
            prereqs(prereqs == currentAspiration) = [];
            %Figure out time left on any prereqs
            if any(prereqs)
                currentAgent.currentPortfolio(1,[prereqs']) = true;
                timeToTraining = max(utilityVariables.utilityDuration(prereqs,1) - currentAgent.experience(prereqs));
            else
                timeToTraining = 0;
            end
            %Figure out max time left in any time-bound layers
            timeLeftInLayer = min(min(utilityVariables.utilityDuration(logical(currentPortfolio),2) - currentAgent.experience(logical(currentPortfolio))), currentAgent.numPeriodsEvaluate);
            if timeLeftInLayer < timeToTraining
                highFidelityDuration = max(timeLeftInLayer,0);
            
            else
                highFidelityDuration = max(timeToTraining,0);
            end

            currentAgent.currentPortfolio(1,end-1) = highFidelityDuration;
        
        
            %Add time to aspiration if there is one (and it already has a non-0 time horizon); else add time to intermediate portfolio
            if any(currentAgent.currentPortfolio(end,1:numLayers)) && currentAgent.currentPortfolio(end,end-1) > 0
                currentAgent.currentPortfolio(end,end-1) = currentAgent.numPeriodsEvaluate - sum(currentAgent.currentPortfolio(1:end-1,end-1));
            elseif height(currentAgent.currentPortfolio) > 2
                currentAgent.currentPortfolio(end-1,end-1) = currentAgent.numPeriodsEvaluate - sum(currentAgent.currentPortfolio(end-2,end-1));
            else
                currentAgent.currentPortfolio(1,end-1) = currentAgent.numPeriodsEvaluate;
            end
        end

    end


    %Now repeat for the B other best portfolios the agent has stored in each of L locations 
    [sortedLocations, sortedIndex] = sortrows(currentAgent.bestPortfolioValues,-1);
    sortedIndex = sortedIndex(sortedLocations > 0);
    bestLocations = sortedIndex(1:min(length(sortedIndex),currentAgent.numBestLocation));

    if ~isempty(bestLocations)

        for indexL = 1:length(bestLocations)
            locationIndex = bestLocations(indexL);
            nextBest = currentAgent.bestPortfolios{locationIndex,1};
            if ~isempty(nextBest)
                focalPortfolio = nextBest(1,1:numLayers)';
                focalAspiration = false(1,numLayers);
                if nextBest(end,end) == 0
                    focalAspiration = nextBest(end,1:numLayers);  
                end
                indAspiration = find(focalAspiration);

                if any(selectableLayers' & focalAspiration)
                    [currentAgent.bestPortfolios{locationIndex}, backCastNum] = createPortfolio(focalAspiration, [],utilityVariables.utilityTimeConstraints, utilityVariables.utilityPrereqs, currentAgent.pAddFitElement, currentAgent.training, currentAgent.experience, utilityVariables.utilityAccessCosts, utilityVariables.utilityDuration, currentAgent.numPeriodsEvaluate, selectableLayers, [], currentAgent.wealth, backCastNum, utilityVariables.utilityAccessCodesMat, modelParameters);
                    %Adjust time of high-fidelity duration if new experience helps fulfill prereq
                else
                    %Ensure portfolio is not empty
                    if any(focalPortfolio)
    
                        %Identify any layers in currentPortfolio that are prereqs for aspiration
                        prereqs = j(i==indAspiration);
                        prereqs(prereqs == indAspiration) = [];
    
                        %Figure out time left on any prereqs
                        if any(prereqs)
                            currentAgent.bestPortfolios{locationIndex}(1,[prereqs']) = true;
                            timeToTraining = max(utilityVariables.utilityDuration(prereqs,1) - currentAgent.experience(prereqs));
                        else
                            timeToTraining = 0;
                        end
                        
                        %Figure out max time left in any time-bound layers
                        timeLeftInLayer = min(min(utilityVariables.utilityDuration(logical(focalPortfolio),2) - currentAgent.experience(logical(focalPortfolio))), currentAgent.numPeriodsEvaluate);
                    
                        if timeLeftInLayer < timeToTraining
                            highFidelityDuration = max(timeLeftInLayer,0);
                
                        else
                            highFidelityDuration = max(timeToTraining,0);
                        end
    
                        currentAgent.bestPortfolios{locationIndex,1}(1,end-1) = highFidelityDuration;
    
                        %Add time to aspiration if there is one (and it already has a non-0 time horizon); else add time to intermediate portfolio
                        if any(nextBest(end,1:numLayers)) && nextBest(end,end-1) > 0
                            currentAgent.bestPortfolios{locationIndex,1}(end,end-1) = currentAgent.numPeriodsEvaluate - sum(currentAgent.bestPortfolios{locationIndex,1}(1:end-1,end-1));
                        elseif height(nextBest) > 2
                            currentAgent.bestPortfolios{locationIndex,1}(end-1,end-1) = currentAgent.numPeriodsEvaluate - sum(currentAgent.bestPortfolios{locationIndex,1}(end-2,end-1));
                        else
                            currentAgent.bestPortfolios{locationIndex,1}(1,end-1) = currentAgent.numPeriodsEvaluate;
                        end
                    end
                end
            end
        end
    end
  end
end


