function [ currentAgent] = trainingTracker(currentAgent, utilityDuration)
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

%Add increment of 1 period experience for each layer in agent's current
%Portfolio
numLayers = size(utilityDuration,1);
currentPortfolio = currentAgent.currentPortfolio(1,1:numLayers)';

currentAgent.experience = currentAgent.experience + currentPortfolio;
%Check whether agent has achieved any new certifications
minLength = utilityDuration(:,1);
newCerts = find(currentAgent.experience >= minLength);
currentAgent.training(newCerts) = true;

end
