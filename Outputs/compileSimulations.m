function compileSimulations()
%Function that compiles key output from ensemble of simulations, for
%purposes of visualizing distributions of results

clear all;
close all;

%Load null output file
prefix = 'SenegalEnsemble_GroundnutBasinDrought_01.14';
fileList = dir([prefix '*.mat']);
outputList = [];

%Loop through each run
for indexI = 1:height(fileList)
    currentRun = load(fileList(indexI).name);
    fprintf(['Run ' num2str(indexI) ' of ' num2str(length(fileList)) '.\n'])
    numAgents = size(currentRun.output.agentSummary.id,1);
    numSteps = size(currentRun.output.agentSummary.backCastProportion{1,1},1);
    

    backCastProportions = zeros(numAgents,numSteps);
    avgBackCastProportion = zeros(numSteps,1);
    agentIncomes = zeros(numAgents,numSteps);
    avgIncomes = zeros(numSteps,1);
    educationHistory = cell(numAgents,1);
    finalYearIncome = zeros(numAgents,1);
    migrationHistory = cell(numAgents,1);
    portfolioHistory = cell(numAgents,1);
    experience = cell(numAgents,1);

    %Setting up inequality calculations
    start_time = 11;
    proportion = 0.2;
    cutoffNumber = floor(proportion * numAgents);
    incomePoorest = zeros(cutoffNumber, numSteps);
    incomeRichest = zeros(cutoffNumber, numSteps);
    avgIncomePoorest = zeros(numSteps,1);
    avgIncomeRichest = zeros(numSteps,1);
    
    %Calculating average backCastProportion across the population for each
    %time step
    for indexA = 1:numAgents
        backCastProportions(indexA,:) = currentRun.output.agentSummary.backCastProportion{indexA,1};
        agentTOD = currentRun.output.agentSummary.TOD(indexA);

        %If agent died before end of model run, add NaN's to income history
        %for years after death
        if agentTOD > 0
            agentIncomes(indexA,:) = [currentRun.output.agentSummary.incomeHistory{indexA,1} NaN(1, (numSteps - agentTOD))];
        else
            agentIncomes(indexA,:) = currentRun.output.agentSummary.incomeHistory{indexA,1};
        end
        
        educationHistory{indexA} = currentRun.output.agentSummary.diploma{indexA,1};
        migrationHistory{indexA} = currentRun.output.agentSummary.moveHistory{indexA,1};
        portfolioHistory{indexA} = currentRun.output.agentSummary.portfolioHistory{indexA,1};
        experience{indexA} = currentRun.output.agentSummary.experience{indexA};

    end
    
    %Calculating starting and final incomes
    startingYearIncome = sum(agentIncomes(:,start_time:start_time+3),2);
    finalYearIncome = sum(agentIncomes(:,end-3:end),2);
    [sortedIncome, sortIndex] = sort(startingYearIncome,'ascend');

    poorestAgents = sortIndex(1:cutoffNumber);
    richestAgents = sortIndex(end-cutoffNumber:end);
    incomePoorest = agentIncomes(poorestAgents,:);
    incomeRichest = agentIncomes(richestAgents,:);

    avgIncomePoorest = nanmean(incomePoorest,1);
    avgIncomeRichest = nanmean(incomeRichest,1);
    avgBackCastProportion = mean(backCastProportions,1);
    avgIncomes = nanmean(agentIncomes,1);
    %for indexT = 1:numSteps
        %avgBackCastProportion(indexT) = mean(backCastProportions(:,indexT));
        %avgIncomes(indexT) = nanmean(agentIncomes(:,indexT));
    %end


    %Compile fields and values for all the key variables we want to track
    output = currentRun.output;   
    field1 = 'migrations'; value1 = currentRun.output.migrations;
    field2 = 'migrationMatrix'; value2 = currentRun.output.migrationMatrix;
    field3 = 'agentJobDistribution'; value3 = currentRun.output.countAgentsPerLayer;
    field4 = 'communityWealth'; value4 = currentRun.output.averageWealth;
    field5 = 'pBackcast'; value5 = avgBackCastProportion;
    field6 = 'avgIncomes'; value6 = avgIncomes;
    field7 = 'diplomas'; value7 = {educationHistory};
    field8 = 'finalYearIncome'; value8 = finalYearIncome;
    field9 = 'migrationHistory'; value9 = {migrationHistory};
    field10 = 'portfolioHistory'; value10 = {portfolioHistory};
    field11 = 'poorestIncome'; value11 = avgIncomePoorest;
    field12 = 'richestIncome'; value12 = avgIncomeRichest;
    field13 = 'experience'; value13 = {experience};
    

    %Put them into one struct for this run
    currentOutputValues = struct(field1, value1, field2, value2, field3, value3, field4, value4, field5, value5, field6, value6, field7, value7, field8, value8);
    
    %Add current run struct to running list
    outputList = [outputList; currentOutputValues];

end

save('GroundnutBasinDrought_01.14.2025.mat', 'outputList')

end