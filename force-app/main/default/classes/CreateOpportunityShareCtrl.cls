public class CreateOpportunityShareCtrl {
    
    @Future
    public  static void  CreateOppyShareRecords(Set<Id> quotelist){
        
        List<Opportunityshare> oppyShareList = new List<Opportunityshare>();
        MAP<Id,List<Id>> repAccOppys = new MAP<Id,List<Id>>();        
    
    for(SBQQ__Quote__c quote: [Select Id, SBQQ__Partner__r.Rep_Account__c, SBQQ__Opportunity2__c FROM SBQQ__Quote__c 
                               WHERE SBQQ__Partner__c!=null AND Id IN: quotelist])
    {
        
        if(repAccOppys.isEmpty()){
            repAccOppys.put(quote.SBQQ__Partner__r.Rep_Account__c, new List<Id>{quote.SBQQ__Opportunity2__c});
        }else if(repAccOppys.get(quote.SBQQ__Partner__r.Rep_Account__c) != null){
            List<Id> ids = repAccOppys.get(quote.SBQQ__Partner__r.Rep_Account__c);
            ids.add(quote.SBQQ__Opportunity2__c);
            repAccOppys.put(quote.SBQQ__Partner__r.Rep_Account__c, ids);
        }else{
            repAccOppys.put(quote.SBQQ__Partner__r.Rep_Account__c, new List<Id>{quote.SBQQ__Opportunity2__c});
        }
        
    }
    system.debug('repAccOppys: '+repAccOppys);
    for(User partnerUser : [Select Id, AccountId FROM User WHERE account.IsPartner = true AND AccountId IN: repAccOppys.keySet()]){
        
        for(Id oppyId : repAccOppys.get(partnerUser.AccountId)){
            Opportunityshare OppyShare = new Opportunityshare();
            OppyShare.OpportunityId = oppyId;
            OppyShare.UserOrGroupId = partnerUser.Id;
            OppyShare.OpportunityAccessLevel = 'edit';
            OppyShare.RowCause = 'Manual';
            
            oppyShareList.add(OppyShare);
        }
        
    }
    
    if(!oppyShareList.isEmpty()){
        Database.SaveResult[] lsr = Database.Insert(oppyShareList,false);
    }
    
    }

}