function selectable = selectableFlag(prereqs, accesscodes, utilityCosts, agentTraining, agentExperience, agentPortfolio, maxDuration)
%Script to identify layers as "selectable" (agent has met prereqs,
%can afford costs) or not. Returns logical array of true (selectable) or
%false (not selectable because of missing prereqs or insufficient savings)

portfolioLayers = size(prereqs,1);
totalcost = 0;

%numPortfolios = size(portfolios,1); %Number of portfolios to consider, total possible layers in one portfolio
selectable = ones(1,portfolioLayers); %1 will designate selectable
if (~isempty(agentTraining))
    neededTraining = prereqs - eye(portfolioLayers);
    
    traininggap = agentTraining' - neededTraining; %NxN matrix where -1 indicates a missing prereq for row layer
    
    %Need to adjust this to if statement that excludes agent from having to
    %afford prereqs if they already have certifications
    for indexI = 1:portfolioLayers
        %Calculate total cost of accessing layer
        layercost = sum(utilityCosts(accesscodes(:,indexI)>0,2)); %Adding utility costs to access each layer in portfolio
        
        if ((any(traininggap(indexI,:) < 0)) && (~(agentPortfolio(indexI)))) %If layer is not already in portfolio
            selectable(indexI) = 0;
        elseif agentExperience(indexI) >= maxDuration(indexI) %kick agents out of layers for which they are no longer eligible (e.g. if an agent has "graduated" from school)
            selectable(indexI) = 0;
        end

    end
end

%Convert to logical array with selectable layers set as "true"
selectable = (selectable > 0)';

end


