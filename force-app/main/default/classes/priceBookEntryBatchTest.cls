@isTest
public class priceBookEntryBatchTest 
{
    Public static testMethod void PriceBookEntryMethod()
    {
        Product2 prodObj = new Product2(Name='Zen', ProductCode='Zen12', IsActive=true);
        insert prodObj;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        PriceBook2 pb1= new PriceBook2(Name= 'New Standard', IsActive=true);
        insert pb1;
        PriceBook2 pb2= new PriceBook2(Name= 'New Price', IsActive=true);
        insert pb2;
        
        
        PriceBookEntry pbe1= new PriceBookEntry(Product2Id= prodObj.id, Pricebook2Id= pricebookId, IsActive=true, UnitPrice=20);
        insert pbe1;
        
        PriceBookEntry pbe2= new PriceBookEntry(Product2Id= prodObj.id, Pricebook2Id= pb1.id, IsActive=False, UnitPrice=30);
        insert pbe2;
        //system.debug('PriceBookEntry: '+pbe2);
        PriceBookEntry pbe3= new PriceBookEntry(Product2Id= prodObj.id, Pricebook2Id= pb2.id, IsActive=true, UnitPrice=40);
        insert pbe3;
        // system.debug('PriceBookEntry: '+pbe3);
        
        //Test for product 2
        Product2 prodObj2 = new Product2(Name='Zenser', ProductCode='Zen132', IsActive=true);
        insert prodObj2;
        
        PriceBookEntry p2be1= new PriceBookEntry(Product2Id= prodObj2.id, Pricebook2Id= Test.getStandardPricebookId(), IsActive=false, UnitPrice=20);
        insert p2be1;
        
        PriceBookEntry p2be2= new PriceBookEntry(Product2Id= prodObj2.id, Pricebook2Id= pb1.id, IsActive=False, UnitPrice=30);
        insert p2be2;
        
        PriceBookEntry p2be3= new PriceBookEntry(Product2Id= prodObj2.id, Pricebook2Id= pb2.id, IsActive=false, UnitPrice=40);
        insert p2be3;
        
       
        
        //Test Batch Execution
        Test.startTest();
        	String CRON_EXP = '0 0 0 '+date.today().day()+' '+date.today().month()+' ? 2029';
			system.schedule('jobPriceBookEntry', CRON_EXP, new priceBookEntryBatchScheduler());
        Test.stopTest();
        
        //Check Expected and actual output 
        Boolean result= [Select Active_In_PriceBook__c from Product2 where id =:prodObj.id].Active_In_PriceBook__c;
        system.assert(true, result);
        
        Boolean result1= [Select Active_In_PriceBook__c from Product2 where id =:prodObj2.id].Active_In_PriceBook__c;
        system.assert(true, result1);
        
    }
}