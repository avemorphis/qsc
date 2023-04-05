/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@IsTest
public class X7sTestUtils {
    static final String BASE_REPO_URL = 'https://bitbucket.org/';
    static final String BASE_CONTENT_URL = 'https://bitbucket.org';
    static final String BASE_API_URL = 'https://api.bitbucket.org/2.0';
    static final String BASIC_URL = BASE_REPO_URL + '{projectname}/{reponame}';
    static final String GIT_URL = BASIC_URL + '.git';
    static final String INFO_PATTERN = BASE_API_URL + '/repositories/{projectname}/{reponame}';
    static final String README_PATTERN = BASE_CONTENT_URL + '/{projectname}/{reponame}/raw/HEAD/README.md';
    static final String CONTENT_URL_PATTERN = BASE_CONTENT_URL + '/{projectname}/{reponame}/HEAD';
    
    public static Developer_Repo__c createDeveloperRepo() {
        String projectName = 'TestProject';
        String repoName = 'TestRepo';
        X7sRepoAPIHTTPGETMock mock = new X7sRepoAPIHTTPGETMock();
        Test.setMock(HttpCalloutMock.class, mock);
        addMockProperties(mock, projectName, repoName);
        Developer_Repo__c dr = new Developer_Repo__c();
        dr.Location__c = GIT_URL.replace('{projectname}', projectName).replace('{reponame}', repoName);
        dr.Category__c = 'QSC Developed';
        dr.Status__c = 'Approved';
        dr.Name = 'test';
        dr.Tags__c = 'test';
        insert dr;
        return dr;
    }

    public static List<Developer_Repo__c> createDeveloperRepos(Integer numRepos, String projectNameBase, String repoNameBase) {
        X7sRepoAPIHTTPGETMock mock = new X7sRepoAPIHTTPGETMock();
        Test.setMock(HttpCalloutMock.class, mock);
        List<Developer_Repo__c> repos = new List<Developer_Repo__c>();
        for(Integer i = 0; i < numRepos; i++) {
            String projectName = projectNameBase + i;
            String repoName = repoNameBase + i;
            addMockProperties(mock, projectName, repoName);
            Developer_Repo__c dr = new Developer_Repo__c();
            dr.Location__c = GIT_URL.replace('{projectname}', projectName).replace('{reponame}', repoName);
            dr.Category__c = 'QSC Developed';
            dr.Status__c = 'Approved';
            dr.Name = 'test';
            dr.Tags__c = 'test';
            repos.add(dr);
        }
        insert repos;
        return repos;
    }

    public static List<User> createCommunityUserQSC(Integer numUsers) {
        
        // get the profile ID
        String profileName = getSetting('CommunityPlusProfile');
		Profile profile = [SELECT Id, Name FROM Profile WHERE Name = :profileName LIMIT 1];
        UserRole role = [SELECT Id, name FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        System.debug('### Profile:' + profile.name);
        System.debug('### Role:' + role.name);

        User sysAdminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId != null AND IsActive = TRUE LIMIT 1];

        System.debug('### System Admin ID: '+sysAdminUser.id);
		 List<User> users = new List<User>();
        System.runAs(sysAdminUser){
            Account acc = new Account(Name = 'testAccount') ;
            insert acc;

            String baseLastname = 'TestContact';
            List<Contact> contacts = new List<Contact>();
            for(Integer i=0; i<numUsers; i++) {
                String email = 'test-' + generateRandomString(10) + '@test.com';
                Contact con = new Contact(
                    LastName = baseLastname + i, 
                    AccountId = acc.Id,
                    Email = email);
                contacts.add(con);
            }
            insert contacts;

            for(Contact con : contacts) {
                User communityUser = new User(Alias = 'Com',
                    Email = con.Email,
                    CommunityNickname = con.LastName,
                    EmailEncodingKey = 'UTF-8',
                    LastName = 'Test',
                    LanguageLocaleKey = 'en_US',
                    LocaleSidKey = 'en_US',
                    //UserRoleId = role.id,
                    ProfileId = profile.Id,
                    ContactId = con.Id,                      
                    TimeZoneSidKey = 'America/Los_Angeles',
                    Username = con.Email);
                users.add(communityUser);
            }
            insert users;

            String permissionSetName = getSetting('CommunityPermissionSet');
            PermissionSet ps = [SELECT Id,Name FROM PermissionSet WHERE Name =: permissionSetName];
            System.debug('### Permission Set:' + ps);

            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            for(User u : users) {
                PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.AssigneeId = u.Id;
                psa.PermissionSetId = ps.Id;
                psaList.add(psa);
            }
            insert psaList;
        }
		return users;		
    }

    public static List<Developer_Repo_Tag__c> loadDeveloperRepoTags() {
        return (List<Developer_Repo_Tag__c>) Test.loadData(Developer_Repo_Tag__c.sObjectType, 'DeveloperRepoTagsPredefined');
    }

    public static Developer_Repo_Tag__c createDeveloperRepoTag(String name) {
        Developer_Repo_Tag__c drt = new Developer_Repo_Tag__c();
        drt.Name = name;
        insert drt;
        return drt;
    }

    public static final Integer NUM_FORKS = 5;
    public static final Integer NUM_WATCHERS = 10;

    public static void addMockProperties(X7sRepoAPIHTTPGETMock mock, String projectName, String repoName) {
        String readmeUrl = README_PATTERN.replace('{projectname}', projectName).replace('{reponame}', repoName);
        String readmeResponse = '#### TEST TEST TEST ![ABSOLUTE URL](images/smile.png "smile") ## SOME OTHER HEADING ## FINAL STUFF * a * b * c';

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
        String watcherPayload = '{"pagelen": 10, "values": [{"display_name": "Ronny Roethof", "uuid": "{09122623-382c-48d3-a7e4-07179f3b2e73}", "links": {"self": {"href": "https://api.bitbucket.org/2.0/users/%7B09122623-382c-48d3-a7e4-07179f3b2e73%7D"}, "html": {"href": "https://bitbucket.org/%7B09122623-382c-48d3-a7e4-07179f3b2e73%7D/"}, "avatar": {"href": "https://secure.gravatar.com/avatar/7180aa6a1c8ddfefc38ea3345dad4253?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FRR-4.png"}}, "nickname": "rroethof", "type": "user", "account_id": "557058:312f352b-972a-4941-ab93-46af0b1080b8"}, {"display_name": "Dennis Hoppe", "uuid": "{cac860cb-12a7-446d-a5f0-9bab342b765a}", "links": {"self": {"href": "https://api.bitbucket.org/2.0/users/%7Bcac860cb-12a7-446d-a5f0-9bab342b765a%7D"}, "html": {"href": "https://bitbucket.org/%7Bcac860cb-12a7-446d-a5f0-9bab342b765a%7D/"}, "avatar": {"href": "https://secure.gravatar.com/avatar/317dbc64094d0fd19f33dd785b203d87?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FDH-2.png"}}, "nickname": "Dennis Hoppe", "type": "user", "account_id": "5e4bcd82c8ec310c955b8298"}, {"display_name": "Monica d", "uuid": "{c00f42cb-dfaa-4d1b-8622-c901ec62b433}", "links": {"self": {"href": "https://api.bitbucket.org/2.0/users/%7Bc00f42cb-dfaa-4d1b-8622-c901ec62b433%7D"}, "html": {"href": "https://bitbucket.org/%7Bc00f42cb-dfaa-4d1b-8622-c901ec62b433%7D/"}, "avatar": {"href": "https://bitbucket.org/account/msloes/avatar/"}}, "nickname": "msloes", "type": "user", "account_id": null}], "page": 1, "size": ' + NUM_WATCHERS + '}';
        String forksPaylod = '{"pagelen": 10, "values": [], "page": 1, "size": ' + NUM_FORKS + '}';

        // set the URLs in the mock
        mock.properties.put(readmeUrl, readmeResponse);
        mock.properties.put(infoUrl, mainPayload);
        mock.properties.put(watchersUrl, watcherPayload);
        mock.properties.put(forksUrl, forksPaylod);        
    }

    public static String getSetting(String name) {
        String value = null;
        List<X7sDeveloperRepoSetting__mdt> settings = [SELECT Label,Value__c FROM X7sDeveloperRepoSetting__mdt WHERE Label = :name LIMIT 1];
        if(settings.size() == 1) {
            value = settings[0].Value__c;
        }
        return value;
    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

}