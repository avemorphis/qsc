/**

* @description        : ScheduleClass for scheduling PriceBookEntry BatchClass at 10 p.m
* @Author             : prakhar.jain@qsc.com
* @Last Modified By   : prakhar.jain@qsc.con
* @Last Modified On   : 21/12/2022
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    21/12/2022     prakhar.jain@qsc.com       Initial Version
**/

public class priceBookEntryBatchScheduler implements Schedulable
{
    public void execute(SchedulableContext SC){
        database.executeBatch(new priceBookEntryBatch());
    }
}

//string sch ='0 0 22 ? * ?';
//system.schedule('jobPriceBookEntry', sch, new priceBookEntryBatchScheduler());