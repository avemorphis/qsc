/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@isTest
private class X7sDeveloperRepoTrigger_Test {
    static final String BASE_PROJECT_NAME = 'TestProject';
    static final String BASE_REPO_NAME = 'TestRepo';
    static final String BASE_REPO_URL = 'https://bitbucket.org/';
    static final String BASE_CONTENT_URL = 'https://bitbucket.org';
    static final String BASE_API_URL = 'https://api.bitbucket.org/2.0';
    static final String BASIC_URL = BASE_REPO_URL + '{projectname}/{reponame}';
    static final String GIT_URL = BASIC_URL + '.git';
    static final String INFO_PATTERN = BASE_API_URL + '/repositories/{projectname}/{reponame}';
    static final String README_PATTERN = BASE_CONTENT_URL + '/{projectname}/{reponame}/raw/master/README.md';
    static final String CONTENT_URL_PATTERN = BASE_CONTENT_URL + '/{projectname}/{reponame}/master';

    @TestSetup
    static void setup() {
        X7sRepoAPIHTTPGETMock mock = new X7sRepoAPIHTTPGETMock();
        Test.setMock(HttpCalloutMock.class, mock);
        addMockProperties(mock, BASE_PROJECT_NAME, BASE_REPO_NAME);
        Developer_Repo__c dr = new Developer_Repo__c();
        dr.Location__c = GIT_URL.replace('{projectname}', BASE_PROJECT_NAME).replace('{reponame}', BASE_REPO_NAME);
        Test.startTest();
        insert dr;
        Test.stopTest();
    }

    @isTest
    static void testCreateDeveloperRepo() {
        String projectName = BASE_PROJECT_NAME + 'Insert';
        String repoName = BASE_REPO_NAME + 'Insert';
        X7sRepoAPIHTTPGETMock mock = new X7sRepoAPIHTTPGETMock();
        Test.setMock(HttpCalloutMock.class, mock);
        addMockProperties(mock, projectName, repoName);
        Developer_Repo__c dr = new Developer_Repo__c();
        dr.Location__c = GIT_URL.replace('{projectname}', projectName).replace('{reponame}', repoName);
        Test.startTest();
        insert dr;
        Test.stopTest();
        Developer_Repo__c currentDR = [SELECT 
            Id,Name,Description__c,Location__c,Readme__c,Fork_Count__c,Watch_Count__c,Owner_Name__c,Owner_Link__c 
            FROM Developer_Repo__c 
            WHERE Id =: dr.Id LIMIT 1];
        System.assertEquals(projectName + '/' + repoName, currentDR.Name, 'Expected modified name');
    }

    @isTest
    static void testUpdateDeveloperRepo() {
        // get an existing developer repo
        String setupName = BASE_PROJECT_NAME + '/' + BASE_REPO_NAME;
        Developer_Repo__c dr = [SELECT 
            Id,Name,Description__c,Location__c,Readme__c,Fork_Count__c,Watch_Count__c,Owner_Name__c,Owner_Link__c 
            FROM Developer_Repo__c 
            WHERE Name=: setupName LIMIT 1];
        String projectName = BASE_PROJECT_NAME + 'Update';
        String repoName = BASE_REPO_NAME + 'Update';
        X7sRepoAPIHTTPGETMock mock = new X7sRepoAPIHTTPGETMock();
        Test.setMock(HttpCalloutMock.class, mock);
        addMockProperties(mock, projectName, repoName);
        String readmeUrl = README_PATTERN.replace('{projectname}', projectName).replace('{reponame}', repoName);
        String readmeResponse = '#### UDPATED README';
        mock.properties.put(readmeUrl, readmeResponse);
        // update the location of the repo
        dr.Location__c = GIT_URL.replace('{projectname}', projectName).replace('{reponame}', repoName);
        Test.startTest();
        update dr;
        Test.stopTest();
        Developer_Repo__c currentDR = [SELECT 
            Id,Name,Description__c,Location__c,Readme__c,Fork_Count__c,Watch_Count__c,Owner_Name__c,Owner_Link__c 
            FROM Developer_Repo__c 
            WHERE Id =: dr.Id LIMIT 1];
        System.assertEquals(projectName + '/' + repoName, currentDR.Name, 'Expected updated repo name');

    }

    // maximum number of records that can get processed 
    private static final Integer NUM_RECORDS = 200;
    @isTest
    static void testBulkCreateDeveloperRepo() {
        List<Developer_Repo__c> repos = new List<Developer_Repo__c>();
        String baseProjectName = BASE_PROJECT_NAME + 'Bulk';
        String baseRepoName = BASE_REPO_NAME + 'Bulk';
        X7sRepoAPIHTTPGETMock mock = new X7sRepoAPIHTTPGETMock();
        Test.setMock(HttpCalloutMock.class, mock);
        for(Integer i=0; i<NUM_RECORDS; i++) {
            String projectName = baseProjectName + i;
            String repoName = baseRepoName + i;
            addMockProperties(mock, projectName, repoName);
            Developer_Repo__c dr = new Developer_Repo__c();
            dr.Location__c = GIT_URL.replace('{projectname}', projectName).replace('{reponame}', repoName);
            repos.add(dr);
        }
        Test.startTest();
        insert repos;
        Test.stopTest();
        Set<Id> repoIds = new Set<Id>();
        for(Developer_Repo__c repo : repos) {
            repoIds.add(repo.Id);
        }
        List<Developer_Repo__c> selectedList = [SELECT 
            Id,Name,Description__c,Location__c,Readme__c,Fork_Count__c,Watch_Count__c,Owner_Name__c,Owner_Link__c 
            FROM Developer_Repo__c 
            WHERE Id IN :repoIds];
        System.assertEquals(NUM_RECORDS, selectedList.size(), 'Expected matching number of records inserted');
    }

    private static void addMockProperties(X7sRepoAPIHTTPGETMock mock, String projectName, String repoName) {
        String readmeUrl = README_PATTERN.replace('{projectname}', projectName).replace('{reponame}', repoName);
        String readmeResponse = '#### TEST TEST TEST [ABSOLUTE URL](https://images.google.com/smile.png "smile") ## SOME OTHER HEADING ## FINAL STUFF * a * b * c';

        String infoUrl = INFO_PATTERN.replace('{projectname}', projectName).replace('{reponame}', repoName);
        String watchersUrl = infoUrl + '/watchers';
        String forksUrl = infoUrl + '/forks';
        String ownerName = 'Test Owner';
        String ownerUrl = 'https://bitbucket.org/users/testowner';
        String ownerNickname = 'testowner';
        String language = 'python';
        String updateTime = '2021-02-12T18:23:43.720674+00:00';
        String repoDescription = 'A short description of the repo';
        String mainPayload = '{"scm": "git", "website": null, "has_wiki": false, "uuid": "{ab28baf2-eccb-4f0d-a873-7b854367996c}", "links": {"watchers": {"href": "' + watchersUrl + '"}, "branches": {"href": "' + infoUrl + '/refs/branches"}, "tags": {"href": "' + infoUrl + '/refs/tags"}, "commits": {"href": "' + infoUrl + '/commits"}, "clone": [{"href": "' + GIT_URL + '", "name": "https"}, {"href": "git@bitbucket.org:' + projectName + '/' + repoName + '.git", "name": "ssh"}], "self": {"href": "' + infoUrl + '"}, "source": {"href": "' + infoUrl + '/src"}, "html": {"href": "' + BASIC_URL + '"}, "avatar": {"href": "https://bytebucket.org/ravatar/%7Bab28baf2-eccb-4f0d-a873-7b854367996c%7D?ts=2746934"}, "hooks": {"href": "' + infoUrl + '/hooks"}, "forks": {"href": "' + infoUrl + '/forks"}, "downloads": {"href": "' + infoUrl + '/downloads"}, "pullrequests": {"href": "' + infoUrl + '/pullrequests"}}, "fork_policy": "allow_forks", "full_name": "' + projectName + '/' + repoName + '", "name": "' + projectName + '", "project": {"links": {"self": {"href": "https://api.bitbucket.org/2.0/workspaces/' + projectName + '/projects/UNITY"}, "html": {"href": "https://bitbucket.org/' + projectName + '/workspace/projects/UNITY"}, "avatar": {"href": "https://bitbucket.org/account/user/' + projectName + '/projects/PROJ/avatar/32?ts=1613099748"}}, "type": "project", "name": "My Projects", "key": "PROJ", "uuid": "{6b67b070-1072-44f7-82d0-92b5ce582f64}"}, "language": "' + language + '", "created_on": "2021-02-12T03:06:39.234818+00:00", "mainbranch": {"type": "branch", "name": "master"}, "workspace": {"slug": "' + projectName + '", "type": "workspace", "name": "' + ownerName + '", "links": {"self": {"href": "https://api.bitbucket.org/2.0/workspaces/' + projectName + '"}, "html": {"href": "https://bitbucket.org/' + projectName + '/"}, "avatar": {"href": "https://bitbucket.org/workspaces/' + projectName + '/avatar/?ts=1613100012"}}, "uuid": "{cf63f919-692f-42a3-8cea-7c0d10a0156f}"}, "has_issues": false, "owner": {"display_name": "' + ownerName + '", "uuid": "{cf63f919-692f-42a3-8cea-7c0d10a0156f}", "links": {"self": {"href": "' + ownerUrl + '"}, "html": {"href": "' + ownerUrl + '"}, "avatar": {"href": "https://secure.gravatar.com/avatar/530ef6719dbbc15e6da3f327be15fe24?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FKZ-6.png"}}, "nickname": "' + ownerNickname + '", "type": "user", "account_id": "557058:6549762e-e82a-4a56-8a5f-216d831f5b3d"}, "updated_on": "' + updateTime + '", "size": 48868207, "type": "repository", "slug": "' + repoName + '", "is_private": false, "description": "' + repoDescription + '"}';        
        Integer numWatchers = 10;
        String watcherPayload = '{"pagelen": 10, "values": [{"display_name": "Ronny Roethof", "uuid": "{09122623-382c-48d3-a7e4-07179f3b2e73}", "links": {"self": {"href": "https://api.bitbucket.org/2.0/users/%7B09122623-382c-48d3-a7e4-07179f3b2e73%7D"}, "html": {"href": "https://bitbucket.org/%7B09122623-382c-48d3-a7e4-07179f3b2e73%7D/"}, "avatar": {"href": "https://secure.gravatar.com/avatar/7180aa6a1c8ddfefc38ea3345dad4253?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FRR-4.png"}}, "nickname": "rroethof", "type": "user", "account_id": "557058:312f352b-972a-4941-ab93-46af0b1080b8"}, {"display_name": "Dennis Hoppe", "uuid": "{cac860cb-12a7-446d-a5f0-9bab342b765a}", "links": {"self": {"href": "https://api.bitbucket.org/2.0/users/%7Bcac860cb-12a7-446d-a5f0-9bab342b765a%7D"}, "html": {"href": "https://bitbucket.org/%7Bcac860cb-12a7-446d-a5f0-9bab342b765a%7D/"}, "avatar": {"href": "https://secure.gravatar.com/avatar/317dbc64094d0fd19f33dd785b203d87?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FDH-2.png"}}, "nickname": "Dennis Hoppe", "type": "user", "account_id": "5e4bcd82c8ec310c955b8298"}, {"display_name": "Monica d", "uuid": "{c00f42cb-dfaa-4d1b-8622-c901ec62b433}", "links": {"self": {"href": "https://api.bitbucket.org/2.0/users/%7Bc00f42cb-dfaa-4d1b-8622-c901ec62b433%7D"}, "html": {"href": "https://bitbucket.org/%7Bc00f42cb-dfaa-4d1b-8622-c901ec62b433%7D/"}, "avatar": {"href": "https://bitbucket.org/account/msloes/avatar/"}}, "nickname": "msloes", "type": "user", "account_id": null}], "page": 1, "size": ' + numWatchers + '}';
        Integer numForks = 5;
        String forksPaylod = '{"pagelen": 10, "values": [], "page": 1, "size": ' + numForks + '}';

        // set the URLs in the mock
        mock.properties.put(readmeUrl, readmeResponse);
        mock.properties.put(infoUrl, mainPayload);
        mock.properties.put(watchersUrl, watcherPayload);
        mock.properties.put(forksUrl, forksPaylod);        
    }


}