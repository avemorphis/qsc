//==================================================================================================
// Object: th_DocusignStatus.cls
// Company: Think AI Corp
// Author: Vivek Manchanda
// Comment: Docusign status Trigger Handler Class
//==================================================================================================
//          Date            Purpose
// Changes: 10/21/2019      Initial Version			
//==================================================================================================
public class th_DocusignStatus {
    public set<Id> accountIds{get;set;}
    public void OnAfterUpdate(List<dsfs__DocuSign_Status__c> newDocusignStatus){
        accountIds = new set<Id>();
        for(dsfs__DocuSign_Status__c docStatus:newDocusignStatus){ 
            // Adding account id in set
            accountIds.add(docStatus.dsfs__Company__c);
        }
        // Fetching Account record linked with docusign status
        List<Account> accList =  [SELECT Id, Name, BillingCountry,Attributes__c,Legal_Agreements__c FROM Account where Id IN:accountIds];
        if(accList.size() >0 ){
            for(dsfs__DocuSign_Status__c docStatus:newDocusignStatus){ 
                for(Account acc : accList){
                    // Check whether status completed and type of legal agreement
                    if(acc.Legal_Agreements__c == 'Reseller Agreement' && docStatus.dsfs__Envelope_Status__c == 'Completed'){
                        acc.Attributes__c = 'Reflect Reseller';            
                    }
                    if(acc.Legal_Agreements__c == 'Referral Agreement' && docStatus.dsfs__Envelope_Status__c == 'Completed'){
                        acc.Attributes__c = 'Reflect Referral';            
                    }
                }
            }
            // Update account list
            update accList;
        }
    }
}