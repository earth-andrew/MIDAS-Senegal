load("SaltwaterUtilityHistoryArray.mat")
saltwaterIncomes = testMatrix;
load("UtilityHistoryArray.mat")
baseIncomes = testMatrix;



saltDifferential = saltwaterIncomes - baseIncomes

ind = find(saltDifferential > 0)

results = [ind', saltDifferential(ind')]