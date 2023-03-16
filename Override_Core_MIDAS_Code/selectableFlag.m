function selectable = selectableFlag(prereqs,accesscodes, utilityCosts, agentTraining, agentWealth)
%Script to identify layers as "selectable" (agent has met prereqs and
%can afford costs) or not. Returns logical array of true (selectable) or
%false (not selectable because of missing prereqs or insufficient savings)


portfolioLayers = size(prereqs,1);
totalcost = 0;
%numPortfolios = size(portfolios,1); %Number of portfolios to consider, total possible layers in one portfolio
selectable = ones(1,portfolioLayers); %1 will designate selectable

if (~isempty(agentTraining))
    traininggap = agentTraining - prereqs; %NxN matrix where -1 indicates a missing prereq for row layer

    for indexI = 1:portfolioLayers
        %Calculate total cost of accessing layer
        layercost = sum(utilityCosts(accesscodes(:,indexI)>0,2)); %Adding utility costs to access each layer in portfolio

        if ((any(traininggap(indexI,:) < 0)) || (layercost > agentWealth))
            selectable(indexI) = 0;
        end

    end
end

%Convert to logical array with selectable layers set as "true"
selectable = selectable > 0;

end


