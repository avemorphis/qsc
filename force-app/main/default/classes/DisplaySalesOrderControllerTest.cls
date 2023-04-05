@isTest
private class DisplaySalesOrderControllerTest {
    
    @isTest
    private static void testGetSiteUserAccountId() {
        Account acc = new Account(Name='Test');
        insert acc;
        
        Contact con = new Contact(LastName ='testCon',AccountId = acc.Id, Phone = '9999999999', Email='tester@testGetSiteUserAccountId.com');
        insert con;

        Id profileId = [SELECT Id FROM Profile WHERE Name ='CPP Community User'].Id;

        User user = new User(alias = 'test123', 
                            email = 'test123@testGetSiteUserAccountId.com',
                            emailencodingkey = 'UTF-8', 
                            lastname = 'Testing', 
                            languagelocalekey = 'en_US',
                            localesidkey = 'en_US', 
                            profileid = profileId, 
                            country = 'United States',
                            IsActive =true,
                            ContactId = con.Id,
                            timezonesidkey='America/Los_Angeles', 
                            username='tester@testGetSiteUserAccountId.com');
       
        insert user;

        DisplaySalesOrderController.AccountWrapper positiveResult = DisplaySalesOrderController.getSiteUserAccountId(user.Id);
        DisplaySalesOrderController.AccountWrapper negetiveResult = DisplaySalesOrderController.getSiteUserAccountId(null);

        System.assertEquals(null, negetiveResult.accountId, 'System admin should not return Account Id');
        System.assertEquals(true, negetiveResult.isParent, 'System admin should not return Account Id');

        System.assertEquals(acc.Id, positiveResult.accountId, 'System does not return account Id');
    }
}