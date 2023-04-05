/**

* @description        : Apex class for sending email and bell notification to community manager
* @Author             : prakhar.jain@qsc.com
* @Last Modified By   : prakhar.jain@qsc.com
* @Last Modified On   : 02/02/2023
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    02/02/2023     prakhar.jain@qsc.com       Initial Version
**/
public class th_feedItemHandler 
{
    Public static void afterInsert(List<feeditem> newFeedList)
    {
        string Emaildetails ='adrien.avellan@qsc.com';
        set<Id> feedIdSet = new set<id>();
        set<id> parentIdSet = new set<id>();
        Set<id> userId = new set<id>();
        Set<id> newsIdSet = new set<id>();
        List<X7S_News__c> newsList = new List<X7S_News__c>();
        List<feeditem> feedList = new List<feeditem>();
        List<User> userList = [SELECT Id, Email, Name FROM User WHERE Email =:Emaildetails];
        Map<id, feeditem> feedMap = new Map<id,feeditem>();
        User objUser = new  User();
        String imageURL;
        
        if(!test.isRunningTest()){
        StaticResource static_resource = [SELECT Body, SystemModstamp, NamespacePrefix, Name FROM StaticResource WHERE Name = 'QscCommunityLogo' LIMIT 1];
        system.debug('Static resource: '+static_resource);
        
         imageURL = URL.getSalesforceBaseUrl().toExternalForm() + '/resource/'
                    + String.valueOf(((DateTime)static_resource.get('SystemModStamp')).getTime())
                    + '/' 
                    + static_resource.get('Name')
                    + '?';
        	System.debug('Here is image url:'+ imageURL );
        }
        
        //For new feed on news get parent Id
        For(FeedItem objFeed: newFeedList)
        {
            If(objFeed.ParentId!=null && objFeed.Type=='TextPost')
            {
                parentIdSet.add(objFeed.ParentId);
                feedIdSet.add(objFeed.id);
             }
        }
        
        //Check parent Id is newsId 
        if(!parentIdSet.isEmpty())
        {
        	newsList = [SELECT Id From X7S_News__c WHERE Id in :parentIdSet];
        }   
        if(!newsList.isEmpty())
        {
            For(X7S_News__c news: newsList)
            {
                newsIdSet.add(news.Id);
            }
        }
        
        //Get feed and related news
        if(!newsIdSet.isEmpty())
        {
            feedList =[SELECT ID, Body, CreatedById, Parent.Name, ParentId FROM feeditem  WHERE ParentId in: newsIdSet and Id in:feedIdSet];
           
            For(feeditem feed: feedList)
            {
                system.debug('feed(news) list: '+feed);
                feedMap.put(feed.Id, feed);
                system.debug('feedId: '+feedMap);
                userId.add(feed.CreatedById);
            }
            
            //Get User Name who commented on News
            if(userId!=null)
            {
                objUser = [SELECT Id, FirstName, LastName FROM User WHERE Id in: userId];
            }   
            
            //If map containd new feed id then call email and bell notification method
            If(!feedMap.isEmpty())
                {
                    For(FeedItem objFeed1: newFeedList)
                    {
                        If(feedMap.containsKey(objFeed1.Id))
                        {
                            If(objFeed1.ParentId!=null && objFeed1.Type=='TextPost')
                            {
                               th_feedItemHandler.sendEmail(feedMap, objFeed1, objUser, Emaildetails, imageURL);
                               th_feedItemHandler.sendBellNoti(feedMap, objFeed1, objUser, Emaildetails, userList);
                            }
                        }
                    }
                }
        	}
       }
    
    //Create new custom email notification
    Public static void sendEmail(Map<id,feeditem> feedMap, feeditem objFeed1, User objUser, string Emaildetails, string imageURL)
    {
        boolean isSandbox = false;
        string sourceLink ='https://qsc--qa.sandbox.my.site.com/QSCDeveloperCommunity/s/x7s-news/';
        isSandbox = [select IsSandbox from Organization limit 1].IsSandbox;
        if(isSandbox)
        {
            sourceLink = 'https://qsc--qa.sandbox.my.site.com/QSCDeveloperCommunity/s/x7s-news/';
        }
        else{
            sourceLink = 'https://developers.qsc.com/s/x7s-news/';
        }
        
        List<Messaging.SingleEmailMessage> listToSendMails = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        
        sendTo.add(Emaildetails);
        system.debug('Emaildetails: '+Emaildetails);
        mail.setToAddresses(sendTo);
        mail.setSenderDisplayName('QSC');
        mail.setsubject(feedMap.get(objFeed1.Id).Parent.Name + ' New Comment');
        system.debug('news name: '+feedMap.get(objFeed1.Id).Parent.Name);
        
        String body = 'Hi,'+'<br/>'+'<br/>';
        body += feedMap.get(objFeed1.Id).Parent.Name + ' recieved a comment from '+ objUser.FirstName +' '+ objUser.LastName +'.<br/>'+'<br/>';
        system.debug('comment user name: '+objUser.FirstName +' '+ objUser.LastName);
        body+= 'Comment: '+'<br/>'+ objFeed1.Body;
        system.debug('feed comment: '+objFeed1.Body);
        body += '<a href="'+ sourceLink +feedMap.get(objFeed1.Id).ParentID+'">View Post</a>';
        body += '<br/>'+'<br/>'+'You are receiving emails when someone posts a comment on Communities News '+'<br/>' +'QSYS, LLC @ 1675 MacArthur Blvd. Costa Mesa, CA 92626 USA';
        
        if(!test.isRunningTest())
        {
        body += '<br/>'+'<br/>'+'<img src=' + imageURL + ' width="125" height="50">';
        }
        
        mail.setHtmlBody(body);
        listToSendMails.add(mail);
        
        If(listToSendMails.size()>0)
        {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(listToSendMails);
            For(Messaging.SendEmailResult sendEmailResult: results)
            {
                If(sendEmailResult.isSuccess())
                {
                    system.debug('email sent succesfully');
                }
                else 
                {
                    For (Messaging.Sendemailerror sendEmailError : sendEmailResult.getErrors())
                    {
                        system.debug('error msg '+ sendEmailError.Message);                                                   
                    }
                }
            }
        }
    }
    
    // Create custom bell Notification
    Public static void sendBellNoti(Map<id,feeditem> feedMap, feeditem objFeed1, User objUser, string Emaildetails, List<User> userList)
    {
        
        Set<String> subscriberIdSet = new Set<String>();
        
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Other_Subscriber_Notifications'];
        
        For(User usr : userList)
        {
            System.debug('Entered in send subscriber notifications');
            Map<String, Object> pageRef = new Map<String, Object>
            {
                'type' => 'standard__webPage',
                 'attributes' => new Map<String, Object> 
                {
                    'url' => '/QSCDeveloperCommunity/s/x7s-news/'+feedMap.get(objFeed1.Id).ParentID
                }
            };
			// Set the contents for the notification
            notification.setTitle(feedMap.get(objFeed1.Id).Parent.Name + ' New Comment'+'!');
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetPageRef(JSON.serialize(pageRef));
            notification.setBody(feedMap.get(objFeed1.Id).Parent.Name + ' recieved a comment from '+ objUser.FirstName +' '+ objUser.LastName);
            
            If(objFeed1.CreatedById != usr.ID)
            {
                subscriberIdSet.add(usr.ID);
                System.debug( ' SubscriberId: '+usr.ID);
			}
        }
		Map<Integer, set<String>> mapOfSubIds = new Map<Integer, set<String>>();
                        
        Integer subSize = subscriberIdSet.size();//1
        Double numberOfNoti = subSize/500;//0.002
        
        Decimal numOfNoti= Decimal.valueOf(numberOfNoti);
        Long maxCountOfNoti = numOfNoti.round(System.RoundingMode.CEILING);//1
        Integer countOfNoti = Integer.valueOf(maxCountOfNoti) + 1;
        
        List<String> subList = new List<String>(subscriberIdSet);//1 id
        For(Integer i = 1; i <= countOfNoti; i++)
        {
            Integer k = i * 500;//500
            Integer z = k - 500;//0
            set<String> subIdSet = new set<String>();
            if(k > subSize)
            {
                k = subSize;//1
            }
            For(Integer j = z; j < k; j++)
            {
                subIdSet.add(subList[j]);
                system.debug('SubIdSet: '+subIdSet);
            }
            mapOfSubIds.put(i, subIdSet);
            System.debug('Map of Sub Id: '+mapOfSubIds);
		}
		 try 
         {
             For(Integer subId : mapOfSubIds.keySet())
             {
                 set<String> subIdstr =  mapOfSubIds.get(subId);
                 notification.send(subIdstr);
                 System.debug('Notification sent to : '+subIdstr);
             }
         }
		 catch (Exception e) 
         {
             System.debug('Problem sending notification: ' + e.getMessage());
         }

    }
}