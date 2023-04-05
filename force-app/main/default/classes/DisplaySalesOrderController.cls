public with sharing class DisplaySalesOrderController {
    
    @AuraEnabled
    public static AccountWrapper getSiteUserAccountId(String userId) {
        String userSfdcId = (userId <> null) ? userId : UserInfo.getUserId();
        User currentUser = [SELECT ContactId, Contact.AccountId, Contact.Account.ParentId FROM User WHERE Id = :userSfdcId WITH SECURITY_ENFORCED];
        if(currentUser.ContactId != NULL && currentUser.Contact.AccountId != NULL) {
            DisplaySalesOrderController.AccountWrapper wrapper = new DisplaySalesOrderController.AccountWrapper();
            wrapper.accountId = currentUser.Contact.AccountId;
            wrapper.isparent = (currentUser.ContactId <> NULL && 
                                currentUser.Contact.AccountId <> NULL &&  
                                currentUser.Contact.Account.ParentId <> NULL) ? false : true;
            return wrapper; 
        }
        else {
            return new DisplaySalesOrderController.AccountWrapper();
        }
    }

    public class AccountWrapper {
        @AuraEnabled public String accountId{get;set;}
        @AuraEnabled public Boolean isParent{get;set;}

        public accountWrapper() {
            this.accountId = null;
            this.isParent = true;
        }
    }
}