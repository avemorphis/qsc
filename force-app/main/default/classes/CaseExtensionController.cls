public class CaseExtensionController {
    
    public Case c;
    public CaseExtensionController(ApexPages.StandardController controller) {
        c = (Case)controller.getRecord();
        c = [Select Id, AccountId, Request_RMA__c, RMA_Status__c, Request_Type__c, Need_by__c, RMA_Type__c, RMA_Priority__c from Case where Id =: c.Id];
    }
    
    public PageReference init() {
        
        //if(!c.Request_RMA__c) {
           // if(c.RMA_Status__c != 'Open') {
           //      c.addError('RMA Status should Open for requesting RMA');
           //      return null;
           // }
           //if(Request_Type__c, Need_by__c, RMA_Type__c, RMA_Priority__c)
           // c.Oracle_Customer_Number__c == null || c.Oracle_Customer_Number__c == '' ||
           Account acc = [Select Id, Name, Customer_Number__c from Account where Id =: c.AccountId];
           if(acc.Customer_Number__c == null || acc.Customer_Number__c == '') {
               c.addError('Customer Number on selected Account is required field to request RMA.');
               return null;
           }
           if(c.Request_Type__c == null || c.Request_Type__c == '' || c.RMA_Type__c == null || c.RMA_Type__c == '' || c.Need_by__c == null || c.RMA_Priority__c == null || c.RMA_Priority__c == '') {
               c.addError('Equipment Type, Need By, RMA Type, RMA Priority are required fields.');
               return null;    
           }
            c.Request_RMA__c = true;
            c.Status = 'RMA Created';
            update c;            
        //}
        return new PageReference('/'+c.Id);
    }
}