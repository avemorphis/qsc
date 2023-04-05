//==================================================================================================
//  Object: Testmethods_StagingContact
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: Test class for Methods_Case
//==================================================================================================
//          Date            Purpose
// Changes: 07/26/2019      Initial Version
//==================================================================================================

@IsTest
public class Testmethods_StagingContact {
    @IsTest
    public static void TeststagingContactMethodsTest() {
        List<Staging_Contact__C> listsccontacts=new List<Staging_Contact__C>();        
        Staging_Contact__c sc1=new Staging_Contact__c();       
        //sc1.CurrencyIsoCode='USD';
		sc1.Company__c='Capital';
		sc1.Domain__c='Test';
        sc1.Customer_Number__c='12345';
        sc1.Email__c='testContact@gmail.com';
        sc1.Phone__c='7707707770';
        sc1.First_Name__c='TD-Test';
        sc1.Last_Name__c='class';
        sc1.Mailing_Address_1__c='235 st';
        sc1.Mailing_Address_2__c='Floar tide';
        sc1.Mailing_City__c='Atlanta';
        sc1.Mailing_Country__c='US';
        sc1.Mailing_Postal_Code__c='25002';        
        sc1.Mailing_US_State__c='USA';
        sc1.QSC_ID_Last_Access__c=Datetime.now();
        sc1.QSC_ID_Last_Login__c=Datetime.now();                
        sc1.QSCId__c='TS458';
        insert sc1;
      //  listsccontacts.add(sc1);
        
        
        Contact nC = new Contact();
              //  nC.RecordTypeId = contactRT; //QSCId Recordtype
                nC.Company__c = sc1.Company__c;
                nC.Email_Opt_In__c = sc1.Email_Opt_In__c;
                nC.FirstName = sc1.First_Name__c;
                nC.LastName = sc1.Last_Name__c;
                nC.Email = sc1.Email__c;
				nC.Group_Slugs__c = '';
                nC.MailingStreet = sc1.Mailing_Address_1__c + '\n' + sc1.Mailing_Address_2__c;
                nC.MailingCity = sc1.Mailing_City__c;
                nC.MailingState = sc1.Mailing_State__c;
                nC.MailingPostalCode = sc1.Mailing_Postal_Code__c;
                nC.MailingCountry = sc1.Mailing_Country__c;
                nC.Mailing_US_State__c = sc1.Mailing_US_State__c;
                nC.Phone = sc1.Phone__c;
                nC.QSC_ID_Last_Access__c = sc1.QSC_ID_Last_Access__c;
                nC.QSC_ID_Last_Login__c = sc1.QSC_ID_Last_Login__c;
                nC.Customer_Number__c = sc1.Customer_Number__c;  //Account Identifier
                nC.Domain__c = sc1.Domain__c;  //Account Identifier
                nC.QSCID__c = sc1.QSCId__c; //QSCID Identifier
                nC.Staging_Contact__c = sc1.Id;  
        		//insert nc;
                 
        List<Contact> listcons=new List<Contact>();      
        listcons.add(nc);
        Test.startTest();        
        listcons=methods_StagingContact.createContactsFromStaging(listsccontacts);
        methods_StagingContact.upsertContacts(listcons);
      //  methods_StagingContact.checkDuplicateContacts(listcons);
        methods_StagingContact.insertContacts(listcons);
        Test.stopTest();
    }
}