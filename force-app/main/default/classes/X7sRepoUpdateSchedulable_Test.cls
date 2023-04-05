@IsTest
private class X7sRepoUpdateSchedulable_Test {
    
    @IsTest
    static void testSchedule() {

        Test.startTest();
        X7sRepoUpdateSchedulable myClass = new X7sRepoUpdateSchedulable();   
        String chron = '0 0 23 * * ?';        
        System.schedule('Test Sched', chron, myClass);
        Test.stopTest();
        
    }

}