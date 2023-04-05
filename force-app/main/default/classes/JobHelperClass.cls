public class JobHelperClass {
    @AuraEnabled
    public static List<string> queryBatchJobs(){
        try {
            List<string> batchJobs = new  List<string>();
            for(ApexClass ac: [SELECT ApiVersion,Body,BodyCrc,CreatedById,CreatedDate,Id,IsValid,LastModifiedById,LastModifiedDate,LengthWithoutComments,Name,NamespacePrefix,Status,SystemModstamp FROM ApexClass where NamespacePrefix ='' ]){
                if(ac.Body.contains('Database.BatchableContext') && ac.Name!='JobHelperClass'){
                    batchJobs.add(ac.Name);
                }
            }
            return batchJobs;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string runBatchJobs(List<string> batchJobsList){
        string batchJobsFailed = '';
          system.debug('The batchJobsList:'+batchJobsList);
        for(string bjName : batchJobsList ){
            system.debug('The batchJobsList:'+batchJobsList);
            Type classType = Type.forName(bjName);
            try{
            Database.executeBatch((Database.Batchable<sObject>)classType.newInstance(), 100);
            }catch(Exception ex){
                if(String.isNotBlank(batchJobsFailed) ){
                    batchJobsFailed = batchJobsFailed +', '+ bjName ;
                }else{
                    batchJobsFailed = bjName;
                }
                system.debug('Exception::::'+ ex);
            }
        }
        if(string.isNotBlank(batchJobsFailed )){
         return batchJobsFailed ;
        }
        else {
            return 'Success Jobs';
        }
    }
    @AuraEnabled
    public static List<AsyncApexJob> queryJobsData(){
        List<AsyncApexJob> asynapxJobs = new List<AsyncApexJob>();
        asynapxJobs = [SELECT ApexClassId,ApexClass.Name,CompletedDate,CreatedById,CreatedDate,CronTriggerId,ExtendedStatus,Id,JobItemsProcessed,JobType,LastProcessed,LastProcessedOffset,MethodName,NumberOfErrors,ParentJobId,Status,TotalJobItems FROM AsyncApexJob where JobType = 'BatchApex' order by createdDate Desc Limit 10];
        return asynapxJobs;
    }
}