@isTest
public class TandC_ControllerClsTest{
    public static UserRole r = [select id from UserRole where developername ='CEO'];
    @testsetup
    public static void testsetupdata() {
        Id ap = [select id from profile where name='System Administrator'].id;
        User auser = new User(alias = 'test1234', email='test1234@noemail.com',UserRoleId= r.Id,
                emailencodingkey='UTF-8', lastname='Testing4', languagelocalekey='en_US',
                localesidkey='en_US', profileid = ap, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='testerGenius@testCon1434.com');
         insert auser;
         system.runAs(auser) {
             Account ac = new Account(name ='testAccount') ;
             insert ac; 
             Contact con = new Contact(LastName ='testCon143',email = 'testCon143@testCon143.com',AccountId = ac.Id);
             insert con;  
             Terms_And_Conditions__c tandc = new Terms_And_Conditions__c(Order__c=1,Terms_Data__c='CPP',Community_ID__c='0DB4X000000k9yJWAQ');
             insert tandc;
             
             Id p = [select id from profile where name='CPP Community User'].id;
             User usr = new User(alias = 'test123', email='test123@noemail.com',
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    contactid = con.id,
                    timezonesidkey='America/Los_Angeles', username='testerTejabrilliant@testCon143.quiz');
             insert usr;
         }
    }
    public static testMethod void validateUser() {
         //contact c = [select id from contact limit 1];
        User u = [select id from user where email='test123@noemail.com'];
        test.startTest();
           system.runAs(u) {
                
               TandC_ControllerCls.validateUser();
               TandC_ControllerCls.updateUser();
           }
        test.stopTest();
    }
    
}