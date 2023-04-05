/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@IsTest
private class X7sUpdateForkWatchCountBatch_Test {

    private static final String PROJECT_NAME_BASE = 'TestProject';
    private static final String REPO_NAME_BASE = 'TestRepo';
    private static final Integer NUM_REPOS = 10;

    @TestSetup
    static void setup() {
        Test.startTest();
        List<Developer_Repo__c> repos = X7sTestUtils.createDeveloperRepos(NUM_REPOS, PROJECT_NAME_BASE, REPO_NAME_BASE);
        Test.stopTest();
        repos = [SELECT Id,Name,Description__c,Fork_Count__c,Watch_Count__c,Last_Updated_Date__c FROM Developer_Repo__c];
    }

    @IsTest
    static void testRunBatchClass() {
        List<Developer_Repo__c> repos = [SELECT Id,Name,Description__c,Fork_Count__c,Watch_Count__c,Last_Updated_Date__c FROM Developer_Repo__c];
        // clear the fork and watch counts and change the Last_Updated_Date__c
        DateTime oldDate = DateTime.now().addDays(-100);
        for(Developer_Repo__c repo : repos) {
            repo.Fork_Count__c = 0;
            repo.Watch_Count__c = 0;
            repo.Last_Updated_Date__c = oldDate;
        }
        update repos;

        // verify that the counts and date have been set
        repos = [SELECT Id,Name,Description__c,Fork_Count__c,Watch_Count__c,Last_Updated_Date__c FROM Developer_Repo__c];
        for(Developer_Repo__c repo : repos) {
            System.assertEquals(0, repo.Fork_Count__c, 'Expected fork count to be zeroed out');
            System.assertEquals(0, repo.Watch_Count__c, 'Expected watch count to be zeroed out');
            System.assertEquals(oldDate, repo.Last_Updated_Date__c, 'Expected last updated date to be 100 days ago');
        }

        // setup mock
        X7sRepoAPIHTTPGETMock mock = new X7sRepoAPIHTTPGETMock();
        Test.setMock(HttpCalloutMock.class, mock);
        for(Developer_Repo__c repo : repos) {
            String[] parts = repo.Name.split('/');
            X7sTestUtils.addMockProperties(mock, parts[0], parts[1]);
        }
        Test.startTest();
        X7sUpdateForkWatchCountBatch batch = new X7sUpdateForkWatchCountBatch();
        DataBase.executeBatch(batch); 
        Test.stopTest();

        repos = [SELECT Id,Name,Description__c,Fork_Count__c,Watch_Count__c,Last_Updated_Date__c FROM Developer_Repo__c];
        for(Developer_Repo__c repo : repos) {
            System.assertEquals(X7sTestUtils.NUM_FORKS, repo.Fork_Count__c, 'Expected fork count to be updated');
            System.assertEquals(X7sTestUtils.NUM_WATCHERS, repo.Watch_Count__c, 'Expected watch count to be updated');
            System.assertNotEquals(oldDate, repo.Last_Updated_Date__c, 'Expected last updated date to not be 100 days ago');
        }
    }
}