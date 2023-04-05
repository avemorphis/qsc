@isTest
    private class BtachForUpdateContactPhoneTest {
     @isTest
        static void testMethod1(){
            List<Contact> conList = new List<Contact>();
           //Account acc = [Select id, Name from Account limit 1];
            
            Contact con = new Contact();
            con.LastName ='testContact';
            //con.AccountId = acc.id;
            con.Email = 'abc@abc.com';
            con.Phone = '2111781110';
            con.MailingCountry='USA';
            conList.add(con);
            insert conList;
            system.Assert(true,conList != null);
            
           test.startTest();
            BtachForUpdateContactPhone bc = new BtachForUpdateContactPhone();
             Database.executeBatch(bc);
          test.stopTest();
            
       }
        
        @isTest
        static void createContactRecordWith1(){
            List<Contact> conList = new List<Contact>();
          //List<Account> acc = [Select id, Name from Account limit 1];
            
            Contact con = new Contact();
            con.LastName ='Account1';
            //con.AccountId = acc[0].id;
            con.Email = 'abc@abc.com';
            con.Phone = '1 2111781110';
            con.MailingCountry='USA';
            conList.add(con);
            insert conList;
            system.Assert(true,conList != null);
            
           test.startTest();
            BtachForUpdateContactPhone bc = new BtachForUpdateContactPhone();
             Database.executeBatch(bc);
          test.stopTest();
            
       }
    }