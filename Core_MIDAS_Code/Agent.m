classdef Agent < handle
    
   properties 
       %agent properties
       id
       location
       matrixLocation
       visX
       visY
       age
       gender
       TOD
       DOB
       trapped
       layerFlag %Flag for category of layers that are available to agent, based on ID e.g. gender, caste, etc.
       
       
       %agent accumulated data
       network
       myIndexInNetwork
       accessCodesPaid
       bestPortfolios
       bestAspirations
       consideredPortfolios
       consideredHistory
       bestFidelity
       bestPortfolioValues
       knowsIncomeLocation
       incomeLayersHistory
       wealth
       incomeHistory
       wealthHistory
       realizedUtility
       training
       vocational
       diploma
       experience
       scratch;
       overlap
       heardOpening
       expectedProbOpening
       timeProbOpeningUpdated

       %incomeLayersTest
       currentPortfolio
       currentAspiration
       currentFidelity
       firstPortfolio
       agentPortfolioHistory
       agentAspirationHistory
       backCastProportion
       personalIncomeHistory
       currentSharedIn
       lastIntendedShareIn
       moveHistory

       %agent preferences
       incomeShareFraction
       shareCostThreshold
       knowledgeShareFrac
       pInteract
       pMeetNew
       pAddFitElement
       pChoose
       fDecay
       pGetLayer_informed
       pGetLayer_uninformed
       pRandomLearn
       countRandomLearn
       numBestLocation
       numBestPortfolio
       numRandomLocation
       numRandomPortfolio
       numPeriodsEvaluate
       numPeriodsMemory
       discountRate
       rValue
       bList
       prospectLoss
   end
   
   events
      %none at the moment
   end
   
   methods 
       %basic constructor
      function A = Agent(id, location)
         A.id = id;
         A.location = location;
         A.network = [];
         A.TOD = -9999;  %TOD is 'time of death'
         A.DOB = -9999;  %DOB is 'date of birth'
         A.trapped = 0;
      end %  
      
      %as written presently, most agent actions are coded as model
      %subroutines with input agents, as opposed to agent member functions
      
      %since there are no child classes that inherit Agent, there isn't
      %really much of a need, and this structure makes it easier to plug
      %and play different routines
     
   end % methods
   
end % classdef