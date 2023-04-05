/*
* Copyright (c) 2020. 7Summits Inc.
*/

public with sharing class x7sIdeasSubscription {
    public static boolean isSandbox = false;
    public static string sourceLink = 'https://qa-qscprod.cs220.force.com/QSCDeveloperCommunity/s/idea/';
    public static string sourceLink1 = 'https://qa-qscprod.cs220.force.com/QSCDeveloperCommunity/s/topic/';
    public static Boolean ideaSubscribe(String userId, String ideaId) {
        System.debug('userId---'+userId+'  ---'+ideaId);
        Boolean subscribed;
        subscribed = false;
        isSandbox = [select IsSandbox from Organization limit 1].IsSandbox;
        if(isSandbox)
        {
            sourceLink = 'https://qa-qscprod.cs220.force.com/QSCDeveloperCommunity/s/idea/';
            sourceLink1 = 'https://qa-qscprod.cs220.force.com/QSCDeveloperCommunity/s/topic/';
        }
        else{
            sourceLink = 'https://qscprod.force.com/s/idea/';//QSC Dev Portal Link will be here.
            sourceLink1 = 'https://developers.qsc.com/s/topic/';
        }
        
        if (String.isNotBlank(ideaId)) {
            List<X7S_Ideas_Subscription__c> ideaSubscriptions = getSubscription(userId, ideaId);
            
            if (ideaSubscriptions.size() == 0) {
                X7S_Ideas_Subscription__c newIdeaSubscription = new X7S_Ideas_Subscription__c(
                    SubscriberId__c = userId,
                    ParentId__c = ideaId);
                try {
                    //if (X7S_Ideas_Subscription__c.SObjectType.getDescribe().isCreateable()) {
                    insert newIdeaSubscription;
                    subscribed = true;
                    sendSubscriptionNotification(userId, ideaId);
                    //sendEmailNotification(ideaId, userId);
                    //}
                }
                catch (DmlException e) {
                    System.debug('Failed to insert Idea subscription record: ' + e.getMessage());
                }
                catch(Exception ex) {
                    System.debug('ideaSubscribe: ' + ex.getMessage());}
            } else {
                // already subscribed
                subscribed = ideaSubscriptions[0].SubscriberId__c == userId;
            }
        }
        
        return subscribed;
    }
    
    public static Boolean ideaSubscribeOnly(String userId, String ideaId) {
        System.debug('userId---'+userId+'  ---'+ideaId);
        Boolean subscribed;
        subscribed = false;
        isSandbox = [select IsSandbox from Organization limit 1].IsSandbox;
        if(isSandbox)
        {
            sourceLink = 'https://qa-qscprod.cs220.force.com/QSCDeveloperCommunity/s/idea/';
            sourceLink1 = 'https://qa-qscprod.cs220.force.com/QSCDeveloperCommunity/s/topic/';
        }
        else{
            sourceLink = 'https://qscprod.force.com/s/idea/';//QSC Dev Portal Link will be here.
            sourceLink1 = 'https://developers.qsc.com/s/topic/';
        }
        
        if (String.isNotBlank(ideaId)) {
            List<X7S_Ideas_Subscription__c> ideaSubscriptions = getSubscription(userId, ideaId);
            
            if (ideaSubscriptions.size() == 0) {
                X7S_Ideas_Subscription__c newIdeaSubscription = new X7S_Ideas_Subscription__c(
                    SubscriberId__c = userId,
                    ParentId__c = ideaId);
                try {
                    //if (X7S_Ideas_Subscription__c.SObjectType.getDescribe().isCreateable()) {
                    insert newIdeaSubscription;
                    subscribed = true;
                    //sendSubscriptionNotification(userId, ideaId);
                    //sendEmailNotification(ideaId, userId);
                    //}
                }
                catch (DmlException e) {
                    System.debug('Failed to insert Idea subscription record: ' + e.getMessage());
                }
                catch(Exception ex) {
                    System.debug('ideaSubscribe: ' + ex.getMessage());}
            } else {
                // already subscribed
                subscribed = ideaSubscriptions[0].SubscriberId__c == userId;
            }
        }
        
        return subscribed;
    }
    
    public static Boolean ideaUnSubscribe(String userId, String ideaId) {
        Boolean unSubscribed;
        unSubscribed = false;
        if (String.isNotBlank(ideaId) &&
            X7S_Ideas_Subscription__c.SObjectType.getDescribe().isDeletable()) {
                List<X7S_Ideas_Subscription__c> ideaSubscriptions = getSubscription(userId, ideaId);
                
                if (ideaSubscriptions.size() > 0) {
                    try {
                        delete ideaSubscriptions;
                        unSubscribed = true;
                    }
                    catch (DmlException e) {
                        System.debug('Failed to remove Idea subscription record: ' + e.getMessage());
                    }
                }
            }
        
        return unSubscribed;
    }
    
    public static Boolean ideaIsSubscribed(String userId, String ideaId) {
        Boolean isFollowing;
        isFollowing = false;
        if (String.isNotBlank(ideaId)) {
            List<X7S_Ideas_Subscription__c> ideaSubscriptions = getSubscription(userId, ideaId);
            
            if (ideaSubscriptions.size() > 0) {
                isFollowing = true;
            }
        }
        
        return isFollowing;
    }
    
    @TestVisible
    public static List<X7S_Ideas_Subscription__c> getSubscription(String userId, String ideaId) {
        String query = 'SELECT Id, SubscriberId__c, ParentId__c' +
            ' FROM X7S_Ideas_Subscription__c ' +
            ' WHERE ' +
            ' SubscriberId__c = ' + '\'' + String.escapeSingleQuotes(userId) + '\'' +
            ' AND ParentId__c = ' + '\'' + String.escapeSingleQuotes(ideaId) + '\'' +
            ' WITH SECURITY_ENFORCED ' +
            ' LIMIT 1';
        
        // PMD : False positive, All variables are checked
        List<X7S_Ideas_Subscription__c> ideaSubscriptions = (List<X7S_Ideas_Subscription__c>) Database.query(query); //NOPMD
        
        return ideaSubscriptions;
    }
    //Author:
    /*
Purpose of Below Block:
The blow block will send the notification when user subscribe to any idea
*/
    public static void sendSubscriptionNotification(String userId, String ideaId){
        Map<String, Object> pageRef = new Map<String, Object>{
            'type' => 'standard__webPage',
                'attributes' => new Map<String, Object> {
                    'url' => '/QSCDeveloperCommunity/s/idea/' + ideaId + '/detail'
                        }
        };
            
            CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='Subscription_Notifier']; 
        // My_Custom_Notification (Enter the API Name of custom notification that you have created)
        
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        
        // Set the contents for the notification
        
        try {
            Idea thisIdea = [select id, CreatedById, Requested_By__c, Title from idea where id =:ideaId limit 1];
            Id recipientsIds = thisIdea.Requested_By__c != null ? thisIdea.Requested_By__c : thisIdea.CreatedById;
            User subscriber = [select id, name, CommunityNickname from user where id =:userid limit 1];
            //String subscriberName = subscriber.CommunityNickname != null ? subscriber.CommunityNickname : subscriber.Name;
            String subscriberName;
            subscriberName = subscriber.Name;
            notification.setTitle('Subscription Notification');
            
            notification.setBody(subscriberName+' has subscribed to your Idea.');
            
            // Set the notification type and target
            notification.setNotificationTypeId(notificationType.Id);
            //notification.setTargetId(targetId);
            notification.setTargetPageRef(JSON.serialize(pageRef));
            // Actually send the notification
            notification.send(new Set<string>{recipientsIds});
            
            notification.setBody('You have subscribed to Idea: ' + thisIdea.Title);
            notification.send(new Set<string>{userid});
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
    public static Boolean ideaSubscribeOnlySub(String userId, String ideaId) {
        System.debug('userId---'+userId+'  ---'+ideaId);
        Boolean subscribed;
        subscribed = false;
        isSandbox = [select IsSandbox from Organization limit 1].IsSandbox;
        if(isSandbox)
        {
            sourceLink = 'https://qa-qscprod.cs220.force.com/QSCDeveloperCommunity/s/idea/';
            sourceLink1 = 'https://qa-qscprod.cs220.force.com/QSCDeveloperCommunity/s/topic/';
        }
        else{
            sourceLink = 'https://qscprod.force.com/s/idea/';//QSC Dev Portal Link will be here.
            sourceLink1 = 'https://developers.qsc.com/s/topic/';
        }
        
        if (String.isNotBlank(ideaId)) {
            List<X7S_Ideas_Subscription__c> ideaSubscriptions = getSubscription(userId, ideaId);
            
            if (ideaSubscriptions.size() == 0) {
                X7S_Ideas_Subscription__c newIdeaSubscription = new X7S_Ideas_Subscription__c(
                    SubscriberId__c = userId,
                    ParentId__c = ideaId);
                try {
                    //if (X7S_Ideas_Subscription__c.SObjectType.getDescribe().isCreateable()) {
                    insert newIdeaSubscription;
                    subscribed = true;
                    sendSubscriptionNotificationOnlySub(userId, ideaId);
                    //sendEmailNotification(ideaId, userId);
                    //}
                }
                catch (DmlException e) {
                    System.debug('Failed to insert Idea subscription record: ' + e.getMessage());
                }
                catch(Exception ex) {
                    System.debug('ideaSubscribe: ' + ex.getMessage());}
            } else {
                // already subscribed
                subscribed = ideaSubscriptions[0].SubscriberId__c == userId;
            }
        }
        
        return subscribed;
    }
    public static void sendSubscriptionNotificationOnlySub(String userId, String ideaId){
        Map<String, Object> pageRef = new Map<String, Object>{
            'type' => 'standard__webPage',
                'attributes' => new Map<String, Object> {
                    'url' => '/QSCDeveloperCommunity/s/idea/' + ideaId + '/detail'
                        }
        };
            
            CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='Subscription_Notifier']; 
        // My_Custom_Notification (Enter the API Name of custom notification that you have created)
        
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        
        // Set the contents for the notification
        
        try {
            Idea thisIdea = [select id, CreatedById, Requested_By__c, Title from idea where id =:ideaId limit 1];
            Id recipientsIds = thisIdea.Requested_By__c != null ? thisIdea.Requested_By__c : thisIdea.CreatedById;
            User subscriber = [select id, name, CommunityNickname from user where id =:userid limit 1];
            //String subscriberName = subscriber.CommunityNickname != null ? subscriber.CommunityNickname : subscriber.Name;
            String subscriberName;
            subscriberName = subscriber.Name;
            notification.setTitle('Subscription Notification');
            
            notification.setBody(subscriberName+' has subscribed to your Idea.');
            
            // Set the notification type and target
            notification.setNotificationTypeId(notificationType.Id);
            //notification.setTargetId(targetId);
            notification.setTargetPageRef(JSON.serialize(pageRef));
            // Actually send the notification
            //notification.send(new Set<string>{recipientsIds});
            
            notification.setBody('You have subscribed to Idea: ' + thisIdea.Title);
            notification.send(new Set<string>{userid});
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }
}