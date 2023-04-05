/**
 * 
 * @author Alan Petersen
 * @description Implementation class to interact with Bitbucket repositories
 */
public with sharing class X7sBitbucketHelper extends X7sRepoHelper {
    private static final String BASE_REPO_URL = 'https://bitbucket.org/';
    private static final String BASE_API_URL = 'https://api.bitbucket.org/2.0';
    private static final String BASE_CONTENT_URL = 'https://bitbucket.org';
    private static final String INFO_PATTERN = BASE_API_URL + '/repositories/{projectname}/{reponame}';
    private static final String README_PATTERN = BASE_CONTENT_URL + '/{projectname}/{reponame}/raw/HEAD/README.md';
    private static final String CONTENT_URL_PATTERN = BASE_CONTENT_URL + '/{projectname}/{reponame}/raw/HEAD';

    // takes the URL and parses it to determine the project and repo names which are needed for the API calls
    public override void setUrl(String url) {
        if(String.isBlank(url)) {
            throw new X7sRepoException('The URL cannot be empty');
        }
        if(!url.startsWithIgnoreCase(BASE_REPO_URL)) {
            throw new X7sRepoException('The URL must be a Bitbucket URL');
        }
        // remove the .git from the URL if present
        this.url = url.trim().replaceAll('\\.git$','');
        // parse the URL to determine the project name and repo name
        String remaining = this.url.remove(BASE_REPO_URL);
        String[] parts = remaining.split('/');
        // save the parsed information for later
        this.projectname = parts[0];
        this.reponame = parts[1];
        this.contentUrlBase = CONTENT_URL_PATTERN.replace('{projectname}', projectname).replace('{reponame}', reponame);
    }

    // retrieve the README.md file from the repo.
    // note that if the file is not called README.md (i.e. case sensitive match) then it will not be retrieved
    // another assumption is that the main branch is called master
    public override String getReadme() {
        String readme = null;
        String url = README_PATTERN.replace('{projectname}', projectname).replace('{reponame}', reponame);
        System.debug('### getReadme: url=' + url);
        HttpResponse res = makeGetRequest(url);
        if(res.getStatusCode() == 200) {
            // if the HTTP response code is 200, then check for any relative links and convert them to absolute links
            readme = processRelativeLinks(res.getBody());
        }
        return readme;
    }

    // retrieve the repo information. For Bitbucket this requires several API calls to get the data:
    //    1. basic repo information can be obtained from https://api.bitbucket.org/2.0/repositories/{projectname}/{reponame}
    //    2. watcher and fork counts must be obtained from separate API calls, the URLs of which are found in the links.watchers.href and links.forks.href elements of the payload
    public override RepoInfo getRepoInfo() {
        RepoInfo info = null;
        String url = INFO_PATTERN.replace('{projectname}', projectname).replace('{reponame}', reponame);
        HttpResponse res = makeGetRequest(url);
        if(res.getStatusCode() == 200) {
            info = new RepoInfo();
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            info.description = (String)m.get('description');
            info.language = (String)m.get('language');
            info.owner = (String)getMapValue(m, 'owner.display_name');
            info.ownerUrl = (String)getMapValue(m, 'owner.links.html.href');
            String lastUpdatedStr = (String)getMapValue(m, 'updated_on');
            if(String.isNotEmpty(lastUpdatedStr)) {
                info.lastUpdated = Datetime.valueOf(lastUpdatedStr.replace('T',' '));
            }
            String watchersLink = (String)getMapValue(m, 'links.watchers.href');
            HttpResponse watchersResponse = makeGetRequest(watchersLink);
            if(watchersResponse.getStatusCode() == 200) {
                Map<String, Object> wm = (Map<String, Object>) JSON.deserializeUntyped(watchersResponse.getBody());
                info.watchers = (Integer)wm.get('size');
            }
            String forksLink = (String)getMapValue(m, 'links.forks.href');
            HttpResponse forksResponse = makeGetRequest(forksLink);
            if(forksResponse.getStatusCode() == 200) {
                Map<String, Object> fm = (Map<String, Object>) JSON.deserializeUntyped(forksResponse.getBody());
                info.forks = (Integer)fm.get('size');
            }
        }
        return info;
    }
}