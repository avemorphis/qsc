public with sharing class notificationToSalesDirector {
    public static void sendNotification(List<Opportunity> report) {
        CustomNotificationType type = [SELECT Id, DeveloperName  FROM CustomNotificationType where DeveloperName  = 'Opportunity_Expires_2_Week_Prior'];
        Messaging.CustomNotification obj = new Messaging.CustomNotification();
        obj.setNotificationTypeId(type.Id);
        for (Opportunity opp : report) {
            system.debug('Sending Notification: '+ opp.name);
            Set<String> users = new Set<String>();
            String body = 'Estimated Closed Date: '+opp.CloseDate.format()+'. Opportunity Name: '+opp.Name+
            '. Partner Account: '+opp.Partner_Account__r.Name+'. End User Account: '+opp.End_User_Account__c+
            '. Amount: '+opp.Amount+'. Stage: '+opp.StageName+'. Sales Director: '+opp.Owner.Name;
            String title = 'Opportunity '+opp.Name+' is Expiring Soon';
            users.add(opp.OwnerId);
            obj.setBody(body);
            obj.setTitle(title);
            obj.setTargetId(opp.Id);
            obj.send(users);

        }
    }
}