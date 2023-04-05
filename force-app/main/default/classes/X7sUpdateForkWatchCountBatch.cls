public  class X7sUpdateForkWatchCountBatch implements Database.Batchable<sObject>,Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id,Location__c FROM Developer_Repo__c WHERE Status__c = \'Approved\'');
    }
    public void execute(Database.BatchableContext bc, List<Developer_Repo__c> repos){
        for(Developer_Repo__c repo: repos){
            X7sRepoHelper helper = X7sRepoHelper.getInstance(repo.Location__c);
            helper.setUrl(repo.Location__c);
            X7sRepoHelper.RepoInfo info = helper.getRepoInfo();
            if(info != null) {
                repo.Watch_Count__c = info.watchers;
                repo.Fork_Count__c = info.forks;
                repo.Last_Updated_Date__c = info.lastUpdated;
            }     
        }
        update repos;
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}