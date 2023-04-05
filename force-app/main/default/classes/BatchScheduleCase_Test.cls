@isTest
public class BatchScheduleCase_Test {
    public static testMethod void test(){
    Test.startTest();
	BatchScheduleCase sh1 = new BatchScheduleCase();
	String sch = '0 0 2 * * ?'; 
	system.schedule('Test Territory Check', sch, sh1); 
	Test.stopTest();
    }

}