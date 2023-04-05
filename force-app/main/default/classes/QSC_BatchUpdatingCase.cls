/**

* @description        : BatchClass for updating No_Of_Days_Until_Resolved__c by +1 everyday  when status is not closed
* @Author             : prakhar.jain@qsc.com
* @Last Modified By   : prakhar.jain@qsc.con
* @Last Modified On   : 06/02/2023
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    06/02/2023     prakhar.jain@qsc.com       Initial Version
**/
public class QSC_BatchUpdatingCase implements Database.Batchable<sObject> {
    public static integer days=0;
    
    public List<case> start(Database.BatchableContext bc) {
        list<case> caseList =[Select Id,No_Of_Days_Until_Resolved__c From Case WHERE Date_When_Entered_L3__c != null and Status != 'Close'];
         return caseList;
        
    }
    public void execute(Database.BatchableContext bc, List<Case> scope){
        system.debug(scope);
        
        for(Case caserecords: scope){
            system.debug('case'+ caserecords.No_Of_Days_Until_Resolved__c);
            caserecords.No_Of_Days_Until_Resolved__c = caserecords.No_Of_Days_Until_Resolved__c + 1;
            system.debug('No Of Days' + caserecords.No_Of_Days_Until_Resolved__c );
            }
        update scope;
    }
    public void finish(Database.BatchableContext bc){
        system.debug('finish');        
   }
  
    

}