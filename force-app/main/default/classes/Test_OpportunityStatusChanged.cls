//==================================================================================================
//  Object: Test_OpportunityStatusChanged
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: Test class for OpportunityStatusChanged
//==================================================================================================
//          Date            Purpose
// Changes: 09/08/2019      Initial Version
//==================================================================================================
@IsTest
public class Test_OpportunityStatusChanged{
    @IsTest
    public static void TestSendEmailMethodsTest(){
        
        // Test Data for Account
        Set<Id> SetopportunityIds=new Set<Id>();
        Account acc=new Account();
        acc.Name='account';
        Id RecordTypeIdIAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User Company').getRecordTypeId();
        acc.RecordTypeId=RecordTypeIdIAccount;
        insert acc; 
        SetopportunityIds.add(acc.Id);
        
        
        //Test data for Contact
        Contact cUp=new Contact();
        cUp.FirstName ='TD-Test';
        cUp.LastName ='Class';
        cUp.Phone = '7707707770';
        cUp.Email = 'tesssact@gmail.com'; 
        cUp.AccountId=acc.Id;
        insert cUp;
        SetopportunityIds.add(cUp.id);
        
        //Test Data for opportunity 
        opportunity opp=new opportunity();
        opp.name='testopp';
        opp.StageName='Qualification';
        opp.closedate=system.today();
        opp.Status__c='Reflect Buy Fail';
        opp.AccountId=acc.Id;
        insert opp;
        SetopportunityIds.add(opp.Id);
        
        //Test data for Asset  
        Asset assets=new Asset();
        assets.name='Testasset';
        assets.AccountId=acc.Id;
        //assets.ContactId=cUp.Id;
        assets.Opportunity__c=opp.Id;
        insert assets;
        SetopportunityIds.add(assets.Id);
        
        //Test data for opportunity Related to Assets to Subscription contact
        Subscription_Contact__c subcons=new Subscription_Contact__c();
        subcons.Asset__c=assets.Id;
        subcons.Contact__c=cUp.Id;
        insert subcons;
        SetopportunityIds.add(subcons.Id);
        
        
        Test.startTest();
        opp.Status__c='Reflect Trial Success';
        update opp;
        //Calling the Class and Method
        OpportunityStatusChanged.SendEmail(SetopportunityIds);
        Test.stopTest();
        
    }
    
}