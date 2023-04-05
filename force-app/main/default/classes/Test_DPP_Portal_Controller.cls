@isTest
public class Test_DPP_Portal_Controller 
{
    @isTest
    public static void testDPPPortalControllerForAdmin()
    {
        Test.startTest();
        
        //Create coustom setting record.
        NFR_API__c nfrsetting = new NFR_API__c(); 
        nfrsetting.EndPoint_url__c = 'www.test.com';
        nfrsetting.Token_url__c = 'www.test.com';
        nfrsetting.Username__c = 'www.test.com';
        nfrsetting.Password__c = 'www.test.com';
        nfrsetting.x_function_key__c = 'www.test.com';
        nfrsetting.QueueURL__c = 'www.test.com';
        nfrsetting.Name = 'Case Trigger';
        insert nfrsetting; 
        
        //Create account record.
        Account objAccount = new Account();
        objAccount.Name = 'Test Acc';
        objAccount.Copy_Billing_Address_to_Shipping_Address__c = true;
        objAccount.Account_Type__c = 'Alliance';
        objAccount.Account_Category__c = 'Developer Partner';
        objAccount.DPP_Agreement_Status__c = 'Active';
        INSERT objAccount;
        
        //Create ContentVersion record.
        ContentVersion objContent = new ContentVersion(); 
        objContent.Title = 'Header_Picture1'; 
        objContent.PathOnClient = '/' + objContent.Title + '.png'; 
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body'); 
        objContent.VersionData = bodyBlob; 
        objContent.origin = 'H';
        INSERT objContent;
        
        //Create ContentVersion record.
        ContentVersion objContent1 = new ContentVersion(); 
        objContent1.Title = 'Header_Picture1'; 
        objContent1.PathOnClient = '/' + objContent.Title + '.pdf'; 
        objContent1.VersionData = bodyBlob; 
        objContent1.origin = 'H';
        INSERT objContent1;
        
        //Create ContentDocumentLink record.
        ContentDocumentLink objContentDocumentLink = new ContentDocumentLink();
        objContentDocumentLink.LinkedEntityId = objAccount.Id;
        objContentDocumentLink.contentdocumentid = [SELECT contentdocumentid FROM contentversion WHERE Id =: objContent.Id].contentdocumentid;
        objContentDocumentLink.ShareType = 'I';
        objContentDocumentLink.Visibility = 'AllUsers'; 
        INSERT objContentDocumentLink;
        
        //Create contact record.
        Contact objContact = new Contact();
        objContact.AccountId = objAccount.Id;
        objContact.LastName = 'Test Con';
        objContact.Email = 'BarneyRocksAllTheTime@barney.com';
        objContact.DPP_Access__c = 'Admin';
        INSERT objContact;
        
        //Create asset record.
        Asset objAsset = new Asset();
        objAsset.Name = 'Test Asset';
        objAsset.accountId = objAccount.Id;
        objAsset.AssociatedQSYSDeveloper__c = objAccount.Id;
        objAsset.X3rd_Party_Developer_Contact__c = objContact.Id;
        objAsset.Asset_Stage__c = 'Development';
        INSERT objAsset;
        
        Id profileId = [SELECT Id FROM profile WHERE Name = 'External User CCP Login'].Id;
        
        //Create user record.
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = profileId, country='United States',
                             IsActive =true,
                             ContactId = objContact.Id, 
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        INSERT user;
        
        System.runAs(user)
        {
            String blobValue = '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';
                
                DPP_Portal_Controller.getDPPAccessIsAdminOrUser();
            DPP_Portal_Controller.getUserAndContactInformation();
            DPP_Portal_Controller.updateContactDPPAccess(true, objContact.Id, true);
            DPP_Portal_Controller.updateContactDPPAccess(null, objContact.Id, true);
            DPP_Portal_Controller.updateContactDPPAccess(null, objContact.Id, false);
            DPP_Portal_Controller.getAssetInformation();
            DPP_Portal_Controller.getAccountDetails();
            DPP_Portal_Controller.assetStagePickListValueDynamically();
            DPP_Portal_Controller.getActiveAdminAndUserContact(objAccount.Id);
            DPP_Portal_Controller.sendEmailForBetaAccess(objContact.Id);
            String str = '{"accountId":"' + objAccount.Id + '","apiFileUploader":{"fileUpload":[{"base64":"' + blobValue + '", "fileName":"fileName"}]},"apiFileUploaderFileBase64":"Unit Test ContentVersion Body","apiFileUploaderFileName":"DPP.png","apiLink":"www.salesforce.com","contactEmail":"naman.gupta@qsc.com","desiredInstallationDate":"2023-02-01","integrationApplicability":"Testing","integrationDeveloperEmail":"testing@gmail.com","integrationDeveloperName":"Testing2","integrationObjective":"Testing1","logosFileUploader":{"fileUpload":[{"base64":"' + blobValue + '", "fileName":"fileName"}]},"logosFileUploaderFileBase64":"Unit Test ContentVersion Body","logosFileUploaderFileName":"avatar-3637561_1280.png","phone":"1234567890","primaryContactId":"' + objContact.Id  + '","prodImgFileUploader":{"fileUpload":[{"base64":"' + blobValue + '", "fileName":"fileName"}]},"prodImgFileUploaderFileBase64":"Unit Test ContentVersion Body","prodImgFileUploaderFileName":"MG-logo.png"}';
            system.debug('str : ' + str);
            Object obj = (Object) Json.deserializeUntyped(str);
            DPP_Portal_Controller.createContentVersion(blobValue, 'Test');
            DPP_Portal_Controller.createOpportunity(obj);
            DPP_Portal_Controller.closeNotification(objAsset.Id);
        }
        
        Test.stopTest();
    }
    
    @isTest
    public static void testDPPPortalControllerForUser()
    {
        Test.startTest();
        
        //Create coustom setting record.
        NFR_API__c nfrsetting = new NFR_API__c(); 
        nfrsetting.EndPoint_url__c = 'www.test.com';
        nfrsetting.Token_url__c = 'www.test.com';
        nfrsetting.Username__c = 'www.test.com';
        nfrsetting.Password__c = 'www.test.com';
        nfrsetting.x_function_key__c = 'www.test.com';
        nfrsetting.QueueURL__c = 'www.test.com';
        nfrsetting.Name = 'Case Trigger';
        insert nfrsetting;
        
        //Create account record.
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.Copy_Billing_Address_to_Shipping_Address__c = true;
        acc.Account_Type__c = 'Alliance';
        acc.Account_Category__c = 'Developer Partner';
        INSERT acc;
        
        //Create contact record.
        Contact con1 = new Contact();
        con1.AccountId = acc.Id;
        con1.LastName = 'Test Con';
        con1.Email = 'BarneyRocksAllTheTime@barney.com';
        con1.DPP_Access__c = 'User';
        INSERT con1;
        
        Id profileId = [SELECT Id FROM profile WHERE Name = 'Customer Community Plus Login User'].Id;
        
        //Create user record.
        User user1 = new User(alias = 'test123', email='test123@noemail.com',
                              emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                              localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
                              ContactId = con1.Id,
                              timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        INSERT user1;
        
        System.runAs(user1)
        {
            DPP_Portal_Controller.getDPPAccessIsAdminOrUser();
            DPP_Portal_Controller.getUserAndContactInformation();
            DPP_Portal_Controller.updateContactDPPAccess(false, con1.Id, true);
            DPP_Portal_Controller.updateContactDPPAccess(null, con1.Id, true);
            DPP_Portal_Controller.updateContactDPPAccess(null, con1.Id, false);
            DPP_Portal_Controller.getAssetInformation();
        }
        
        Test.stopTest();
    }
}