@istest
public class LMSAutomatedEmailSchedulerTest {

    static testmethod void test() {
        String CRON_EXP = '0 0 0 3 9 ? 2022';
   Test.startTest();

        String jobId = System.schedule('testScheduledApex',CRON_EXP,new LMSAutomatedEmailScheduler());

        Test.stopTest();
    }
    
}