load Aspirations_SenegalTest_AllPrereqs_Backcast_t500_11-Dec-2023_15-49-27.mat
backcast = output;

load '../Data/SenegalIncomeData.mat'
income = orderedTable


X = income.rural_services

Y = output.countAgentsPerLayer(:,8,end)

plot(X,Y,'LineWidth',3)
ax = gca;
ax.FontSize = 16;
ylabel('Number Agents','FontSize',16)
xlabel('Income', 'FontSize',16)

