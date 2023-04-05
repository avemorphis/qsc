/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@isTest
public with sharing class X7sGitHubHelper_Test {
    static final String BASE_REPO_URL = 'https://github.com/';
    static final String BASE_API_URL = 'https://api.github.com/';
    static final String BASE_CONTENT_URL = 'https://github.com';
    static final String OWNER_NAME = 'mySuperProject';
    static final String REPO_NAME = 'myGreatRepo';
    static final String BASIC_URL = BASE_REPO_URL + OWNER_NAME + '/' + REPO_NAME;
    static final String GIT_URL = BASIC_URL + '.git';
    static final String NON_GITHUB_URL = 'https://bitbucket.org/' + REPO_NAME + '/' + REPO_NAME;
    static final String BAD_URL = ' ';
    static final String INFO_PATTERN = BASE_API_URL + 'repos/'+OWNER_NAME+'/'+REPO_NAME;
    static final String README_PATTERN = BASE_API_URL + 'repos/'+OWNER_NAME+'/'+REPO_NAME+'/readme';
    static final String DOWNLOAD_README_URL = 'https://raw.githubusercontent.com/'+OWNER_NAME+'/'+OWNER_NAME+'.rb/master/README.md'; 
    static final String CONTENT_URL_PATTERN = BASE_API_URL + 'repos/'+OWNER_NAME+'/'+REPO_NAME+'/contents/{path}';
    
    @isTest
    static void testSetUrl() {
        // first try with the .git style URL
        X7sRepoHelper helper = new X7sGitHubHelper();
        helper.setUrl(GIT_URL);
        System.assertEquals(BASIC_URL, helper.url, 'Expected the basic URL to be set');
        System.assertEquals(OWNER_NAME, helper.owner, 'Expected the correct owner to be set');
        System.assertEquals(REPO_NAME, helper.reponame, 'Expected the correct repo to be set');

        // now try without .git style URL
        helper.setUrl(BASIC_URL);
        System.assertEquals(BASIC_URL, helper.url, 'Expected the basic_url URL to be set');
        System.assertEquals(OWNER_NAME, helper.owner, 'Expected the correct project to be set');
        System.assertEquals(REPO_NAME, helper.reponame, 'Expected the correct repo to be set');

        // try with a non-bitbucket URL
        try {
            helper.setUrl(NON_GITHUB_URL);
            System.assert(false, 'Expected exception to be thrown when a non-GitHub URL is set');
        } catch (X7sRepoException re) {
            System.assert(re.getMessage().contains('The URL must be a GitHub or Bitbucket URL'), 'Expected specific error message in the exception');
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
        String readMeBody = '{"type": "file","encoding": "base64","size": 5362,"name": "README.md","path": "README.md","content": "encoded content ...","sha": "3d21ec53a331a6f037a91c368710b99387d012c1","url": "https://api.github.com/repos/octokit/octokit.rb/contents/README.md","git_url": "https://api.github.com/repos/octokit/octokit.rb/git/blobs/3d21ec53a331a6f037a91c368710b99387d012c1","html_url": "https://github.com/octokit/octokit.rb/blob/master/README.md","download_url": "'+DOWNLOAD_README_URL+'","_links": {"git": "https://api.github.com/repos/octokit/octokit.rb/git/blobs/3d21ec53a331a6f037a91c368710b99387d012c1","self": "https://api.github.com/repos/octokit/octokit.rb/contents/README.md","html": "https://github.com/octokit/octokit.rb/blob/master/README.md"}}';
        String rawReadme    = '### TEST TEST TEST ## SOME OTHER HEADING ' + imageWithRelativePath          + ' ## FINAL STUFF * a * b * c';
        
        X7sRepoAPIHTTPGETMock mock = new X7sRepoAPIHTTPGETMock();
        mock.properties.put(README_PATTERN, readMeBody);
        mock.properties.put(DOWNLOAD_README_URL, rawReadme);
        Test.setMock(HttpCalloutMock.class, mock);

        X7sRepoHelper helper = new X7sGitHubHelper();
        helper.setUrl(GIT_URL);
        System.debug(helper.contentUrlBase);
        Test.startTest();
        String readme = helper.getReadme();
        Test.stopTest();
        // ensure that the readme is returned and that the relative URL was rewritten
        System.assert(String.isNotEmpty(readme),'Expected readme returned');
    }

    @isTest
    static void testGetRepoInfo() {
        String ownerName = 'mySuperProject';
        String ownerUrl = 'https://github.com/'+OWNER_NAME;
        String language = 'Apex';
        String updateTime = '2011-01-26T19:14:43Z';
        DateTime updateDatetime = DateTime.valueOf(updateTime.replace('T',' '));
        String repoDescription = 'A short description of the repo';
        Integer numWatchers = 10;
        Integer numForks = 5;
        String mainPayload = '{"id": 1296269,"node_id": "MDEwOlJlcG9zaXRvcnkxMjk2MjY5","name": "Hello-World","full_name": "octocat/Hello-World","owner": {"login": "octocat","html_url": "'+ownerUrl+'","type": "User","site_admin": false},"private": false,"html_url": "https://github.com/octocat/Hello-World","description": "'+repoDescription+'","fork": false,"homepage": "https://github.com","language": "'+language+'","forks_count": 5,"forks": '+numForks+',"stargazers_count": 80,"watchers_count": 10,"subscribers_count":'+numWatchers+',"update_at":"'+updateTime+'"}';        
        
        

        X7sRepoAPIHTTPGETMock mock = new X7sRepoAPIHTTPGETMock();
        mock.properties.put(INFO_PATTERN, mainPayload);
        Test.setMock(HttpCalloutMock.class, mock);

        X7sRepoHelper helper = new X7sGitHubHelper();
        helper.setUrl(BASIC_URL);
        X7sRepoHelper.RepoInfo info = helper.getRepoInfo();
        System.assertEquals(ownerName, info.owner, 'Expected matching owner name');
        System.assertEquals(ownerUrl, info.ownerUrl, 'Expected matching owner URL');
        System.assertEquals(language, info.language, 'Expected matching language');
        System.assertEquals(repoDescription, info.description, 'Expected matching description');
        System.assertEquals(numForks, info.forks, 'Expected matching number of forks');
        System.assertEquals(numWatchers, info.watchers, 'Expected matching number of watchers');
    }

    @isTest static void testRefreshReadme(){
        String imageWithRelativePath = '![RELATIVE URL](/images/picture.png)';
        String ownerName = 'mySuperProject';
        String ownerUrl = 'https://github.com/'+OWNER_NAME;
        String language = 'Apex';
        String updateTime = '2011-01-26T19:14:43Z';
        DateTime updateDatetime = DateTime.valueOf(updateTime.replace('T',' '));
        String repoDescription = 'A short description of the repo';
        Integer numWatchers = 10;
        Integer numForks = 5;
        String mainPayload = '{"id": 1296269,"node_id": "MDEwOlJlcG9zaXRvcnkxMjk2MjY5","name": "Hello-World","full_name": "octocat/Hello-World","owner": {"login": "octocat","html_url": "'+ownerUrl+'","type": "User","site_admin": false},"private": false,"html_url": "https://github.com/octocat/Hello-World","description": "'+repoDescription+'","fork": false,"homepage": "https://github.com","language": "'+language+'","forks_count": 5,"forks": '+numForks+',"stargazers_count": 80,"watchers_count": 10,"watchers":'+numWatchers+',"update_at":"'+updateTime+'"}';        
        String readMeBody = '{"type": "file","encoding": "base64","size": 5362,"name": "README.md","path": "README.md","content": "encoded content ...","sha": "3d21ec53a331a6f037a91c368710b99387d012c1","url": "https://api.github.com/repos/octokit/octokit.rb/contents/README.md","git_url": "https://api.github.com/repos/octokit/octokit.rb/git/blobs/3d21ec53a331a6f037a91c368710b99387d012c1","html_url": "https://github.com/octokit/octokit.rb/blob/master/README.md","download_url": "'+DOWNLOAD_README_URL+'","_links": {"git": "https://api.github.com/repos/octokit/octokit.rb/git/blobs/3d21ec53a331a6f037a91c368710b99387d012c1","self": "https://api.github.com/repos/octokit/octokit.rb/contents/README.md","html": "https://github.com/octokit/octokit.rb/blob/master/README.md"}}';
        String rawReadme    = '### TEST TEST TEST ## SOME OTHER HEADING ' + imageWithRelativePath          + ' ## FINAL STUFF * a * b * c';
        String IMAGE_URL = CONTENT_URL_PATTERN.replace('{path}','images/picture.png)');
        String imageBody = '{"download_url":"https://raw.githubusercontent.com/mySuperProject/myGreatRepo/master/images/picture.png"}';

        X7sRepoAPIHTTPGETMock mock = new X7sRepoAPIHTTPGETMock();
        mock.properties.put(INFO_PATTERN, mainPayload);
        mock.properties.put(README_PATTERN, readMeBody);
        mock.properties.put(DOWNLOAD_README_URL, rawReadme);
        mock.properties.put(IMAGE_URL, imageBody);
        Test.setMock(HttpCalloutMock.class, mock);

        Developer_Repo__c repo = new Developer_Repo__c();
        repo.name = 'Hello-World';
        repo.description__c = 'Old description';
        repo.readme__c = 'Old readme';
        repo.fork_count__c = 0;
        repo.watch_count__c = 0;
        repo.Location__c = BASIC_URL;
        insert repo;

        List<Developer_Repo__c> newRepo = [SELECT id, description__c FROM Developer_Repo__c WHERE name = 'Hello-World' LIMIT 1];
        Test.startTest();
            if(newRepo.size() > 0){
                newRepo[0].description__c = 'New description';
                update newRepo;
            }
        Test.stopTest();
        
    }

}