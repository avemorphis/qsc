/**

* @description        : TestBatchClass for sending newsletter everyday for Idea creation
* @Last Modified By   : prakhar.jain@qsc.con
* @Last Modified On   : 22/02/2023
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    22/02/2023     prakhar.jain@qsc.com       Initial Version
**/

@isTest
public class testBatchIdeaNewsletter {
    public static testMethod void testBatchApex() {
        
        Topic t = new Topic();
        t.Name = 'Amps';
        insert t;
        
        Idea tmpIdea = new Idea(CommunityId = System.label.Dev_Com_Community_Id, Title = 'TEST_IDEA_NAME', Related_Topic_Name__c = t.Name);
        insert tmpIdea;
        
        EntitySubscription ent = new EntitySubscription();
        ent.ParentId = t.Id;
		ent.SubscriberId = userinfo.getuserid();
        insert ent;
        
        Test.StartTest();
		ScheduleBatchIdeaNewsletter testsche = new ScheduleBatchIdeaNewsletter();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
    }
   
}