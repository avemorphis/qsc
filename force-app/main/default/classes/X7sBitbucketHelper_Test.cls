/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@isTest
private class X7sBitbucketHelper_Test {
    static final String BASE_REPO_URL = 'https://bitbucket.org/';
    static final String BASE_CONTENT_URL = 'https://bitbucket.org';
    static final String BASE_API_URL = 'https://api.bitbucket.org/2.0';
    static final String PROJECT_NAME = 'mySuperProject';
    static final String REPO_NAME = 'myGreatRepo';
    static final String BASIC_URL = BASE_REPO_URL + PROJECT_NAME + '/' + REPO_NAME;
    static final String GIT_URL = BASIC_URL + '.git';
    static final String NON_BITBUCKET_URL = 'https://github.com/' + PROJECT_NAME + '/' + REPO_NAME;
    static final String BAD_URL = ' ';
    static final String INFO_PATTERN = BASE_API_URL + '/repositories/' + PROJECT_NAME + '/' + REPO_NAME;
    static final String README_PATTERN = BASE_CONTENT_URL + '/' + PROJECT_NAME + '/' + REPO_NAME + '/raw/HEAD/README.md';
    static final String CONTENT_URL_PATTERN = BASE_CONTENT_URL + '/' + PROJECT_NAME + '/' + REPO_NAME + '/raw/HEAD/';

    @isTest
    static void testSetUrl() {
        // first try with the .git style URL
        X7sRepoHelper helper = new X7sBitbucketHelper();
        helper.setUrl(GIT_URL);
        System.assertEquals(BASIC_URL, helper.url, 'Expected the basic URL to be set');
        System.assertEquals(PROJECT_NAME, helper.projectname, 'Expected the correct project to be set');
        System.assertEquals(REPO_NAME, helper.reponame, 'Expected the correct repo to be set');

        // now try without .git style URL
        helper.setUrl(BASIC_URL);
        System.assertEquals(BASIC_URL, helper.url, 'Expected the basic_url URL to be set');
        System.assertEquals(PROJECT_NAME, helper.projectname, 'Expected the correct project to be set');
        System.assertEquals(REPO_NAME, helper.reponame, 'Expected the correct repo to be set');

        // try with a non-bitbucket URL
        try {
            helper.setUrl(NON_BITBUCKET_URL);
            System.assert(false, 'Expected exception to be thrown when a non-Bitbucket URL is set');
        } catch (X7sRepoException re) {
            System.assert(re.getMessage().contains('The URL must be a Bitbucket URL'), 'Expected specific error message in the exception');
        }

        // now try with a bad URL 
        try {
            helper.setUrl(BAD_URL);
            System.assert(false, 'Expected exception to be thrown when a bad URL is set');
        } catch (X7sRepoException re) {
            System.assert(re.getMessage().contains('The URL cannot be empty'), 'Expected specific error message in the exception');
        }
    }

    @isTest
    static void testGetReadme() {
        String imageWithRelativePath = '![RELATIVE URL](/images/picture.png "some picture")';
        String rewrittenImageWithRelativePath = '![RELATIVE URL](' + CONTENT_URL_PATTERN + '/images/picture.png "some picture")';
        String rawReadme    = '#### TEST TEST TEST ## SOME OTHER HEADING ' + imageWithRelativePath          + ' ## FINAL STUFF * a * b * c';
        String targetReadme = '#### TEST TEST TEST ## SOME OTHER HEADING ' + rewrittenImageWithRelativePath + ' ## FINAL STUFF * a * b * c';
        
        X7sRepoAPIHTTPGETMock mock = new X7sRepoAPIHTTPGETMock();
        mock.properties.put(README_PATTERN, rawReadme);
        Test.setMock(HttpCalloutMock.class, mock);

        X7sRepoHelper helper = new X7sBitbucketHelper();
        helper.setUrl(GIT_URL);
        System.debug(helper.contentUrlBase);
        Test.startTest();
        String readme = helper.getReadme();
        Test.stopTest();
        // ensure that the readme is returned and that the relative URL was rewritten
        System.assertEquals(targetReadme, readme, 'Expected readme returned');
    }

    @isTest
    static void testGetRepoInfo() {
        String watchersUrl = INFO_PATTERN + '/watchers';
        String forksUrl = INFO_PATTERN + '/forks';
        String ownerName = 'Test Owner';
        String ownerUrl = 'https://bitbucket.org/users/testowner';
        String ownerNickname = 'testowner';
        String language = 'python';
        String updateTime = '2021-02-12T18:23:43.720674+00:00';
        DateTime updateDatetime = DateTime.valueOf(updateTime.replace('T',' '));
        String repoDescription = 'A short description of the repo';
        String mainPayload = '{"scm": "git", "website": null, "has_wiki": false, "uuid": "{ab28baf2-eccb-4f0d-a873-7b854367996c}", "links": {"watchers": {"href": "' + watchersUrl + '"}, "branches": {"href": "' + INFO_PATTERN + '/refs/branches"}, "tags": {"href": "' + INFO_PATTERN + '/refs/tags"}, "commits": {"href": "' + INFO_PATTERN + '/commits"}, "clone": [{"href": "' + GIT_URL + '", "name": "https"}, {"href": "git@bitbucket.org:' + PROJECT_NAME + '/' + REPO_NAME + '.git", "name": "ssh"}], "self": {"href": "' + INFO_PATTERN + '"}, "source": {"href": "' + INFO_PATTERN + '/src"}, "html": {"href": "' + BASIC_URL + '"}, "avatar": {"href": "https://bytebucket.org/ravatar/%7Bab28baf2-eccb-4f0d-a873-7b854367996c%7D?ts=2746934"}, "hooks": {"href": "' + INFO_PATTERN + '/hooks"}, "forks": {"href": "' + INFO_PATTERN + '/forks"}, "downloads": {"href": "' + INFO_PATTERN + '/downloads"}, "pullrequests": {"href": "' + INFO_PATTERN + '/pullrequests"}}, "fork_policy": "allow_forks", "full_name": "' + PROJECT_NAME + '/' + REPO_NAME + '", "name": "' + PROJECT_NAME + '", "project": {"links": {"self": {"href": "https://api.bitbucket.org/2.0/workspaces/' + PROJECT_NAME + '/projects/UNITY"}, "html": {"href": "https://bitbucket.org/' + PROJECT_NAME + '/workspace/projects/UNITY"}, "avatar": {"href": "https://bitbucket.org/account/user/' + PROJECT_NAME + '/projects/PROJ/avatar/32?ts=1613099748"}}, "type": "project", "name": "My Projects", "key": "PROJ", "uuid": "{6b67b070-1072-44f7-82d0-92b5ce582f64}"}, "language": "' + language + '", "created_on": "2021-02-12T03:06:39.234818+00:00", "mainbranch": {"type": "branch", "name": "master"}, "workspace": {"slug": "' + PROJECT_NAME + '", "type": "workspace", "name": "' + ownerName + '", "links": {"self": {"href": "https://api.bitbucket.org/2.0/workspaces/' + PROJECT_NAME + '"}, "html": {"href": "https://bitbucket.org/' + PROJECT_NAME + '/"}, "avatar": {"href": "https://bitbucket.org/workspaces/' + PROJECT_NAME + '/avatar/?ts=1613100012"}}, "uuid": "{cf63f919-692f-42a3-8cea-7c0d10a0156f}"}, "has_issues": false, "owner": {"display_name": "' + ownerName + '", "uuid": "{cf63f919-692f-42a3-8cea-7c0d10a0156f}", "links": {"self": {"href": "' + ownerUrl + '"}, "html": {"href": "' + ownerUrl + '"}, "avatar": {"href": "https://secure.gravatar.com/avatar/530ef6719dbbc15e6da3f327be15fe24?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FKZ-6.png"}}, "nickname": "' + ownerNickname + '", "type": "user", "account_id": "557058:6549762e-e82a-4a56-8a5f-216d831f5b3d"}, "updated_on": "' + updateTime + '", "size": 48868207, "type": "repository", "slug": "' + REPO_NAME + '", "is_private": false, "description": "' + repoDescription + '"}';        
        Integer numWatchers = 10;
        String watcherPayload = '{"pagelen": 10, "values": [{"display_name": "Ronny Roethof", "uuid": "{09122623-382c-48d3-a7e4-07179f3b2e73}", "links": {"self": {"href": "https://api.bitbucket.org/2.0/users/%7B09122623-382c-48d3-a7e4-07179f3b2e73%7D"}, "html": {"href": "https://bitbucket.org/%7B09122623-382c-48d3-a7e4-07179f3b2e73%7D/"}, "avatar": {"href": "https://secure.gravatar.com/avatar/7180aa6a1c8ddfefc38ea3345dad4253?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FRR-4.png"}}, "nickname": "rroethof", "type": "user", "account_id": "557058:312f352b-972a-4941-ab93-46af0b1080b8"}, {"display_name": "Dennis Hoppe", "uuid": "{cac860cb-12a7-446d-a5f0-9bab342b765a}", "links": {"self": {"href": "https://api.bitbucket.org/2.0/users/%7Bcac860cb-12a7-446d-a5f0-9bab342b765a%7D"}, "html": {"href": "https://bitbucket.org/%7Bcac860cb-12a7-446d-a5f0-9bab342b765a%7D/"}, "avatar": {"href": "https://secure.gravatar.com/avatar/317dbc64094d0fd19f33dd785b203d87?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FDH-2.png"}}, "nickname": "Dennis Hoppe", "type": "user", "account_id": "5e4bcd82c8ec310c955b8298"}, {"display_name": "Monica d", "uuid": "{c00f42cb-dfaa-4d1b-8622-c901ec62b433}", "links": {"self": {"href": "https://api.bitbucket.org/2.0/users/%7Bc00f42cb-dfaa-4d1b-8622-c901ec62b433%7D"}, "html": {"href": "https://bitbucket.org/%7Bc00f42cb-dfaa-4d1b-8622-c901ec62b433%7D/"}, "avatar": {"href": "https://bitbucket.org/account/msloes/avatar/"}}, "nickname": "msloes", "type": "user", "account_id": null}], "page": 1, "size": ' + numWatchers + '}';
        Integer numForks = 5;
        String forksPaylod = '{"pagelen": 10, "values": [], "page": 1, "size": ' + numForks + '}';

        X7sRepoAPIHTTPGETMock mock = new X7sRepoAPIHTTPGETMock();
        mock.properties.put(INFO_PATTERN, mainPayload);
        mock.properties.put(watchersUrl, watcherPayload);
        mock.properties.put(forksUrl, forksPaylod);
        Test.setMock(HttpCalloutMock.class, mock);

        X7sRepoHelper helper = new X7sBitbucketHelper();
        helper.setUrl(GIT_URL);
        X7sRepoHelper.RepoInfo info = helper.getRepoInfo();
        System.assertEquals(ownerName, info.owner, 'Expected matching owner name');
        System.assertEquals(ownerUrl, info.ownerUrl, 'Expected matching owner URL');
        System.assertEquals(language, info.language, 'Expected matching language');
        System.assertEquals(repoDescription, info.description, 'Expected matching description');
        System.assertEquals(numForks, info.forks, 'Expected matching number of forks');
        System.assertEquals(numWatchers, info.watchers, 'Expected matching number of watchers');
        System.assertEquals(updateDatetime, info.lastUpdated, 'Expected matching last update time');
    }


}