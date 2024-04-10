function [ utilityLayerFunctions, utilityHistory, utilityAccessCosts, utilityTimeConstraints, utilityDuration, utilityAccessCodesMat, utilityPrereqs, utilityBaseLayers, utilityForms, incomeForms, nExpected, hardSlotCountYN ] = createUtilityLayers(locations, modelParameters, demographicVariables )
%createUtilityLayers defines the different income/utility layers (and the
%functions that generate them)

%utility layers are described in this model by:
% 
% i) a function used to generate a utility value, utilityLayerFunctions
% ii) a set of particular codes corresponding to access requirements to use 
% this layer, utilityAccessCodesMat
% iii) a vector of costs associated with each of those codes,
% utilityAccessCosts, and
% iv) a time constraint explaining the fraction of an agent's time consumed 
% by accessing that particular layer, utilityTimeConstraints

% additionally, the estimation of utility is likely to require in most
% applications:
%
% v) a 'base' trajectory for each utility layer over time, that is modified
% by the utility function, utilityBaseLayers
% vi) a stored value of the realized utility value at each point in time
% and space, utilityHistory
% vii) a relationship matrix describing which layers must previously have
% been accessed in order to access a layer, utilityPrereqs
% viii) an identification of the expected occupancy of the layer for which
% utility levels are defined, nExpected
% ix) a flag for whether the expected number can be exceeded or not,
% hardSlotCountYN
% x) a flag differentiating the form of utility generated (against which
% agents may have heterogeneous preferences), utilityForm
% xi) a binary version of the above identifying income as a utility form
% xii) A selectable logical array indicating which utility layers can be
% selected by agent in time t (e.g. whether agents have met pre-reqs and
% sufficient funds)

%all of these variables are generated here.

%CHECK HOW MEAN VALUES IS CALCULATED - DO THESE REPRESENT MEANS OVER TIME
%(AS THEY SHOULD) AND ARE THEY GREATER THAN COSTS?

%load([modelParameters.utilityDataPath '/utility_base_layers.mat'])
load([modelParameters.utilityDataPath '/SenegalIncomeData.mat'])

%other things to port in or define:
noise = modelParameters.utility_noise;
iReturn = modelParameters.utility_iReturn;
iDiscount = modelParameters.utility_iDiscount;
iYears = modelParameters.utility_iYears;
utility_levels = 1;
utility_layers = table2array(orderedTable);
numLocations = size(utility_layers,1);
utility_layers = [utility_layers zeros(numLocations,1) zeros(numLocations,1)]; %Add 2 additional income layers for education - rural/urban

%%%%%%%%%%%%%%%%%%%%%%%
%%utilityLayerFunctions
%%%%%%%%%%%%%%%%%%%%%%%
%in the sample below, individual layer functions are defined as anonymous functions
%of x, y, t (timestep), and n (number of agents occupying the layer).  any
%additional arguments can be fed by varargin.  the key constraint of the
%anonymous function is that whatever is input must be executable in a
%single line of code - if the structure for the layer is more complicated,
%one must either export some of the calculation to an intermediate variable
%that can be fed to a single-line version of the layer function OR revisit
%this anonymous function structure.

utilityLayerFunctions = [];
for indexI = 1:(size(utility_layers,2))  %6  incomesources * rural/urban categories for each 
    utilityLayerFunctions{indexI,1} = @(k,m,nExpected,n_actual, base) base * (m * nExpected) / (max(0, n_actual - m * nExpected) * k + m * nExpected);   %some income layer - base layer input times density-dependent extinction
end


%%%%%%%%%%%%%%%%%%%%%%%
%%utilityHistory
%%%%%%%%%%%%%%%%%%%%%%%
leadTime = modelParameters.spinupTime;
timeSteps = modelParameters.numCycles * modelParameters.cycleLength; 
utilityHistory = zeros(height(locations),height(utilityLayerFunctions),timeSteps+leadTime);

%%%%%%%%%%%%%%%%%%%%%%%
%%utilityBaseLayers
%%%%%%%%%%%%%%%%%%%%%%%

%utilityBaseLayers has dimensions of (location, activity, time)



localOnly = [1; ... %ag-aqua rural
    1; %ag-aqua urban
    1; ... %livestock rural
    1; %livestock urban
    0; ... %professional rural
    0; %professional urban
    0; ... %services rural
    0; %services urban
    1; ... %small business rural
    1; %small business urban
    1; ... %trades rural
    1; %trades urban
    0; ... %education rural
    0; %education urban
];


timeQs =[0 .5 .5 0; ... %ag-aqua rural
     0 .5 .5 0; %ag-aqua urban
    .5 0 0 0; ... %livestock rural
    .5 0 0 0; %livestock urban
    .75 .75 .75 .75; ... %professional rural
    .75 .75 .75 .75; %professional urban
    .5 .5 .5 .5; ... %services rural
    .5 .5 .5 .5; %services urban
    .5 .5 .5 .5; ... %small business rural
    .5 .5 .5 .5; %small business urban
    .5 .5 .5 .5; ... %trades rural
    .5 .5 .5 .5; %trades urban
    .75 .75 .75 .75; %education rural
    .75 .75 .75 .75];  %education urban


incomeQs =[0 0 0 1; ... %ag-aqua rural
    0 0 0 1; %ag-aqua urban
    0 0 1 0; ... %livestock rural
    0 0 1 0; %livestock urban
    1 1 1 1; ... %professional rural
    1 1 1 1; %professional urban
    1 1 1 1; ... %services rural
    1 1 1 1; %services urban
    1 1 1 1; ... %small businesses rural
    1 1 1 1; %small business urban
    1 1 1 1; ... %trades rural
    1 1 1 1; %trades urban
    1 1 1 1; %education rural
    1 1 1 1];  %education urban

% N x 2 Matrix specifying the [minimum, maximum] number of cycles that each layer entails

utilityDuration = [8 inf; %ag-aqua rural
    8 inf; %ag-aqua urban
    16 inf; %livestock rural
    16 inf; %livestock urban
    12 inf; %professional rural
    12 inf; %professional urban
    8 inf;  %services rural
    8 inf; %services urban
    8 inf; %small business rural
    8 inf; %small business urban
    4 inf; %trades rural
    4 inf; %trades urban
    modelParameters.schoolLength modelParameters.schoolLength %education rural
    modelParameters.schoolLength modelParameters.schoolLength]; %education urban


quarterShare = incomeQs ./ (sum(incomeQs,2));
utilityBaseLayers = ones(height(locations),height(utilityLayerFunctions),timeSteps);

%Read in table of climate-affected locations
climateTable = readtable(modelParameters.climateFile);
climateLocations = climateTable.MIDASIndex; %List of indices for locations affected by climate

for indexI = 1:modelParameters.cycleLength:size(utilityBaseLayers,3)
    if modelParameters.randomUtilitiesYN == 1
        utilityBaseLayers(:,:,indexI) = 1100000 * rand();
    else
    
        utilityBaseLayers(:,:,indexI) = utility_layers;
    
        if modelParameters.climateFlag == 1
            %For timespans within climate event period, adjust income for given
            %locations
            if ge(indexI, modelParameters.climateStart) && le(indexI, modelParameters.climateStop)
                %utilityBaseLayers(climateLocations, modelParameters.climateLayers,indexI) = utilityBaseLayers(climateLocations,modelParameters.climateLayers,indexI) .* (1 - (1 - modelParameters.climateEffect) .* (indexI - modelParameters.climateStart) / (modelParameters.climateStop - modelParameters.climateStart)) ;
                utilityBaseLayers(climateLocations, modelParameters.climateLayers,indexI) = utilityBaseLayers(climateLocations,modelParameters.climateLayers,indexI) .* 0;
            end
            
        end
    end
end



for indexI = 1:size(utilityBaseLayers,1)
    for indexJ = 1:size(utilityBaseLayers,2)
        temp_2 = zeros(size(utilityBaseLayers,3),1);
        for indexM = 1:modelParameters.cycleLength:size(utilityBaseLayers,3)
            temp_2(indexM:indexM + modelParameters.cycleLength - 1) = utilityBaseLayers(indexI,indexJ,indexM) * quarterShare(ceil(indexJ/utility_levels),:);
        end
        utilityBaseLayers(indexI,indexJ,:) = temp_2;
    end
end

%now add some lead time for agents to learn before time actually starts
%moving
utilityBaseLayers(:,:,leadTime+1:leadTime+timeSteps) = utilityBaseLayers;

for indexI = leadTime:-1:1
   utilityBaseLayers(:,:,indexI) = utilityBaseLayers(:,:,indexI+modelParameters.cycleLength); 
end



%Converting any NaN's to 0
utilityBaseLayers(isnan(utilityBaseLayers)) = 0;

%%%%%%%%%%%%%%%%%%%%%%%
%%utilityAccessCosts and utilityAccessCodesMat
%%%%%%%%%%%%%%%%%%%%%%%
%define the cost of access for utility layers ... payments may provide
%access to different locations (i.e., a license within a state or country)
%or to different layers (i.e., training and certification in related
%fields, or capital investment in related tools, etc.)  

%utilityAccessCosts Dimensions: n x 2, where n is the number of different costs, and the 2
%columns are for the ID and the value

%utilityAccessCodesMat Dimensions: n x m x k, where n is the number of different costs, m is the
%number of different utility layers, and k is the number of locations

%estimate costs for access, such that the expected ROI is i +/- noise, given discount
%rate j, assuming average value over time from incomeMean and estimating
%marginal increase moving from one quartile to the next.  for assets, these
%values are place-specific.  for qualifications, average the costs over the
%appropriate domain
accessCodeCount = 1;
numCodes = sum(localOnly) * utility_levels * size(locations,1) + sum(~localOnly) * utility_levels;

utilityAccessCodesMat = false(numCodes,height(utilityLayerFunctions),height(locations));
utilityAccessCosts = [];
for indexI = 1:height(localOnly)
   if(localOnly(indexI))
        %meanValues = mean(utilityBaseLayers(:,(indexI-1)*utility_levels+1:indexI*utility_levels,:,:),3);
        meanValues = mean(utilityBaseLayers(:,indexI,:),3);
        accessCost = meanValues / (1 + iReturn) * ((1+iDiscount)^iYears -1) / iDiscount / ((1 + iDiscount)^iYears);  %using Capital Cost Recovery Factor to estimate access cost
        for indexJ = 1:utility_levels
           utilityAccessCosts = [utilityAccessCosts; [(accessCodeCount:accessCodeCount + height(locations)-1)' accessCost(:,indexJ)]];   
           for indexK = 1:height(locations)
               utilityAccessCodesMat(accessCodeCount, (indexI-1)*utility_levels+indexJ, indexK) = 1;
               accessCodeCount = accessCodeCount + 1;
           end
        end       
   else
        %meanValues = mean(mean(utilityBaseLayers(:,(indexI-1)*utility_levels+1:indexI*utility_levels,:,:),3),1);
        meanValues = mean(mean(utilityBaseLayers(:,indexI,:),3),1);
        accessCost = meanValues / (1 + iReturn) * ((1+iDiscount)^iYears -1) / iDiscount / ((1 + iDiscount)^iYears);
        for indexJ = 1:utility_levels
           utilityAccessCosts = [utilityAccessCosts; [(accessCodeCount+1) accessCost(indexJ)]];   
           utilityAccessCodesMat(accessCodeCount,(indexI-1)*utility_levels+indexJ,:) = 1;
           accessCodeCount = accessCodeCount + 1;
        end
   end
end


%%%%%%%%%%%%%%%%%
%nExpected
%%%%%%%%%%%%%%%%%
%in some way, estimate the number of agents you expect to be occupying a
%particular slot, as well as whether there are a fixed number of slots
%(i.e., jobs) or not (i.e., free entry to that layer).  By default these
%are all set to 0

locationProb = demographicVariables.locationLikelihood;
locationProb(2:end) = locationProb(2:end) - locationProb(1:end-1);
numAgentsModel = locationProb * modelParameters.numAgents;

%utility_layers_prop gives the proportion of agents who would occupy each
%layer, so this one is a simple multiplication.  first 15 of 30 layers are
%'jobs' with fixed slots available, last 15 of 30 are small enterprises
%without fixed slots

%FIX PROPORTIONS FOR UTILITY_LAYERS_PROP (FOR NOW JUST SET TO
%UTILITY_LAYERS. AND CHECK HARDSLOTCOUNT

%nExpected =  (numAgentsModel*ones(1,size(utility_layers_prop,2))) .* utility_layers_prop;

%Set nExpected as a function of place AND time
nExpected = zeros(size(numAgentsModel,1),size(utility_layers,2),(leadTime + timeSteps));
nExpected = numAgentsModel .* ones(1,size(utility_layers,2),(leadTime + timeSteps));

%Add Education-specific proportions
edTable = readtable(modelParameters.educationFile);

%First set education slots to 0 for all regions and time slots
nExpected(:,13:14,:) = numAgentsModel .* zeros(1,2,(leadTime + timeSteps));

%Then create ed slots by multiply education propotion * total ed slots * 0.5 to distribute between rural and urban layers
nExpected(edTable.locationIndex,13:14,:) = (edTable.educationProbability .* modelParameters.educationSlots .* 0.5) .* ones(1,2,(leadTime + timeSteps));

%Now adjust for education expansion scenario if specified
if modelParameters.edExpansionFlag == 1
    expansionTable = readtable(modelParameters.edExpansionFile);
    nExpected(expansionTable.locationIndex,13:14,(leadTime + modelParameters.edExpansionStart):end) = nExpected(expansionTable.locationIndex,13:14,(leadTime + 1)) + expansionTable.educationProbability .* modelParameters.expansionSlots .* 0.5 .* ones(1,2,(timeSteps + 1 - modelParameters.edExpansionStart)); %Distributing additional slots by geographic location 
end

hardSlotCountYN = false(size(nExpected,1:2));
%Set hard slots for educational opportunities
hardSlotCountYN(:,13:14) = true;

%utility layers may be income, use value, etc.  identify what form of
%utility it is, so that they get added and weighted appropriately in
%calculation.  BY DEFAULT, '1' is income.  THE NUMBER IN UTILITY FORMS
%CORRESPONDS WITH THE ELEMENT IN THE AGENT'S B LIST.
utilityForms = zeros(height(utilityLayerFunctions),1);

%Utility form values correspond to the list of utility coefficients in
%agent utility functions (i.e., numbered 1 to n) ... in null case, all are
%income (same coefficient)
utilityForms(1:height(utilityLayerFunctions)) = 1;

%Income form is either 0 or 1 (with 1 meaning income)
incomeForms = utilityForms == 1;


%utilityTimeConstraints: n x (k+1) where n is number of layers and k number of periods in cycle
% specify the fraction of time for each period in a cycle that a layer
%consumes (this example using a year with 4 periods)
%utilityTimeConstraints = ...
%    [1 0.5 0.25 0.25 0.5; %accessing layer 1 is a 25% FTE commitment
%    2 0.5 0.25 0.25 0.5; %accessing layer 2 is a 50% FTE commitment
%    3 0.5 0.75 0.75 0]; %accessing layer 3 is a 50% FTE commitment

utilityTimeConstraints = [];
for indexI = 1:size(timeQs,1)
    utilityTimeConstraints = [utilityTimeConstraints; ...
        ones(utility_levels,1) * timeQs(indexI,:)];
end
utilityTimeConstraints = [(1:size(utilityTimeConstraints,1))' utilityTimeConstraints];

%define linkages between layers (such as where different layers represent
%progressive investment in a particular line of utility (e.g., farmland)
utilityPrereqs = zeros(size(utilityTimeConstraints,1));

%for now, no prereqs, but can apply the below code if we want to link 1st
%through 5th (for example) layers in farming, livestock, etc., to capture
%the idea of simply growing the enterprise

%let the 2nd Quartile require the 1st, the 3rd require 2nd and 1st, and 4th
%require 1st, 2nd, and 3rd for every layer source
% for indexI = 4:4:size(utilityTimeConstraints,1)
%    utilityPrereqs(indexI, indexI-3:indexI-1) = 1; 
%    utilityPrereqs(indexI-1, indexI-3:indexI-2) = 1; 
%    utilityPrereqs(indexI-2, indexI-3) = 1; 
% end


%in the form utilityPrereqs('this layer' , 'requires this layer') = 1;
%utilityPrereqs(2, 1) = 0; %unskilled 2 requires unskilled 1
%utilityPrereqs(5, 4) = 0; %ag 2 requires ag 1
%utilityPrereqs(3, 6) = 1; %skilled labor requires school

utilityPrereqs(3,1) = 1; %Livestock in rural space requires ag in rural space
utilityPrereqs(4,2) = 1; %Livestock in urban space requires ag in urban space
utilityPrereqs(5,13) = 1; %Professional work in rural or urban space requires education in rural or urban setting
utilityPrereqs(5,14) = 1;
utilityPrereqs(6,13) = 1;
utilityPrereqs(6,14) = 1;
utilityPrereqs(7,13) = 1; %Services requires education in rural or urban setting
utilityPrereqs(7,14) = 1;
utilityPrereqs(8,13) = 1;
utilityPrereqs(8,14) = 1;
utilityPrereqs(9,13) = 1; %small business require education
utilityPrereqs(9,14) = 1; 
utilityPrereqs(10,13) = 1;
utilityPrereqs(10,14) = 1;
utilityPrereqs(11,13) = 1; %trades require education
utilityPrereqs(11,14) = 1; 
utilityPrereqs(12,13) = 1;
utilityPrereqs(12,14) = 1;



%each layer 'requires' itself
utilityPrereqs = utilityPrereqs + eye(size(utilityTimeConstraints,1));
utilityPrereqs = sparse(utilityPrereqs);

%with these linkages in place, need to account for the fact that in the
%model, any agent occupying Q4 of something will automatically occupy Q1,
%Q2, Q3, but at present the values nExpected don't account for this.  Thus,
%nExpected for Q1 needs to add in Q2-4, for Q2 needs to add in Q3-4, etc.
%More generally, all 'expected' values need to be adjusted up to allow for
%all things that rely on them.  This is because of a difference between how
%the model interprets layers (occupying Q4 means occupying Q4 + all
%pre-requisites) and the input data (occupying Q4 means only occupying Q4)

%tempExpected = zeros(size(nExpected));
%for indexI = 1:size(nExpected,2)
   %tempExpected(:,indexI) = sum(nExpected(:,utilityPrereqs(:,indexI) > 0),2); 
%end
%nExpected = tempExpected

%%% OTHER EXAMPLE CODE BELOW HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
