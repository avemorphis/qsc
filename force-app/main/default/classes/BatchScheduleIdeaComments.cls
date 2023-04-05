public class BatchScheduleIdeaComments implements Database.Batchable<sObject>{

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Database.QueryLocator q = Database.getQueryLocator(
            [Select id,IdeaId,Idea.Title, CreatedDate, CommentBody, CreatedById, CreatedBy.Name from IdeaComment 
             Where CommunityId =: System.label.Dev_Com_Community_Id AND CreatedDate = TODAY]);
        return q;
    }
    
    public void execute(Database.BatchableContext BC, List<IdeaComment> records){
         boolean isSandbox = false;
         string sourceLink = 'https://qsc--qa.sandbox.my.site.com/QSCDeveloperCommunity/s/idea/';
        
        isSandbox = [select IsSandbox from Organization limit 1].IsSandbox;
        if(isSandbox)
        {
            sourceLink = 'https://qsc--qa.sandbox.my.site.com/QSCDeveloperCommunity/s/idea/';
        }
        else{
            sourceLink = 'https://qsc--thinkaidev.sandbox.my.site.com/QSCDeveloperCommunity/s/idea/';//QSC Dev Portal Link will be here.
        }
        //Get Ideas
        Set<Id> ideadIds = new Set<Id>();
        for(IdeaComment Ic : records)
        {
            ideadIds.add(Ic.IdeaId);
        }
        
        //Get Subscribers
        Set<Id> userIds = new Set<Id>();
        List<X7S_Ideas_Subscription__c> subscriberList = [SELECT Id, SubscriberId__r.name, SubscriberId__c, SubscriberId__r.email,
                                                          ParentId__r.title  
                                                          FROM X7S_Ideas_Subscription__c
                                                          WHERE parentId__c =: ideadIds];
        Map<Id, List<IdeaComment>> mapIdeaData = new Map<Id, List<IdeaComment>>();
        Map<Id, X7S_Ideas_Subscription__c> mapSubscription = new Map<Id, X7S_Ideas_Subscription__c>();
        
        for(X7S_Ideas_Subscription__c idSub : subscriberList)
        {
            mapSubscription.put(idSub.SubscriberId__c, idSub);
        }
        for(String ideaId : ideadIds)
        {
            List<IdeaComment> commentsList = new List<IdeaComment>();
            for(IdeaComment ideaCom : records)
            {
                //Check Idea comment Id and Idea Id
                if(ideaCom.IdeaId == ideaId)
                {
                    commentsList.add(ideaCom);
                }
                mapIdeaData.put(ideaId, commentsList);
            }
        }
        Set<Id> subscriberIds = new Set<Id>();
        Map<Id, Set<Id>> mapIds = new Map<Id, Set<Id>>();
        
        For(X7S_Ideas_Subscription__c SD : subscriberList){
            subscriberIds.add(SD.SubscriberId__c);
        }
        
        for(Id subId : subscriberIds)
        {
            Set<Id> ideaIds = new Set<Id>();
            For(X7S_Ideas_Subscription__c SD : subscriberList)
            {
                //To check Ideas subscribers
                if(subId == SD.SubscriberId__c)
                {
                    ideaIds.add(SD.ParentId__c);
                }
            }
            mapIds.put(subId, ideaIds);
        }
        
        //Sending Emails
        String orgWideEmailAddressLabel = System.Label.for_QSC_communities;
        List<Messaging.SingleEmailMessage> listToSendMails = new List<Messaging.SingleEmailMessage>();
        
        for(Id subId : subscriberIds)
        {
            X7S_Ideas_Subscription__c subscriptionData = mapSubscription.get(subId);
            String emailBody = 'Hello '+ subscriptionData.SubscriberId__r.name +'!<br/><br/>';
            Set<Id> ideaList = mapIds.get(subId);
            for(String strId : ideaList)
            {
                List<IdeaComment> commList = mapIdeaData.get(strId);
                
                for(IdeaComment commData : commList)
                {
                    emailBody += commData.CreatedBy.Name +' left a comment on '+'<a href='+ sourceLink + commData.ideaId + '/detail>'+ commData.Idea.Title +'</a>, an idea you follow in the Q-SYS Communities for developers.'+ commData.CommentBody;
                	
                }
                
            }
            emailBody += '<br/>Best Regards,<br/> Q-SYS Communities for Developers';
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Idea and Comments of Subscribed Ideas');
            mail.setHtmlBody(emailBody);
            mail.setToAddresses(new List<string>{subscriptionData.SubscriberId__r.email});
            mail.setOrgWideEmailAddressId(orgWideEmailAddressLabel);
            listToSendMails.add(mail);
        }
        
        try{
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