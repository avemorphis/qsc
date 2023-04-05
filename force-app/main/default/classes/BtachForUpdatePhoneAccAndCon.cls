/*
*******************************************************************************************
# FILE...BtachForUpdateContactPhone
# CREATED BY...Chirag Rathi
# CREATED DATE.... 9/18/2022 
# LAST MODIFIED BY......Chirag Rathi 
# LAST MODIFIED DATE....9/28/2022
# Test Class Name ....BtachForUpdatePhoneAccAndConTest
*******************************************************************************************
# AUTHOR...Chirag Rathi
# DESCRIPTION...Batch class for update phone according to Mailing Country(us/u.s./USA/United States Of America) code(add +1).
# CHANGE/ BUG FIX LOG...................:
******************************************************************************************
*/

global class BtachForUpdatePhoneAccAndCon implements Database.Batchable<sObject>{
    //Query to get the case details for the new attachments attached to case.
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('>>>>>inside >>>   batch');
        string Query;
        //set<string> idset = new set<string>{'0017X00000v7x7SQAQ'};
        //,'0010y00001m54rTAAQ','0014X00002YIUfnQAH','001E000000U0tmrIAB','0010y00001n2KI3AAM'
        return Database.getQueryLocator([SELECT Id, BillingCountry,Phone FROM Account
                                         Where (BillingCountry ='USA' OR BillingCountry ='U.S.' OR BillingCountry='US' OR BillingCountry='United States' OR BillingCountry='United States of America')
                                         AND Phone !=null ]);         
    }
    
    
    global void execute(Database.BatchableContext BC, List<Account> accList){ 
        List<Account> listAccount = new List<Account>();
        string accPhone ;
        string extension;
        system.debug('batchList== '+accList);
        map <string,Account> phoneMap = new map<string,Account>();
        for(Account acc:accList){
     //if(acc.BillingCountry =='USA' || acc.BillingCountry == 'United States' || acc.BillingCountry =='US'){

            //system.Assert(false,'test0');
            if(!acc.phone.containsIgnoreCase('ex') && !acc.phone.containsIgnoreCase('x') && !acc.phone.containsIgnoreCase('ext')){
                if(!String.valueOf(acc.Phone).startsWith('+1') && !String.valueOf(acc.Phone).startsWith('1') && !String.valueOf(acc.Phone).startsWith('(1)')){
                    
                    acc.Phone ='+1 '+acc.Phone ;
                    listAccount.add(acc);   
                    
                }if((String.valueOf(acc.Phone).startsWith('1') || String.valueOf(acc.Phone).startsWith('(1)')) && !acc.phone.contains('+')){
                    acc.Phone ='+'+acc.Phone ;
                    listAccount.add(acc);
                } 
            }
            
        }
        
        if(listAccount.size()>0){
            system.debug('listAccount  '+listAccount);
            system.debug('listAccount  '+listAccount.size());
            update listAccount;  
        }
        
    }
    
    
    global void finish(Database.BatchableContext BC){
        
        
    }
}