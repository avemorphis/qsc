public class BatchIdeaNewsletter implements Database.Batchable<sObject>
{
    
    public Database.QueryLocator start(Database.BatchableContext bc) 
    {
        Database.QueryLocator q = Database.getQueryLocator(
            [SELECT Id, Related_Topic_Name__c, Title, CreatedDate, CreatedById, CreatedBy.Name FROM Idea Where CreatedDate = Today]);
        return q;
    }
    public void execute(Database.BatchableContext BC, List<Idea> ideaLst)
    {
        
        Set<String> topicNameSet = new Set<String>();
        Map<String, List<Idea>> topIdeaMap = new Map<string, List<Idea>>();
        
        for(Idea i : ideaLst)//idea-1
        {
            system.debug('Received Idea....'+i);
            topicNameSet.add(i.Related_Topic_Name__c);
            system.debug('topic name: '+topicNameSet);
            
            if(!topIdeaMap.containsKey(i.Related_Topic_Name__c))
            {
                topIdeaMap.put(i.Related_Topic_Name__c.toUpperCase(), new List<idea>());
            }
            topIdeaMap.get(i.Related_Topic_Name__c.toUpperCase()).add(i);
            system.debug('topic with idea...'+topIdeaMap);
        }
        List<topic> topicList = new List<topic>();
        If(!topicNameSet.isEmpty())
        {
            topicList = [SELECT Id, NetworkId, Name, Description, CreatedDate, CreatedById, 
                         TalkingAbout, ManagedTopicType, SystemModstamp FROM Topic
                         Where Name IN: topicNameSet];
        }
        Set<Id> topicIdSet = new Set<Id>();
        If(!topicList.isEmpty())
        {
            for(topic T : topicList)
            {
                topicIdSet.add(T.id);
            }
        }
        //List<entity> where parent Id IN topic
        Map<id, List<string>> entitySubMap = new Map<id, List<string>>();
        List<EntitySubscription> entitySubData = new List<EntitySubscription>();
        if(!topicIdSet.isEmpty())
        {
            entitySubData = [SELECT Id, ParentId, Parent.Name, SubscriberId, Subscriber.Name, Subscriber.Email, CreatedById, 
                             CreatedDate, IsDeleted, NetworkId 
                             FROM EntitySubscription Where ParentId IN: topicIdSet];
        }
        if(!entitySubData.isEmpty())
        {
            For(EntitySubscription entity:entitySubData)
            {
                if(!entitySubMap.containsKey(entity.SubscriberId))
                {
                    entitySubMap.put(entity.SubscriberId, new List<string>());
                }
                entitySubMap.get(entity.SubscriberId).add(entity.Parent.Name);
            }
            System.debug('entitySubMap--'+entitySubMap);
        }
        //getting valid user email id
        List<User> userList = new List<User>();
        if(!entitySubMap.isEmpty())
        {
            userList = [Select Id, Name, Email from User Where Id IN: entitySubMap.keySet() and isActive = true 
                        and (Not email Like '%invalid%')];
        }
        
        //Send Email Newsletter
        List<Messaging.SingleEmailMessage> listToSendMails = new List<Messaging.SingleEmailMessage>();
        boolean isSandbox = false;
        string sourceLink ='https://qsc--qa.sandbox.my.site.com/QSCDeveloperCommunity/s/idea/';
        isSandbox = [select IsSandbox from Organization limit 1].IsSandbox;
        if(isSandbox)
        {
            sourceLink = 'https://qsc--qa.sandbox.my.site.com/QSCDeveloperCommunity/s/idea/';
        }
        else{
            sourceLink = 'https://developers.qsc.com/s/idea/';
        }
        
        if(!userList.isEmpty())
        {
            system.debug('user list: '+userList.size());
            for(User usr : userList)//5
            {
                String emailBody='';
                system.debug('@@@@@@@@@@@@@@@@@');
                if((entitySubMap.containskey(usr.Id)) && entitySubMap.get(usr.Id)!=null)
                {
                    Integer count = 0;
                    
                    emailBody = 'Hello '+ usr.Name+'!<br/><br/>';
                    List<string> topList = entitySubMap.get(usr.Id);
                    system.debug('topList: '+topList.size());//4
                    if(!topList.isEmpty())
                    {
                        For(string tpic: topList)//4
                        {
                            system.debug('topIdeaMap consist.... '+topIdeaMap.get(tpic.toUpperCase()));
                            If(topIdeaMap.get(tpic.toUpperCase()) != null)
                            {
                                List<Idea> idList = topIdeaMap.get(tpic.toUpperCase());
                                system.debug('idealist: '+idList.size());
                                if(!idList.isEmpty())
                                {
                                    for(Idea i : idList)
                                    {
                                        emailBody += 'A New Idea, '+i.Title+' associated with the Topic of '+tpic+' was created in communities. <br/>';
                                        emailBody += 'Vote and comment on this Idea from the community to continue the conversation! <br/>';
                                        emailBody +='<a href="'+sourceLink + i.id + '/detail' +'">Click here</a><br/><br/><br/>';
                                        
                                    }
                                    system.debug('idea present: '+emailBody);
                                    count = count + 1;
                                }
                            }
                        }
                        emailBody += 'You are receiving this mail because you are subscribed to the content associated with the topic above.<br/><br/>';
                        emailBody += '<br/>Best Regards,<br/> Q-SYS Communities for Developers';
                        
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        
                        mail.setSubject('A new Ideas was created in your followed topics in communities');
                        mail.setHtmlBody(emailBody);
                        
                        
                        mail.setToAddresses(new List<string>{usr.Email});
                        system.debug('Count : ' + count);
                        If(count > 0)
                        {
                            listToSendMails.add(mail);
                        }
                    }
                }
            }
            If(listToSendMails.size()>0)
            {
                Messaging.sendEmailResult[] sendEmailResults = Messaging.sendEmail(listtosendmails);
                
                for(Messaging.SendEmailResult sendEmailResult: sendEmailResults)
                {
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
                
                system.debug('listToSendMails: '+listToSendMails.size());
            }
        }
    }
    public void finish(Database.BatchableContext BC)
    {
        
    }
}