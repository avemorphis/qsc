@isTest
public class RMARequestFormControllerTest{
    public static testMethod void getContactAccountDetails() {
        list<filterCriteriaForCase__c> caseCS=caseDataFactory.customCaseSetting();
        insert caseCS;
        NFR_API__c apiCS=caseDataFactory.customApisSetting();
        apiCS.Name = 'Case Trigger';
        insert apiCS;
        test.startTest();
        RMARequestFormController.getContactAccountDetails();
        test.stopTest();
    }
    public static testMethod void GetCaseRecord() {
        list<filterCriteriaForCase__c> caseCS=caseDataFactory.customCaseSetting();
        insert caseCS;
        NFR_API__c apiCS=caseDataFactory.customApisSetting();
        apiCS.Name = 'Case Trigger';
        insert apiCS;
        list<account> accList=caseDataFactory.createAccounts(1);
        insert acclist;
        case cs=CaseDataFactory.createCase(acclist[0].id);
        insert cs;
        test.startTest();
        RMARequestFormController.GetCaseRecord(cs.ID);
        test.stopTest();
    }
    public static testMethod void SaveCaseRecord() {
        list<filterCriteriaForCase__c> caseCS=caseDataFactory.customCaseSetting();
        insert caseCS;
        NFR_API__c apiCS=caseDataFactory.customApisSetting();
        apiCS.Name = 'Case Trigger';
        insert apiCS;
        list<account> accList=caseDataFactory.createAccounts(1);
        insert acclist;
        case cs=CaseDataFactory.createCase(acclist[0].id);
        insert cs;
        test.startTest();
        RMARequestFormController.SaveCaseRecord(cs);
        test.stopTest();
    }
    public static testMethod void fetchLookupData() {
        test.startTest();
        RMARequestFormController.fetchLookupData('test','Contact');
        test.stopTest();
    }
    public static testMethod void fetchDefaultRecord() {
        list<filterCriteriaForCase__c> caseCS=caseDataFactory.customCaseSetting();
        insert caseCS;
        NFR_API__c apiCS=caseDataFactory.customApisSetting();
        apiCS.Name = 'Case Trigger';
        insert apiCS;
        list<account> accList=caseDataFactory.createAccounts(1);
        insert acclist;
        test.startTest();
        RMARequestFormController.fetchDefaultRecord(acclist[0].Id,'Account');
        test.stopTest();
    }
    public static testMethod void createCase() {
        list<filterCriteriaForCase__c> caseCS=caseDataFactory.customCaseSetting();
        insert caseCS;
        NFR_API__c apiCS=caseDataFactory.customApisSetting();
        apiCS.Name = 'Case Trigger';
        insert apiCS;
        list<account> accList=caseDataFactory.createAccounts(1);
        insert acclist;
        case cs=CaseDataFactory.createCase(acclist[0].id);
        insert cs;
        test.startTest();
        RMARequestFormController.RMARequestWrapper rmaWrap = new RMARequestFormController.RMARequestWrapper();
        RMARequestFormController.Request  req = new RMARequestFormController.Request();
        req.serial = '100';
        req.model ='iphone';
        req.description='New Product';
        req.needbyDate = system.today();
        req.reqanEstimate = false;
        req.needaBox = true;
        RMARequestFormController.Address add = new RMARequestFormController.Address();
        add.street = 'Test';
        add.city = 'test';
        add.state = 'test';
        add.country = 'test';
        add.postalCode = '10000';
        rmaWrap.contactName = 'teja';
        rmaWrap.accountId = accList[0].id;
        rmaWrap.billingAddress = add;
        rmaWrap.rmaShippingAddress = add;
        rmaWrap.business = true;
        rmaWrap.residential = true;
        rmaWrap.needaBox = false;
        rmaWrap.reqanEstimate = false;
        rmaWrap.customerPO  = '10009';
        rmaWrap.req1 = req;
        rmaWrap.req2 = req;
        rmaWrap.req3 = req;
        rmaWrap.req4 = req;
        rmaWrap.req5 = req;
        rmaWrap.req6 = req;
        rmaWrap.req7 = req;
        rmaWrap.req8 = req;
        rmaWrap.req9 = req;
        rmaWrap.req10 = req;
        RMARequestFormController.createCase(rmaWrap);
        test.stopTest();
    }
}