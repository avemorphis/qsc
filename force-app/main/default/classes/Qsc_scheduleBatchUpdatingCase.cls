/**

* @description        : Schedule Class for updating No_Of_Days_Until_Resolved__c by +1 everyday  when status is not closed
* @Author             : prakhar.jain@qsc.com
* @Last Modified By   : prakhar.jain@qsc.con
* @Last Modified On   : 06/02/2023
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    06/02/2023     prakhar.jain@qsc.com       Initial Version
**/

global class Qsc_scheduleBatchUpdatingCase implements Schedulable{
    global void execute(SchedulableContext sc){
    QSC_BatchUpdatingCase batchClass = new QSC_BatchUpdatingCase();
    Database.executeBatch(batchClass);
    }

}