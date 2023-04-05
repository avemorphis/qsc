/**
 * 
 * @author Aravind R.
 * @description Utility class for frontend typeahead functionality
 */
public without sharing class X7sTypeAheadUtility {
    
    // method to provide typeahead functionality for tags
    @AuraEnabled(cacheable=true)
    public static List<String> tagSearch(String searchStr) {
        System.debug('searchStr---'+searchStr);
        List<String> tagList = new List<String>();
        String searchTag = searchStr + '%';
        for(Developer_Repo_Tag__c tag: [SELECT Id,Name FROM Developer_Repo_Tag__c WHERE Name LIKE : searchTag LIMIT 4]){
            tagList.add(tag.Name);
        }
        return tagList;
    }

    // method to provide typeahead functionality for community members
    @AuraEnabled(cacheable=true)
    public static List<NetworkMember> userSearch(String searchStr) {
        System.debug('searchStr---'+searchStr.length());
        String networkName = getSetting('DefaultNetworkName');
        List<NetworkMember> memberList = new List<NetworkMember>();
        if(searchStr.length() >= 4)
        {
            memberList = [SELECT Id,MemberId,Member.Name,Member.Email FROM NetworkMember WHERE Network.Name=:networkName AND Member.Email LIKE: searchStr + '%' LIMIT 2];
        }
        
        return memberList;
    }

    private static String getSetting(String name) {
        String value = null;
        List<X7sDeveloperRepoSetting__mdt> settings = [SELECT Label,Value__c FROM X7sDeveloperRepoSetting__mdt WHERE Label = :name LIMIT 1];
        if(settings.size() == 1) {
            value = settings[0].Value__c;
        }
        return value;
    }
}