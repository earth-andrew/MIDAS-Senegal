function [ agentList ] = assignInitialLayers( agentList, utilityVariables, currentT, modelParameters )
%assignInitialLayers initializes who is doing what at the start of the
%simulation

numLayers = size(utilityVariables.utilityDuration,1);

%Flag for whether the randomly-generated portfolio is backcasted
backCastCount = 0;

for indexA = 1:length(agentList)
    currentAgent = agentList(indexA);
   %some basic temporary code to initialize layers.  ideally this initial
   %distribution is informed by census data or other.  note that layers
   %that agents' access code profile should be updated to capture their
   %respective initial state, though i haven't done that here.

   
   currentAgent.currentPortfolio = false(size(utilityVariables.utilityLayerFunctions,1),1); 
   currentAgent.currentAspiration = false(size(utilityVariables.utilityLayerFunctions,1),1);

   %randomly assign a couple of the initial base layers
   selectable = true(size(utilityVariables.utilityBaseLayers,2),1); %Initially, allow agent to access all layers
   [restrictedLayers,~] = find(utilityVariables.utilityRestrictions(:,currentAgent.layerFlag) == 0);
   selectable(restrictedLayers) = 0;
   [portfolioSet, backCastCount] = createPortfolio([], find(selectable), utilityVariables.utilityTimeConstraints, utilityVariables.utilityPrereqs, currentAgent.pAddFitElement, currentAgent.training, currentAgent.experience, currentAgent.layerFlag, utilityVariables.utilityAccessCosts, utilityVariables.utilityRestrictions, utilityVariables.utilityDuration, currentAgent.numPeriodsEvaluate, selectable, utilityVariables.utilityHistory, currentAgent.wealth, backCastCount, utilityVariables.utilityAccessCodesMat, modelParameters);
   currentAgent.currentPortfolio = logical(portfolioSet(1,1:size(utilityVariables.utilityHistory,2)));
   if portfolioSet(end,end) == 0
       currentAgent.currentAspiration = logical(portfolioSet(end,1:size(utilityVariables.utilityHistory,2)));
   end
   
   currentAgent.currentFidelity = portfolioSet(1,end-1);
   
   currentAgent.accessCodesPaid(any(utilityVariables.utilityAccessCodesMat(:,currentAgent.currentPortfolio(1,1:numLayers)', currentAgent.matrixLocation),2)) = true;
   
   currentAgent.firstPortfolio = currentAgent.currentPortfolio;
   
   currentAgent = trainingTracker(currentAgent, utilityVariables, modelParameters, backCastCount, currentT);
   currentAgent.agentPortfolioHistory{currentT} = currentAgent.currentPortfolio;
   currentAgent.agentAspirationHistory{currentT} = currentAgent.currentAspiration;
   currentAgent.backCastProportion(currentT) = backCastCount; %Since only 1 portfolio is randomly generated, this is either 0 or 1
end