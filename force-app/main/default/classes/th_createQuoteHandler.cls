/**

* @description        : createQuoteHandler class for creating Quote trigger when API call is completed
* @Author             : prakhar.jain@qsc.com
* @Last Modified By   : prakhar.jain@qsc.con
* @Last Modified On   : 21/12/2022
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    21/12/2022     prakhar.jain@qsc.com       Initial Version
**/

public class th_createQuoteHandler 
{
    //To avoid recurssion
    Public static Boolean flag= true;	
    
    //Calling AfterUpdate
    Public static void afterUpdate(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppList)
    {
        
        If(flag){
            flag=false;
            //Call insertQuote Method of opportunityHelper class
            createQuoteHelper.insertQuote(newOppList, oldOppList);   
        }
        
    }
}