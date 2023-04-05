@isTest
public class BatchCertificatesOnAccountTest {
	@isTest
    public static void createAccount(){
        Account acc                                     = new Account();
        acc.Name                                        = 'Test Acc';
        acc.Account_Type__c                             = 'Partner';
        acc.Customer_Class__c                           = 'MULTI CHANNEL';
        acc.Partner_Category__c                         = 'DISTRIBUTOR';
        acc.Region_Oracle__c                            = 'EMEA';
        acc.Copy_Billing_Address_to_Shipping_Address__c = true;
        insert acc;
        
        Contact con                     = new Contact();
        con.AccountId                   = acc.Id;
        con.Active_Lookup__c            = acc.Id;
        con.FirstName                   = 'Test';
        con.LastName                    = 'Con';
        con.Status__c                   = 'Inactive';
        con.Communication_Attributes__c = 'Partnership Program Manager;Corporate';
        con.Email                       = 'testforCampMembers@campMembers.com';
        Insert con;
        
        Course__c c  = new Course__c();
        c.Contact__c = con.Id;
        c.Name       = 'Test Course for Batch';
        Insert c;
        
        List<Certificate__c> certificateList = New List<Certificate__c>();
        Certificate__c cr     = new Certificate__c();
        cr.course_sfdc_id__c  = c.Id;
        cr.Name               = 'Test Certification';
        cr.certified__c       = 'yes';
        certificateList.add(cr);
        insert certificateList;
        System.assert(true,certificateList != null);
        
        test.startTest();
        BatchCertificatesOnAccount bc = new BatchCertificatesOnAccount();
        database.executeBatch(bc);
        test.stopTest();
    }
}