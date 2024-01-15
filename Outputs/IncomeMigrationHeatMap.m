load Aspirations_SenegalTest_AllPrereqs_Backcast0_12-Dec-2023_09-25-48.mat
backcast = output;

load '../Data/SenegalIncomeData.mat'
income = orderedTable


X = income.rural_services

Y = output.countAgentsPerLayer(:,8,end)

scatter(X,Y)
ax = gca;
ax.FontSize = 16;
ylabel('Number Agents','FontSize',16)
xlabel('Income', 'FontSize',16)

