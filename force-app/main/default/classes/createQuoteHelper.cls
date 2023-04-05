/**

* @description        : createQuoteHelper class for creating Quote trigger when API call is completed
* @Author             : prakhar.jain@qsc.com
* @Last Modified By   : prakhar.jain@qsc.con
* @Last Modified On   : 21/12/2022
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    21/12/2022     prakhar.jain@qsc.com       Initial Version
**/

public class createQuoteHelper 
{
    Public static void insertQuote(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppList)
    {
        
     /*   List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        set<Id> oppId =  new Set<Id>();
        
        date d = system.today();
        Date endDate= d.addYears(1);
        For(Opportunity objOpp: newOppList)
        {
        	//oppId.add(objOpp);
        	
            //Check if Api call completed checkkbox is true
            If((objOpp.API_Call_Completed__c) && (objOpp.API_Call_Completed__c!=oldOppList.get(objOpp.id).API_Call_Completed__c)) 
            {
               //Add Quote details
                SBQQ__Quote__c objQuote = new SBQQ__Quote__c(SBQQ__Primary__c= true,  SBQQ__Opportunity2__c = objOpp.Id, SBQQ__StartDate__c= d, SBQQ__EndDate__c=endDate, SBQQ__PriceBook__c = objOpp.Pricebook2Id);
                quoteList.add(objQuote);
            }
        }
        
        //Insert list into database
        insert quoteList;
        //system.debug('hello '+quoteList);
        
        //Querying Product and price book from Opportunity Line Item 
        /*List<OpportunityLineItem> oppLineItemList = [SELECT Id, PricebookEntryId, Product2Id, OpportunityId, Quantity, UnitPrice FROM OpportunityLineItem where OpportunityId in:oppId];
        system.debug(oppLineItemList);
        //Creating Quote Line for each quote inserted by API call
        list<SBQQ__QuoteLine__c> insertList = new List<SBQQ__QuoteLine__c>();
        
        IF(!oppLineItemList.isEmpty()){
        For(OpportunityLineItem oli : oppLineItemList)
        {
            For(SBQQ__Quote__c qt : quoteList)
            {
                IF(oli.OpportunityId == qt.SBQQ__Opportunity2__c)
                {
                    SBQQ__QuoteLine__c newitem = new SBQQ__QuoteLine__c();
                    newitem.SBQQ__Product__c = oli.Product2Id;
                    newitem.SBQQ__Quantity__c = oli.Quantity;
                    newitem.SBQQ__CustomerPrice__c = oli.UnitPrice;
                    newitem.SBQQ__Quote__c = qt.id;
                    newitem.SBQQ__PricebookEntryId__c = oli.PricebookEntryId;
                    insertList.add(newitem);
                }
            }
        }
        system.debug(insertList);    
        Insert insertList;
    }*/
    }
}