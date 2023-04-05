/*
*******************************************************************************************
# FILE...AssetTrigger_Test
# CREATED BY...Chirag Rathi
# CREATED DATE....1st March 2022
# LAST MODIFIED BY......Chirag Rathi 
# LAST MODIFIED DATE....1st March 2022
*******************************************************************************************
# AUTHOR...Chirag Rathi
# DESCRIPTION...Test class to cover methods of AssetTrigger for new created assets having files and field of related Opportunity
				when opportunity stage is 'Quote Accepted SOW Signed' and record type is 'Professional Service Opportunity'.
# CHANGE/ BUG FIX LOG...................:
******************************************************************************************
*/
@isTest
public class AssetTrigger_Test {
    Public static testMethod void test(){
        date closedt = date.today();
        Account acc = new Account (name= 'TestAccountAcc');
        insert acc;
        system.debug('>>>>acc'+acc.id);
        
        Id OppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Professional Services Opportunity').getRecordTypeId();
        opportunity opp = new opportunity (name = 'testOpportunity',accountId = acc.id,stagename = 'Draft', CloseDate = closedt, recordtypeid = OppRecordTypeId);
        insert opp;
        system.debug('>>>>opp'+opp.id);
        
        Id pricebookId = Test.getStandardPricebookId();
		
        //create your quore
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__PricebookId__c = pricebookId;
        quote.SBQQ__Account__c = acc.Id;
        quote.SBQQ__Status__c = 'Approved';
        quote.SBQQ__Opportunity2__c = opp.Id;
        //quote.Name = 'Test Quote';
        insert quote;
        
        //Create your product
        Product2 prod = new Product2(
             Name = 'Product X',
             ProductCode = 'Pro-X',
             isActive = true
        );
        insert prod;
        //system.assert(prod.id!=null);
        
        //Create pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
             Pricebook2Id = pricebookId,
             Product2Id = prod.Id,
             UnitPrice = 100.00,
             IsActive = true
        );
        insert pbEntry;
        //system.assert(pbEntry.id!=null);
        
        //create opportunity line item.  This assumes that opportunity is already created, called opp
        OpportunityLineItem oli = new OpportunityLineItem(
             OpportunityId = opp.Id,
             Quantity = 5,
             PricebookEntryId = pbEntry.Id,
             TotalPrice = 5 * pbEntry.UnitPrice
        );
        insert oli;
		//system.assert(oli.id!=null);
                
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        system.assert(content.id!=null);
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=opp.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
       	insert contentlink;
        //system.assert(contentlink.id!=null);
        
        opportunity Opp1 = new opportunity (id=opp.id,stageName= 'Quote Accepted SOW Signed');
        update opp1;
        
    }

}