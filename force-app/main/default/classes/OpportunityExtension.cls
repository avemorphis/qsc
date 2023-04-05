public class OpportunityExtension {

    public List<AlertWrapper> alerts {get; set;}
    public OpportunityExtension(ApexPages.StandardController controller) {
        Opportunity opp = (Opportunity) controller.getRecord();
        opp = [Select Id, AccountId, Account.Customer_Number__c from Opportunity where Id =: opp.Id];
        alerts = new List<AlertWrapper>();
        List<OpportunityLineItem> oppLineItemList = [SELECT Id,OpportunityId,PricebookEntryId, PricebookEntry.Product2Id, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Model_Line__c FROM OpportunityLineItem where OpportunityId =: opp.Id];
        System.debug('-----------------------------------------oppLineItemList:'+oppLineItemList);
        
        List<Product_Authorization__c> prodAuthList = [SELECT Account_Number__c, Id,Item_Number__c,Model_Line__c FROM Product_Authorization__c where Account_Number__c =: opp.Account.Customer_Number__c];
        for(OpportunityLineItem oli: oppLineItemList) {
            AlertWrapper aw = new AlertWrapper();
            if(prodAuthList == null || prodAuthList.size() > 0) {
                Boolean isAuthrized = false;
                for(Product_Authorization__c prodAuth: prodAuthList) {
                    if(prodAuth.Item_Number__c == oli.PricebookEntry.Product2.Name && prodAuth.Model_Line__c == oli.PricebookEntry.Product2.Model_Line__c) {          
                        isAuthrized = true;                        
                    }
                }
                if(!isAuthrized) {
                    aw.name = oli.PricebookEntry.Product2.Name +' With Sales Part: '+ oli.PricebookEntry.Product2.ProductCode +' is not an authorized product.';
                    alerts.add(aw);
                }
            } else {
                aw.name = oli.PricebookEntry.Product2.Name +' With Sales Part: '+ oli.PricebookEntry.Product2.ProductCode +' is not an authorized product.';
                alerts.add(aw);
            }
        }
        
        System.debug('------------------------------------alerts:'+alerts);
    }

    public class AlertWrapper {
        public String name {get; set;}
        public AlertWrapper() {            
        }
    }
}