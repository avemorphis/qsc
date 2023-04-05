//==================================================================================================
//  Object: th_Account.cls
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: Account Trigger Handler Class
//==================================================================================================
//          Date            Purpose
// Changes: 06/14/2018      Initial Version
//			09/05/2019		Functionality to send Docusign Referral Onboarding Docusign Document
//==================================================================================================

public class th_Account {
    
    //TH Variables
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    //Constructor
    public th_Account(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    
    /**************************************************************************************************************
OnAfterInsert
Booleans:
updateContactSync - If new Account is created by Contact Sync

Methods:
updateContactAccount:  Populates Contact Account Value
**************************************************************************************************************/
    public void OnAfterInsert(Account[] newAccounts, map<Id, Account> newMap){
        
        //Booleans
        Boolean updateContactSync = false;  //Contact Sync Account
        
        //Contact Sync Update Set
        List<Account> csAccountIds = new List<Account>();                   
        
        for(Account at : newAccounts){
            
            //Check if it is a ContactSync
            if(at.Account_Category__c == 'Individual'  || at.Account_Category__c == 'Company') {
                
                //Update Boolean
                updateContactSync = true;
                
                //Populate Group Slug
                csAccountIds.add(at);
            }
        } 
        
        //Process Boolean -  Update Contact Records
        if(updateContactSync){			
            methods_Account.updateContactAccount(csAccountIds);
        }
    }
    
    
    /**************************************************************************************************************
OnAfterUpdate
Booleans:
sendRefOBDoc - Send Docusign Referral Onboarding Document

Methods:
sendReferralOnboardingDoc:  Sends Docusign Referral Onboarding Document
**************************************************************************************************************/
    public void OnAfterUpdate(Account[] oldAccounts, Account[] newAccounts, map<Id, Account> oldMap, map<Id, Account> newMap){
        
        
        //Booleans
        Boolean sendAgreement = false;  //Send legal agreement
        
        //Variables
        String type = ''; // Type of legal agreement
        String billingCountry = '';
        
        Set<Id> actRRP = new Set<Id>();              
        
        for(Account act : newMap.values()){
            
            //Old Account
            Account oldAccount = oldMap.get(act.id);
            
            //Account Legal agreement value updated       
            if(!(oldAccount.Legal_Agreements__c == act.Legal_Agreements__c) && act.Legal_Agreements__c != null){
                
                //Update Boolean
                sendAgreement = true;
                
                //Populate Update Sets
                actRRP.add(act.Id); 
                billingCountry = act.BillingCountry; // Account billing country
                type = act.Legal_Agreements__c; // Type of legal agreement                
            }
        }    
        if(sendAgreement){
            methods_Account.sendOnboardingDocument(actRRP,billingCountry,type);
        }
    }
    
    /**************************************************************************************************************

* @File Name          : th_Account.cls
* @description        : After update the account category field value, we assign and remove the permission set to
						the active contacts.
* @Author             : naman.gupta@qsc.com
* @Group              : 
* @Last Modified By   : naman.gupta@qsc.com
* @Last Modified On   : 19/12/2022
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    19/12/2022   	naman.gupta
**************************************************************************************************************/
    
    public static void OnAfterUpdateAssignAndRemovePermissionSetToDPPUser(Map<Id, Account> mapOldAccounts, List<Account> listNewAccounts)
    {
        //Check list is not empty.
        If(!listNewAccounts.isEmpty())
        {
            Set<Id> setDeveloperPartnerAccountIds = new Set<Id>();
            Set<Id> setDeveloperPartnerParentAccountIds = new Set<Id>();
            Set<Id> setAccountIds = new Set<Id>();
            
            //Iterate list of account records.
            For(Account objAccount : listNewAccounts)
            {
                //Check Account_Category__c is not null and not match with previous record and Account_Category__c is Developer Partner.
                If(String.isNotEmpty(objAccount.Account_Category__c) && mapOldAccounts.get(objAccount.Id).Account_Category__c != objAccount.Account_Category__c && objAccount.Account_Category__c == 'Developer Partner' && objAccount.Account_Type__c == 'Alliance')
                {
                    setDeveloperPartnerAccountIds.add(objAccount.Id);
                }
                Else If(String.isNotEmpty(objAccount.Account_Category__c) && mapOldAccounts.get(objAccount.Id).Account_Category__c != objAccount.Account_Category__c && objAccount.Account_Category__c != 'Developer Partner')
                {
                    setAccountIds.add(objAccount.Id);
                }
                
                //Check ParentId is not null
                If(String.isNotEmpty(objAccount.ParentId))
                {
                    setDeveloperPartnerParentAccountIds.add(objAccount.ParentId);
                }
            }
            
            //Check setDeveloperPartnerAccountIds is not empty.
            If(!setDeveloperPartnerAccountIds.isEmpty())
            {
                //Call the DPPPermissionSet class feature assignPermissionSetToUser methode.
                DPPPermissionSet.assignPermissionSetToUser(setDeveloperPartnerAccountIds, setDeveloperPartnerParentAccountIds);
            }
            
            //Check setAccountIds is not empty.
            If(!setAccountIds.isEmpty())
            {
                //Call the DPPPermissionSet class feature removePermissionSetToUser methode.
                DPPPermissionSet.removePermissionSetToUser(setAccountIds, setDeveloperPartnerParentAccountIds);
            }
        }
    }
}