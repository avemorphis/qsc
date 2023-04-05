/**

* @description        : ScheduleBatchClass for sending newsletter everyday for Idea creation
* @Last Modified By   : prakhar.jain@qsc.con
* @Last Modified On   : 22/02/2023
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    22/02/2023     prakhar.jain@qsc.com       Initial Version
**/
global class ScheduleBatchIdeaNewsletter implements Schedulable{
    global void execute(SchedulableContext sc) {
        BatchIdeaNewsletter b = new BatchIdeaNewsletter(); 
        database.executebatch(b, 10);
        
    }
}
//String cronExp = '00 30 20 * * ? *';
//system.schedule('ScheduleBatchIdeaNewsletterJob', cronExp, new ScheduleBatchIdeaNewsletter());