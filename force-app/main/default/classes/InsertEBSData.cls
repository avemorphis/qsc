global class InsertEBSData {
/*
    global class AccountInsertResult {
        webservice Account[] accs;
        webservice boolean inserted;
        webservice boolean success;
        webservice String errorMessage;
    }

    webservice static AccountInsertResult insertAccountsInfo(Account[] acc) {
        AccountInsertResult a = new AccountInsertResult();
        Savepoint sp = Database.setSavepoint();

        try {
        
            if(acc == null) {
                a.inserted = false;
                a.success = false;
                a.errorMessage = 'No Account data is available as input parameter.';
                System.debug(a);
                return a;
            }

            List<Account> acnts = new List<Account>();
            
            for(Account acs: acc) {
                acnts.add(acs);
            }

            insert acnts;
            System.debug('********************************** Accounts inserted: '+ acnts);
            a.inserted = true;
            a.success = true;
            
        }
        Catch(exception e) {
            a.inserted = false;
            a.success = false;
            a.errorMessage = e.getMessage();
            System.debug(e.getMessage());
            Database.rollback(sp);
        }
    System.debug('************************************** AccountInsertResult a: '+ a);  
    return a;
    }
    */
}