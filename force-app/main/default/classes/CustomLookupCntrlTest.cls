@isTest
public class CustomLookupCntrlTest {
    public static testMethod void fetchLookupData1(){
                NFR_API__c nfrSettingRecord = new NFR_API__c();
        nfrSettingRecord.Name = 'Case Trigger';
        nfrSettingRecord.EndPoint_url__c = 'https://web-apid01.qsc.com/api/Reflect/ExtendNFRDemoRequest';
        nfrSettingRecord.Password__c = 'test';
        nfrSettingRecord.QueueURL__c = 'https://web-apid01.qsc.com/api/Reflect/ExtendNFRDemoRequest';
        nfrSettingRecord.Token_url__c = 'https://web-apid01.qsc.com/token';
        nfrSettingRecord.Username__c = 'test';
        nfrSettingRecord.x_function_key__c = '100';
        insert nfrSettingRecord;
      Account acc= new account(name='testAccount', 
                                 Previous_2_FY__c= 100,
                                 FY_20__c=100,
                                 Previous_FY__c=200,
                                 FY_21__c=200
                                );
        insert acc;
        Id p = [select id from profile where name='TPP Community User'].id;
        
        Contact con = new Contact(LastName ='testCon',AccountId = acc.Id,email='testcommunity@gmail.com');
        insert con;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='TestingFinalcommunityUser', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = con.Id,
                             timezonesidkey='America/Los_Angeles', username='testercomdksldsdasmljd@noemail.com');
        
       
        insert user;
        System.debug('check user account'+user.AccountId);
        system.runAs(user) {
            
            Test.startTest();
            CustomLookupCntrl.fetchLookupData('testCon','Contact','qsysPluginReqForm','');
            Test.stopTest();
        }
    }
     public static testMethod void fetchDefaultRecord1(){
         NFR_API__c nfrSettingRecord = new NFR_API__c();
        nfrSettingRecord.Name = 'Case Trigger';
        nfrSettingRecord.EndPoint_url__c = 'https://web-apid01.qsc.com/api/Reflect/ExtendNFRDemoRequest';
        nfrSettingRecord.Password__c = 'test';
        nfrSettingRecord.QueueURL__c = 'https://web-apid01.qsc.com/api/Reflect/ExtendNFRDemoRequest';
        nfrSettingRecord.Token_url__c = 'https://web-apid01.qsc.com/token';
        nfrSettingRecord.Username__c = 'test';
        nfrSettingRecord.x_function_key__c = '100';
        insert nfrSettingRecord;
          Account acc= new account(name='testAccount', 
                                     Previous_2_FY__c= 100,
                                     FY_20__c=100,
                                     Previous_FY__c=200,
                                     FY_21__c=200
                                    );
            insert acc;
           Test.startTest();
            CustomLookupCntrl.fetchDefaultRecord(acc.id,'Account');
          CustomLookupCntrl.fetchDefaultRecord('','Account');
            Test.stopTest();
          
        }
        
      public static testMethod void fetchDefaultRecord2(){
          NFR_API__c nfrSettingRecord = new NFR_API__c();
        nfrSettingRecord.Name = 'Case Trigger';
        nfrSettingRecord.EndPoint_url__c = 'https://web-apid01.qsc.com/api/Reflect/ExtendNFRDemoRequest';
        nfrSettingRecord.Password__c = 'test';
        nfrSettingRecord.QueueURL__c = 'https://web-apid01.qsc.com/api/Reflect/ExtendNFRDemoRequest';
        nfrSettingRecord.Token_url__c = 'https://web-apid01.qsc.com/token';
        nfrSettingRecord.Username__c = 'test';
        nfrSettingRecord.x_function_key__c = '100';
        insert nfrSettingRecord;
          Account acc= new account(name='testAccount', 
                                     Previous_2_FY__c= 100,
                                     FY_20__c=100,
                                     Previous_FY__c=200,
                                     FY_21__c=200
                                    );
            insert acc;
           Test.startTest();
          CustomLookupCntrl.fetchLookupData('testCon','Contact',null,'');
           CustomLookupCntrl.fetchLookupData('testCon','Contact','qsysPluginReqForm','');
          CustomLookupCntrl.fetchLookupData('testCon','Contact','AddMembersForm','');
            Test.stopTest();
          
        }

}