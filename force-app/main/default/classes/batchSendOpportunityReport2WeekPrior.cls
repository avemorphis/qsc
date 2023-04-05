public with sharing class batchSendOpportunityReport2WeekPrior implements Database.Batchable<SObject> {
    //OpportunityReport2WeekPrior_Test
    public Database.QueryLocator start(Database.BatchableContext BC){
        Date prior2Week = Date.parse(System.today().addDays(14).format());
        Date todaysDate = date.parse(System.today().format());
        String query = 'Select id, CloseDate, Name, Partner_Account__r.Name, End_User_Account__c, Amount, StageName, Owner.Name,OwnerId from Opportunity where closedate >=:todaysDate and CloseDate <:prior2Week and (not stagename like \'%Closed%\') order by closedate, ownerid';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Opportunity> scope){
        Map<String,List<Opportunity>> mapUserOpportunity = new Map<String,List<Opportunity>>();
        integer i=0;
        for (Opportunity opp : scope) {
            String s = opp.stagename;
            if(s.containsIgnoreCase('Closed')){
                System.debug('================Alert========QueryFail======');
            }
            List<Opportunity> oppList = new List<Opportunity>();
            if(mapUserOpportunity.containsKey(opp.OwnerId)){
                i++;
                System.debug('test');
                oppList.addAll(mapUserOpportunity.get(opp.OwnerId));
                oppList.add(opp);
                mapUserOpportunity.put(String.valueof(opp.OwnerId), oppList);
            }else{
                System.debug('test2');
                oppList.add(opp);
                mapUserOpportunity.put(String.valueof(opp.OwnerId), oppList);
            }
           
        }
        System.debug('Opportunities: '+ i);
        System.debug(mapUserOpportunity.values());
        notificationToSalesDirector.sendNotification(scope);
        emailToSalesDirector.sendEmail(mapUserOpportunity);
    }
    public void finish(Database.BatchableContext BC   ){

    }
}