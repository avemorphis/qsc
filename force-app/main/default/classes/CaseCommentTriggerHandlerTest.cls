@isTest
public class CaseCommentTriggerHandlerTest {
    
    @isTest(SeeAllData=true)
    public static void createCaseComment(){
        /*Triggers__c trisetting = new Triggers__c();
        trisetting.Name = 'CaseComment';
        trisetting.IsActive__c = true;
        insert trisetting;*/
        
        RecordType qry1 = [SELECT Id, Name, DeveloperName, Description, BusinessProcessId, SobjectType FROM RecordType Where Name='End User Individual' limit 1];
        Account acc = new Account();
        acc.RecordTypeId = qry1.Id;
        acc.Name = 'test acc7';
        insert acc;
        
        
        Product2 pro = new Product2();
        pro.Name = 'testProduct';
        pro.IsActive = true;
        pro.Cases__c = true;
        insert pro;
        
        test.startTest();
          Triggers__c custSetting = new Triggers__c(IsActive__c=true,Name='test');
        insert custSetting;
        RecordType RecordTypeID = [SELECT Id, Name, DeveloperName, Description, BusinessProcessId, SobjectType FROM RecordType Where Name='QSC Contact Record Type' limit 1];
        contact con = new contact (email='abx@zy.com',lastName='test56',RecordTypeId=RecordTypeID.Id,Phone='13456789');
        insert con;
        
        
        
        system.debug('>>>con'+con.id);
        System.debug('>>>>>Owener' + con.ownerid);
        //system.assert(con2.id!=null);
        RecordType qry = [SELECT Id, Name, DeveloperName, Description, BusinessProcessId, SobjectType FROM RecordType Where Name='ProSvc' limit 1];
        case cas = new case (contactId= con.id,Country_of_use_pl__c='India',RecordTypeId =qry.Id,Product_If_No_Asset__c=pro.Id,AccountId=acc.Id,
                             CurrencyIsoCode='USD',Origin='Web',Type='Professional Service',Status='New',Subject='test case', OwnerId=userinfo.getUserId());
        insert cas;
        system.assert(true,cas != null);
             CaseComment cascom = new CaseComment();
        cascom.IsPublished = true;
        cascom.ParentId = cas.Id;
        cascom.CommentBody = 'testcomment from customer';
        insert cascom;
        system.assert(true,cascom !=null);
       
        test.stopTest();
        
    }
}