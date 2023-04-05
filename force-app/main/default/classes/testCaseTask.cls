@isTest
private class testCaseTask {
    static testMethod void triggerCase() {
        list<filterCriteriaForCase__c> caseCS=caseDataFactory.customCaseSetting();
        insert caseCS;
        
        NFR_API__c apiCS=caseDataFactory.customApisSetting();
        apiCS.Name = 'Case Trigger';
        insert apiCS;
        list<account> accList=caseDataFactory.createAccounts(1);
        insert acclist;
        Id accountIdReflect;
        Id accountIdDenied;
        accountIdDenied = acclist[0].Id;
        accountIdReflect = acclist[1].Id;
        opportunity opp=CaseDataFactory.createOpportunity(accountIdReflect);
        insert opp;
        contact con=CaseDataFactory.createContact(accountIdDenied);
        insert con;
        Test.setMock(HttpCalloutMock.class, new mockNfrUrl());
        test.startTest();
        case case1=CaseDataFactory.createCase(accountIdReflect);
        insert case1;
        case case2=CaseDataFactory.createCase(accountIdDenied);
        insert case2;
        case1.status='Close';
        th_Case.isFirstTime = true;
        update case1;
        case2.status='Close';
        th_Case.isFirstTime = true;
        update case2;
        test.stopTest();
    }
}