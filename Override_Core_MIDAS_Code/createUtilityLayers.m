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

%all of these variables are generated here.

mean_utility_by_layer = [10; ... %unskilled 1
    20; ... %unskilled 2
    60; ... %skilled
    10; ... %ag 1
    30; ... %ag 2
    0; ... %school
];

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
for indexI = 1:(size(mean_utility_by_layer,1))  %16 (or 13) different sources, with 4 levels
    utilityLayerFunctions{indexI,1} = @(k,m,nExpected,n_actual, base) base * (m * nExpected) / (max(0, n_actual - m * nExpected) * k + m * nExpected);   %some income layer - base layer input times density-dependent extinction
end

%%%%%%%%%%%%%%%%%%%%%%%
%%utilityHistory
%%%%%%%%%%%%%%%%%%%%%%%
leadTime = modelParameters.spinupTime;
timeSteps = modelParameters.numCycles * modelParameters.cycleLength; 
utilityHistory = zeros(size(locations,1),size(utilityLayerFunctions,1),timeSteps+leadTime);

%%%%%%%%%%%%%%%%%%%%%%%
%%utilityBaseLayers
%%%%%%%%%%%%%%%%%%%%%%%

%utilityBaseLayers has dimensions of (location, activity, time)


localOnly = [0; ... %unskilled 1
    0; ... %unskilled 2
    0; ... %skilled
    1; ... %ag 1
    1; ... %ag 2
    0; ... %school
];

timeQs =[0.5 0.5 0.5 0.5; ... %unskilled 1
    0.5 0.5 0.5 0.5; ... %unskilled 2
    0.75 0.75 0.75 0.75; ... %skilled
    0.0 0.5 0.5 0; ... %ag 1 
    0.0 0.1 0.1 0; ... %ag 2
    0.5 0.5 0.5 0.5; ... %school
];

incomeQs =[1 1 1 1; ... %unskilled 1
    1 1 1 1; ... %unskilled 2
    1 1 1 1; ... %skilled
    0 0 0 1; ... %ag 1 %Initial 0 0 0 1
    0 0 0 1; ... %ag 2 %Initial 0 0 0 1
    0 0 0 0];  %school

%Array specifying the minimum number of cycles that each layer entails
utilityDuration = [4; %unskilled 1
    4; %unskilled 2
    12; %skilled
    4; %ag 1
    4; %ag 2
    16; %school
    ];

quarterShare = incomeQs ./ (sum(incomeQs,2));
quarterShare(isnan(quarterShare)) = 0;

utilityBaseLayers = ones(size(locations,1),size(utilityLayerFunctions,1),timeSteps);

%Adjustment factor for creating spatial variation
epsilon = 0.0; %proportion of total income that may vary across regions
climate_epsilon = 0.3; %proportion of total income that may vary across years
for indexK = 1:size(locations,1)
    for indexI = 1:modelParameters.cycleLength:size(utilityBaseLayers,3)
        %utilityBaseLayers(indexK,:,indexI) = mean_utility_by_layer;
        for indexJ = 1:size(mean_utility_by_layer,1)
            if 3 < indexJ < 6
                utilityBaseLayers(indexK,indexJ,indexI) = mean_utility_by_layer(indexJ,1) * (1 + epsilon * (-1 + 2 * rand(1))) * (1 + climate_epsilon * (-1 + 2 * rand(1)));
            else
                utilityBaseLayers(indexK,indexJ,indexI) = mean_utility_by_layer(indexJ,1);
            end
        end
        
    end
end

for indexI = 1:size(utilityBaseLayers,1)
    for indexJ = 1:size(utilityBaseLayers,2)
        temp_2 = zeros(size(utilityBaseLayers,3),1);
        for indexM = 1:modelParameters.cycleLength:size(utilityBaseLayers,3)
            temp_2(indexM:indexM + modelParameters.cycleLength - 1) = utilityBaseLayers(indexI,indexJ,indexM) * quarterShare(indexJ,:);
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

utilityAccessCosts = [ ...
    1 1000; %cost of buying small farm %original 1000
    2 4000; %cost of growing to a large farm %original 4000
    3 5000; %cost of going to school %original 5000
    ];

utilityAccessCodesMat = zeros(size(utilityAccessCosts,1), size(mean_utility_by_layer,1), size(locations,1));
utilityAccessCodesMat(1,4,:) = 1;
utilityAccessCodesMat(2,5,:) = 1;
utilityAccessCodesMat(3,6,:) = 1;

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

nExpected =  zeros(size(locations,1),size(mean_utility_by_layer,1));

%let initial occupation be about 40% in unskilled 1, 15% in unskilled 2,
%and 5% in skilled; 40% in ag 1, 20% in ag 2, and 10% in school.
nExpected(:,1) = floor(numAgentsModel * 0.4);
nExpected(:,2) = floor(numAgentsModel * 0.15);
nExpected(:,3) = floor(numAgentsModel * 0.05);
nExpected(:,4) = floor(numAgentsModel * 0.4);
nExpected(:,5) = floor(numAgentsModel * 0.2);
nExpected(:,6) = floor(numAgentsModel * 0.1);

hardSlotCountYN = false(size(nExpected));
hardSlotCountYN(:,3) = true;  %skilled labor opportunities represent fixed job opportunities
hardSlotCountYN(:,6) = true;  %schools have fixed numbers of seats available

%utility layers may be income, use value, etc.  identify what form of
%utility it is, so that they get added and weighted appropriately in
%calculation.  BY DEFAULT, '1' is income.  THE NUMBER IN UTILITY FORMS
%CORRESPONDS WITH THE ELEMENT IN THE AGENT'S B LIST.
utilityForms = zeros(length(utilityLayerFunctions),1);

%Utility form values correspond to the list of utility coefficients in
%agent utility functions (i.e., numbered 1 to n) ... in null case, all are
%income (same coefficient)
utilityForms(1:length(utilityLayerFunctions)) = 1;

%Income form is either 0 or 1 (with 1 meaning income)
incomeForms = utilityForms == 1;


%utilityTimeConstraints: n x (k+1) where n is number of layers and k number of periods in cycle
% specify the fraction of time for each period in a cycle that a layer
%consumes (this example using a year with 4 periods)
%utilityTimeConstraints = ...
%    [1 0.5 0.25 0.25 0.5; %accessing layer 1 is a 25% FTE commitment
%    2 0.5 0.25 0.25 0.5; %accessing layer 2 is a 50% FTE commitment
%    3 0.5 0.75 0.75 0]; %accessing layer 3 is a 50% FTE commitment

utilityTimeConstraints = [(1:size(timeQs,1))' timeQs];

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
utilityPrereqs(2, 1) = 0; %unskilled 2 requires unskilled 1
utilityPrereqs(5, 4) = 0; %ag 2 requires ag 1
utilityPrereqs(3, 6) = 0; %skilled labor requires school



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
tempExpected = zeros(size(nExpected));

for indexI = 1:size(nExpected,2)
   tempExpected(:,indexI) = sum(nExpected(:,utilityPrereqs(:,indexI) > 0),2); 
end
nExpected = tempExpected;




%%% OTHER EXAMPLE CODE BELOW HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
