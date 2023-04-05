@isTest(SeeAllData=true)
public class TestProjectAfterTrigger {
    public static testMethod void testProject() {
        
        Projects__c proj = new Projects__c();
        proj.Project_Stage__c = 'Open';
        insert proj;
        
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.DFI__c = 2;
        insert acc;
        
        //get standard pricebook
        Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];

        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', FG_Number__c = '123', isActive = true);
        insert prd1;        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb.id,UnitPrice=50, isActive=true);
        insert pbe1;        
        
        Opportunity opp = new Opportunity (Name='Opp1',StageName='On Hold',CloseDate=Date.today(), Projects__c = proj.Id,Pricebook2Id = pbe1.Pricebook2Id, AccountId = acc.id);
        insert opp;
        
        proj.Project_Stage__c = 'On Hold';
        update proj;        
    }
}