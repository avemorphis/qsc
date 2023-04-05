public class LMSAutomatedEmailBatch implements Database.Batchable<sObject>{
    
    //get all the exam records qualified for sending notifications
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Contact__c,exam_submission_status__c,Last_LMS_Notification_Date__c, Date_of_Most_Recent_Feedback__c,Date_of_Most_Recent_Submission__c, Difference_Between_MRFToday__c, IsEmailAllowed__c,Contact__r.Email FROM Exam__c WHERE IsEmailAllowed__c = TRUE AND ((Date_of_Most_Recent_Feedback__c != null AND Date_of_Most_Recent_Feedback__c = LAST_N_DAYS:45) OR (exam_submission_status__c =\'Completed\' AND Last_LMS_Notification_Date__c != NULL ))  ORDER BY Date_of_Most_Recent_Feedback__c';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Exam__c> scope){
        
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        List<Exam__c> CompletedExamsList = new List<Exam__c>();
        List<Decimal> mdtList = new List<Decimal>();
        MAP<Decimal,String> lsmmdt = new MAP<Decimal,String>();
        
        //get the setup for notification from metadata when it should trigger email and which template to select
        for(LMS_Email_Notification_Deadline__mdt lms : [Select IsActive__c, TemplateId__c, No_of_Days_for_Notification__c,Order__c  from LMS_Email_Notification_Deadline__mdt where IsActive__c = true order by Order__c]){
            lsmmdt.put(lms.No_of_Days_for_Notification__c,lms.TemplateId__c);
            mdtList.add(lms.No_of_Days_for_Notification__c);
        }
        
        
        for(Exam__c exam : scope)
        {        
       
            Integer j = 0;
            for(Decimal d: mdtList){
                
                
                if(exam.exam_submission_status__c == 'Completed' && (exam.Last_LMS_Notification_Date__c == NULL || (exam.Last_LMS_Notification_Date__c != NULL && exam.Date_of_Most_Recent_Feedback__c != exam.Date_of_Most_Recent_Feedback__c))){
                    messages.addAll(SingleMessageServiceClass.sendLMSautomatedNotification(exam.Id,exam.Contact__c,exam.contact__r.Email,lsmmdt.get(mdtList[mdtList.size()-1])));
                    exam.IsEmailAllowed__c = FALSE;
                    exam.Last_LMS_Notification_Date__c = exam.Date_of_Most_Recent_Feedback__c;
                    CompletedExamsList.add(exam);
                    break;
                }
                
                if( d == exam.Difference_Between_MRFToday__c && (exam.Last_LMS_Notification_Date__c == NULL || (exam.Last_LMS_Notification_Date__c != NULL && exam.Date_of_Most_Recent_Feedback__c != exam.Date_of_Most_Recent_Feedback__c)) ){
                    messages.addAll(SingleMessageServiceClass.sendLMSautomatedNotification(exam.Id,exam.Contact__c,exam.contact__r.Email,lsmmdt.get(mdtList[j])));
                    exam.Last_LMS_Notification_Date__c = exam.Date_of_Most_Recent_Feedback__c;
                    CompletedExamsList.add(exam);
                    break;
                }    
                ++j;
            }
            
        }
      
        try {
        
            //send email using email message service and that will automatically log email in Exam record
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if(!CompletedExamsList.isEmpty()){
                update CompletedExamsList;
            }
            
        } catch(Exception e) {
          
             //Get running Class and Method
            String sTrace = e.getStackTraceString().substringAfter('\n');
           
            //Log Exception
            if(System.IsBatch() == false && System.isFuture() == false){ 
                globalExceptionHandlers.logInsertORUpdateException(globalExceptionHandlers.getClassName(sTrace), globalExceptionHandlers.getMethod(sTrace), String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            }
            
        }
        
    }
    
    public void finish(Database.BatchableContext BC){
    }
}