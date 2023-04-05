//=================================================================================================================
//  Object: methods_cpqQuotelines.cls
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: Contact Methods Clas
//=================================================================================================================
//          Date            Purpose
// Changes: 02/21/2019      Initial Version
//=================================================================================================================

public class methods_cpqQuotelines  {


    /**************************************************************************************************************
    updateCPQValues
    Method to Update CPQQuoteLines with PBE Values

    ---------------------------------------------------------------------------------------------------------------
    @param    lCPQlines   List of CPQLines from Trigger
    @return   void
    **************************************************************************************************************/
    public static void updateCPQValues(List<SBQQ__QuoteLine__c> lCPQlines) {
    
        //Build Collections for PBE
        set<id> cpqlIds = new set<id>(); //Pricebook Entry
		List<CPQ_Exclude_Products_List__mdt> cmExProd = new List<CPQ_Exclude_Products_List__mdt>(); //Products to Exclude
		List<String> exProdList = new List<String>();  //Collection to reference

        //Populate Collections
			//cmExProd: CPQ Exclude Products List Custom Metadata Object
			cmExProd = [select Product_Id__c FROM CPQ_Exclude_Products_List__mdt];
			//exProdList:  Collection of ProductId Strings
			for(CPQ_Exclude_Products_List__mdt b : cmExProd) {
				//Populate exProdList
				exProdList.add(Id.valueOf(b.Product_Id__c));
			}
			//cpqlIds: Transaction Data Set
			for(SBQQ__QuoteLine__c q : lCPQlines) {
				//Check if Product is excluded
				if(!exProdList.contains(q.SBQQ__Product__c)) {
					cpqlIds.add(Id.valueOf(q.SBQQ__PricebookEntryId__c));
				}
			}
		
		//Check size & Execute
		if(cpqlIds.size() > 0) {
			
			try {
				//Get PBE Data
				Map<Id,PricebookEntry> PBELookup = new Map<Id,PricebookEntry>([select id, MSRP__c,cogs__c,Tariff__c, Product2Id from PricebookEntry where id in: cpqlIds]);
			
				//Cycle and Update
				for(SBQQ__QuoteLine__c cpqQ: lCPQlines) {
        
					//Get PBE Values & Update Record
					cpqQ.MSRP__c = PBELookup.get(Id.valueOf(cpqQ.SBQQ__PricebookEntryId__c)).MSRP__c;
					cpqQ.COGS__c = PBELookup.get(Id.valueOf(cpqQ.SBQQ__PricebookEntryId__c)).cogs__c;
					cpqQ.Tariff__c = PBELookup.get(Id.valueOf(cpqQ.SBQQ__PricebookEntryId__c)).Tariff__c;
				}
			}
			catch(Exception e) {
				//Log in Debug Log
				system.debug('methods_cpqQuotelines-->updateCPQValues Exception: ' + e.getMessage());

				//set friendly message
				e.setMessage(System.Label.Exception_Message);

				//Log Exception
				globalExceptionHandlers.logInsertORUpdateException('methods_cpqQuotelines', 'updateCPQValues', String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
			}
		}
    }
}