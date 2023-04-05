/**
 * 
 * @author Aravind R
 * @description Controller class to LWC
 */
public without sharing class X7sDeveloperRepoController {

    @AuraEnabled(cacheable=false)
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

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getRepos(String searchString, String category, List<String> tags, String orderBy, Integer pageSize, Integer pageNumber, Boolean mine) {
        if(pageSize == null) {
            pageSize = 10;
        }
        if(pageNumber == null) {
            pageNumber = 1;
        }
        if(mine == null) {
            mine = false;
        }
        Integer offset = pageSize * (pageNumber - 1);
        String escapedSearchString = null;
        if(String.isNotBlank(searchString)) {
            escapedSearchString = String.escapeSingleQuotes(searchString.trim());
        }
        String escapedCategory = null;
        if(String.isNotBlank(category)) {
            escapedCategory = String.escapeSingleQuotes(category.trim());
        }
        Map<String, String> orderbyMap = new Map<String, String>
        {   'MOST_RECENT' => 'Last_Updated_Date__c DESC', 
            'OLDEST_FIRST' => 'Last_Updated_Date__c ASC',
            'MOST_POPULAR' => 'Watch_Count__c DESC'
        };

        List<String> statusFilter = new List<String>{'Approved'};
        if(mine) {
            statusFilter.add('Needs Work');
            statusFilter.add('Draft');
        }
        
        // build query
        String returnFields = 'Id,Name,Status__c,Description__c,Category__c,Fork_Count__c,Watch_Count__c,Owner_Name__c,Tags__c,Language__c,Last_Updated_Date__c';

        String whereClause = 'Status__c IN :statusFilter';

        if(String.isNotBlank(category)) {
            whereClause += ' AND Category__c =: escapedCategory';
        }

        Id myid = UserInfo.getUserId();
        if(mine) {
            whereClause += ' AND OwnerId =: myid';
        }

        if(tags != null && tags.size() > 0) {
            whereClause += ' AND (Tags__c LIKE \'%' + String.join(tags, '%\' OR Tags__c LIKE \'%') + '%\')';
        }

        String orderClause = '';
        if(orderbyMap.containsKey(orderBy)) {
            orderClause = orderByMap.get(orderBy);
        } else {
            orderClause = 'LastModifiedDate DESC';
        }
        String offsetClause = ' LIMIT :pageSize OFFSET :offset';

        String soslQuery = 'FIND :escapedSearchString IN ALL FIELDS RETURNING Developer_Repo__c(' + 
            returnFields + ' WHERE ' + whereClause + ' ORDER BY ' + orderClause + offsetClause + ')';
        String soqlQuery = 'SELECT ' + returnFields + ' FROM Developer_Repo__c WHERE ' + 
            whereClause + ' ORDER BY ' + orderClause + offsetClause;
        String countQuery = 'SELECT COUNT(Id) FROM Developer_Repo__c WHERE ' + whereClause;

        System.debug('#### Status Filter: ' + statusFilter);
        System.debug('#### Page Size: ' + pageSize);
        System.debug('#### Offset: ' + offset);
        System.debug('#### SOSL: ' + soslQuery);
        System.debug('#### SOQL: ' + soqlQuery);

        // get overall count of matching records
        AggregateResult[] aggregate = Database.query(countQuery);
        Integer count = Integer.valueOf(aggregate[0].get('expr0'));


        List<Developer_Repo__c> repos;
		if(String.isNotBlank(searchString)) {
            List<List<sObject>> results = search.query(soslQuery);
			repos = ((List<Developer_Repo__c>)results[0]);
		} else {  
            repos = Database.query(soqlQuery);
		}
        Map<String,Object> returnmap = new Map<String,Object>();
        returnmap.put('total', count);
        returnmap.put('records', repos);
        return returnmap;
    }

    @AuraEnabled
    public static Id submitRepo(Id repoId, String location, List<Id> contributors, List<String> tags){
        // use the repo helper to determine if the repo location is valid
        try {
            X7sRepoHelper helper = X7sRepoHelper.getInstance(location);
        } catch(X7sRepoException e) {
            throw new AuraHandledException('Invalid location');
        }
        
        // collect the contributor ids in a set to make it eaasier to process and avoid duplicates
        Set<Id> contributorSet = new Set<Id>();
        for(Id contributorId: contributors) {
            contributorSet.add(contributorId);
        }
        // collection of contributors to insert
        List<Developer_Repo_Contributor__c> contributorInsertList = new List<Developer_Repo_Contributor__c>();
        // collection of contributors that need deletion
        List<Developer_Repo_Contributor__c> contributorDeleteList = new List<Developer_Repo_Contributor__c>();
        
        // create a developer repo
        Developer_Repo__c repo = new Developer_Repo__c();
        repo.Location__c = location;
        repo.Tags__c = String.join(tags, ',');

        for(Developer_Repo_Tag__c tag : [SELECT Id, Name FROM Developer_Repo_Tag__c WHERE Name IN :tags]){
            Integer index = tags.indexOf(tag.Name);
            if(index != -1){
                tags.remove(index);
            }
        }

        List<Developer_Repo_Tag__c> tagsToCreate = new List<Developer_Repo_Tag__c>();
        for(String tag : tags){
            tagsToCreate.add(new Developer_Repo_Tag__c(Name = tag));
        }

        if(!tagsToCreate.isEmpty()){
            insert tagsToCreate;
        }
        
        // if an Id is passed to the method, then this is updating an existing record rather than creating a new one
        if(String.isNotBlank(repoId)) {
            repo.Id = repoId;
            // check for any existing contributors... 
            for(Developer_Repo_Contributor__c contributor : [SELECT Id,Contributor__c FROM Developer_Repo_Contributor__c WHERE Developer_Repo__c =:repoId]) {
                if(!contributorset.contains(contributor.Contributor__c)) {
                    // if the incoming list of contributors does not include an existing one, the existing one should be removed
                    contributorDeleteList.add(contributor);   
                } else {
                    // if the incoming contributor list already exists, we don't need to create it again
                    contributorSet.remove(contributor.Contributor__c);
                }
            }
        }
        
        try {
            // now that the repo information is populated, insert or update it
            //Submit_for_approval__c checkbox value will be used to send record for approval after it gets data from api 
            repo.Submit_for_approval__c = true;
            UPSERT repo;
        } catch(Exception e) {
            throw new AuraHandledException('Exception occurred while inserting/updating developer repo record '+e.getMessage());
        }
        
        // for any contributors remaining in the list, we need to create them
        for(Id contributorId : contributorSet) {
            contributorInsertList.add(createDPC(repo.Id, contributorId));
        }
        if(!contributorInsertList.isEmpty()) {
            INSERT contributorInsertList;
        }
        if(!contributorDeleteList.isEmpty()) {
            DELETE contributorDeleteList;
        }
        
        // set the status to submitted to invoke the approval process
        /*repo.Status__c = 'Submitted';
        try {
            UPDATE repo;
        } catch(Exception e){
            throw new AuraHandledException('Exception occurred while submitting record for approval '+e.getMessage());
        }*/
        
        return repo.Id;
        
    }
    
    @AuraEnabled
    public static Boolean sendInvitation(String email, String name, String user){
        Integer networkMemberCount = [SELECT count() FROM NetworkMember WHERE Member.Email =:email AND Network.Name=:getSetting('DefaultNetworkName')];
        if(networkMemberCount > 0){
            return false;
        }
        else{
            X7s_Invitation_email__mdt metadataRec = getEmailContent('Dev');
            String emailBody = metadataRec.Email_body__c.replace('{name}',name).replace('{user}',user);
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setSubject(metadataRec.Email_Subject__c);
            message.setPlainTextBody(emailBody);
            message.toAddresses = new String[] {email};
            if(Test.isRunningTest()) {
                return true;
            }
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {message});
            if (!results[0].success) {
                throw new AuraHandledException('Exception while sending the email '+results[0].errors[0].message);
            }
            return true;
        }
    }
    
    @AuraEnabled
    public static void deleteRepo(String repoId){
        List<Developer_Repo__c> repos = [SELECT Id,OwnerId FROM Developer_Repo__c WHERE Id=:repoId];
        if(repos == null || repos.isEmpty()){
            throw new AuraHandledException('Developer repo id is invalid');
        }
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id;
        if(repos[0].OwnerId == UserInfo.getUserId() || UserInfo.getProfileId() == adminProfileId){
            DELETE repos;
        }
    }
    
    // helper method to create a contributor record
    private static Developer_Repo_Contributor__c createDPC(Id repoId, Id contributorId) {
        Developer_Repo_Contributor__c dpc = new Developer_Repo_Contributor__c();
        dpc.Developer_Repo__c =  repoId;
        dpc.Contributor__c =  contributorId;
        return dpc;
    }
    
    //helper method to get setting's value from X7sDeveloperRepoSetting__mdt custom metadata
    private static String getSetting(String name) {
        String value = null;
        List<X7sDeveloperRepoSetting__mdt> settings = [SELECT Label,Value__c FROM X7sDeveloperRepoSetting__mdt WHERE Label = :name LIMIT 1];
        if(settings.size() == 1) {
            value = settings[0].Value__c;
        }
        return value;
    }
    
    //helper method to get email content from X7s_Invitation_email__mdt custom metadata
    private static X7s_Invitation_email__mdt getEmailContent(String name) {
        return [SELECT Email_body__c,Email_Subject__c FROM X7s_Invitation_email__mdt WHERE DeveloperName = :name LIMIT 1];
    }

    @AuraEnabled(cacheable=true)
    public static Developer_Repo__c getRepoInfoById(String repoId){
        return [SELECT Id,Name,OwnerId,Owner.Name,Status__c,Location__c,Last_Updated_Date__c,Tags__c,Description__c,Readme__c,Watch_Count__c,Fork_Count__c,Category__c,Owner_Name__c,Owner_Link__c,(SELECT Id,Contributor__c, Contributor__r.Id, Contributor__r.FirstName, Contributor__r.LastName, Contributor__r.Email FROM Developer_Repo_Contributors__r) FROM Developer_Repo__c WHERE Id=:repoId];
    }

}