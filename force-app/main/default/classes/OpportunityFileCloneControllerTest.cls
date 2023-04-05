@isTest
public class OpportunityFileCloneControllerTest {
   static testMethod void method1(){
        
        //List<OpportunityLineItem> oLi = new List<OpportunityLineItem>();
        Account acc= new Account();
        acc.Name = 'Test';
        insert acc;
        
        Product2 pro = new Product2();
        pro.Name = 'Test';
        insert pro;
       
        Pricebook2 pricebook = new Pricebook2(Name = 'Pricebook');
        insert pricebook;
        ID standardPricebookID = Test.getStandardPricebookId();
        Product2 product1 = new Product2(Name = 'Product1',
                                             IsActive = true);
            insert product1;
        Product2 product2 = new Product2(Name = 'Product1',
                                             IsActive = true);
            insert product2;
       
        PricebookEntry sPricebookEntry1 = new PricebookEntry(Product2Id = product1.ID,
                                                                 Pricebook2Id = standardPricebookID,
                                                                 UnitPrice = 1,
                                                                 IsActive = true );
            insert sPricebookEntry1;
        //List<Opportunity> opp=new List<Opportunity>();
        Opportunity oppo = new Opportunity();
        oppo.AccountId = acc.Id;
        oppo.CloseDate = system.today();
        oppo.Name = 'Test1';
        oppo.StageName = 'Negotiation';
        oppo.Pricebook2Id = standardPricebookID;
        insert oppo;
       
        OpportunityLineItem oppLine = new OpportunityLineItem();
        oppLine.TotalPrice = 1244;
        oppLine.Product2Id =product1.ID;
        oppLine.PricebookEntryId = sPricebookEntry1.Id;
        oppLine.Quantity = 10;
        oppLine.OpportunityId = oppo.Id;
        insert oppLine;
       
        Contract con = new Contract();
        con.AccountId = acc.id;
        con.ContractTerm = 12;
        con.StartDate = system.today();
        con.Name = 'test';
        insert con;
       
       Order ord = new Order();
       ord.AccountId = acc.Id;
       ord.Status = 'Draft';
       ord.Name = 'test';
       ord.EffectiveDate = system.today();
       insert ord;
        
        Test.StartTest(); 
            ApexPages.StandardController sc = new ApexPages.StandardController(oppo);
            PageReference pageRef2 = Page.cloneWithFiles;
            pageRef2.getParameters().put('id',String.valueOf(oppo.Id));
            Test.setCurrentPage(pageRef2);
            
			OpportunityFileCloneController  obj = new OpportunityFileCloneController(sc);
            obj.cloneWithFiles();
 
		Test.StopTest();
        
    }
}