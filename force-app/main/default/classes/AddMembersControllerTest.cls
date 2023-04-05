@isTest
public class AddMembersControllerTest {

    
     @testsetup
    public static void testsetupdata() {
        NFR_API__c apiCS=caseDataFactory.customApisSetting();
            apiCS.Name = 'Case Trigger';
            insert apiCS;
        Account ac = new Account(name ='testAccount') ;
            insert ac; 
            Contact con = new Contact(LastName ='testCon143',email = 'testCon143@testCon1432.com',AccountId = ac.Id);
            insert con; 
        
    }
    
      public static testMethod void getAssetsForAccount() {
       
          Contact con = [Select id from Contact where email != null LIMIT 1];
        AddMembersController.createUser(con.Id);
       
    }
}