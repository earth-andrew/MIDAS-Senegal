function plotEdHistogram()
%Function that plots histogram of agents by years (periods) of educational
%experience

load SenegalBaseCase_MedianRun0_28-Mar-2024_17-18-21.mat
baseOutput = output;

numAgents = size(baseOutput.agentSummary,1);
agentEdExperience = zeros(numAgents,1);

for indexA = 1:numAgents
    agentEdExperience(indexA,1) = max(baseOutput.agentSummary.experience{indexA,1}(13:14));
end

%Convert from periods to years
agentEdExperience = agentEdExperience ./ 4;

%Set edges by year
edges = [0:0.5:4]

h = histogram(agentEdExperience, edges, 'Normalization', 'probability')
ax = gca;
ax.FontSize = 16;
xlabel('Years of Educational Experience', 'FontSize',16)
ylabel('Proportion of Agents', 'FontSize', 16)


end