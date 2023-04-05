public class QuoteHanlderController {
    
    public static void CreateSharingRecordsforOpportunity(Set<Id> quotelist){
        CreateOpportunityShareCtrl.CreateOppyShareRecords(quotelist);
    }
    
    //Delete affiliation records where there is no associated Quote 
	public static void DeleteAffiliationRecords(){
        
        List<Affiliated_Opportunity__c> affiliationsList = new List<Affiliated_Opportunity__c>();
        affiliationsList = [SELECT Id FROM Affiliated_Opportunity__c WHERE Quote2__c = null];
        
        if(!affiliationsList.isEmpty()){
            Delete affiliationsList;
        }
        
    }
    
}