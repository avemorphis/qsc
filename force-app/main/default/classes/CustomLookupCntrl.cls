public with sharing class CustomLookupCntrl {
    // Method to fetch lookup search result   
    public static List<string> assetStage = new List<string>{'Development','Released'};
    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName , string identifier, string parameter) {    
        List < sObject > returnList = new List < sObject > ();
        string sWildCardText = '%' + searchKey + '%';
        string sQuery = '';
        if(identifier == 'qsysPluginReqForm'){
            User u = [Select Id,AccountId,Account.Name FROM User WHERE ID =: UserInfo.getUserId() LIMIT 1];
            if(u!=null){
                Id accountId = u.AccountId;
                sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Name Like : sWildCardText and AccountId =: accountId order by lastmodifieddate DESC LIMIT 5';
            }
        }
        //Added the below  by Narasimha to resume the component for addmembers form.
        else if (identifier == 'AddMembersForm'){
            User u = [Select Id,AccountId,Account.Name FROM User WHERE ID =: UserInfo.getUserId() LIMIT 1];
            if(u!=null){
                Id accountId = u.AccountId;
                sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Name Like : sWildCardText AND AccountId =: accountId AND Status__c = \'Active\'  AND ID NOT IN (select ContactId from user where contactId !=null ) order by lastmodifieddate DESC LIMIT 5';
                system.debug(sQuery +'Squery123$');
            }
        }
        else if (identifier == 'cloneOpportunity'){
            sQuery = 'Select Id,Name,CurrencyIsoCode From ' + sObjectApiName + ' Where Account_Type__c =\'Partner\' and CurrencyIsoCode =:parameter and Name Like : sWildCardText LIMIT 10';
        }
        else if(identifier == 'tppAssetUpdate'){
            string userId = UserInfo.getUserId();
            sQuery = 'Select id,Name from '+ sObjectApiName + ' Where Asset_Stage__c IN :assetStage and AccountId IN (select accountId from User where Id =: userId) and Name Like :sWildCardText LIMIT 20';
            
        }
        else{
            sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Name Like : sWildCardText order by lastmodifieddate DESC LIMIT 5';
        }
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
    // Method to fetch lookup default value 
    @AuraEnabled
    public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
        string sRecId = recordId;    
        string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
        for (sObject obj: database.query(sQuery)) {
            return obj;
        }
        return null;
    }
}