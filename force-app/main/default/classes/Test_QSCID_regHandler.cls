//========================================================================
//  Object: Test_QSCID_regHandler
// Company: Young Technology Group
//  Author: Barney Young Jr
// Comment: Class to test the main class QSCID_regHandler
//========================================================================
//          Date            Purpose
// Changes: 4/29/2020       Initial Version
//========================================================================
@isTest
private class Test_QSCID_regHandler {
    
    /******************************************************************************************************************************************************
    setup
    Method to create base records for the test methods
    -------------------------------------------------------------------------------------------------------------------------------------------------------
    ******************************************************************************************************************************************************/
    @testSetup static void setup() {

        //We need an account
        Account newAccount =new Account();
        newAccount.Name = System.label.Default_Account;
        insert newAccount;

        //A contact
        Contact newContact = new Contact();
        newContact.LastName = 'testlastname';
        newContact.FirstName = 'testFirstName';
        newContact.Email = 'usertqsx_id_reghandler@testorgqscid.com';
        insert newContact;

        //A a new user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='usertqsx_id_reghandler@testorgqscid.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='usertqsx_id_reghandler@testorgqscid.com');
        insert u;
    }
    
    /******************************************************************************************************************************************************
    testInitiateMethod
    Method to test the QSC_ID_OAuth_Class.initiate method
    -------------------------------------------------------------------------------------------------------------------------------------------------------
    ******************************************************************************************************************************************************/
    static testMethod void testContactUserHandling() { 

        //Lets create an instance of the class that we want to test.
        QSCID_regHandler handlerQSCID = new QSCID_regHandler();
        
        //Lets create a fake map for the UserData
        Map<String,String> provMap = new Map<String,String>(); 
        provMap.put('key1', 'value1'); 
        provMap.put('key2', 'value2');

        //starting the test
        test.startTest();

            //Lest create a fake UserData with null required values
            Auth.UserData expectedUserData = new Auth.UserData('LOGIN-ID', 'FIRST-NAME', null, 'FULL-NAME', null, null, 'email@email.com', null, 'PROVIDER', null, provMap);       
          
            //ASSERT , We expect a null value, because the data was invalid
            system.assertEquals(NULL, handlerQSCID.createUser(userinfo.getUserId(),expectedUserData));
        
            //Lets try with a new valid Contact/User
            expectedUserData = new Auth.UserData('LOGIN-ID', 'FIRST-NAME', 'LAST-NAME', 'FULL-NAME', 'email@email.com', null, 'email@email.com', null, 'PROVIDER', null, provMap); 

            //Now we send the method to create a valid user
            User testUser = handlerQSCID.createUser(userinfo.getUserId(),expectedUserData);

            //We validate with the expectedUserData
            system.assertEquals(expectedUserData.FirstName, testUser.FirstName);
            system.assertEquals(expectedUserData.LastName, testUser.LastName);
            system.assertEquals(expectedUserData.Email, testUser.Email);

            //We run this method again to try to create the same user again
            testUser = handlerQSCID.createUser(userinfo.getUserId(),expectedUserData);

            //We validate with the expectedUserData
            system.assertEquals(expectedUserData.FirstName, testUser.FirstName);
            system.assertEquals(expectedUserData.LastName, testUser.LastName);
            system.assertEquals(expectedUserData.Email, testUser.Email);
        
            //Lets try the user update method
            User userToUpdate = [Select id from User where email = 'usertqsx_id_reghandler@testorgqscid.com'];
            handlerQSCID.updateUser(userToUpdate.Id, userinfo.getUserId(), expectedUserData);

            //We validate with the expectedUserData, so we can validate the new name and email
            userToUpdate = [Select id, FirstName, LastName, Email from User where username = 'usertqsx_id_reghandler@testorgqscid.com'];
            system.assertEquals(expectedUserData.FirstName, userToUpdate.FirstName);
            system.assertEquals(expectedUserData.LastName, userToUpdate.LastName);
            system.assertEquals(expectedUserData.Email, userToUpdate.Email);
        
        //stoping the test
        test.stopTest();
    }
}