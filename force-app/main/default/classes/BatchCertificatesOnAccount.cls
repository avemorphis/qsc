/*
*******************************************************************************************
# FILE...BatchCertificatesOnAccount
# VERSION...............................:
# CREATED BY...Chirag
# CREATED DATE....29th April 2022
# LAST MODIFIED BY......................:
# LAST MODIFIED DATE....................:
*******************************************************************************************
# AUTHOR...Chirag
# DESCRIPTION...Batch class for updating certificate records that can be shown at Account related list if the certificate is completed
# CHANGE/ BUG FIX LOG...................:
******************************************************************************************
*/

global class BatchCertificatesOnAccount implements database.batchable<sObject> {
    string yes ='yes';
    public database.QueryLocator start (Database.BatchableContext BC){
        string query ='select id,certified__c,Accounts__c,contact_sfdc_id__c,contact_sfdc_id__r.AccountId from Certificate__c where certified__c = \'yes\'' +' AND accounts__c = null';
        system.debug('>>>>query>>'+query);
        return database.getQueryLocator (query);
    }
    global void execute (Database.BatchableContext BC, list<certificate__c> scope){
        list<certificate__c> listtoUpdate = new list<certificate__c>();
        for (certificate__c objScope: scope) {
            // Added by  Chirag Null point check
            if(objScope.contact_sfdc_id__r.accountid != null){
                System.debug('Rocket==>' +objScope.contact_sfdc_id__r.accountid);
                objScope.Accounts__c = objScope.contact_sfdc_id__r.AccountId;
            }
            listtoUpdate.add(objScope);
        }
        if(listtoUpdate.size()>0){
            system.debug('listtoUpdate=>' +listtoUpdate.size());   
            update listtoUpdate;
        }
    }
    public void finish(database.BatchableContext bc){
        
    }
    
}