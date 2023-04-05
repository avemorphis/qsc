//==================================================================================================
//  Object: Testmethods_Case
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: Test class for Methods_Case
//==================================================================================================
//          Date            Purpose
// Changes: 07/26/2019      Initial Version
//==================================================================================================
@IsTest
public class Testmethods_Case {
    
    
    @IsTest
    public static void TestCaseMethodsTest() {
		//Build Account
        Account a = new Account();
        a.Name = 'Account';
        Insert a;
        //TestData for  If Subject is NotBlank
        Case cases = New Case();
        cases.Status ='Open';
        cases.Origin ='Email';
        cases.Subject='Please enter a subject for this case.';
        cases.Type='Product Issue';
        cases.AccountId = a.Id;
        
        // Create Custom Setting record
        NFR_API__c nfrSettingRecord = new NFR_API__c();
        nfrSettingRecord.Name = 'Case Trigger';
        nfrSettingRecord.EndPoint_url__c = 'https://web-apid01.qsc.com/api/Reflect/ExtendNFRDemoRequest';
        nfrSettingRecord.Password__c = 'test';
        nfrSettingRecord.QueueURL__c = '';
        nfrSettingRecord.Token_url__c = 'https://web-apid01.qsc.com/token';
        nfrSettingRecord.Username__c = 'test';
        insert nfrSettingRecord;
        
        try {
            cases.Subject='';
            Insert cases;
        }catch(Exception e){
            System.assert(e.getMessage().contains('Please enter a subject for this case.'));
            
        }
        //Test Data for  If Subject Contains 'OOO'
        Case casesSub = New Case();
        casesSub.Status ='Open';
        casesSub.Origin ='Email';
        casesSub.Subject='OOO';
        casesSub.Description='Not Saving Email2Case: OOO';
        casesSub.AccountId = a.Id;
        try {
            casesSub.Subject='OOO';
            casesSub.Description='Not Saving Email2Case: OOO';
            Insert casesSub;
        }catch(Exception e){
            System.assert(e.getMessage().contains('Not Saving Email2Case: OOO:'));
        }
        
        //Test Data for  If Subject Contains the words 'Out' and 'Office'
        Case casesOutOffice = New Case();
        casesOutOffice.Status ='Open';
        casesOutOffice.Origin ='Email';
        casesOutOffice.Subject='Out && Office';
        casesOutOffice.Description='Not Saving Email2Case: Out of Office';
        casesOutOffice.AccountId = a.Id;
        try {
            casesOutOffice.Subject='Out && Office';
            casesOutOffice.Description='Not Saving Email2Case: Out of Office';
            Insert casesOutOffice;
        }catch(Exception e){
            System.debug('e.getMessage()======='+e.getMessage());
            System.assert(e.getMessage().contains('Not Saving Email2Case: OOO:'));
        }
        
        List<case> cs=new List<case>();
        Test.startTest();
        // calling the Class and Method
        methods_Case.checkEmailBounce(cs);
        Test.stopTest();
    }
}