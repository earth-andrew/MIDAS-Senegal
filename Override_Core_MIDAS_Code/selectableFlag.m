function selectable = selectableFlag(prereqs, accesscodes, utilityCosts, agentTraining, agentExperience, agentPortfolio, agentWealth, maxDuration)
%Script to identify layers as "selectable" (agent has met prereqs,
%can afford costs, and has not exceeded max duration of layer) or not. Returns logical array of true (selectable) or
%false (not selectable because of missing prereqs or insufficient savings)

portfolioLayers = size(prereqs,1);
totalcost = 0;
testb = maxDuration;
testc = agentExperience;

selectable = ones(1,portfolioLayers); %1 will designate selectable
neededTraining = prereqs - eye(portfolioLayers);
traininggap = agentTraining' - neededTraining; %NxN matrix where -1 indicates a missing prereq for row layer
 
%Need to adjust this to if statement that excludes agent from having to afford prereqs if they already have certifications
for indexI = 1:portfolioLayers
    %Calculate total cost of accessing layer
    layercost = sum(utilityCosts(accesscodes(:,indexI)>0,2)); %Adding utility costs to access each layer in portfolio

     %If agent is missing required training for layer I set it as not selectable
     if ((any(traininggap(indexI,:) < 0)) || (agentExperience(indexI) >= maxDuration(indexI)))
        selectable(indexI) = 0;
     end
end

%Convert to logical array with selectable layers set as "true"
selectable = (selectable > 0)';

end


