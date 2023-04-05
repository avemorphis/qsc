/**

* @description        : Test class for creating Quote trigger when API call is completed
* @Author             : prakhar.jain@qsc.com
* @Last Modified By   : prakhar.jain@qsc.con
* @Last Modified On   : 21/12/2022
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    21/12/2022     prakhar.jain@qsc.com       Initial Version
**/

@isTest
public class testCreateQuoteClass {
	
    
    Public static testmethod void testmethod1(){
        date d = system.today()+ 30;
        
        Opportunity objOpp = new Opportunity(Name='Sheela', CloseDate= d, StageName= 'Qualification', Venue_Type__c='Boardroom', CurrencyIsoCode='USD', Market_Segment__c='Cinema', Installation_Country2__c= 'India', API_Call_Completed__c=false);
        insert objOpp;
        system.debug(objOpp.id);
        
        Id pricebookId = Test.getStandardPricebookId();
        
        /* Pricebook2 pb = new Pricebook2(Name='Standard Price Book 2009', isActive= true);
        insert pb;
        system.debug(pb.id);
        
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
    	system.debug(standardPB.id); */  
        
        Product2 objProd = New Product2(Name= 'Tata Steel', isActive=true, ProductCode='G5639');
        insert objProd;
        system.debug(objProd.id);
        
        PriceBookEntry pbe= new PriceBookEntry(priceBook2Id= pricebookId, Product2Id= objProd.id, UnitPrice=20, isActive=true);
        insert pbe;
        system.debug(pbe.id);
        
        OpportunityLineItem oli= new OpportunityLineItem(OpportunityId= objOpp.id, Product2Id= objProd.id, PriceBookEntryId= pbe.id, Quantity=1, totalPrice = 20.00);
        insert oli;
        system.debug(oli.id);
        
        th_createQuoteHandler.flag= true;
        
        Opportunity objOpport = [Select Api_Call_Completed__c from Opportunity where id =:objOpp.id];
       	system.debug(objOpport.API_Call_Completed__c);
        objOpport.API_Call_Completed__c=true;
        objOpport.priceBook2Id= pricebookId;
        update objOpport;
        system.debug(objOpport.API_Call_Completed__c);
        
    }
    
     
   
}