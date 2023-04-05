/**
 * 
 * @author Alan Petersen
 * @description Handler class for the Devloper Repo trigger
 */
public inherited sharing class X7sDeveloperRepoTriggerHandler {
    
    // set the names of the repos
    public static void handleBeforeInsert(List<Developer_Repo__c> repos) {
        X7sDeveloperRepoTriggerHelper.setRecordNames(repos);
    }

    public static void handleAfterInsert(List<Developer_Repo__c> repos) {
        // gather a collection of the IDs of the records inserted
        Set<Id> recordIds = new Set<Id>();
        for(Developer_Repo__c repo : repos) {
            recordIds.add(repo.Id);
        }
        if(recordIds.size() > 0) {
            // call the future method which will update the records
            X7sDeveloperRepoTriggerHelper.processRecords(recordIds);
        }
    }

    public static void  handleBeforeUpdate(Map<Id,Developer_Repo__c> oldMap, List<Developer_Repo__c> repos) {
        List<Developer_Repo__c> nameUpdateList = new List<Developer_Repo__c>();
        for(Developer_Repo__c repo : repos) {
            // check to see if the location has been changed
            if(repo.Location__c != oldMap.get(repo.Id).Location__c) {
                nameUpdateList.add(repo);
            }
            // This block to send record to approval process as we donot have to wait for data from bitbucket api
            else if(repo.Submit_for_approval__c){
                repo.Submit_for_approval__c = false;
                repo.Status__c = 'Submitted';
                X7sRepoHelper.refreshReadme(repo.Id);
            }
        }
        // update names for repos where the location has changed
        if(!nameUpdateList.isEmpty()) {
            X7sDeveloperRepoTriggerHelper.setRecordNames(nameUpdateList);
        }
    }

    public static void  handleAfterUpdate(Map<Id,Developer_Repo__c> oldMap, List<Developer_Repo__c> repos) {
        // gather a collection of the IDs of the records inserted
        Set<Id> recordIds = new Set<Id>();
        Set<Id> recordIdsToRecall = new Set<Id>();

        for(Developer_Repo__c repo : repos) {
            if(repo.Location__c != oldMap.get(repo.Id).Location__c) {
                recordIds.add(repo.Id);
            }
            if(repo.Status__c == 'Needs Work' && repo.Status__c != oldMap.get(repo.Id).Status__c) {
                recordIdsToRecall.add(repo.Id);
            }
        }
        if(recordIds.size() > 0) {
            // call the future method which will update the records
            X7sDeveloperRepoTriggerHelper.processRecords(recordIds);
        }
        if(recordIdsToRecall.size() > 0) {
            X7sDeveloperRepoTriggerHelper.recallFromApprovalProcess(recordIdsToRecall);
        }
    }

}