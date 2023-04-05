@isTest
public class TestCreateStagingContact {
    static testmethod void method1(){
        Higher_Ed__c hed = new Higher_Ed__c();
        hed.Company__c='test';
        hed.Email_Opt_In__c=true;
        hed.First_Name__c='fname';
        hed.Last_Name__c='lname';
        hed.Email_Address__c='test@test123.com';
        hed.Country__c='US';
        hed.Phone_Number__c='1234567890';
        insert hed;
    }
}