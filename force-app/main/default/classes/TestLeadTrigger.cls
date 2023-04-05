@isTest
public class TestLeadTrigger {
    public static testMethod void testTriggers() {
        Lead ld = new Lead(LastName='Test Lead', 
                         Company='Test1 Inc.',
                         Status='Open - Not Contacted',
                         New_Project_Name__c = 'Test Proj',
                         Email='test@gmail.com',
                         Project_Type__c='Cinema',
                         Estimated_Budget__c=5.3,
                         Project_Estimated_close_Date__c = System.today(),
                         Project_City__c = 'NJ',
                         Project_Country__c = 'USA',
                         Project_Region__c = 'Test Region');
        insert ld;
    }
}