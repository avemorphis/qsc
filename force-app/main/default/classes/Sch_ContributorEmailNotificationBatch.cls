/**

* @description        : Sch_ContributorEmailNotificationBatch for sending email notification to developer repo contributon every friday using ContributorEmailNotificationBatch class.
* @Last Modified By   : prakhar.jain@qsc.con
* @Last Modified On   : 20/03/2023
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    20/03/2023     prakhar.jain@qsc.com       Initial Version
**/
global class Sch_ContributorEmailNotificationBatch implements Schedulable
{
	global void execute(SchedulableContext sc) 
    {
        ContributorEmailNotificationBatch b = new ContributorEmailNotificationBatch(); 
        database.executebatch(b, 200);
        
    }
}