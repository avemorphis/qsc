@isTest
public class TestBatchScheduleIdeaComments {
    public static testMethod void testBatchApex() {
        
        Idea tmpIdea = new Idea(CommunityId = System.label.Dev_Com_Community_Id, Title = 'TEST_IDEA_NAME');
        insert tmpIdea;
        
        IdeaComment ic = new IdeaComment();
        ic.IdeaId = tmpIdea.Id;
        ic.CommentBody = 'Test';
        insert ic;
        
        X7S_Ideas_Subscription__c is = new X7S_Ideas_Subscription__c();
        is.SubscriberId__c = UserInfo.getUserId();
        is.ParentId__c = tmpIdea.id;
        insert is;
        
        Test.StartTest();
		scheduleBatchIdeaComment testsche = new scheduleBatchIdeaComment();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
    }
}