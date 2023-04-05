public class TPPAccountCompanyLogoFormCntl {
    @AuraEnabled
    public static user getAccountDetails() {
        User userRecord = [SELECT Id, AccountId, Account.Name, ContactId, Contact.Name, Contact.Email FROM User WHERE ID =: UserInfo.getUserId() LIMIT 1];
        return userRecord;
    }
    @AuraEnabled
    public static string updateCompanyDescription(string accountId, string companyDescrp, string fileName, string filebase64) {
        /*Account acc = new Account();
        acc.Id = accountId;
        acc.Company_Description__c = companyDescrp;
        //update acc;*/
        user usr = getAccountDetails();
        TPP_Data_Update__e tdu = new TPP_Data_Update__e();
        tdu.AccountId__c = accountId;
        tdu.Account_Description__c = companyDescrp;
        tdu.Type__c = 'Account';
        tdu.ContactId_for_Email__c = usr.ContactId;
        EventBus.publish(tdu);
        if(string.isNotBlank(fileName) && String.isNotBlank(filebase64)){
            ContentVersion cv = createContentVersion(filebase64,fileName);
            ContentDocumentLink cdl = createContentLink(cv.Id, accountId);
        }
        return 'Success';
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