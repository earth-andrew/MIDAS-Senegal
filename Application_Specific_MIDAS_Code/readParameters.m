function [agentParameters, modelParameters, networkParameters, mapParameters] = readParameters(inputs)

%All model parameters go here
modelParameters.spinupTime = 10;
modelParameters.numAgents = 2000;
mapParameters.sizeX = 600;
mapParameters.sizeY = 600;
mapParameters.levelID = '_PCODE';
mapParameters.levelName = '_FR';
modelParameters.cycleLength = 4;
modelParameters.numCycles = 5;
modelParameters.incomeInterval = 1;
modelParameters.visualizeYN = 0;
modelParameters.listTimeStepYN = 1;
modelParameters.visualizeInterval = 2;
modelParameters.showMovesOrNetwork = 1; %1 for recent moves, 0 for network
modelParameters.movesFadeSteps = 12; 
modelParameters.edgeAlpha = 0.2; 
modelParameters.ageDecision = 15;
modelParameters.ageLearn = 10;
modelParameters.utility_k = 4.321; 
modelParameters.utility_m = 9.498; 
modelParameters.utility_noise = 0.05;
modelParameters.utility_iReturn = 0.264;
modelParameters.utility_iDiscount = 0.05;
modelParameters.utility_iYears = floor(0.5 * modelParameters.numCycles); %Check that this should be 1/2 of number of cycles
modelParameters.incomeDraw = randi(100);
modelParameters.testDev = 1;
modelParameters.income_levels = 3; %Number of income level per livelihood layer

%Randomize Utilities Flag
modelParameters.randomUtilitiesYN = 0; %1 to randomize utilities, 0 to take utilities from data
modelParameters.medianValuesYN = 1; %1 to work with median income parameters, 0 to work with random draws from distribution

%Aspirations Flag
modelParameters.aspirationsFlag = 1; %0 for no aspirations, 1 to enable aspirations

%Climate Parameters
modelParameters.climateFlag = 0; %1 to impose climate effects
modelParameters.agClimateEffect = 0.9; %Proportional income loss due to climate impact (0.45 drought; 0.9 saltwater)
modelParameters.nonAgClimateEffect = 0.276; %Proportional income loss due to climate impact in nonAg sectors (0.138 drought, 0.276 for saltwater)
modelParameters.climateStart = 30; %Time step at which climate effects start (30 for drought; 1 for saltwater)
modelParameters.climateLength = 20; %Duration of climate impact in timesteps
modelParameters.climateStop = modelParameters.climateStart + modelParameters.climateLength; %time step at which climate effects stop (50 for drought, 100 for saltwater)
modelParameters.agLayers = [1:12]; %Layers that are affected by ag climate impacts
modelParameters.nonAgLayers = [12:36]; %Layers affected by non-ag climate impacts
modelParameters.climateScenarioIndex = 1; %1 for Senegal River Drought, 2 for Saltwater Intrusion
%modelParameters.climateFile = './Data/SenegalRiverDroughtFile.csv';

%Ed Expansion Parameters
modelParameters.educationLayer = 37; %Layer index for post-secondary education
modelParameters.educationCost = 100000; 
modelParameters.educationStipend = 500000;
modelParameters.educationSlots4yr = 200; %Number of agents that can enroll in 4 yr ed at any time
modelParameters.educationSlotsVocational = 1000; %Number of agents that can enroll in vocational ed at any time
modelParameters.educationFile = 'Data/SenegalEducationProbability.csv'; %Location of existing institutions
modelParameters.edExpansionFlag = 0; %1 to specify education expansion
modelParameters.edExpansionStart = 1; %Time at which education expansion starts
modelParameters.edExpansionFile = 'Data/SenegalEducationExpansion.csv'; %Locations of expanded institutions
modelParameters.expansionSlots = modelParameters.educationSlotsVocational; %Number of additional slots to be created as a result of ed expansion policy
modelParameters.schoolLength = 16; %Number of time steps to complete post-secondary education


modelParameters.remitRate = 0;
modelParameters.creditMultiplier = 0.0316;
modelParameters.normalFloodMultiplier = 1;
modelParameters.ruralUrbanTime = 0.446; %Round 1: 0.15; %Proportion of time needed for transit between rural and urban layers of portfolio
modelParameters.movingCostPerMile = 91195; %Round 1: 5725
modelParameters.minDistForCost = 50;
modelParameters.maxDistForCost = 400;
networkParameters.networkDistanceSD = 7;
networkParameters.connectionsMean = 15; %Round 1: 8
networkParameters.connectionsSD = 0;
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
mapParameters.saveDirectory = 'Outputs/';

mapParameters.filePath = 'Data/SenegalBoundaryFilesAdmin2/Admin_2_Senegal.shp';
%mapParameters.filePath = '';

modelParameters.popFile = 'Data/Senegal_Population_Extract.csv';
modelParameters.survivalFile = 'Data/mortality_sen.xls';
modelParameters.fertilityFile = 'Data/fert_age_sen.xls';
modelParameters.agePreferencesFile = 'Data/age_specific_params.xls';
modelParameters.utilityDataPath = 'Data/';
modelParameters.saveImg = true;
modelParameters.shortName = 'Random_map_test';
agentParameters.currentID = 1;
agentParameters.incomeShareFractionMean = 0.664; %Round 1: 0.225
agentParameters.incomeShareFractionSD = 0;
agentParameters.shareCostThresholdMean = 0.3;
agentParameters.shareCostThresholdSD = 0;
agentParameters.wealthMean = 0;
agentParameters.wealthSD = 0;
agentParameters.interactMean = 0.8;
agentParameters.interactSD = 0;
agentParameters.meetNewMean = 0.1;
agentParameters.meetNewSD = 0;
agentParameters.probAddFitElementMean = 1.0;
agentParameters.probAddFitElementSD = 0;
agentParameters.randomLearnMean = 1;
agentParameters.randomLearnSD = 0;
agentParameters.randomLearnCountMean = 5;
agentParameters.randomLearnCountSD = 0;
agentParameters.chooseMean = 1.0;
agentParameters.chooseSD = 0;
agentParameters.knowledgeShareFracMean = 0.3;
agentParameters.knowledgeShareFracSD = 0;
agentParameters.bestLocationMean = 2;
agentParameters.bestLocationSD = 0;
agentParameters.bestPortfolioMean = 2;
agentParameters.bestPortfolioSD = 0;
agentParameters.randomLocationMean = 2;
agentParameters.randomLocationSD = 0;
agentParameters.randomPortfolioMean = 1;
agentParameters.randomPortfolioSD = 0;
agentParameters.bestPortfolioAspirationsMean = 2;
agentParameters.bestPortfolioAspirationsSD = 0;
agentParameters.numPeriodsEvaluateMean = 28;
agentParameters.numPeriodsEvaluateSD = 0;
agentParameters.numPeriodsMemoryMean = 20; %Round 1: 22
agentParameters.numPeriodsMemorySD = 0;
agentParameters.discountRateMean = 0.494; %Round 1: 0.24
agentParameters.discountRateSD = 0;
agentParameters.rValueMean = 0.85;
agentParameters.rValueSD = 0.2;
agentParameters.bListMean = 0.5;
agentParameters.bListSD = 0.2;
agentParameters.prospectLossMean = 3.2746;
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

