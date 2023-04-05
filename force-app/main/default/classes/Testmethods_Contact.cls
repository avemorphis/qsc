//==================================================================================================
//  Object: Testmethods_Contact
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: Test class for Methods_Case
//==================================================================================================
//          Date            Purpose
// Changes: 07/26/2019      Initial Version
//==================================================================================================

@IsTest
public class Testmethods_Contact {
    
    @IsTest
    public static void TestinsertDeletePSAsTest() {
        
    /****************************TestData for insertDeletePSAs Method *************************************/
        NFR_API__c apiCS=caseDataFactory.customApisSetting();
        apiCS.Name = 'Case Trigger';
        insert apiCS;
        //Set<Id> contactIds=new set<id>();
        Set<Id>userIds=new set<Id>();

        List<account> accList = new List<account>();
        Account AccNum=new Account();
        AccNum.Name='DupAccName1';
        AccNum.Customer_Number__c='1234561';
        AccNum.Domain_s__c='testdomain11';
        accList.add(AccNum); 
        Account DupAccNum=new Account();
        DupAccNum.Name='DupAccName';
        DupAccNum.Customer_Number__c='123456';
        DupAccNum.Domain_s__c='testdomain1';
        accList.add(DupAccNum);
        Account DupAccDomain=new Account();
        DupAccDomain.Name='DupAccName2';
        DupAccDomain.Domain_s__c='testdomain123112.com';
        accList.add(DupAccDomain);
        insert accList;
        
        List<contact>  cList = new List<contact>();
        //Test data for Cinema
        Contact cUp=new Contact();
        cUp.FirstName ='TD-Test';
        cUp.LastName = 'tdfthgf';
        cUp.Phone = '7707707770';
        cUp.Email = 'testContact@gmail.com';       
        // cUp.Group_Slugs__c = 'cinema-community';
        cList.add(cUp);
        
        //Test data for QSYS Dev
        Contact cUp1=new Contact();
        cUp1.FirstName ='TD-jjTest';
        cUp1.LastName ='Class';
        cUp1.Phone = '7777707770';
        cUp1.Email = 'tvghtConttt@gmail.com';       
        //cUp1.Group_Slugs__c = 'q-sys-developer';
        cList.add(cUp1);
        
        //Test data for Service Center
        Contact cUp2=new Contact();
        cUp2.FirstName ='Ttt-jjTest';
        cUp2.LastName ='ghf';
        cUp2.Phone = '454387687';
        cUp2.Email = 'tvgfdgtt@gmail.com';       
       // cUp2.Group_Slugs__c = 'service-partner';
        cList.add(cUp2);
       
        
        //Test data for Technical Support
        Contact cUp3=new Contact();
        cUp3.FirstName ='Tsdsa-jjTest';
        cUp3.LastName ='servier';
        cUp3.Phone = '466484845';
        cUp3.Email = 'tech@gmail.com';       
        //cUp3.Group_Slugs__c = 'tech-support';
        cList.add(cUp3);
        
        //Test data for EMS
        Contact cUp4=new Contact();
        cUp4.FirstName ='sa-jjTest';
        cUp4.LastName ='emass';
        cUp4.Phone = '456465';
        cUp4.Email = 'ems@gmail.com';       
        // cUp4.Group_Slugs__c = 'ems';
        cList.add(cUp4);
        
        // Test data for Service Training        
        Contact cUp5=new Contact();
        cUp5.FirstName ='cSds-jjTest';
        cUp5.LastName ='servicesdf';
        cUp5.Phone = '454666';
        cUp5.Email = 'services@gmail.com';       
        cUp5.Group_Slugs__c = 'service-training';
        cUp5.Community_User__c  = UserInfo.getUserId();
        cUp5.Communication_Attributes__c = 'Partnership Program Manager';
        cList.add(cUp5);
        
        
        //Test Data for QSC Rep
        Contact cUp6=new Contact();
        cUp6.FirstName ='qsc-jjTest';
        cUp6.LastName ='qscsfdsf';
        cUp6.Phone = '4589353';
        cUp6.Email = 'qscqw@gmail.com';      
        cUp6.AccountId = AccNum.Id;     
       // cUp6.Group_Slugs__c ='qsc-rep';
        cList.add(cUp6);
        insert cList;
        
        cList[1].Group_Slugs__c = 'q-sys-developer';
        cList[2].Group_Slugs__c = 'tech-support';
        cList[3].Group_Slugs__c = 'commHigherEd';
        cList[5].Communication_Attributes__c = 'Partnership Program Manager;Corporate';
        cList[6].Communication_Attributes__c = 'Partnership Program Manager';
        update cList;
        
/*******************************************************************************************/ 
        
        
/******************************Test Data for updateUserGroupSlug Method**********************/
       
        Set<Id> cIds=new set<Id>();
        //Test user for Contact Record with User Id
        User u = new User();
        u.username = 'temmunity@user.test.commu';
        u.email = 'testommunity@test.com';
        u.lastName = 'Tas';
        u.firstName = 'TTer';
        String alias = u.firstName + u.lastName;
        u.alias = alias;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'QSC Service User'].Id;
        //u.Group_Slugs__c= globalHelper.getGroupSlugs('CommDev');
        insert u;
        
        //Test Data for Contact with Community User Id
        Contact CommunityUsr=new Contact();
        CommunityUsr.FirstName ='cccomunt-jjTest';
        CommunityUsr.LastName ='communru';
        CommunityUsr.Phone = '46679';
        CommunityUsr.Community_User__c=u.id;
        CommunityUsr.Email = 'Communitye@gmail.com';       
        CommunityUsr.Group_Slugs__c =u.Group_Slugs__c;
        insert CommunityUsr;
        cIds.add(CommunityUsr.id);
        cUp.Group_Slugs__c='cinema-community';
        update cUp;
 /************************************************************************************************/
         
  /*********************************checkContactDupe Method ****************************************/
        Test.startTest();
        List<contact> condup=new List<contact>();
        //Test data for Check for Email Match //
        Contact conDupemail=new Contact();
        conDupemail.FirstName ='CoEma-jjTest';
        conDupemail.LastName='emialCheck';
        conDupemail.Email='testas@gmail.com';
        conDupemail.AccountId=DupAccNum.Id;
        conDupemail.Group_Slugs__c= ';SHP;LMS';
        conDupemail.Customer_Number__c='123456';
        condup.add(conDupemail);
        
        //Test data for Check for Domain Match //
        Contact conDomain=new Contact();
        conDomain.FirstName ='CoEmaDomai-jjTest';
        conDomain.LastName='CoEmaDomai-jjTest';
        conDomain.Email='testdomain@testdomain123.com';
        condup.add(conDomain);
        
        //test data for Check generic email domains //
        Generic_Email_List__c dGenericEmail = new Generic_Email_List__c(); 
        dGenericEmail.Domain__c='testdomain12322.com';
        insert dGenericEmail;

        //Trigger Company Creation
        Contact conDomain2=new Contact();
        conDomain2.FirstName ='Test Class First';
        conDomain2.LastName='Test Class Last';
        conDomain2.Email='testclassfirsttestclasslast13243954@gmail.com';
        condup.add(conDomain2);
        insert condup;
        
   /*******************************************************************************************/
      
        //Calling the Class and methods with Parameters
       // methods_Contact.insertDeletePSAs(userIds,contactIds);
       // methods_Contact.updateUserGroupSlug(cIds);
       methods_Contact.checkContactDupe(condup, 'Insert');
        methods_Contact.checkContactDupe(condup, 'Update');        
        Test.stopTest();
    }
    /*************************************************************************************/
    
     @IsTest
    public static void TestinsertDeleteCampaignMembers() {
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
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.Active_Lookup__c = acc.Id;
        con.LastName = 'Test Con';
        con.Communication_Attributes__c = 'Product Info;Service';
        con.Email = 'testforCampMembers@campMembers.com';
        insert con;
        
        Contact con2 = new Contact();
        con2.AccountId = acc.Id;
        con2.Active_Lookup__c = acc.Id;
        con2.LastName = 'Test Con';
        con2.Communication_Attributes__c = 'Partnership Program Manager;Corporate';
        con2.Email = 'testforCampMembers@campMembers.com';
        insert con2;
        
        con.Communication_Attributes__c = 'Service';
        Update con;
        
        con.Communication_Attributes__c = 'Product Info';
        Update con;
        
        con.Status__c = 'Inactive';
        con.Communication_Attributes__c = 'Product Info';
        Update con;
        Map<Id,Contact> contacts = new Map<Id,Contact>();
        contacts.put(con2.Id,con2);
        methods_Contact.updateAccountsPartnershipProgramContact(contacts,contacts);
    }
    
    @IsTest
    public static void TestinsertContact() {
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
        
        Contact con2 = new Contact();
        con2.AccountId = acc.Id;
        con2.Active_Lookup__c = acc.Id;
        con2.LastName = 'Test Con';
        con2.Communication_Attributes__c = 'Partnership Program Manager;Corporate';
        con2.Email = 'testforCampMembers@campMembers.com';
        insert con2;
        contact c = [select id,AccountId,Active_Lookup__c,LastName,Communication_Attributes__c,Email from contact where id =: con2.Id];
        Map<Id,Contact> ocontacts = new Map<Id,Contact>();
        ocontacts.put(c.Id,c);
        con2.Communication_Attributes__c = 'Corporate';
        update con2;
        Map<Id,Contact> contacts = new Map<Id,Contact>();
        contacts.put(con2.Id,con2);
        methods_Contact.updateAccountsPartnershipProgramContact(contacts,ocontacts);
    }
    @IsTest
    public static void TestinsertContact2() {
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
        
        Contact con2 = new Contact();
        con2.AccountId = acc.Id;
        con2.Active_Lookup__c = acc.Id;
        con2.LastName = 'Test Con';
        con2.Communication_Attributes__c = 'Partnership Program Manager;Corporate';
        con2.Email = 'testforCampMembers@campMembers.com';
        insert con2;
        contact c = [select id,AccountId,Active_Lookup__c,LastName,Communication_Attributes__c,Email from contact where id =: con2.Id];
        Map<Id,Contact> ocontacts = new Map<Id,Contact>();
        ocontacts.put(c.Id,c);
        con2.Communication_Attributes__c = null;
        update con2;
        Map<Id,Contact> contacts = new Map<Id,Contact>();
        contacts.put(con2.Id,con2);
        methods_Contact.updateAccountsPartnershipProgramContact(contacts,ocontacts);
    }
    @isTest
    public static void testupdateUser(){
        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'CEO' Limit 1];
        User adminUser = new user();
        adminUser.Id = UserInfo.getUserId();
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        System.runAs(adminUser){
        test.startTest();
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
        //acc.isPartner = true;
        insert acc;
        
        Contact con2 = new Contact();
        con2.AccountId = acc.Id;
        con2.Active_Lookup__c = acc.Id;
        con2.LastName = 'Test Con';
        con2.Communication_Attributes__c = 'Partnership Program Manager;Corporate';
        con2.Email = 'testforCampMembers@campMembers.com';
        insert con2;
        User u = new User();
        u.username = 'temmunity@user.test.commutt';
        u.email = 'testommunitywa@test.com';
        u.lastName = 'T1';
        u.firstName = 'TTer2';
        String alias = u.firstName + u.lastName;
        u.alias = alias;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CPP Community User'].Id;
        u.contactId = con2.Id;
        u.CommunityNickname  = 'abcT';
        
        //u.Group_Slugs__c= globalHelper.getGroupSlugs('CommDev');
        insert u;
        con2.Community_Access__c = 'CPP Community User';
        update con2;
        map<Id,string> contactIdCommunityAccessMap = new map<Id,string>();
        contactIdCommunityAccessMap.put(con2.Id,'CPP Community User');
        methods_Contact.updateUser(contactIdCommunityAccessMap);
        test.stopTest();
        }
    }
    @isTest
    public static void testupdateUserTransition(){
        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'CEO' Limit 1];
        User adminUser = new user();
        adminUser.Id = UserInfo.getUserId();
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        System.runAs(adminUser){
        test.startTest();
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
        acc.Customer_Number__c  = '8888111';
        //acc.isPartner = true;
        insert acc;
        
        Contact con2 = new Contact();
        con2.AccountId = acc.Id;
        con2.Active_Lookup__c = acc.Id;
        con2.LastName = 'Test Con';
        con2.Communication_Attributes__c = 'Partnership Program Manager;Corporate';
        con2.Email = 'testforCampMembers@campMembers.com';
        con2.Customer_Number__c = '9087111';
        insert con2;
        con2.Community_Access__c = 'CPP Community User';
        update con2;
        con2.Community_Access__c = 'TPP Community User';
        try{
            update con2;
        }
        catch(Exception ex){
            system.debug('Exception caught on transition');
        }
        map<Id,string> contactIdCommunityAccessMap = new map<Id,string>();
        contactIdCommunityAccessMap.put(con2.Id,'CPP Community User');
        methods_Contact.updateUser(contactIdCommunityAccessMap);
        test.stopTest();
        }
    }
}