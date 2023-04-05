@isTest
Public class BtachForUpdatePhoneAccAndConTest {
  @isTest
    public static void createAccountRecords(){
        
        Id qaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();

        List<Account> accList = new List<Account>();
        Account acc = new Account ();
        acc.Name ='test account test1'; 
        acc.RecordTypeId= qaRecordTypeId;
        acc.BillingCountry = 'United States';
        acc.Phone = '8765436789';
        acc.CurrencyIsoCode ='USD';
        accList.add(acc);
        
         
        Insert accList;
 
        system.Assert(true,accList!=null);

        test.startTest();
        BtachForUpdatePhoneAccAndCon bc = new BtachForUpdatePhoneAccAndCon();
        database.executeBatch(bc);
        test.stopTest();
    }
    
    @isTest
    public static void createAccountRecordsWithPhoneCode1(){
        Id qaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Account acc = new Account ();
        acc.Name ='test account test1'; 
        acc.RecordTypeId= qaRecordTypeId;
        acc.BillingCountry = 'United States';
        acc.Phone = '1 8765436789';
        acc.CurrencyIsoCode ='USD';
        Insert acc;
        
        system.Assert(true,acc!=null);
        test.startTest();
        BtachForUpdatePhoneAccAndCon bc = new BtachForUpdatePhoneAccAndCon();
        database.executeBatch(bc);
        test.stopTest();
    }
       
}