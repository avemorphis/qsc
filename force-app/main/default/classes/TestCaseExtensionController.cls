@isTest(SeeAllData=true)
public class TestCaseExtensionController  {
    public static testMethod void testCaseExtension() {
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.DFI__c = 2;
        insert acc;
        
        Case c = new Case();
        c.AccountId = acc.Id;
        c.Request_RMA__c = false;
        insert c;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        CaseExtensionController cc = new CaseExtensionController(sc);
        cc.init();
        
        Product2 prod = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', FG_Number__c = '123', isActive = true);
        insert prod; 
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.Request_RMA__c = false;
        //ca.Product_If_No_Asset__c = prod.Id;
        insert ca;
        
    }
}