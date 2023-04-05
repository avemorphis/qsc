global with sharing class scheduleBatchClassOpportunityExpires implements Schedulable  {
    global void execute(SchedulableContext SC) {
        batchSendOpportunityReport2WeekPrior bc = new batchSendOpportunityReport2WeekPrior();
        //if(!Test.isRunningTest())
        Database.executeBatch(bc);
     }
}