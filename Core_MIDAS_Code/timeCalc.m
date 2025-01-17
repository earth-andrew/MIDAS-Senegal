function timeUse = timeCalc(constraints, portfolio, modelParameters)
%This function returns a 1x4 vector of an agent's time use given an input
%portfolio, time constraints for each layer, and any additional time costs
%if an agent is doing both rural and urban activities in a given quarter

timeUse = zeros(1,4);

%Sum rows in constraints for active portfolio layers (starting from index 2, as index 1 represents the index of the layer)
timeUse = sum(constraints(portfolio,2:end),1); 

%Now check for any concurrent rural-urban activities

for indexQ = 1:size(constraints(:,2:end),2)
    tempRural = any(mod(portfolio,2)); %Rural layers are odd indices
    tempUrban = any(~mod(portfolio,2)); %Urban layers are even indices
    
    if ~isempty(tempRural) && ~isempty(tempUrban)
        timeUse(indexQ) = timeUse(indexQ) + modelParameters.ruralUrbanTime;
    end
end

end