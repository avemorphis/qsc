@isTest()
public class sendEmailCDL_Test {
    public static testMethod void test(){
    Account acc = new Account(Name = 'testcontr');
        insert acc;
        system.debug('>>>>acc'+ acc.id);
        //system.assert(acc.id!=null);
        Id recordTypeId_APAC = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('APAC Partner Contract').getRecordTypeId();
        Contract contr = new Contract(accountId=acc.id, status='draft', recordtypeid =recordTypeId_APAC);
        insert contr;
        system.debug('>>>>contr'+ contr.id);
        //system.assert(contr.id!=null);
        
        ContentDocumentLink__c custSetting = new ContentDocumentLink__c(ActiveTrigger__c=true);
        insert custSetting;
        
        contact con = new contact (email='mathur.meha@kcloudtechnologies.com',lastName='X');
        insert con;
        contact con2 = new contact (email='aba@yz.com',lastName='Xz');
        insert con2;
        system.debug('>>>con'+con.id);
        System.debug('>>>>>Owener' + con.ownerid);
        
         case cas = new case (contactId= con.id,Country_of_use_pl__c='India',CurrencyIsoCode='USD',Origin='Phone',Type='None',Status='New');
        insert cas;
         case cas2 = new case (contactId= con2.id,Country_of_use_pl__c='India',CurrencyIsoCode='USD',Origin='Phone',Type='None',Status='New');
        insert cas2;
        //case cas3 = new case (contactId= con2.id,Country_of_use_pl__c='India',CurrencyIsoCode='USD',Origin='Phone',Type='None',Status='Pending Closure',id = cas.id,New_Attachment__c = true);
        //update cas3;

        //case cas4 = new case (contactId= con2.id,Country_of_use_pl__c='India',CurrencyIsoCode='USD',Origin='Phone',Type='None',Status='Pending Closure',id = cas.id,New_Attachment__c = true);
        //update cas4; 
        
        System.debug('>>>>Case Owner' + cas.ownerid);
        System.debug('>>>>Case Owner' + cas.owner.email);
        system.debug('>>>cas'+ cas.id);
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        //system.assert(content.id!=null);
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=contr.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
       	insert contentlink;
        
        ContentDocumentLink contentlink2=new ContentDocumentLink();
        contentlink2.LinkedEntityId=cas.id;
        contentlink2.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink2.ShareType = 'I';
        contentlink2.Visibility = 'AllUsers'; 
       	insert contentlink2;
        
	}
    
   

}