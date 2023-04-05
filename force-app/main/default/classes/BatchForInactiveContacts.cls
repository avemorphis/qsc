global class BatchForInactiveContacts implements Database.Batchable<sObject>{
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id,Name,Status__c,LastName FROM Contact WHERE Status__c = 'Inactive']);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> conList){
        system.debug('conList'+conList);
        system.debug('conList'+conList.size());
        List<Contact> updateContactList = new List<Contact>();
        for(Contact con : conList){
            if(!con.LastName .contains('Inactive')){
                con.LastName = con.LastName +' Inactive';
                updateContactList.add(con);
                system.debug('updateContactList'+updateContactList);
            }  
        }
        
        system.debug('updateContactList'+updateContactList.size());
        if(updateContactList.size() > 0){
            Update updateContactList;
            system.debug('updateContactList'+updateContactList);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}