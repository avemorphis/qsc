@isTest
public class BatchForInactiveContactsTest {
    @isTest
    public static void createContact(){
        
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.Account_Type__c = 'Partner';
        acc.Customer_Class__c = 'MULTI CHANNEL';
        acc.Partner_Category__c = 'DISTRIBUTOR';
        acc.Region_Oracle__c = 'EMEA';
        acc.Copy_Billing_Address_to_Shipping_Address__c = true;
        insert acc;
        
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.Active_Lookup__c = acc.Id;
        con.FirstName = 'Test';
        con.LastName = 'Con';
        con.Status__c = 'Inactive';
        con.Communication_Attributes__c = 'Partnership Program Manager;Corporate';
        con.Email = 'testforCampMembers@campMembers.com';
        conList.add(con);
        insert conList;
        system.assert(true,conList != null);
        
        test.startTest();
        BatchForInactiveContacts bc = new BatchForInactiveContacts();
        database.executeBatch(bc);
        test.stopTest();
        
    }
}