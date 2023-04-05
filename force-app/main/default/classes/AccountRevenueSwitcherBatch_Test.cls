@isTest
public class AccountRevenueSwitcherBatch_Test {
    public static testMethod void test(){
        Account acc= new account(name='testAccount', 
                                 Previous_2_FY__c= 100,
                                 FY_20__c=100,
                                 Previous_FY__c=200,
                                 FY_21__c=200
                                );
        insert acc;
        system.debug('>>>>acc' + acc.id);
    
        Test.startTest();
        AccountRevenueSwitcherBatch batchRev = new AccountRevenueSwitcherBatch();
		database.executeBatch(batchRev,100);
        Test.stopTest();
    
    }
}