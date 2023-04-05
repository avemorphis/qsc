/**

* @description        : Sch_ContributorEmailNotificationBatch for sending email notification to developer repo contributon every friday using ContributorEmailNotificationBatch class.
* @Last Modified By   : prakhar.jain@qsc.con
* @Last Modified On   : 20/03/2023
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    20/03/2023     prakhar.jain@qsc.com       Initial Version
**/

@isTest
public class Test_ContributorEmailNotificationBatch 
{
    
    private static final String PROJECT_NAME_BASE = 'TestProject';
    private static final String REPO_NAME_BASE = 'TestRepo';
    private static final Integer NUM_REPOS = 50;
    
    public static testMethod void testBatchApex() 
    {
        Test.startTest();
        
        //Create Developer_Repo__c Record.
        List<Developer_Repo__c> repos = X7sTestUtils.createDeveloperRepos(NUM_REPOS, PROJECT_NAME_BASE, REPO_NAME_BASE);
        
        String contricutorId = userinfo.getUserId();
        
        //Create Developer_Repo_Contributor__c Record.
        Developer_Repo_Contributor__c objDeveloperRepoContributor = new Developer_Repo_Contributor__c();
        objDeveloperRepoContributor.Contributor__c = contricutorId;
        objDeveloperRepoContributor.Developer_Repo__c = repos[0].Id;
        INSERT objDeveloperRepoContributor;
        
        //Create FeedItem Record.
        FeedItem objFeedItem = new FeedItem();
        objFeedItem.ParentId = repos[0].Id;
        objFeedItem.Body = 'Testing';
        INSERT objFeedItem;
        
        //Create FeedComment Record.
        FeedComment objFeedComment = new FeedComment();
        objFeedComment.CommentBody = 'Testing';
        objFeedComment.FeedItemId = objFeedItem.Id;
        INSERT objFeedComment;
        
        Sch_ContributorEmailNotificationBatch testsche = new Sch_ContributorEmailNotificationBatch();
		String sch = '1 0 * ? * * *';
		system.schedule('Test status Check', sch, testsche );
        
        Test.stopTest();
    }
}