@isTest
public class TestTaskEventTrigger {
    public static testMethod void testTriggers() {
        Task t = new Task ();
        t.ActivityDate = System.today().addDays(5);
        t.Status = 'Not started';
        t.Priority = 'Normal';
        t.Subject = 'Test task';
        insert t;
        
        Event ev = new Event(Subject ='Work Order',StartDateTime=System.Now(),DurationInMinutes=30 );
        insert ev;
    }
}