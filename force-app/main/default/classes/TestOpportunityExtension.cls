@isTest(SeeAllData=true)
public class TestOpportunityExtension {
    public static testMethod void testOpp() {
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.DFI__c = 2;
        insert acc;
        
        Projects__c pj= new Projects__c(Name='project1' ,Business_Segment__c='test',City__c='test',Project_US_State__c='test',Country__c='test',Project_region__c='test',Estimated_Budget__c= 3000);
        //Estimated_Close_Date__c,Estimated_Bid_Date__c
        Insert pj;
        //get standard pricebook
        Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];

        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', FG_Number__c = '123', isActive = true);
        insert prd1;        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb.id,UnitPrice=50, isActive=true);
        insert pbe1;        
        
        Opportunity opp1 = new Opportunity (Name='Opp1',Projects__c=pj.id,StageName='Stage 0 - Lead Handed Off',CloseDate=Date.today(),Pricebook2Id = pbe1.Pricebook2Id, AccountId = acc.id);
        insert opp1;

        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp1.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200);
        insert lineItem1;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(opp1);
        OpportunityExtension oe = new OpportunityExtension(sc);
    }
}