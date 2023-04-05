@isTest
public class JobHelperClass_Test {
	public static testMethod void JobHelperClass(){
        //List<SObject> batchJob = new List<SObject>();  
        test.startTest();
        JobHelperClass.queryBatchJobs();
        test.stopTest();
    }
    	 
    @isTest
    public static void runBatchJobs(){
        string batchJobsFailed = '';
       // String bjName = '';
        List<String> lstString = new List<String>();
        lstString.add('test');
        lstString.add('success');
        lstString.add('testid');
        test.startTest();
        JobHelperClass.runBatchJobs(lstString);
        test.stopTest();
    }  
    
    @isTest
    public static void getQueryJobData(){
        List<AsyncApexJob> asynapxJobs = new List<AsyncApexJob>();
        asynapxJobs = [SELECT ApexClassId,ApexClass.Name,CompletedDate,CreatedById,CreatedDate,CronTriggerId,ExtendedStatus,Id,JobItemsProcessed,JobType,LastProcessed,LastProcessedOffset,MethodName,NumberOfErrors,ParentJobId,Status,TotalJobItems FROM AsyncApexJob where JobType = 'BatchApex' order by createdDate Desc Limit 10];
        test.startTest();
        JobHelperClass.queryJobsData();
        test.stopTest();
    }
}