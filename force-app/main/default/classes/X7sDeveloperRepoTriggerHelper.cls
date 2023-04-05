/**
 * 
 * @author Alan Petersen
 * @description Helper class for the Devloper Repo trigger
 */
public inherited sharing class X7sDeveloperRepoTriggerHelper {
    private static final String BITBUCKET_URL = 'https://bitbucket.org/';
    private static final String GITHUB_URL = 'https://github.com/';

    public static void setRecordNames(List<Developer_Repo__c> repos) {
        for(Developer_Repo__c repo : repos) {
            String location = repo.Location__c;
            String substr = '';
            
            if(location.contains(BITBUCKET_URL)){
                // remove the URL part and .git extension (if it exists) and use that as the record name
                substr = repo.Location__c.replace(BITBUCKET_URL,'').replaceAll('\\.git$','');
            }else{
                substr = repo.Location__c.replace(GITHUB_URL,'');
            }

            if(String.isNotEmpty(substr)) {
                String [] parts = substr.split('/');
                String newName = parts[0];
                if(parts.size() > 1) {
                    newName += '/' + parts[1];
                }
                repo.Name = newName;
            }
        }
    }

    // process the records in batches of 25 items (because each one has several callouts)
    public static void processRecords(Set<Id> recordIds) {
        List<Set<Id>> listOfSets = new List<Set<Id>>();
        Set<Id> idSet = new Set<Id>();
        listOfSets.add(idSet);
        for(Id recordId : recordIds) {
            if(idSet.size() > 24) {
                idSet = new Set<Id>();
                listOfSets.add(idSet);
            }
            idSet.add(recordId);
        }
        for(Set<Id> idBatch : listOfSets) {
            processRecordsFuture(idBatch);
        }
    }

    // future method to retrieve the readme and repo info for each repo record
    @Future(callout=true)
    public static void processRecordsFuture(Set<Id> recordIds) {
        List<Developer_Repo__c> repos = [SELECT Id, Name, Location__c, Readme__c, Submit_for_approval__c FROM Developer_Repo__c WHERE Id IN :recordIds];
        for(Developer_Repo__c repo : repos) {
            X7sRepoHelper helper = X7sRepoHelper.getInstance(repo.Location__c);
            helper.setUrl(repo.Location__c);
            repo.Readme__c = helper.getReadme();
            X7sRepoHelper.RepoInfo info = helper.getRepoInfo();
            if(info != null) {
                repo.Watch_Count__c = info.watchers;
                repo.Fork_Count__c = info.forks;
                repo.Owner_Name__c = info.owner;
                repo.Owner_Link__c = info.ownerUrl;
                repo.Language__c = info.language;
                repo.Description__c = info.description;
                repo.Last_Updated_Date__c = info.lastUpdated;
            }
            // To submit developer repo record to approval process after updating details from bitbucket api
            if(repo.Submit_for_approval__c){
                repo.Submit_for_approval__c = false;
                repo.Status__c = 'Submitted';
            }
        }
        update repos;
    }

    //Method to recall the developer repo record from approval process
    public static void recallFromApprovalProcess(Set<Id> recordIds) {
        List<ProcessInstanceWorkitem> piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId IN :recordIds
                                                AND ProcessInstance.Status = 'Pending']; 
        List<Approval.ProcessWorkItemRequest> pwiList = new  List<Approval.ProcessWorkItemRequest>();

        for(ProcessInstanceWorkitem piWorkItem : piWorkItems){
            Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
            pwiRequest.setAction('Removed');
            pwiRequest.setWorkItemId(piWorkItem.Id);
            pwiList.add(pwiRequest);
        }
        if(pwiList != null && !pwiList.isEmpty()){
            List<Approval.ProcessResult> results = Approval.process(pwiList);
        }
    }

}