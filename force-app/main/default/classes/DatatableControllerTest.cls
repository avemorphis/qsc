/**
 * @File Name          : DatatableControllerTest.cls
 * @Last Modified By   : Uday Kumar k
**/

@isTest
private class DatatableControllerTest {
    
    static testMethod void fetchDataMapCachedTest() {
       
        Map<String, Object> params = new Map<String, Object>();
        
        params.put('objectName','Contact');
        params.put('fields','Name');
        params.put('queryFilters',' Inactive__c = FALSE ');
        params.put('sortBy','Name');
        params.put('queryType','SOQL');
        params.put('sortAsc',false);
        params.put('limitRecords',10);
        
      /*  Account acc = TestDataUtil.createAccount(true);
        Contact con1 = TestDataUtil.createContact(false, acc.Id);
        Contact con2 = TestDataUtil.createContact(false, acc.Id);
        con1.LastName = 'testfor';
        Insert new List<Contact>{con1, con2};*/
            
        Map<String, Object> returnMap =  DatatableController.fetchDataMapCached(params);
        system.assert(returnMap.size() == 1, 'records are not fetched');
        
    }
    
    static testMethod void fetchDataMapCachedTest1() {
       
        Map<String, Object> params = new Map<String, Object>();
        
      /*  Account acc = TestDataUtil.createAccount(true);
        Contact con1 = TestDataUtil.createContact(false, acc.Id);
        con1.LastName = 'testforTable';
        con1.Email = 'testforTable@test.com';
        Insert new List<Contact>{con1};*/
       
        params.put('objectName','Contact');
        params.put('fields','Name');
        params.put('queryType','SOSL');
        params.put('soslSearchTerm','testforTable');
        
        Map<String, Object> returnMap =  DatatableController.fetchDataMapCached(params);
        system.assert(returnMap.size() == 1, 'records are not fetched');
      
    }
  
  
}