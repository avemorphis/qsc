global class AccountRevenueSwitcherBatch implements database.Batchable<sObject>{
    public database.QueryLocator start(Database.BatchableContext bc){
        return database.getQueryLocator('select id, FY_20__c, FY_21__c, Previous_2_FY__c, Previous_FY__c from account where FY_20__c != null or FY_21__c != null');
    }
    public void execute(Database.BatchableContext bc, List<account> acList){
        List<Account> listToUpdate = new List<account>();
        for(Account ac: acList){
            System.debug('{ID: '+ac.id+',FY20: ' + ac.FY_20__c+', FY21: '+ac.FY_21__c+ '}');
            System.debug('{OldID: '+ac.id+',Previous_2_FY__c: '+ ac.Previous_2_FY__c+', Previous_FY__c: '+ ac.Previous_FY__c+'}');
            ac.Previous_2_FY__c = ac.FY_20__c;
            ac.Previous_FY__c = ac.FY_21__c;
            System.debug('{ID: '+ac.id+',Previous_2_FY__c: '+ ac.Previous_2_FY__c+', Previous_FY__c: '+ ac.Previous_FY__c+'}');
            listToUpdate.add(ac);
        }
        update listToUpdate;
    }
    public void finish(database.BatchableContext bc){
        
    }
}