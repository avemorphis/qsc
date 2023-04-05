@isTest (seeAllData = true)
 public class TestQuoteLineItemTrigger {
    public static testMethod void testTriggers() {
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.DFI__c = 2;
        insert acc;
        
        Projects__c pj= new Projects__c(Name='project1' ,Business_Segment__c='test',City__c='test',Project_US_State__c='test',Country__c='test',Project_region__c='test',Estimated_Budget__c= 3000);
        //Estimated_Close_Date__c,Estimated_Bid_Date__c
        Insert pj;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Acc';
        opp.AccountId = acc.Id;
        opp.StageName = 'Design';
        opp.Projects__c=pj.id;
        opp.CloseDate = System.today();
       // opp.DFI_Level__c = '1%';
        insert opp;
        
        Product2 prod = new Product2();
        prod.Name = 'Test Prod';
        prod.FG_Number__c = '123';
        insert prod;
        
        PriceBook2 pb = [Select Id from PriceBook2 where Name =: 'Standard Price Book'];
        
        PriceBookEntry pbe = new PriceBookEntry();
        pbe.Product2Id = prod.Id;        
        pbe.UnitPrice = 220;
        pbe.Pricebook2Id = pb.Id;
        pbe.isActive = true;
        insert pbe;
        
        Quote q = new Quote();
        q.Name = 'Test Quote';
        q.OpportunityId = opp.Id;
        q.Pricebook2Id = pb.Id;        
        insert q;
        q.Special_Discount__c = 5.00;
        update q;
                
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = q.Id;
        qli.PricebookEntryId = pbe.Id;
        qli.Quantity = 1;
        qli.UnitPrice = 220;
        qli.Special_Discount__c = 6.00;
        //qli.Product2Id = prod.Id;
        insert qli;
        
        q.Special_Discount__c = 4.00;
        update q;
    }
}