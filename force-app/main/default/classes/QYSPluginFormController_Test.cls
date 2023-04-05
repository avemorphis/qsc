@isTest
public class QYSPluginFormController_Test {
@isTest
    public static void test(){
        NFR_API__c apiCS=caseDataFactory.customApisSetting();
        apiCS.Name = 'Case Trigger';
        insert apiCS;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        Account a = new Account();
        a.Name = 'testAccount';
        Insert a;
        
        opportunity opp = new opportunity();
        opp.name = 'test';
        opp.StageName = 'open';
        opp.AccountId = a.Id;
        opp.CloseDate = system.today();
        insert opp;
        
        
        QYSPluginFormController.getAccountDetails();
        QYSPluginFormController.QYSFormRequestWrapper wrapper = new QYSPluginFormController.QYSFormRequestWrapper();
        wrapper.accountId = a.Id;
        wrapper.compDivBusinessUnit = 'compDivBusinessUnit';
        wrapper.contactEmail = 'contactEmail@test.com';
        wrapper.phone = '1234234565';
        wrapper.integrationDeveloperEmail = 'contactEmail@test.com';
        wrapper.integrationDeveloperName = 'integrationDeveloperName';
        wrapper.integrationApplicability = 'Test';
        List<String> verticals = new List<String>();
        verticals.add('Corporate');
        verticals.add('Healthcare');
        
        wrapper.verticalsServed = verticals;
        wrapper.desiredInstallationDate = System.today();
        
        //wrapper.integrationDevelopment = true;
        wrapper.integrationDeveloper = true;
        QYSPluginFormController.createOpportunity(wrapper);
        
            }
}