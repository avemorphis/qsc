public with sharing class TPPAssetFormController {
    @AuraEnabled
    public static List<Asset> getAssetsForAccount(){
        try {
            return [SELECT Id, TPP_ID__c,Name,Asset_Stage__c,Certification_Award_Date__c,Q_SYS_Expiration_Date__c,Is_Scoping__c,Q_SYS_Integration_Type__c FROM Asset WHERE Asset_Stage__c IN ('Planned','In Progress','Development','Award Testing','Released') AND AccountId IN (Select AccountId from User where Id =: UserInfo.getUserId() )];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string createCaseRecord(String assetIds,String subject,string description, string file,string filebase64){
        try {
            Id csRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Integration Support').getRecordTypeId();
            Case cs = new case();
            cs.Assets__c =  assetIds;
            cs.Subject =  subject;
            cs.Description =  description;
            cs.Origin = 'Web';
            cs.status = 'New';
            cs.RecordTypeId = csRecordTypeId;
            insert cs;
            system.debug('Case created'+cs.id);
            if(file != null && filebase64 != null){
                ContentVersion cv = createContentVersion(filebase64, file);
                ContentDocumentLink cdl = createContentLink(cv.Id, cs.Id);
            }
            Case c = [select id,CaseNumber from Case where Id=: cs.Id];
            Network myNetwork = [SELECT Id FROM Network WHERE Name ='tpp' ];
            string networkCaseUrl = Network.getLoginUrl(myNetwork.id).removeEnd('login');
            networkCaseUrl += 'case/'+c.Id;
            system.debug('networkCaseUrl>>>>>>>'+networkCaseUrl);
            return networkCaseUrl;
        } catch (Exception e) {
            system.debug('Exception caught'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
          insert cv;
          return cv;
        } catch(DMLException e) {
          System.debug(e);
          return null;
        }
    }
    @TestVisible 
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
        SELECT ContentDocumentId 
        FROM ContentVersion 
        WHERE Id =: contentVersionId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
}