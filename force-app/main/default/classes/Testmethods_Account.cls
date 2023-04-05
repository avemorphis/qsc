@IsTest
public class Testmethods_Account {
    @IsTest
    public static void TestAccountMethodsTest() {
        NFR_API__c nfrsetting = new NFR_API__c(); 
        nfrsetting.EndPoint_url__c = 'www.test.com';
        nfrsetting.Token_url__c = 'www.test.com';
       nfrsetting.Username__c = 'www.test.com';
       nfrsetting.Password__c = 'www.test.com';
       nfrsetting.x_function_key__c = 'www.test.com';
       nfrsetting.QueueURL__c = 'www.test.com';
        nfrsetting.Name = 'Case Trigger';
        insert nfrsetting;
        ///Build Contact Record//
        contact c=new contact();
        c.FirstName ='TD-Test';
        c.LastName ='Class';
        c.Phone='4561334554'; 
        c.Email='test123@gmail.com';
        insert c;
        //Update Account on Contact//
        Account acc=new Account();
        acc.Name='account';
        acc.Synced_Contact__c=c.Id;
        acc.Account_Category__c='Individual';
        acc.Account_Type__c = 'Partner';
        acc.Attributes__c = 'Reflect Reseller';
        insert acc;
        
        List<Account> accs=new List<Account>();
        Test.startTest();
        // calling the Class and Method with parameteres
        methods_Account.updateContactAccount(accs);
        
        Test.stopTest();
    }
    
    
}