//==================================================================================================
// Test Class : Docusign automation
// Company: Think AI Corp
// Author: Vivek Manchanda
// Comment: Docusign automation
//==================================================================================================
//          Date            Purpose
// Changes: 10/17/2019      Initial Version
//							
//==================================================================================================
@isTest
private class testDocusignAutomation {
    static testMethod void triggerAccount() {
        
        // Inserting new contact, Account also created with contact insertion
        List<Contact> contactList = new List<Contact>();
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Name';
        con.Email = 'test@test.com';
        con.Phone = '987654321';
        con.Has_authority_to_execute_legal_agreement__c = true; 
        contactList.add(con);
        insert contactList;
        
        // Inserting new Template configuration custom setting
        List<TemplateConfiguration__c> templateConfigurationList = new List<TemplateConfiguration__c>();
        TemplateConfiguration__c tempConfig = new TemplateConfiguration__c();
        tempConfig.name = 'Referral USA';
        tempConfig.Country__c = 'USA';
        tempConfig.Template_Id__c = '12345678-5678-1234-8787-257246789015';
        tempConfig.Template_Name__c = 'Test : Template USA';
        tempConfig.Agreement_type__c = 'Referral Agreement';
        templateConfigurationList.add(tempConfig);
        TemplateConfiguration__c tempConfigAU = new TemplateConfiguration__c();
        tempConfigAU.name = 'Reseller AU';
        tempConfigAU.Country__c = 'AU';
        tempConfigAU.Template_Id__c = '12345678-5678-1234-8787-257246789015';
        tempConfigAU.Template_Name__c = 'Test : Template AU';
        tempConfigAU.Agreement_type__c = 'Reseller Agreement';
        templateConfigurationList.add(tempConfigAU);
        insert templateConfigurationList;
        
        //Fetching Account and updating values to start the trigger
        List <Account> accountList = [SELECT Id, Name FROM Account];
        for(Account acc : accountList){
            acc.Legal_Agreements__c = 'Referral Agreement';
            acc.BillingCountry = 'AU';
        }
        update accountList;
        
        for(Account acc : accountList){
            acc.Legal_Agreements__c = 'Reseller Agreement';
        }
        update accountList;
    }
}