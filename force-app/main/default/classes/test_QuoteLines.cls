//========================================================================
//  Object: test_QuoteLines
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: Quote Line Test Class
//========================================================================
//          Date            Purpose
// Changes: 03/11/2019      Initial Version
//========================================================================

@isTest (SeeAllData=true)
private class test_QuoteLines {

	/*************************************************************************************************
	New Quote and Quote Line Record
		-Initial Test to get coverage
	
	Test Data Class/Method:  None
	
	Functional Test Logic
	-----------------------------------------------------------------------------
	1.  Create Quote
	2.  Create Quote Line
	**************************************************************************************************/
	
	@isTest(SeeAllData=true)
	private static void createQuoteandLines() {
		
		//Build Account
        Account a = [select Id,name from account LIMIT 1];


		//Insert Quote
			//Get Date
			Date EDate = Date.today();

			//Pricebook
			Pricebook2 spb= [select Id,name from Pricebook2 where name = : 'GLOBAL DEALER MASTER PL' limit 1];

			//Product
			Product2 pr = [select id,name from product2 where name = : 'MISC-Limited Extended Warranty' limit 1];

			//PBE
			PricebookEntry pbe = [select id,name from PricebookEntry where Product2Id = : pr.id and Pricebook2Id = : spb.Id limit 1];

			//Build Opportunity
			Opportunity o = new Opportunity();
			o.Name = 'Test Oppty';
			o.AccountId = a.Id;
			o.StageName = 'New';
			o.CloseDate = Date.today().addDays(5);
			o.Pricebook2Id = spb.Id;
			insert o;

			//Add Quote
			SBQQ__Quote__c cq = new SBQQ__Quote__c();
				cq.SBQQ__Account__c = a.Id; 
				cq.SBQQ__ExpirationDate__c = EDate.addDays(30);
				cq.SBQQ__PricebookId__c = sPB.Id;
				cq.SBQQ__Opportunity2__c = o.Id;
				cq.SBQQ__Partner__c = a.Id;
			Insert cq;
			
			//Insert sbq
			SBQQ__QuoteLine__c sq = new SBQQ__QuoteLine__c();
				sq.SBQQ__Quote__c = cq.Id;
				sq.SBQQ__Product__c = pr.Id;
				sq.SBQQ__Quantity__c = 5;
				sq.SBQQ__PricebookEntryId__c = pbe.Id;
			insert sq;
			
			

	}
}