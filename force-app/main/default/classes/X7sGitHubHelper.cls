/**
 * 
 * @author Ronald Stewart
 * @description Implementation class to interact with GitHub repositories
 */
public with sharing class X7sGitHubHelper extends X7sRepoHelper {
    private static final String BASE_REPO_URL = 'https://github.com/';
    private static final String BASE_API_URL = 'https://api.github.com/';
    private static final String BASE_CONTENT_URL = 'https://github.com';
    private static final String INFO_PATTERN = BASE_API_URL + 'repos/{owner}/{repo}';
    private static final String README_PATTERN = BASE_API_URL + 'repos/{owner}/{repo}/readme';
    private static final String CONTENT_URL_PATTERN = BASE_API_URL + 'repos/{owner}/{repo}/contents/{path}';

    // takes the URL and parses it to determine the project and repo names which are needed for the API calls
    public override void setUrl(String url) {
        if(String.isBlank(url)) {
            throw new X7sRepoException('The URL cannot be empty');
        }
        if(!url.startsWithIgnoreCase(BASE_REPO_URL)) {
            throw new X7sRepoException('The URL must be a GitHub or Bitbucket URL');
        }
        // remove the .git from the URL if present
        this.url = url.trim().replaceAll('\\.git$','');
        // parse the URL to determine the project name and repo name
        String remaining = this.url.remove(BASE_REPO_URL);
        String[] parts = remaining.split('/');
        // save the parsed information for later
        this.owner = parts[0];
        this.reponame = parts[1];
        this.contentUrlBase = CONTENT_URL_PATTERN.replace('{owner}', owner).replace('{repo}', reponame);
    }

    private String convertRelativeToAbsoluteLinks(String body){
        String regex = '(?<=\\]\\()(.*?)(?=\\))';
        Pattern regexPattern = Pattern.compile(regex);
        Matcher m = regexPattern.matcher(body);
        while(m.find()) {
            String found = m.group(0);
            if(!found.contains('https://')){
                System.debug('### FOUND: '+found);
                String foundRemoveBegin = found.removeStart('/');
                //If the HTTP response is 200, then check add the content url for file path content
                String contentUrl = this.contentUrlBase.replace('{path}',foundRemoveBegin);
                System.debug('### Content Url: '+contentUrl);
                HttpResponse res = makeGetRequest(contentUrl);
                if(res.getStatusCode() == 200){
                    //replace(target, replacement) signature used here
                    System.debug(res.getBody());
                    Map<String, Object> mp = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    String replacement = found.replace(found,(String) mp.get('download_url'));
                    body = body.replace(found,replacement);
                }
            }
        }
        return body;
    }
    // retrieve the README.md file from the repo.
    // note that if the file is not called README.md (i.e. case sensitive match) then it will not be retrieved
    // another assumption is that the main branch is called master
    public override String getReadme() {
        String readme = null;
        String url = README_PATTERN.replace('{owner}', owner).replace('{repo}', reponame);
        System.debug('### getReadme: url=' + url);
        HttpResponse res = makeGetRequest(url);
        Map<String, Object> m = new Map<String, Object>();
        // if the HTTP response code is 200, then check for any relative links and convert them to absolute links
        if(res.getStatusCode() == 200) {
            //Get the ReadMe raw format
            m = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            HttpResponse readMeRes = makeGetRequest((String) m.get('download_url'));
            // if the HTTP response code is 200, then check for any relative links and convert them to absolute links
            if(readMeRes.getStatusCode() == 200){
                readme = convertRelativeToAbsoluteLinks(readMeRes.getBody());    
            }
        }
        return readme;
    }

    // retrieve the repo information. For GitHub this requires several API calls to get the data:
    //    1. basic repo information can be obtained from https://api.github.com/repo/{owner}/{reponame}
    //    2. watcher and fork counts must be obtained from separate API calls, the URLs of which are found in the links.watchers.href and links.forks.href elements of the payload
    public override RepoInfo getRepoInfo() {
        RepoInfo info = null;
        String url = INFO_PATTERN.replace('{owner}', owner).replace('{repo}', reponame);
        HttpResponse res = makeGetRequest(url);
        if(res.getStatusCode() == 200) {
            info = new RepoInfo();
            System.debug(res.getBody());
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            // Get (String) description;
            info.description = (String)m.get('description');
            // Get (String) owner;
            info.owner = this.owner;
            // Get (String) ownerUrl;
            info.ownerUrl = (String)getMapValue(m,'owner.html_url');
            System.debug('info.ownerUrl: '+info.ownerUrl);
            // Get (String) language;
            info.language = (String)m.get('language');
            // Get (Integer) forks;
            info.forks = (Integer)m.get('forks');    
            // Get (Integer) watchers;
            info.watchers = (Integer)m.get('subscribers_count');
            // Get (DateTime) lastUpdated;
            String lastUpdatedStr = (String)getMapValue(m, 'updated_at');
            if(String.isNotEmpty(lastUpdatedStr)) {
                info.lastUpdated = Datetime.valueOf(lastUpdatedStr.replace('T',' '));
            }
        }
        return info;
    }
}