/*
*******************************************************************************************
# FILE...BtachForUpdateContactPhone
# CREATED BY...Chirag Rathi
# CREATED DATE.... 9/20/2022
# LAST MODIFIED BY......Chirag Rathi 
# LAST MODIFIED DATE....9/28/2022
# Test Class Name ....BtachForUpdateContactPhoneTest
*******************************************************************************************
# AUTHOR...Chirag Rathi
# DESCRIPTION...Batch class for update phone according to Mailing Country(us/u.s./USA/United States Of America) code(add +1).
# CHANGE/ BUG FIX LOG...................:
******************************************************************************************
*/

global class BtachForUpdateContactPhone implements Database.Batchable<sObject>{
    //Query to get the case details for the new attachments attached to case.
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        system.debug('>>>>>inside >>>   batch');
        string Query;
        return Database.getQueryLocator([SELECT Id, MailingCountry,Phone FROM Contact
                                         Where (MailingCountry='USA' OR MailingCountry='US' OR MailingCountry='U.S.' OR MailingCountry='United States' OR MailingCountry='United States of America')
                                         AND Phone !=null]); 
    }
    
    
    global void execute(Database.BatchableContext BC, List<Contact> conList){ 
        List<Contact> listContact = new List<Contact>();
        system.debug('batchList== '+conList);
        for(Contact contact:conList){
            //if(contact.MailingCountry =='USA' || contact.MailingCountry == 'United States' || contact.MailingCountry =='US'||contact.MailingCountry == 'United States of America'){
            //system.Assert(false,'test0');
            if(!contact.phone.contains('ex') && !contact.phone.contains('x') && !contact.phone.contains('ext')){
                if(!String.valueOf(contact.Phone).startsWith('+1') && !String.valueOf(contact.Phone).startsWith('1') && !String.valueOf(contact.Phone).startsWith('(1)')){
                    contact.Phone ='+1 '+ contact.Phone ;
                    listContact.add(contact);   
                    
                }else if((String.valueOf(contact.Phone).startsWith('1') || String.valueOf(contact.Phone).startsWith('(1)')) && !contact.phone.contains('+')){
                    contact.Phone ='+'+ contact.Phone ;
                    listContact.add(contact);
                }
                
                
            }
            
        }
        
        if(listContact.size()>0){
            system.debug('listContact  '+listContact);
            system.debug('listContact  '+listContact.size());
            update listContact;  
        }
        
    }
    
    
    global void finish(Database.BatchableContext BC){
        
        
    }
}