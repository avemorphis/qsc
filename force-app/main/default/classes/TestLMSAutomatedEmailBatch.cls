@isTest
public class TestLMSAutomatedEmailBatch {
    
    @istest
    public static void test1(){
        
        Contact c=new Contact();
        c.LastName='Test Contact';
        c.Phone='12456';
        c.CurrencyIsoCode='USD';
        c.Email='test.contact@gmail.com';
        insert c;
        
        Course__c course_obj=new Course__c();
        course_obj.Name='Q-SYS Level 1 Training';
        course_obj.CurrencyIsoCode='USD';
        course_obj.Contact__c=c.Id;
        insert course_obj;
        
        Exam__c exam_obj=new Exam__c();
        exam_obj.Contact__c=c.Id;
        exam_obj.Date_of_Most_Recent_Feedback__c=System.now();
        exam_obj.IsEmailAllowed__c=true;
        exam_obj.exam_submission_status__c='Completed';
        exam_obj.course_sfdc_id__c =course_obj.id;
        insert exam_obj;
        
        
        Exam__c exam_obj2=new Exam__c();
        exam_obj2.Contact__c=c.Id;
        exam_obj2.Date_of_Most_Recent_Feedback__c=System.now() - 20;
        exam_obj2.IsEmailAllowed__c=true;
        exam_obj2.exam_submission_status__c='Revision';
        exam_obj2.course_sfdc_id__c =course_obj.id;
        insert exam_obj2;
        
        Test.startTest();
        
        LMSAutomatedEmailBatch obj = new LMSAutomatedEmailBatch(); 
        DataBase.executeBatch(obj);
        
        Test.stopTest();
    }
}