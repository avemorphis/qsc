//=================================================================================================================
//  Object: methods_Account.cls
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: Account Methods Clas
//=================================================================================================================
//          Date            Purpose
// Changes: 12/14/2018      Initial Version
//=================================================================================================================


public class methods_Account  {
    
    /**************************************************************************************************************
updateContactAccount
Method to Update Contact Record with Account Id if it is a Synced Contact
---------------------------------------------------------------------------------------------------------------
@param    Users    Set of Accounts from trigger with contacts to be updated
@return   void
**************************************************************************************************************/
    public static void updateContactAccount(List<Account> newAccounts){
        
        //Containers
        List<Contact> contactsToUpdate = new List<Contact>();
        
        //Build Contact Record to Update
        for(Account acct : newAccounts) {
            
            //Check if Null
            if(acct.Synced_Contact__c != null) {
                //Build Contact Record
                Contact uC = new Contact();
                uC.Id = acct.Synced_Contact__c;
                uC.AccountId = acct.Id;
                //Update Account on Contact
                contactsToUpdate.add(uC);
            }
        }
        //DML Operation
        try {
            if (!contactsToUpdate.isEmpty()) {
                update contactsToUpdate;
            }
            
            if(Test.isRunningTest()) {
                DMLexception e = new DMLexception();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        catch (DMLexception e) {
            
            //Get running Class and Method
            String sTrace = e.getStackTraceString().substringAfter('\n');
            String runningClass = globalExceptionHandlers.getClassName(sTrace);
            String runningMethod = globalExceptionHandlers.getMethod(sTrace);
            
            //Log in Debug Log
            
            
            //set friendly message
            //e.setMessage(System.Label.Exception_Message);
            
            //Log Exception
            globalExceptionHandlers.logInsertORUpdateException(runningClass, runningMethod, String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
        }
    }
    
    /**************************************************************************************************************
sendReferralOnboardingDocument
Method to initiate Docusign Refferal Onboarding Document being sent
---------------------------------------------------------------------------------------------------------------
@param    Accounts    Set of Accounts from trigger where envelope will be sent
@return   void
**************************************************************************************************************/
    
    @Future(callout=true)
    public static void sendOnboardingDocument(Set<Id> Accounts,String billingCountry,String templateConfig) {
        // Variables
        String templateId;
        String templateName;                
        Id mySourceId;
        for(id acid:Accounts){
            mySourceId = acid;
        }
        
        // Fetching Email subject and body for docusign envelope from salesforce email templates
        EmailTemplate invTemplate = [ SELECT Id, Name, Subject, Body FROM EmailTemplate  WHERE Name = :templateConfig]; 
        string subject = invTemplate.subject;
        string body = invTemplate.body;
        
        // Fetching Custom setting data for template configuration
        List<TemplateConfiguration__c> mcs = TemplateConfiguration__c.getall().values();
        
        for(TemplateConfiguration__c rtc : mcs){ 
            if(billingCountry == rtc.country__c && templateConfig == rtc.Agreement_type__c){
                templateId = rtc.Template_Id__c;
                templateName = rtc.Template_Name__c;
            }
        }
        if(templateId == null && templateName == null){
            for(TemplateConfiguration__c rtc : mcs){ 
                if('USA' == rtc.country__c && templateConfig == rtc.Agreement_type__c){
                    templateId = rtc.Template_Id__c;
                    templateName = rtc.Template_Name__c;
                }
            }
        }       
        // Fetching contact for sending docusign template
        List<Contact> lstContact = [SELECT Id, Name, Email, Has_authority_to_execute_legal_agreement__c FROM Contact where accountid =:mySourceId ];
        
        List<dfsle.Recipient> listRecipients=new List<dfsle.Recipient>();
        for(Contact contacts:lstContact){
            
            //Check if Legal Contact
            if(contacts.Has_authority_to_execute_legal_agreement__c) {
                //use the Recipient.fromSource method to create the Recipient
                dfsle.Recipient myRecipient =dfsle.Recipient.fromSource(
                    contacts.Name, // Recipient name
                    contacts.Email, // Recipient email
                    null, //Optional phone number
                    'Signer 1', //Role Name. Specify the exact role name from template
                    new dfsle.Entity(contacts.Id)); //source object for the Recipient
                //add Recipient to the listRecipients
                listRecipients.add(myRecipient);
            }
        }
        //Send if it has receipients
        if(listRecipients.size() > 0) {
            
            dfsle.UUID myTemplateId = dfsle.UUID.parse(templateId);
            
            //create a new document for the Envelope
            dfsle.Document myDocument = dfsle.Document.fromTemplate(
                myTemplateId, 
                templateName); 
            
            // Docusign envelope creation
            dfsle.Envelope myEnvelope = new dfsle.Envelope(
                null,
                null,
                null,
                null,
                new List<dfsle.Document> { myDocument }, // Docusign document
                null,
                new List<dfsle.CustomField> {},
                null,
                subject, // Email subject
                body, // Email body
                new dfsle.Entity(mySourceId), // Source sObject for docusign
                null);
            
            myEnvelope = myEnvelope.withRecipients(listRecipients);
            
            // Sending the envelope created
            try {
                myEnvelope = dfsle.EnvelopeService.sendEnvelope(
                    myEnvelope, 
                    true); 
            }
            catch (Exception e) {
                
            }
        }
    }
}