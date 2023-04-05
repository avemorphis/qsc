@isTest
public class DisplayAllianceAttrContactsContrTest{
    @testsetup
    public static void testsetupdata() {
            NFR_API__c apiCS=caseDataFactory.customApisSetting();
            apiCS.Name = 'Case Trigger';
            insert apiCS;
            Account ac = new Account(name ='testAccount') ;
            insert ac; 
            Contact con = new Contact(LastName ='testCon143',email = 'testCon143@testCon1432.com',AccountId = ac.Id,Alliance_Attributes__c ='TPP Primary Contact;TPP Technical Contact;TPP Marketing Contact;TPP Billing Contact;TPP Admin Contact;TPP Legal Contact');
            insert con;
    }
    public static testMethod void getAllianceAttrContactData(){
        Account acc = [select id from Account limit 1];
        test.startTest();
        DisplayAllianceAttrContactsController.getAllianceAttrContactData(acc.Id);
        test.stoptest();
        
    }
}