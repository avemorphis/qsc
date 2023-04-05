public class caseDataFactory {
    
    public static NFR_API__c customApisSetting() {
        NFR_API__c apiCS=new NFR_API__c();
        apiCS.EndPoint_url__c='https://web-api02.qsc.com/api/Reflect/ExtendNFRDemoRequest';
        apiCS.Token_url__c='https://web-api02.qsc.com/token';
        apiCS.Name='Case trigger';
        apiCS.Password__c='test123';
        apiCS.Username__c='test123';
        apiCS.QueueURL__c='https://qschttptriggerdev.azurewebsites.net/api/v1/addrequesttoqueue';
        apiCS.x_function_key__c='testing';
        return apiCS;
    }
    public static list<filterCriteriaForCase__c> customCaseSetting() {
        list<filterCriteriaForCase__c> filterCS=new list<filterCriteriaForCase__c>();
        filterCriteriaForCase__c caseRT = new filterCriteriaForCase__c();
        caseRT.Record_type_Id__c='Software Subscription';
        caseRT.Name='Software Subscription Case';
        caseRT.Record_type_name__c='Software Subscription Case';
        caseRT.Case_Reason__c='NFR demo request';
        caseRT.Case_subject__c='Reflect NFR';
        caseRT.Object_name__c='Case';
        caseRT.Account_Attribute__c='Reflect NFR Extension Denied';
        caseRT.Contact_Attribute__c='Reflect Admin';
        filterCriteriaForCase__c opportunityRT = new filterCriteriaForCase__c();
        opportunityRT.Name='Reflect Opportunity';
        opportunityRT.Object_name__c='Opportunity';
        opportunityRT.Opportunity_status__c='Reflect NFR Success';
        opportunityRT.Record_type_Id__c='0120y000000i8a6AAA';
        opportunityRT.Record_type_name__c='Reflect Opportunity';
        filterCS.add(caseRT);
        filterCS.add(opportunityRT);
        return filterCS;        
    }
    public static List<Account> createAccounts( Integer numberOfAccounts) {
        List<Account> accounts = new List<Account>();
        Account account1 = new Account(name='TestAccount',Attributes__c = 'Reflect NFR Extension Denied');
        accounts.add(account1);
        for ( Integer i = 1 ; i <= numberOfAccounts ; i++ ) {            
            Account account = new Account(name='TestAccount'+i,Attributes__c = 'Reflect NFR Extension Approved',Account_Type__c='End User'); 
            accounts.add( account);            
        }        
        return accounts;        
    }
    public static Case createCase(ID accountId) {
        case case1 = new Case();
        case1.AccountId=accountId;
        case1.Status='Open';
        case1.Type='Software Subscription';
        case1.Origin='Email';
        case1.RecordTypeId='0120y000000CFiPAAW';
        case1.Subject='Reflect NFR';
        case1.Reason='NFR demo request';
        return case1;        
    }
    public static opportunity createOpportunity(id accountId)
    {
        opportunity opp=new opportunity();
        opp.name='Testingclass';
        opp.AccountId=accountId;
        opp.StageName='Qualification';
        opp.RecordTypeId='0120y000000i8a6AAA';
        opp.Status__c='Reflect NFR Success';
        opp.CloseDate=date.newInstance(2021,3,31);
        return opp;
    }
    public static contact createContact(id accountId)
    {
        contact con=new contact();
        con.AccountId = accountId;
        con.LastName = 'test';
        con.Contact_Attributes__c = 'Reflect Admin';
        con.Email = 'test@gmailtest.com';
        con.Phone = '123456789';
        return con;
    }
}