public class SingleMessageServiceClass {
    
    public static List<Messaging.SingleEmailMessage> sendLMSautomatedNotification(Id ExamId, Id ContactId, String ContactEmail, String emailTemplateId){

    Messaging.SingleEmailMessage message = new  Messaging.SingleEmailMessage();
    message.setTargetObjectId(ContactId); 
    message.setSenderDisplayName('Company Support'); 
    message.setReplyTo('no-reply@company.com');
    message.setUseSignature(false); 
    message.setBccSender(false); 
    
    message.setSaveAsActivity(true); 
    message.setTemplateID(emailTemplateId); 
    message.setWhatId(ExamId); //This is important for the merge fields in template to work
    message.toAddresses = new String[] { ContactEmail };
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            return messages;
    
}
}