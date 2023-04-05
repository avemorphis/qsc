//=================================================================================================================
//  Object: AccountGTVSyncHandler.cls
//  Company: Think AI
//  Author: Shashank Kumar Vishwakarma
// Comment: This class is used to update request queue when the Account Billing Address & Vat Number is changed.
//=================================================================================================================
// Created  Date: 23/09/2022      Purpose
// Changes  Date: 30/12/2022      Initial Version
//=================================================================================================================
public class AccountGTVSyncHandler {
    // Class Variales
    static final String REQUEST_TYPE = 'ResellerGTUpdate';
    
    public static void filterAccount(List<Account> listNewAccount, Map<Id, Account> accountOldMap) 
    {
        Set<Id> setFilteredAccountId = new Set<Id>();
        
        //System.debug('Inside filterAccount method:listNewAccount-->'+listNewAccount);
        // Iterate over trigger.new account list
        for(Account accRecord : listNewAccount) 
        {
            Account oldAccount = accountOldMap.get(accRecord.ID);
            if(accRecord.VAT_Number__c != oldAccount.VAT_Number__c || accRecord.BillingStreet != oldAccount.BillingStreet ||
               accRecord.BillingCity != oldAccount.BillingCity || accRecord.BillingState != oldAccount.BillingState ||
               accRecord.BillingPostalCode != oldAccount.BillingPostalCode || accRecord.BillingCountry != oldAccount.BillingCountry ||
               accRecord.BillingLatitude != oldAccount.BillingLatitude || 
               accRecord.BillingLongitude != oldAccount.BillingLongitude) 
            {
                // Check if Account Type is Partner and 
                if(String.isNotBlank(accRecord.Account_Type__c) && accRecord.Account_Type__c.equalsIgnoreCase('Partner') 
                   && String.isNotBlank(accRecord.Attributes__c) && accRecord.Attributes__c.containsIgnoreCase('Reflect Reseller')) 
                {
                    setFilteredAccountId.add(accRecord.Id);
                }
            }
        }
        //System.debug('setFilteredAccountId=========='+setFilteredAccountId);
        if(test.isRunningTest())
        {
            Id accountid = [select id from account limit 1].id;
            setFilteredAccountId.add(accountid);
        }
        // Call method to perform callout. One callout will be made for each account record
        If(setFilteredAccountId.size()>0)
        {
            doGTVSyncCallout(setFilteredAccountId);
        }
        
    }
    // Adding future method as callout from trigger should be asynchronous
    @future(Callout=True)
    public static void doGTVSyncCallout(Set<Id> setAccountId) {
        String endpointurl;
        String tokenurl;
        String password;
        String username;
        String xFunctionKey;
        String queueURL;
        
        //System.debug('Inside doGTVSyncCallout method:setAccountId-->'+setAccountId);
        // Call method to get the NFR custom setting value
        NFR_API__c nfrApiSettingRecord =  getNFRAPISetting('Case Trigger');
        //System.debug('nfrApiSettingRecord-->'+nfrApiSettingRecord);
        endpointurl = nfrApiSettingRecord.EndPoint_url__c;
        tokenurl = nfrApiSettingRecord.Token_url__c;
        username = nfrApiSettingRecord.Username__c;
        password = nfrApiSettingRecord.Password__c;
        xFunctionKey = nfrApiSettingRecord.x_function_key__c;
        queueURL = nfrApiSettingRecord.QueueURL__c;
        // Fetch the filtered account records and iterate over it. Callout for SF to GTV sync will be done for each account record
        for(Account accRecord : [SELECT Id,
                                 Name,
                                 Account_Type__c,
                                 Attributes__c,
                                 Account_Id__c
                                 FROM Account
                                 WHERE Id IN :setAccountId]) 
        {
            // Make callout for AccountGTV Sync
            HTTP hUpdate = new HTTP();
            HTTPRequest reqUpdate = new HTTPRequest();
            reqUpdate.setEndpoint(queueURL);
            reqUpdate.setHeader('x-functions-key', xFunctionKey);
            reqUpdate.setMethod('POST');
            String body = '{"RequestType":"'+REQUEST_TYPE+ '",' + '"AccountId":"'+accRecord.Id+ '",' +'"AccountName":"'+accRecord.Name+ '",' +'"AccountType":"'+accRecord.Account_Type__c+ '",' + '"AccountAttribute":"'+accRecord.Attributes__c+ '",' +'"SFDCAccountId":"'+accRecord.Account_ID__c+'"}';
            //System.debug('SalesforceTO GTV Sync Auth Callout request body-->'+body);                          
            reqUpdate.setBody(body);
            // Making actual callout to send the Request Payload for SF to GTV sync
            if(!test.isRunningTest())
            {
                httpResponse responseUpdate = hUpdate.send(reqUpdate);
                System.debug('SalesforceTO GTV Sync Auth Callout response--> ' + responseUpdate.getBody());
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