/**
 * 
 * @author Alan Petersen
 * @description Abstract class used as the base for other repo helpers
 */
public abstract class X7sRepoHelper {

    public String url;
    public String projectname;
    public String reponame;
    public String contentUrlBase;
    public String owner;

    public abstract void setUrl(String url);
    public abstract String getReadme();
    public abstract RepoInfo getRepoInfo();

    // a utility method to make a generic HTTP GET request
    public HttpResponse makeGetRequest(String url) {
        try {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod('GET');
            HttpResponse resp = h.send(req);
            if(resp.getStatusCode() != 200) {
                System.debug(LoggingLevel.ERROR, resp.getStatus());
            }
            return resp;
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            throw new X7sRepoException(ex);
        }
    }

    // a utility method to convert relative links to absolute links
    public String processRelativeLinks(String body) {
        String regex = '!\\[.+?\\]\\(.+?\\)';
        Pattern regexPattern = Pattern.compile(regex);
        Matcher m = regexPattern.matcher(body);
        while(m.find()) {
            String found = m.group(0);
            String replacement = found.replace('](','](' + contentUrlBase + '/');
            body = body.replace(found,replacement);
        }
        return body;
    }

    // a utility method to traverse maps of maps (obtained when deserializng JSON files)
    public Object getMapValue(Map<String,Object> m, String key) {
        Object value = null;
        String[] keyparts = key.split('\\.',2);
        if(keyparts.size() == 2) {
            Map<String,Object> m2 = (Map<String,Object>) m.get(keyparts[0]);
            if(m2 != null) {
                value = getMapValue(m2, keyparts[1]);
            }
        } else {
            value = m.get(key);
        }
        return value;
    }

    private static final String BITBUCKET_URL = 'https://bitbucket.org/';
    private static final String GITHUB_URL = 'https://github.com/';
    // map of URLs to the API helpers that are used to process them
    private static Map<String,String> classmap = new Map<String,String>{
        BITBUCKET_URL => 'X7sBitbucketHelper',
        GITHUB_URL => 'X7sGitHubHelper'
    };
    
    // helper method to get the implementation class given the url
    public static X7sRepoHelper getInstance(String url) {
        String classname = null;
        for(String prefix : classmap.keySet()) {
            if(url.startsWith(prefix)) {
                classname = classmap.get(prefix);
                break;
            }
        }
        // if the base URL has no mapping, throw an exception
        if(classname == null) {
            throw new X7sRepoException('Unable to find processor for url ' + url);
        }
        return (X7sRepoHelper)Type.forName(classname).newInstance();
    }

    @future (callout=true)
    public static void refreshReadme(Id recordId) {
        // get the repo record for the supplied id
        List<Developer_Repo__c> repos = [SELECT Id, Name, Location__c, Readme__c FROM Developer_Repo__c WHERE Id = :recordId LIMIT 1];
        if(repos != null && !repos.isEmpty()){
            X7sRepoHelper helper = X7sRepoHelper.getInstance(repos[0].Location__c);
            helper.setUrl(repos[0].Location__c);
            repos[0].Readme__c = helper.getReadme();
            update repos;
        }
    }

    // inner wrapper class to make it easier to pass back data
    public class RepoInfo {
        public String description;
        public String owner;
        public String ownerUrl;
        public String language;
        public Integer forks;
        public Integer watchers;
        public DateTime lastUpdated;
    }
}