//==================================================================================================
// Test Class: Docusign Trigger test class
// Company: Think AI Corp
// Author: Vivek Manchanda
// Comment: Docusign trigger test class
//==================================================================================================
//          Date            Purpose
// Changes: 10/17/2019      Initial Version
//							
//==================================================================================================
@isTest
private class testDocusignUpdate {
    static testMethod void triggerDocusign() {   
        // Creating new account
        Account acc = new Account();  
        acc.Name = 'Test';
        acc.Legal_Agreements__c = 'Reseller Agreement';
        insert acc;
        
        // Creating new Docusign status record
        dsfs__DocuSign_Status__c  dsfs = new dsfs__DocuSign_Status__c();
        dsfs.dsfs__Company__c = acc.id;
        dsfs.dsfs__Envelope_Status__c = 'Sent';
        dsfs.dsfs__DocuSign_Envelope_ID__c = '1001A123-1234-5678-1D84-F8D44652A382';
        dsfs.dsfs__Subject__c = 'QSC Reflect Reseller Agreement – Please Sign';
        insert dsfs;
        dsfs.dsfs__Envelope_Status__c = 'Completed';
        update dsfs;
        acc.Legal_Agreements__c = 'Referral Agreement';
		update acc;
        dsfs.dsfs__Subject__c = 'QSC Reflect Referral Agreement – Please sign';
        update dsfs;
    }
}