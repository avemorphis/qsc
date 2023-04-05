@isTest
public class UpdateAssingedAgentTest{
    public static testMethod void testTriggers() {
        
        List<Account> accList = new  List<Account>();
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.Copy_Billing_Address_to_Shipping_Address__c = true;
        acc.F_Loyalty_Level__c ='DIAMOND';
        acc.Assigned_Agent__c = UserInfo.getUserID();
        accList.add(acc);
        Account acc2 = new Account();
        acc2.Name = 'Test Acc2';
        acc2.Copy_Billing_Address_to_Shipping_Address__c = true;
        acc2.F_Loyalty_Level__c ='SILVER';
        accList.add(acc2);
        insert accList;
        
        test.startTest();
        list<contact> cl = new List<contact>();
        Contact con = new Contact();
        con.AccountId = accList[0].Id;
        con.LastName = 'Test Con';
        con.Email = 'BarneyRocksAllTheTime@barney.com';
        con.Assign_Agent_Manually__c = false;
        con.MailingPostalCode ='50003';
        insert con;
        Contact con2 = new Contact();
        con2.AccountId = accList[1].Id;
        con2.LastName = 'Test Con2';
        con2.Email = 'BarneyRocksAllTheTime1@barney.com';
        con2.Assign_Agent_Manually__c = false;
        con2.MailingPostalCode ='50002';
        insert con2;
        
        test.stopTest();
    }


}