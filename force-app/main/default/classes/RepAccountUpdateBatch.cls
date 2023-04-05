/*****************************************************************
*   Author  :QSC
*   Date    :18/01/2021
*   Purpose :Batch class for updating Rep Account field in Account object with the respective Rep Account.
******************************************************************/
global class RepAccountUpdateBatch implements Database.Batchable<sObject>{
    
    String query = 'Select Id,Rep_Firm_Oracle_Number__c from Account where Rep_Code_Changed__c = true';
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        List<String> repCodes = new List<String>();
        for(Account acc :scope){
            repCodes.add(acc.Rep_Firm_Oracle_Number__c);
        }
        
        Map<Id,Account> accountMap = new Map<Id,Account>([Select Id,Customer_Number__c from Account where Customer_Number__c IN:repCodes ]);
        Map<String,String> repFirmAccountIdMap = new Map<String,String>();
        
        for(Account acc :accountMap.values()){
            repFirmAccountIdMap.put(acc.Customer_Number__c,acc.Id);
        }
        
        List<Account> updateAccounts = new List<Account>();
        for(Account acc :scope){
            acc.Rep_Account__c = repFirmAccountIdMap.get(acc.Rep_Firm_Oracle_Number__c);
            updateAccounts.add(acc);
        }
        
        update updateAccounts;
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
}