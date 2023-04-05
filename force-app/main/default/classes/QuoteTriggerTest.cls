@isTest
//written to deply quotetrigger and CreateOpportunityShareCtrl class
public class QuoteTriggerTest {
    
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
        
        system.debug('contact: '+c);
        
        Account acc2=new Account();
        acc2.Name='non partner account';
        acc2.Domain_s__c = 'gmail12.com';
        acc2.Account_Category__c='Individual';
        acc2.Rep_Account__c = acc.Id;
        Insert acc2;
        
        system.debug('acc2: '+acc2);
        
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc2.Id;
        opp.StageName = 'Investigation';
        opp.CloseDate = Date.valueOf('2022-01-01');
        opp.Name = 'New Oppyfor test';

        Insert opp;
        
        Opportunity opp2 = new Opportunity();
        opp2.AccountId = acc2.Id;
        opp2.StageName = 'Investigation';
        opp2.CloseDate = Date.valueOf('2022-06-01');
        opp2.Name = 'New Oppyfor test2';

        Insert opp2;
        
        acc.isPartner = true;
        acc.Synced_Contact__c=c.Id;
        update acc;
        
        SBQQ__Quote__c quot = new SBQQ__Quote__c();
        quot.SBQQ__Partner__c = acc2.Id;
        quot.SBQQ__Opportunity2__c = opp.Id;
    
        SBQQ__Quote__c quot2 = new SBQQ__Quote__c();
        quot2.SBQQ__Partner__c = acc2.Id;
        quot2.SBQQ__Opportunity2__c = opp2.Id;
     
        List<SBQQ__Quote__c> qutoes = new List<SBQQ__Quote__c>();
        qutoes.add(quot);
        qutoes.add(quot2);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='PRM Partner Community User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, ContactId = c.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser12345@qscqa.com');

        
        
        Test.startTest();
        
        Insert u;
        
        
        System.debug('user' +  [Select Id,AccountId,Account.isPartner from User Where Id =: u.Id]);
        
        Insert quot;
        //Insert qutoes;
        Delete quot;
        Test.stopTest();
    }


}