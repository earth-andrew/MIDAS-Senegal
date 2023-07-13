function [agentParameters, modelParameters, networkParameters, mapParameters] = readParameters(inputs)

%All model parameters go here
modelParameters.spinupTime = 10;
modelParameters.numAgents = 2000;
mapParameters.sizeX = 600;
mapParameters.sizeY = 600;
mapParameters.levelID = '_PCODE';
mapParameters.levelName = '_FR';
modelParameters.cycleLength = 4;
modelParameters.numCycles = 40;
modelParameters.incomeInterval = 1;
modelParameters.visualizeYN = 1;
modelParameters.listTimeStepYN = 1;
modelParameters.visualizeInterval = 2;
modelParameters.showMovesOrNetwork = 1; %1 for recent moves, 0 for network
modelParameters.movesFadeSteps = 12; 
modelParameters.edgeAlpha = 0.2; 
modelParameters.ageDecision = 15;
modelParameters.ageLearn = 10;
modelParameters.utility_k = 0;
modelParameters.utility_m = 1;
modelParameters.utility_noise = 0.05;
modelParameters.utility_iReturn = 0.05;
modelParameters.utility_iDiscount = 0.05;
modelParameters.utility_iYears = 20;
modelParameters.educationCost = 0;
modelParameters.largeFarmCost = 400;
modelParameters.smallFarmCost = 100;
modelParameters.skilledUtility = 100;
modelParameters.ag2Utility = 30;
modelParameters.skilledUtility = 100;
modelParameters.unskilled1Utility = 10;
modelParameters.remitRate = 0;
modelParameters.creditMultiplier = 0.3;
modelParameters.normalFloodMultiplier = 1;
mapParameters.movingCostPerMile = 0;
mapParameters.minDistForCost = 50;
mapParameters.maxDistForCost = 400;
networkParameters.networkDistanceSD = 7;
networkParameters.connectionsMean = 2;
networkParameters.connectionsSD = 2;
networkParameters.agentPreAllocation = modelParameters.numAgents * 3;
networkParameters.nonZeroPreAllocation = networkParameters.agentPreAllocation * 10;
networkParameters.weightLocation = 3;
networkParameters.weightNetworkLink = 5;
networkParameters.weightSameLayer = 3;
networkParameters.distancePolynomial = 0.0002;
networkParameters.decayPerStep = 0.002;
networkParameters.interactBump = 0.01;
networkParameters.shareBump = 0.001;
mapParameters.degToRad = 0.0174533;
mapParameters.milesPerDeg = 69; %use for estimating actual distances in distance Matrix
mapParameters.density = 60; %pixels per degree Lat/Long, if using .shp input
mapParameters.colorSpacing = 20;
mapParameters.numDivisionMean = [2 8 9];
mapParameters.numDivisionSD = [0 2 1];
mapParameters.position = [300 100 600 600];
modelParameters.samplePortfolios = 100; %Number of example portfolios to create average utility for each aspirational layer
mapParameters.r1 = []; %this will be the spatial reference if we are pulling from a shape file
mapParameters.saveDirectory = './Outputs/';

mapParameters.filePath = './Data/Senegal Boundary Files Admin 2/Admin_2_lat_lon.shp';
modelParameters.popFile = './Data/senegal_population_extract.xls';
modelParameters.survivalFile = './Data/mortality_sen.xls';
modelParameters.fertilityFile = './Data/fert_age_sen.xls';


mapParameters.filePath = []; %'./Data/Senegal Boundary Files Admin 2/Admin_2_lat_lon.shp';
modelParameters.popFile = []; %'./Data/senegal_population_extract.xls';
modelParameters.survivalFile = []; %'./Data/mortality_sen.xls';
modelParameters.fertilityFile = []; %'./Data/fert_age_sen.xls';


modelParameters.agePreferencesFile = './Data/age_specific_params.xls';
modelParameters.utilityDataPath = './Data';
modelParameters.saveImg = true;
modelParameters.shortName = 'Random_map_test';
agentParameters.currentID = 1;
agentParameters.incomeShareFractionMean = 0.4;
agentParameters.incomeShareFractionSD = 0;
agentParameters.shareCostThresholdMean = 0.3;
agentParameters.shareCostThresholdSD = 0;
agentParameters.wealthMean = 0;
agentParameters.wealthSD = 0;
agentParameters.interactMean = 0.8;
agentParameters.interactSD = 0;
agentParameters.meetNewMean = 0.1;
agentParameters.meetNewSD = 0;
agentParameters.probAddFitElementMean = 0.4;
agentParameters.probAddFitElementSD = 0;
agentParameters.randomLearnMean = 1;
agentParameters.randomLearnSD = 0;
agentParameters.randomLearnCountMean = 5;
agentParameters.randomLearnCountSD = 0;
agentParameters.chooseMean = 1.0;
agentParameters.chooseSD = 0;
agentParameters.backCastMean = 0.0;
agentParameters.backCastSD = 0;
agentParameters.knowledgeShareFracMean = 0.3;
agentParameters.knowledgeShareFracSD = 0;
agentParameters.bestLocationMean = 2;
agentParameters.bestLocationSD = 0;
agentParameters.bestPortfolioMean = 5;
agentParameters.bestPortfolioSD = 0;
agentParameters.randomLocationMean = 2;
agentParameters.randomLocationSD = 0;
agentParameters.randomPortfolioMean = 2;
agentParameters.randomPortfolioSD = 0;
agentParameters.bestPortfolioAspirationsMean = 2;
agentParameters.bestPortfolioAspirationsSD = 0;
agentParameters.numPeriodsEvaluateMean = 40;
agentParameters.numPeriodsEvaluateSD = 0;
agentParameters.numPeriodsMemoryMean = 40;
agentParameters.numPeriodsMemorySD = 0;
agentParameters.discountRateMean = 0.04;
agentParameters.discountRateSD = 0;
agentParameters.rValueMean = 0.85;
agentParameters.rValueSD = 0.2;
agentParameters.bListMean = 0.5;
agentParameters.bListSD = 0.2;
agentParameters.prospectLossMean = 2;
agentParameters.prospectLossSD = 0;
agentParameters.informedExpectedProbJoinLayerMean = 1;
agentParameters.informedExpectedProbJoinLayerSD = 0;
agentParameters.uninformedMaxExpectedProbJoinLayerMean = 0.4;
agentParameters.uninformedMaxExpectedProbJoinLayerSD = 0;
agentParameters.expectationDecayMean = 0.1;
agentParameters.expectationDecaySD = 0;

%override any input variables. 'inputs' should be a dataset with two columns,
%one with the parameter name and one with the value
if(~isempty(inputs))
   for indexI = 1:size(inputs,1)
       eval([inputs.parameterNames{indexI} ' = ' num2str(inputs.parameterValues(indexI)) ';']);
   end
end

modelParameters.timeSteps = modelParameters.spinupTime + modelParameters.numCycles * modelParameters.cycleLength;  %in this particular experiment only, there are 204 time steps with data


end

