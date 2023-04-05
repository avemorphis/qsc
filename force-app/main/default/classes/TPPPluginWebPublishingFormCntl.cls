public class TPPPluginWebPublishingFormCntl {
    @AuraEnabled
    public static string SaveFormDetailsinAsset(string assetId, string webnameofInteg, string webdescpofInteg, string imgOfProductName, string imgfilebase64, string lstFilesData) {
        User userRecord = [SELECT Id, AccountId, Account.Name, ContactId, Contact.Name, Contact.Email FROM User WHERE ID =: UserInfo.getUserId() LIMIT 1];
        TPP_Data_Update__e tdu = new TPP_Data_Update__e();
        tdu.AssetId__c = assetId;
        tdu.Web_Name_of_Intg__c = webnameofInteg;
        tdu.Web_Descr_of_Integ__c = webdescpofInteg;
        tdu.ContactId_for_Email__c = userRecord.ContactId;
        tdu.Type__c = 'Asset';
        EventBus.publish(tdu);
        if(string.isNotBlank(imgfilebase64) && string.isNotBlank(imgOfProductName)){
            ContentVersion cv = CreateFilesDynamically.createContentVersion(imgfilebase64,imgOfProductName);
            ContentDocumentLink cdl = CreateFilesDynamically.createContentLink(cv.Id, assetId);
        }
        if(string.isNotBlank(lstFilesData)){
            CreateFilesDynamically.createFilesinBulk(assetId,lstFilesData);
        }
        return 'Success';
    }
   
}