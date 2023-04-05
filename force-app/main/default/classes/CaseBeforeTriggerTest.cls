@isTest
public class CaseBeforeTriggerTest {
	@isTest(SeeAllData=true)
    Static void testMethod1(){
        Product2 pro        = new Product2();
        pro.Name            = 'Testing Product for this test class';
        pro.CurrencyIsoCode = 'USD';
        pro.Model_Line__c   = 'Test Model Line';
        pro.Model_Name__c   = 'Test Model Name';
        pro.IsActive		= True;
        pro.Cases__c		= True;
        insert pro;
        
        Case c                   = New Case();
        c.Type                   = 'Service_Center_Onboarding';
        c.Origin                 = 'Web';
        c.Status                 = 'Open';
        c.RecordTypeId           = '0120y000000McdXAAS';
        c.Product_If_No_Asset__c = pro.Id;
        
        Insert c;
        
        c.Model_Line__c          = pro.Model_Line__c;
        c.Model_Name__c          = pro.Model_Name__c;
        Update c;
    }
}