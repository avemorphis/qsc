public class OpportunityFileCloneController {
    private final Id recordId;
    private final Opportunity record;
    
    private final ApexPages.StandardController controller; 
    
    public OpportunityFileCloneController(ApexPages.StandardController controller) {
        this.controller = controller;
        this.record = (Opportunity)(this.controller.getRecord());
        this.recordId = this.controller.getId();
        System.debug('this.recordId'+recordId);
    }    
    
    public PageReference cloneWithFiles() {
      
        Opportunity newOpportunity = this.record.clone(false, true);  
        Opportunity cd = [Select id,Name,CloseDate,StageName,Primary_Contact__c,Request_Verticals_Served__c,Request_Phone__c,Request_Integration_Developer_Email__c,Request_Contact_Email__c,Request_Integration_Developer_Name__c,CommitStatus__c,Status__c,Funding__c,LeadSource,AccountId,Est_Installation_Date__c,X3rd_Party_Developer_Contact__c,Manufacturer_Developer_Contact__c,Manufacturing_Scoping_Contact__c,Q_Sys_Integration__c,Q_SYS_Integration_Type__c,QSC_Testing_Equipment_Required__c,Manufacturer_Testing_Equipment_Required__c,Integration_Type_Dropdown__c,Asset_Manager_Categorization__c,Reflect_Enabled__c,Certification_Award_Date__c,Verification_Award_Date__c,Jira_Link__c,Confluence_Link__c,Customer_Scoping_Contact__c,Scoping_Service__c,Web_Name_of_Integration__c,Web_Description_of_Integration__c,Partner_Links_and_Resources__c,ManufacturerIntegrationSupport__c,Developer_Integration_Support__c,Developer_Integration_Support_Contact__c,Developer_Specific_Support_Link__c,Developer_Support_Number__c,Developer_Support_Term_Expiration__c,Support_Notes__c,Manufacturer_Integration_Support_Contact__c,Manufacturer_Specific_Support_Link__c,Manufacturer_Support_Number__c,Manufacturer_Support_Term_Expiration__c,Legal_Code_Owner_of_record__c,Author_published_Q_SYS_OS_version__c,Q_SYS_Publishing_Date__c,Parent_Opportunity__c,Probability,Additional_Notes__c from Opportunity where id =: this.recordId];
        newOpportunity.StageName = cd.StageName;
        newOpportunity.Name = cd.Name;
        newOpportunity.AccountId = cd.AccountId;
        newOpportunity.Est_Installation_Date__c = cd.Est_Installation_Date__c;
        //newOpportunity.TPP_Annual_Subscription__c = cd.TPP_Annual_Subscription__c;
        //newOpportunity.TPP_Membership__c = cd.TPP_Membership__c;
        //newOpportunity.TPP_Membership_Renewal_Date__c = cd.TPP_Membership_Renewal_Date__c;
       // newOpportunity.test_field__c = cd.test_field__c;
        newOpportunity.CommitStatus__c = cd.CommitStatus__c;
        newOpportunity.Status__c = cd.Status__c;
        newOpportunity.Funding__c = cd.Funding__c;
       // newOpportunity.TPP_Annual_Membership_Origination_Date__c = cd.TPP_Annual_Membership_Origination_Date__c;
        newOpportunity.Request_Integration_Developer_Name__c = cd.Request_Integration_Developer_Name__c;
        newOpportunity.Request_Integration_Developer_Email__c = cd.Request_Integration_Developer_Email__c;
        newOpportunity.Request_Contact_Email__c = cd.Request_Contact_Email__c;
        newOpportunity.Request_Phone__c = cd.Request_Phone__c;
        newOpportunity.Request_Verticals_Served__c = cd.Request_Verticals_Served__c;
       // newOpportunity.API_Call_Completed__c = cd.API_Call_Completed__c;
       // newOpportunity.AssociatedQSYSDeveloper__c = cd.AssociatedQSYSDeveloper__c;
       // newOpportunity.QSC_SOA_Contact__c = cd.QSC_SOA_Contact__c;
       // newOpportunity.QSC_Lead_Developer_Contact__c = cd.QSC_Lead_Developer_Contact__c;
        newOpportunity.Primary_Contact__c = cd.Primary_Contact__c;
        newOpportunity.X3rd_Party_Developer_Contact__c = cd.X3rd_Party_Developer_Contact__c;
        newOpportunity.Manufacturer_Developer_Contact__c = cd.Manufacturer_Developer_Contact__c;
        newOpportunity.Manufacturing_Scoping_Contact__c = cd.Manufacturing_Scoping_Contact__c;
        newOpportunity.Q_Sys_Integration__c = cd.Q_Sys_Integration__c;
        newOpportunity.Q_SYS_Integration_Type__c = cd.Q_SYS_Integration_Type__c;
        newOpportunity.QSC_Testing_Equipment_Required__c = cd.QSC_Testing_Equipment_Required__c;
        newOpportunity.Manufacturer_Testing_Equipment_Required__c = cd.Manufacturer_Testing_Equipment_Required__c;
        newOpportunity.Integration_Type_Dropdown__c = cd.Integration_Type_Dropdown__c;
        newOpportunity.Asset_Manager_Categorization__c = cd.Asset_Manager_Categorization__c;
        newOpportunity.Reflect_Enabled__c = cd.Reflect_Enabled__c;
        newOpportunity.Certification_Award_Date__c = cd.Certification_Award_Date__c;
        newOpportunity.Verification_Award_Date__c = cd.Verification_Award_Date__c;
        newOpportunity.Jira_Link__c = cd.Jira_Link__c;
        newOpportunity.Confluence_Link__c = cd.Confluence_Link__c;
        newOpportunity.Customer_Scoping_Contact__c = cd.Customer_Scoping_Contact__c;
        newOpportunity.Scoping_Service__c = cd.Scoping_Service__c;
        newOpportunity.Web_Name_of_Integration__c = cd.Web_Name_of_Integration__c;
        newOpportunity.Web_Description_of_Integration__c = cd.Web_Description_of_Integration__c;
        newOpportunity.Partner_Links_and_Resources__c = cd.Partner_Links_and_Resources__c;
        newOpportunity.ManufacturerIntegrationSupport__c = cd.ManufacturerIntegrationSupport__c;
        newOpportunity.Developer_Integration_Support__c = cd.Developer_Integration_Support__c;
        newOpportunity.Developer_Integration_Support_Contact__c = cd.Developer_Integration_Support_Contact__c;
        newOpportunity.Developer_Specific_Support_Link__c = cd.Developer_Specific_Support_Link__c;
        newOpportunity.Developer_Support_Number__c = cd.Developer_Support_Number__c;
        newOpportunity.Developer_Support_Term_Expiration__c = cd.Developer_Support_Term_Expiration__c;
        newOpportunity.Support_Notes__c = cd.Support_Notes__c;
        newOpportunity.Manufacturer_Integration_Support_Contact__c = cd.Manufacturer_Integration_Support_Contact__c;
        newOpportunity.Manufacturer_Specific_Support_Link__c = cd.Manufacturer_Specific_Support_Link__c;
        newOpportunity.Manufacturer_Support_Number__c = cd.Manufacturer_Support_Number__c;
        newOpportunity.Manufacturer_Support_Term_Expiration__c = cd.Manufacturer_Support_Term_Expiration__c;
        newOpportunity.Legal_Code_Owner_of_record__c = cd.Legal_Code_Owner_of_record__c;
        newOpportunity.Author_published_Q_SYS_OS_version__c = cd.Author_published_Q_SYS_OS_version__c;
        newOpportunity.Q_SYS_Publishing_Date__c = cd.Q_SYS_Publishing_Date__c;
        newOpportunity.Parent_Opportunity__c = cd.Parent_Opportunity__c;
        newOpportunity.Probability = cd.Probability;
        newOpportunity.Additional_Notes__c = cd.Additional_Notes__c;
        newOpportunity.CloseDate = cd.CloseDate;
        insert newOpportunity;
        
        List<Contract> clonedContract = new List<Contract>();
        for(Contract cot : [Select id, AccountId, Status, CurrencyIsoCode, StartDate,ContractTerm,SBQQ__Opportunity__c from Contract where SBQQ__Opportunity__c =: this.recordId]){
            Contract newContract = cot.clone(false, true);
            newContract.SBQQ__Opportunity__c = newOpportunity.id;
            clonedContract.add(newContract);
        }
        insert clonedContract;
        
        /*List<Asset> clonedAsset = new List<Asset>();
        for(Asset asst : [Select id, AccountId,Name,CurrencyIsoCode,Opportunity__c from Asset where Opportunity__c =:this.recordId]){
            Asset newAsset = asst.clone(false, true);
            newAsset.Opportunity__c = newOpportunity.id;
            clonedAsset.add(newAsset);
        }
        insert clonedAsset;*/
        
         List<ContentDocumentLink> clonedContentDoc = new List<ContentDocumentLink>();
        for(ContentDocumentLink cdl :[SELECT ContentDocumentId,Id,IsDeleted,LinkedEntityId,ShareType,SystemModstamp,Visibility FROM ContentDocumentLink where LinkedEntityId=:this.recordId]){
            ContentDocumentLink newCdl = cdl.clone(false,true);
            newCdl.LinkedEntityId = newOpportunity.id;
            clonedContentDoc.add(newCdl);
        }
        if(!clonedContentDoc.isEmpty()){
            System.debug('Inside ClonedContentDoc');
            System.debug('ClonedContentDoc'+clonedContentDoc.size());
            insert clonedContentDoc;
        }
        
        List<Order> clonedOrders = new List<Order>();
        for(Order ord : [Select id, AccountId,ContractId, EffectiveDate, Status,OpportunityId from Order where OpportunityId =:this.recordId]){
            Order newOrders = ord.clone(false, true);
            newOrders.OpportunityId = newOpportunity.id;
            clonedOrders.add(newOrders);
        }
        insert clonedOrders;
        
        List<SBQQ__RelatedContent__c> clonedAdditional = new List<SBQQ__RelatedContent__c>();
        for(SBQQ__RelatedContent__c add : [Select id,SBQQ__Opportunity__c from SBQQ__RelatedContent__c where SBQQ__Opportunity__c =:this.recordId]){
            SBQQ__RelatedContent__c newAdditional = add.clone(false, true);
            newAdditional.SBQQ__Opportunity__c = newOpportunity.id;
            clonedAdditional.add(newAdditional);
        }
        insert clonedAdditional;     
        
       /* List<TPP_Activity__c> clonedActivity = new List<TPP_Activity__c>();
        for(TPP_Activity__c tpp : [Select id,Opportunity_Name__c,Name from TPP_Activity__c where Opportunity_Name__c =:this.recordId]){
            TPP_Activity__c newActivity = tpp.clone(false, true);
            newActivity.Opportunity_Name__c = newOpportunity.id;
            clonedActivity.add(newActivity);
        }
        insert clonedActivity; */
       
        List<Partner> partners = new List<Partner>();
        for (Partner pr : [Select AccountToId,p.IsPrimary, p.OpportunityId, p.Role From Partner p where OpportunityId = :cd.id]) {
        if (pr.AccountToId != newOpportunity.AccountId) {
        Partner newPR = pr.clone(false);
        newPR.OpportunityId = newOpportunity.id;
        partners.add(newPR);
        System.debug(newOpportunity.id);
       }

    }
  insert partners;
        
        OpportunityLineItem oppLineItemCloneRecord = new OpportunityLineItem(); 
            List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>(); 
            for(Opportunity opportunityObject: [SELECT Id, Name, (SELECT Id, Name, Quantity, TotalPrice,PricebookEntryId FROM OpportunityLineItems) FROM Opportunity WHERE Id = :recordId])
            {
                for(OpportunityLineItem oppLineItemObject: opportunityObject.OpportunityLineItems)
                {
                    oppLineItemCloneRecord = oppLineItemObject.clone(false, true, false, false); 
                    oppLineItemCloneRecord.OpportunityId = newOpportunity.Id; 
                    oppLineItemCloneRecord.Quantity = oppLineItemObject.Quantity;
                    oppLineItemCloneRecord.TotalPrice = oppLineItemObject.TotalPrice;
                    System.debug('oppLineItemCloneRecord----->' + oppLineItemCloneRecord);
                    
                    oppLineItemList.add(oppLineItemCloneRecord); 
                    
                    System.debug('oppLineItemList----->' + oppLineItemList);
                }
                
                insert oppLineItemList; 
            } 
        
        
        return new ApexPages.StandardController(newOpportunity).view();
    }      
}