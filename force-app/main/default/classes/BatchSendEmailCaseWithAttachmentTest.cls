@isTest
public class BatchSendEmailCaseWithAttachmentTest {
    @testsetup
    private static void doSetup(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'myUser', Email='mohnish.pp@kcloudtechnologies.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='mohnish.pp@kcloudtechnologies.com');
        insert u;
        User u2 = new User(Alias = 'MX000', Email='mohnish.op@kcloudtechnologies.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='test@kcloudtechnologies.com', signature='This For Test\n\nThanks');
        insert u2;
        System.debug('>>>>>UserId' + userinfo.getUserId());
        Group testGroup = new Group(Name='Testing Queue', Type='Queue');
        insert testGroup;
        QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
        insert testQueue;
        groupmember m = new groupmember(groupid = testGroup.id, userorgroupid = u2.id);
        insert m;
    }
    public static testMethod void test(){
        List<user> u = [select id from user where alias in ('MX000', 'myUser')];
        System.debug('Usr:' + u);
        List<queuesobject> queueList = [select id, queueid, SObjectType from queuesobject where SObjectType = 'Case'];
        System.debug('Q: ' + queueList);
        List<group> gr = [select id from group where id in (select groupid from groupmember where userorgroupid =:u)];
        System.debug('GroupId: ' + gr);
        contact con = new contact (email='mathur.meha@kcloudtechnologies.com',lastName='X', ownerid = u[0].id);
        insert con;
        contact con2 = new contact (email='aba@yz.com',lastName='Xz', ownerid = u[1].id);
        insert con2;
        system.debug('>>>con'+con.id);
        System.debug('>>>>>Owener' + con.ownerid);
        //system.assert(con2.id!=null);
        
        case cas = new case (contactId= con.id,Country_of_use_pl__c='India',CurrencyIsoCode='USD',Origin='Phone',Type='None',Status='New', ownerid = u[1].id);
        insert cas;
         case cas2 = new case (contactId= con2.id,Country_of_use_pl__c='India',CurrencyIsoCode='USD',Origin='Phone',Type='None',Status='New', ownerid = gr[0].id);
        insert cas2;
        
        
        System.debug('>>>>Case Owner' + cas.ownerid);
        System.debug('>>>>Case Owner' + cas.owner.email);
        system.debug('>>>cas'+ cas.id);
        //system.assert(case.id!=null);
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture2'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body1'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        
        ContentVersion content2=new ContentVersion(); 
        content2.Title='Header_Picture22'; 
        content2.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob2=Blob.valueOf('Unit Test ContentVersion Body12'); 
        content2.VersionData=bodyBlob2; 
        //content.LinkedEntityId=sub.id;
        content2.origin = 'H';
        insert content2;
        system.debug('>>>content>>> ' + content2.id );
        //system.assert(content2!=null);
        
        ContentVersion content3=new ContentVersion(); 
        content3.Title='5MB Data'; 
        content3.PathOnClient='/' + content.Title + '.zip'; 
        Blob bodyBlob3=Blob.valueOf('a'.repeat(5242880)); 
        content3.VersionData=bodyBlob3; 
        //content.LinkedEntityId=sub.id;
        content3.origin = 'H';
        insert content3;
        system.debug('>>>content>>> ' + content3.id );
        //system.assert(content2!=null);
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=cas.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
       	insert contentlink;
        
        ContentDocumentLink contentlink2=new ContentDocumentLink();
        contentlink2.LinkedEntityId=cas.id;
        contentlink2.contentdocumentid=[select contentdocumentid from contentversion where id =: content2.id].contentdocumentid;
        contentlink2.ShareType = 'I';
        contentlink2.Visibility = 'AllUsers'; 
       	insert contentlink2;
        
        ContentDocumentLink contentlink3=new ContentDocumentLink();
        contentlink3.LinkedEntityId=cas2.id;
        contentlink3.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink3.ShareType = 'I';
        contentlink3.Visibility = 'AllUsers'; 
       	insert contentlink3;
        
        ContentDocumentLink contentlink21=new ContentDocumentLink();
        contentlink21.LinkedEntityId=cas2.id;
        contentlink21.contentdocumentid=[select contentdocumentid from contentversion where id =: content2.id].contentdocumentid;
        contentlink21.ShareType = 'I';
        contentlink21.Visibility = 'AllUsers'; 
       	insert contentlink21;
        system.debug('>>>contentLink' + contentlink2.id);
        //system.assert(contentlink!=null);
        ContentDocumentLink contentlink211=new ContentDocumentLink();
        contentlink211.LinkedEntityId=cas2.id;
        contentlink211.contentdocumentid=[select contentdocumentid from contentversion where id =: content3.id].contentdocumentid;
        contentlink211.ShareType = 'I';
        contentlink211.Visibility = 'AllUsers'; 
       	insert contentlink211;
        system.debug('>>>contentLink' + contentlink211.id);
        //system.assert(contentlink211!=null);
        Test.startTest();
        Database.executeBatch(new BatchSendEmailforCasewithAttachment(), 100);
        Test.stopTest();
        
    }

}