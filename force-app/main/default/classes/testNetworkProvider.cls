/**

* @description        : networkProvider Testclass for fetching network and storing related data in custom setting
* @Author             : prakhar.jain@qsc.com
* @Last Modified By   : prakhar.jain@qsc.com
* @Last Modified On   : 30/12/2022
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    30/12/2022     prakhar.jain@qsc.com       Initial Version
**/

@isTest
public class testNetworkProvider {
    
    
    
    Public static testmethod void testNetwork()
    {
        networkProvider.getCommunity();
    }
    
    Public static testmethod void testsaveFields()
    {
        
        Id caseRecordTypeId = '0124X000001ySqIQAU';
        Id networkId = '0DB4X000000wkLpWAI';
        string caseFields = 'CaseNumber,Status,RecordTypeId,Request_RMA__c,CreatedDate';
        networkProvider.saveFields(caseRecordTypeId, networkId, caseFields);
        
        Id caseRecordTypeId2 = '0124X000001ySqIQAU';
        Id networkId2 = '0DB4X000000wkLpWAI';
        string caseFields2 = 'CaseNumber,Status,RecordTypeId,Request_RMA__c,CreatedDate';
        

        
        networkProvider.saveFields(caseRecordTypeId2, networkId2, caseFields);
        
		Id caseRecordTypeId3 = '0124X000001uGtCQAU';
        Id networkId3 = '0DB4X000000wkLpWAI';
        networkProvider.saveFields(caseRecordTypeId3, networkId3, null);
    }
    
    Public static testmethod void testfetchRecievedField()
    {
        string caseRecordTypeName = 'Login Issue / Email Update';
        dynamic_field__c objDynamic = new dynamic_field__c(Name= 'LogQSC'+' DataSet', Record_Type__c= 'Login Issue / Email Update', 	Community_Type__c='QSC Communities for Developers',Selected_Case_Fields__c= 'CaseNumber,Status,RecordTypeId,Request_RMA__c,CreatedDate');
        INSERT objDynamic; 
		
        networkProvider.fetchRecievedField(caseRecordTypeName);
    }
}