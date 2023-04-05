@isTest
public class RollupCertificationTest {

    static testmethod void myTestMethod1() {
     
          //Update Account on Contact//
        Account acc=new Account();
        acc.Name='partner account';
        
        acc.Domain_s__c = 'gmail1.com';
        acc.Account_Category__c='Individual';
        Insert acc;
        system.debug('acc: '+acc);
       
         ///Build Contact Record//
        contact c=new contact();
        c.FirstName ='TD-Test';
        c.LastName ='Class';
        c.Phone='4561334554'; 
        c.Email='test123@gmail34.com';
        c.AccountId = acc.Id;
        Insert c;
        
        Course__c co = new Course__c();
        co.Contact__c = c.Id;
        co.Name = 'Nametest';
        Insert co;
        
        Certificate__c cert = new Certificate__c();
        cert.course_sfdc_id__c = co.id;
        cert.contact_sfdc_id__c = c.id;
        cert.name = 'Q-SYS Control 201 Certificate';
        cert.certified__c = 'yes';
        Insert cert;
        
      
    }
    
    static testmethod void myTestMethod2() {
     
          //Update Account on Contact//
        Account acc=new Account();
        acc.Name='partner account';
        
        acc.Domain_s__c = 'gmail1.com';
        acc.Account_Category__c='Individual';
        Insert acc;
        system.debug('acc: '+acc);
       
         ///Build Contact Record//
        contact c=new contact();
        c.FirstName ='TD-Test';
        c.LastName ='Class';
        c.Phone='4561334554'; 
        c.Email='test123@gmail34.com';
        c.AccountId = acc.Id;
        Insert c;
       
       
        c.Email='test123@gmai34.com';
           c.AccountId = null;
        update c;
        
      
    }
    
    

}