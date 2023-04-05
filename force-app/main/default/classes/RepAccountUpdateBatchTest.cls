@isTest
private class RepAccountUpdateBatchTest {
 
    @isTest 
    private static void testmethod1(){
       
        Account parentAcc = new Account();
        parentAcc.Name = 'Parent test';
        parentAcc.Customer_Number__c = '12345';
        insert parentAcc;
        Account childAcc = new Account();
        childAcc.Name = 'Child test';
        childAcc.Rep_Firm_Oracle_Number__c = '12345';
        insert childAcc;
        
        String cronExpr = '0 0 0 15 3 ? 2022';
        String jobRunningTime = '2022-03-15 00:00:00';
        
        Test.startTest();
        String jobId = System.schedule('myJobTestJobName', cronExpr, new RepAccountUpdateScheduler());
        Test.stopTest();

    
    }
}