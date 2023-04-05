/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*/
@isTest
private class X7sDeveloperRepoController_Test {
    
    private static final String PROJECT_NAME_BASE = 'TestProject';
    private static final String REPO_NAME_BASE = 'TestRepo';
    private static final Integer NUM_REPOS = 50;
    private static final String MOST_RECENT_ORDER = 'MOST_RECENT';
    private static final String OLDEST_ORDER = 'OLDEST';
    private static final String MOST_POPULAR_ORDER = 'MOST_POPULAR';

    @TestSetup
    static void setup() {
        Test.startTest();
        List<Developer_Repo__c> repos = X7sTestUtils.createDeveloperRepos(NUM_REPOS, PROJECT_NAME_BASE, REPO_NAME_BASE);
        Test.stopTest();
    }

    @IsTest
    static void testRefreshReadme() {
        // get a repo that has been created
        Developer_Repo__c dr = getRepos().get(0);
        String oldReadme = dr.Readme__c;
        dr.Readme__c = null;
        update dr;
        dr = getRepo(dr.Id);
        System.assertEquals(null, dr.Readme__c, 'Expected readme field to be blanked out');

        String[] parts = dr.Name.split('/');
        X7sRepoAPIHTTPGETMock mock = new X7sRepoAPIHTTPGETMock();
        Test.setMock(HttpCalloutMock.class, mock);
        X7sTestUtils.addMockProperties(mock, parts[0], parts[1]);

        Test.startTest();
        X7sDeveloperRepoController.refreshReadme(dr.Id);
        Test.stopTest();

        dr = getRepo(dr.Id);
        System.assertEquals(oldReadme, dr.Readme__c, 'Expected readme to have been reloaded');
    }
    
    @IsTest
    static void testGetReposSOQL() {

        String everythingTag = 'Everything';
        String evenTag = 'Even';
        String oddTag = 'Odd';
        String firstHalfTag = 'FirstHalf';
        String secondHalfTag = 'SecondHalf';

        List<Developer_Repo__c> repos = getRepos();
        Integer index = 0;
        for(Developer_Repo__c repo : repos) {
            if(repo.Last_Updated_Date__c == null) {
                repo.Last_Updated_Date__c = DateTime.now();
            }
            repo.Last_Updated_Date__c = repo.Last_Updated_Date__c.addDays(index);
            String[] parts = repo.Name.split('/');
            Integer num = Integer.valueOf(parts[0].replace(PROJECT_NAME_BASE, ''));
            List<String> tags = new List<String>();
            tags.add(everythingTag);
            if(Math.mod(num,2) == 0) {
                tags.add(evenTag);
            } else {
                tags.add(oddTag);
            }
            if(num < (NUM_REPOS/2)) {
                tags.add(firstHalfTag);
            } else {
                tags.add(secondHalfTag);
            }
            repo.Tags__c = String.join(tags, ',');
            index++;
        }
        update repos;

        Integer pageSize = 10;
        // first find everything
        Test.startTest();
        List<Developer_Repo__c> results1 = (List<Developer_Repo__c>) X7sDeveloperRepoController.getRepos(null, null, null, MOST_RECENT_ORDER, null, null, null).get('records');
        List<Developer_Repo__c> results2 = (List<Developer_Repo__c>) X7sDeveloperRepoController.getRepos(null, null, null, MOST_RECENT_ORDER, pageSize, 2, false).get('records');
        List<Developer_Repo__c> results3 = (List<Developer_Repo__c>) X7sDeveloperRepoController.getRepos(null, null, null, OLDEST_ORDER, pageSize, 1, false).get('records');
        List<Developer_Repo__c> results4 = (List<Developer_Repo__c>) X7sDeveloperRepoController.getRepos(null, null, null, MOST_RECENT_ORDER, pageSize, 2, false).get('records');
        List<Developer_Repo__c> results5 = (List<Developer_Repo__c>) X7sDeveloperRepoController.getRepos(null, null, new List<String>{evenTag}, MOST_RECENT_ORDER, pageSize, 1, false).get('records');
        Test.stopTest();

        // verify that only one page was returned
        System.assertEquals(pageSize, results1.size(), 'Expected one page of results returned');

        DateTime testdate = DateTime.now().addDays(NUM_REPOS + 10);
        // verify that most recent are listed first
        for(Developer_Repo__c repo : results1) {
            System.assert(repo.Last_Updated_Date__c < testdate, 'Expected record to be older than last one');
            testdate = repo.Last_Updated_Date__c;
        }

        System.assertEquals(pageSize, results2.size(), 'Expected one page of results returned');
        Developer_Repo__c last1 = results1[pageSize - 1];
        Developer_Repo__c first2 = results2[0];
        System.assert(first2.Last_Updated_Date__c < last1.Last_Updated_Date__c, 'Expected next page to be older than previous page');

        System.assertEquals(pageSize, results5.size(), 'Expected a full page of results for even tag search');
        for(Developer_Repo__c repo : results5) {
            String[] parts = repo.Name.split('/');
            Integer num = Integer.valueOf(parts[0].replace(PROJECT_NAME_BASE, ''));
            System.assert(Math.mod(num,2)==0, 'Expected only repos tagged with even returned ' + repo.Name);
        }
    }

    @IsTest
    static void testSubmitRepo() {

        List<User> contributorList = X7sTestUtils.createCommunityUserQSC(10);
        List<Id> contributors = new List<Id>();
        for(Integer i=0; i<5; i++) {
            contributors.add(contributorList[i].Id);
        }
        List<Id> moreContributors = new List<Id>();
        for(Integer i=3; i<10; i++) {
            moreContributors.add(contributorList[i].Id);
        }
        List<String> tags = new List<String>{'tag1','tag2'};


        String projectName = 'TestProject';
        String repoName = 'TestRepo';
        X7sRepoAPIHTTPGETMock mock = new X7sRepoAPIHTTPGETMock();
        Test.setMock(HttpCalloutMock.class, mock);
        X7sTestUtils.addMockProperties(mock, projectName, repoName);

        String validLocation = 'https://bitbucket.org/' + projectName + '/' + repoName + 'Repo.git';

        // 
        Test.startTest();
        Id submittedId = X7sDeveloperRepoController.submitRepo(null, validLocation, contributors, tags);
        System.assert(submittedId != null, 'Expected that the submitted repo would have been created');
        Id latestId = X7sDeveloperRepoController.submitRepo(submittedId, validLocation, moreContributors, tags);
        System.assert(latestId != null, 'Expected that the latest Id would be present');
        Test.stopTest();
    }

    static List<Developer_Repo__c> getRepos() {
        return [SELECT Id,Name,Description__c,Readme__c,Last_Updated_Date__c,Tags__c FROM Developer_Repo__c];
    }

    static Developer_Repo__c getRepo(Id repoId) {
        return [SELECT Id,Name,Description__c,Readme__c,Last_Updated_Date__c,Tags__c FROM Developer_Repo__c WHERE Id = :repoId LIMIT 1];
    }

    @IsTest
    static void testSendInvitation() {
        Boolean result = X7sDeveloperRepoController.sendInvitation('dummy@host.com', 'Dummy User', 'Dummy Sender');
        System.assert(result, 'Expected successful sendInvitation call');
    }

}