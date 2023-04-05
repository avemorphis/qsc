/**************************************************************************************************************
* @File Name          : Test_ContentDocumentLinkTrigger.cls
* @description        : This class is a test class where we testing the ContentDocumentLinkTrigger.
* @Author             : naman.gupta@qsc.com
* @Group              : 
* @Last Modified By   : naman.gupta@qsc.com
* @Last Modified On   : 04/01/2023
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    04/01/2023   	naman.gupta
**************************************************************************************************************/
@isTest
public class Test_ContentDocumentLinkTrigger 
{
	@isTest
    public static void testTrigger()
    {
        Test.startTest();
        
        //Create Account Record.
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        INSERT objAccount;
        
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
        
        //Create ContentVersion Record.
        ContentVersion objContentVersion = new ContentVersion(); 
        objContentVersion.Title = 'Header_Picture1'; 
        objContentVersion.PathOnClient = '/' + objContentVersion.Title + '.jpg'; 
        objContentVersion.VersionData = bodyBlob; 
        objContentVersion.origin = 'H';
        INSERT objContentVersion;
        
        System.assertEquals('Header_Picture1', objContentVersion.Title);
        
        String contentDocumentId = [SELECT contentdocumentid FROM contentversion WHERE Id =: objContentVersion.Id].contentdocumentid;
        
        //Create ContentDocumentLink Record.
        ContentDocumentLink objContentDocumentLink = new ContentDocumentLink();
        objContentDocumentLink.LinkedEntityId = objAccount.Id;
        objContentDocumentLink.contentdocumentid = contentDocumentId;
        objContentDocumentLink.ShareType = 'I';
        objContentDocumentLink.Visibility = 'AllUsers';
        INSERT objContentDocumentLink;
        
        List<Account> listAccounts = [SELECT Id, DPP_Agreement_Signed_Date__c 
                                      FROM Account
                                      WHERE Id =: objAccount.Id
                                     ];
        
        System.assertEquals('AllUsers', objContentDocumentLink.Visibility);
        System.assertEquals(Date.today(), listAccounts[0].DPP_Agreement_Signed_Date__c);
        
        Test.stopTest();
    }
}