@isTest
public class TPPAccountCompanyLogoFormCntl_Test {
    @isTest
    public static void getAccountDetails(){
        
        TPPAccountCompanyLogoFormCntl.getAccountDetails();
    }
    @isTest
    public static void updateCompanyDescription(){
        NFR_API__c apiCS=caseDataFactory.customApisSetting();
        apiCS.Name = 'Case Trigger';
        insert apiCS;
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.Account_Type__c = 'Partner';
        acc.Customer_Class__c = 'MULTI CHANNEL';
        acc.Partner_Category__c = 'DISTRIBUTOR';
        acc.Region_Oracle__c = 'EMEA';
        acc.Copy_Billing_Address_to_Shipping_Address__c = true;
        insert acc;
        test.startTest();
        TPPAccountCompanyLogoFormCntl.updateCompanyDescription(acc.id,'test','test','test');
        test.stopTest();
        
    }
}