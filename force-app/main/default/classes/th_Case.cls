//==================================================================================================
//  Object: th_Case.cls
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: Case Trigger Handler Class
//==================================================================================================
//          Date            Purpose
// Changes: 07/16/2019      Initial Version
//==================================================================================================


public class th_Case  {
    
    //TH Variables
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public static Boolean isFirstTime = true;
    //Constructor
    public th_Case(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }   
    
    /**************************************************************************************************************
OnBeforeInsert
1. Check Cases submitted by email for OOO Bounce
**************************************************************************************************************/
    public void OnBeforeInsert(Case[] newCases, map<Id, Case> newMap){
        
        //Check Case Subjects to see if it bounces
        methods_Case.checkEmailBounce(newCases);
    }   
    
    
    /**************************************************************************************************************
OnAfterUpdate
NOT developed by Young Technology Group or Barney Young

Developed By ThinkAI corp
1.Check case if its closed and meets the required subject, reason, type and call webAPI Method
2.Check case if its closed and meets the required subject, reason and call AddRequestQueue Method developed on 23 July 2020
**************************************************************************************************************/
    public void OnAfterUpdate(Case[] oldCases, Case[] newCases, map<Id, Case> oldMap, map<Id, Case> newMap){
        if(th_Case.isFirstTime){
            th_Case.isFirstTime = false;
            // Variables
            Boolean updateAccount = false;
            Set<Id> caseIds = new Set<Id>(); 
            Set<Id> accountIds = new Set<Id> ();
            String caseTypeId;
            String caseSubject;
            String caseReason;
            String accountAttribute;
            String contactAttribute;
            String queueUrl;
            String functionKey;
            // Call method to get the NFR custom setting value
            NFR_API__c nfrApiSettingRecord =  getNFRAPISetting('Case Trigger');
            queueUrl = nfrApiSettingRecord.QueueURL__c;
            functionKey = nfrApiSettingRecord.x_function_key__c;
            
            // Commented below code
            /*
            //Populate collections
            List<NFR_API__c> nfrdetails=[select QueueURL__c,x_function_key__c from NFR_API__c];
            for(NFR_API__c url : nfrdetails)
            {
                queueUrl = url.QueueURL__c;
                functionKey = url.x_function_key__c;
            }
			*/
            List<filterCriteriaForCase__c> caseTypes = [Select Contact_Attribute__c,Record_type_Id__c,Record_type_name__c,Case_subject__c,Case_Reason__c,Account_Attribute__c from filterCriteriaForCase__c where Object_name__c='Case'];
            for(filterCriteriaForCase__c caseType : caseTypes)
            {
                if(caseType.Case_subject__c != null && caseType.Case_Reason__c != null){
                    caseTypeId = caseType.Record_type_Id__c;
                    caseSubject = caseType.Case_subject__c;
                    caseReason = caseType.Case_Reason__c;
                    accountAttribute = caseType.Account_Attribute__c;
                    contactAttribute = caseType.Contact_Attribute__c;
                }
            }
            
            //Cycle through New Cases
            for(Case newCase : newMap.values()){
                if(newCase.AccountId != null){
                    accountIds.add(newCase.AccountId);
                }
            }
            
            //Populate collections
            List<Account> accountList = [Select id,Attributes__c From account Where Id IN:accountIds];
            List<Contact> contactList = [Select accountId,Contact_Attributes__c,Email From contact Where accountId IN:accountIds AND Contact_Attributes__c =:contactAttribute];
            
            //Cycle through New Cases
            for(Case newCase : newMap.values())
            {
                
                //Old Case
                Case oldCase = oldMap.get(newCase.id);
                
                //Check case status, subject,reason
                if(!(oldCase.Status == newCase.Status) && newCase.Status == 'Close' && newcase.Subject == caseSubject && newcase.Reason == caseReason)
                { 
                    
                    //Check case type
                    if(newCase.Type == caseTypeId)
                    {
                        updateAccount = true;
                        caseIds.add(newCase.id);
                    }
                    
                    //Cycle through Accounts
                    for(Account acc : AccountList)
                    {
                        String adminEmail;                        
                        //Cycle through Accounts
                        for(Contact con : contactList)
                        {           
                            //Match contact Account and contact attribute
                            if(con.accountId == acc.Id && con.Contact_Attributes__c == contactAttribute)
                            {
                                
                                //Check if contact email is not blank
                                if(!String.isBlank(con.Email))
                                {
                                    adminEmail = con.Email;
                                }
                            }
                        }
                        
                        //Match account attribute and  account Id and email is not empty
                        if(acc.Attributes__c.contains(accountAttribute) &&  acc.Id == newcase.AccountId && !String.isBlank(adminEmail))
                        {
                            
                            //Calling add Request API 
                            //We need to call future method in for loop as the API endpoint takes single account ID per request
                            methods_Case.callAddRequestQueue(acc.Id,adminEmail,queueUrl,functionKey);
                        }
                    }
                }                
            }
            
            // Check if updateAccout and size of caseIds
            // This will be executed at any point when Account is getting updated
            // callWebApi will also get called when account attribute is "Reflect NFR Extension Approved" check at line 110 in methods_Case class
            if(updateAccount && caseIds.size() > 0){
                
                //Calling Web API
                methods_Case.callWebApi(caseIds,accountIds, JSON.serialize(nfrApiSettingRecord));
                //methods_Case.updateAccountAttribute(accountIds);
            }
        }
    }
    /**************************************************************************************************************
    getNFRAPISetting
    Method to fetch the NFP API custom setting record.  
    ---------------------------------------------------------------------------------------------------------------
    @param    instanceName   Record name of NFR API custom setting
    @return   NFR_API__c
    **************************************************************************************************************/
    public static NFR_API__c getNFRAPISetting(String instanceName) {
        // Variable Declarations
        NFR_API__c nfrApiSettingRecord = NFR_API__c.getInstance(instanceName);
        return nfrApiSettingRecord;
    }
}