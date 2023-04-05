public class BatchScheduleIdeasNotifications implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Database.QueryLocator q = Database.getQueryLocator(
            [SELECT Id, Related_Topic_Name__c, Title, CreatedDate, CreatedById, CreatedBy.Name FROM Idea Where CreatedDate = Today]);
        return q;
    }
    
    public void execute(Database.BatchableContext BC, List<Idea> records){
        Set<String> topicNames = new Set<String>();
        Map<String, List<Idea>> topWidIdea = new Map<string, List<Idea>>();
        for(Idea i : records)
        {
            system.debug('records recieved: '+i);
            topicNames.add(i.Related_Topic_Name__c);
            
            IF(topWidIdea.containsKey(i.Related_Topic_Name__c))
            {
            	List<idea> ideaList= topWidIdea.get(i.Related_Topic_Name__c);
            	ideaList.add(i);
            	topWidIdea.put(i.Related_Topic_Name__c,ideaList);
            }
            Else if(!topWidIdea.containsKey(i.Related_Topic_Name__c))
            {
            	List<idea> ideaList= new List<Idea>();
            	ideaList.add(i);
            	topWidIdea.put(i.Related_Topic_Name__c,ideaList);
            }
        }
         
        
        List<topic> topicData = [SELECT Id, NetworkId, Name, Description, CreatedDate, CreatedById, 
                                 TalkingAbout, ManagedTopicType, SystemModstamp FROM Topic
                                 Where Name IN: topicNames];
        Set<Id> topicIds = new Set<Id>();
        for(topic T : topicData)
        {
            topicIds.add(T.id);
        }
        //List<entity> where parent Id IN topic
        List<EntitySubscription> entitySubData = [SELECT Id, ParentId, Parent.Name, SubscriberId, Subscriber.Name, Subscriber.Email, CreatedById, 
                                                  CreatedDate, IsDeleted, NetworkId 
                                                  FROM EntitySubscription Where ParentId IN: topicIds];
        System.debug('entitySubData--'+entitySubData);
        
       Map<Id, List<String>> userWidTop = new Map<Id, List<String>>();
        set<Id> userIds = new set<Id>();
        for(EntitySubscription entSub : entitySubData)
        {
            //Retrieving user ids
            userIds.add(entSub.SubscriberId);
        }
        
        
       
        for(String userId : userIds)
        {
            list<String> topicNamelist = new List<string>();
            for(EntitySubscription entSub : entitySubData)
            {
                if(entSub.SubscriberId == userId)
                {
                    topicNamelist.add(entSub.Parent.Name);
                }
            }
            userWidTop.put(userId, topicNamelist);
        }
       
               
        //
        //
        //list<email>
        List<User> userData = [Select Id, Name, Email from User Where Id IN: userIds];
        List<Messaging.SingleEmailMessage> listToSendMails = new List<Messaging.SingleEmailMessage>();
        for(User usr : userData)
        {
            System.debug('usrName--'+usr.Name);
            //email - 
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String emailBody = 'Hello '+ usr.Name+'!<br/><br/>';
            List<string> topList = userWidTop.get(usr.Id);
            
            System.debug('topList---'+topList.size());
              for(string tpData : topList)
                {
                        List<Idea> idList = topWidIdea.get(tpData);
                        System.debug('idList---'+idList.size());
                        for(Idea i : idList)
                        {
                            emailBody += 'A New Idea, '+i.Title+' associated with the Topic of '+tpData+' was created in communities. <br/><br/>';
                        }
                    
                    }
                
            
            emailBody += 'Vote and comment on this Idea from the community to continue the conversation! <br/><br/>';
            emailBody += 'You are receiving this mail because you are subscribed to the content associated with the topic above.<br/><br/>';
            emailBody += '<br/>Best Regards,<br/> Q-SYS Communities for Developers';
            mail.setSubject('A new Ideas was created in your followed topics in communities');
            mail.setHtmlBody(emailBody);
            mail.setToAddresses(new List<string>{usr.Email});
            listToSendMails.add(mail);
        }
        
        try{
            system.debug('listToSendMails: '+listToSendMails);
            if(listtosendmails.size()>0){
               Messaging.sendEmailResult[] sendEmailResults = Messaging.sendEmail(listtosendmails);
                for(Messaging.SendEmailResult sendEmailResult: sendEmailResults){
                    if(sendEmailResult.isSuccess()){
                        system.debug('email sent succesfully');
                    }
                    else {
                       for (Messaging.Sendemailerror sendEmailError : 
                             sendEmailResult.getErrors()){
                                 system.debug('error msg '+ sendEmailError.Message);                                                   
                             }
                    }
                }
            }
        }catch(Exception e){
            System.debug('Exception while sending mail....');
        }
    }
    public void finish(Database.BatchableContext BC){
        
    }
}