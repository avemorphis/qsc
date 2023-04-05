/**************************************************************************************************************
* @File Name          : Th_ContentDocumentLinkTrigger.cls
* @description        : This class is calling from ContentDocumentLinkTrigger.
* @Author             : naman.gupta@qsc.com
* @Group              : 
* @Last Modified By   : naman.gupta@qsc.com
* @Last Modified On   : 04/01/2023
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    04/01/2023   	naman.gupta
**************************************************************************************************************/
public class Th_ContentDocumentLinkTrigger 
{
    
    /**************************************************************************************************************
* @Method Name        : onAfterInsert
* @description        : This method is called from ContentDocumentLinkTrigger and in this method we update the DPP_Agreement_Signed_Date__c field value on the related account record when the document is uploading.
* @Last Modified By   : naman.gupta@qsc.com
* @Last Modified On   : 04/01/2023
**************************************************************************************************************/
	public static void onAfterInsert(List<ContentDocumentLink> listContentDocumentLinks)
    {
        //Checking the listContentDocumentLinks is not empty.
        If(!listContentDocumentLinks.isEmpty())
        {
            Set<Id> setAccountIds = new Set<Id>();
            
            //Iterating the ContentDocumentLink list of records.
            For(ContentDocumentLink objContentDocumentLink : listContentDocumentLinks)
            {
                If(String.isNotEmpty(objContentDocumentLink.LinkedEntityId))
                {
                    setAccountIds.add(objContentDocumentLink.LinkedEntityId);
                }
            }
            
            //Checking the setAccountIds is not empty.
            If(!setAccountIds.isEmpty())
            {
                //Getting account records using setAccountIds.
                List<Account> listAccounts = [SELECT Id, DPP_Agreement_Signed_Date__c, DPP_Agreement_Status__c 
                                              FROM Account
                                              WHERE Id IN : setAccountIds
                                             ];
                
                //Checking the listAccounts is not empty.
                If(!listAccounts.isEmpty())
                {
                    //Iterating the Account list of records.
                    For(Account objAccount : listAccounts)
                    {
                        objAccount.DPP_Agreement_Signed_Date__c = Date.today();
                        objAccount.DPP_Agreement_Status__c = 'Active';
                    }
                    
                    UPDATE listAccounts;
                }
            }
        }
    }
}