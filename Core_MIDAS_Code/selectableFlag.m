function selectable = selectableFlag(prereqs, accesscodes, utilityCosts, agentTraining, agentExperience, agentPortfolio, agentWealth, maxDuration)
%Script to identify layers as "selectable" (agent has met prereqs,
%can afford costs, and has not exceeded max duration of layer) or not. Returns logical array of true (selectable) or
%false (not selectable because of missing prereqs or insufficient savings)

portfolioLayers = size(prereqs,1);
totalcost = 0;

selectable = ones(1,portfolioLayers); %1 will designate selectable
neededTraining = prereqs - eye(portfolioLayers);



traininggap = agentTraining' - neededTraining; %NxN matrix where -1 indicates a missing prereq for row layer
 
%Need to adjust this to if statement that excludes agent from having to afford prereqs if they already have certifications
for indexI = 1:portfolioLayers
    %Calculate total cost of accessing layer
    layercost = sum(utilityCosts(accesscodes(:,indexI)>0,2)); %Adding utility costs to access each layer in portfolio
    
    %First check if agent has already reached maximum time limit in layer
    %"indexI
    if agentExperience(indexI) >= maxDuration(indexI)
        selectable(indexI) = 0;
    
    %Next check if layer "indexI" requires any other layers as prereqs
    elseif any(neededTraining(indexI,:))
        enablingLayers = find(neededTraining(indexI,:));
        
        %Now check if agent has at least one of those layers (as there may
        %be multiple possible enabling layers reflecting rural or urban
        %space
        if ~any(agentTraining(enablingLayers))
            selectable(indexI) = 0;
        end
    end


     %If agent is missing required training for layer I set it as not selectable
     %if ((any(traininggap(indexI,:) < 0)) || (agentExperience(indexI) >= maxDuration(indexI)))
        %selectable(indexI) = 0;
     %end
end

%Convert to logical array with selectable layers set as "true"
selectable = (selectable > 0)';

end


