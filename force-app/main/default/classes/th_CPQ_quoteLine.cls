//==================================================================================================
//  Object: th_CPQ_quoteLine.cls
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: Contact Trigger Handler Class
//==================================================================================================
//          Date            Purpose
// Changes: 02/21/2018      Initial Version
//==================================================================================================

public class th_CPQ_quoteLine  {


    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public th_CPQ_quoteLine (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    

    //Before Insert
    public void OnBeforeInsert(list<SBQQ__QuoteLine__c> updatedQuotes, Map<Id, SBQQ__QuoteLine__c> OldQuoteMap, Map<Id, SBQQ__QuoteLine__c> NewQuoteMap){
        

        //Update PBE On QuoteLines
        methods_cpqQuotelines.updateCPQValues(updatedQuotes);
    }

    //Before Update
    public void OnBeforeUpdate(list<SBQQ__QuoteLine__c> oldQuotes, list<SBQQ__QuoteLine__c> updatedQuotes, Map<Id, SBQQ__QuoteLine__c> OldQuoteMap, Map<Id, SBQQ__QuoteLine__c> NewQuoteMap){
        
        //Update PBE On QuoteLines
        methods_cpqQuotelines.updateCPQValues(updatedQuotes);
    }
 
}