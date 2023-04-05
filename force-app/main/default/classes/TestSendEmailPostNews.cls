@isTest
/**

* @description        : Test class for sending email and bell notification to community manager
* @Author             : prakhar.jain@qsc.com
* @Last Modified By   : prakhar.jain@qsc.com
* @Last Modified On   : 02/02/2023
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    02/02/2023     prakhar.jain@qsc.com       Initial Version
**/
public class TestSendEmailPostNews 
{
	Public static testmethod void testMethod1()
    {
        date dt = system.today();
        X7S_News__c objNews = new X7S_News__c(Name='Plugin Release: Somfy Connect UAI+', Publish_DateTime__c = dt,
                                              NetworkId__c ='0DB4X000000wkLpWAI', Details__c='The Somfy Connect™ Universal Automation Interface (UAI) Plus allows for commissioning and integrating Somfy Digital Network™ (SDN) Motors over IP/Ethernet.');
        insert objNews;
        
        Profile p = [Select Id, Name FROM Profile WHERE Name='System Administrator'];
        
        User objUsr = new User(Alias = 'test', Email= 'test_email@gmail.com', 
          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
          LocaleSidKey='en_US', ProfileId = p.Id, 
          TimeZoneSidKey='America/New_York', UserName= 'test_email@gmail.com');
        insert objUsr;
        
        CollaborationGroup objGroup = new CollaborationGroup(Name='Test group', CollaborationType='Public');
        Insert objGroup;
        
        feeditem objfeed = new feeditem(ParentId=objNews.id, Type='TextPost', Body='New post by test class', CreatedById = objUsr.id);
        insert objfeed;
        feeditem objfeed1 = new feeditem(ParentId=objGroup.id, Type='TextPost', Body='Without News Parent', CreatedById = objUsr.id);
        insert objfeed1;
    }
}