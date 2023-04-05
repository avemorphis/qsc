@isTest
public class ScheduleContractCase_Test {
    public static testMethod void test(){
    Test.startTest();
    BatchScheduleCaseContract sh = new BatchScheduleCaseContract();
    String sch = '0 0 2 * * ?'; 
    system.schedule('Test Territory Check', sch, sh); 
    Test.stopTest();
    }
}