/*
*******************************************************************************************
# FILE...BatchSendEmailContractwithAttachmentTest
# CREATED BY...Meha Mathur
# CREATED DATE....10th Feb 2022
# LAST MODIFIED BY......Meha Mathur
# LAST MODIFIED DATE....13th Feb 2022
*******************************************************************************************
# AUTHOR...Meha Mathur
# DESCRIPTION...Test class for Batch class 'BatchSendEmailforContractwithAttachment'.
# CHANGE/ BUG FIX LOG...................:
******************************************************************************************
*/

@istest
public class BatchSendEmailContractwithAttachmentTest {
    public static testMethod void test(){
        Account acc = new Account(Name = 'testcontr');
        insert acc;
        system.debug('>>>>acc'+ acc.id);
        system.assert(acc.id!=null);
        Id recordTypeId_APAC = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('APAC Partner Contract').getRecordTypeId();
        Contract contr = new Contract(accountId=acc.id, status='draft', recordtypeid =recordTypeId_APAC);
        insert contr;
        system.debug('>>>>contr'+ contr.id);
        system.assert(contr.id!=null);
        
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
        contentlink.LinkedEntityId=contr.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
       	insert contentlink;
        system.assert(contentlink.id!=null);
               
        Test.startTest();
        BatchSendEmailforContractwithAttachment batchContr = new BatchSendEmailforContractwithAttachment();
		database.executeBatch(batchContr,100);
        Test.stopTest();
        
        
    }

}