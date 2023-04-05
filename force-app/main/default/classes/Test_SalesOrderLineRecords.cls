/**************************************************************************************************************
* @File Name          : Test_SalesOrderLineRecords.cls
* @description        : This is the test class, which test the SalesOrderLineRecords.cls.
* @Author             : naman.gupta@qsc.com
* @Group              : 
* @Last Modified By   : naman.gupta@qsc.com
* @Last Modified On   : 28/02/2023
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    28/02/2023   	naman.gupta
**************************************************************************************************************/
@isTest
public class Test_SalesOrderLineRecords 
{
  
    @isTest
    public static void testSalesOrderLineRecords()
    {
        Test.setMock(HttpCalloutMock.class, new MockExternalRecordResponseGenerator());
        
        Test.startTest();
        HTTPRequest req = new HTTPRequest();
        HttpResponse res = MockExternalRecordResponseGenerator.respond(req);
        
        system.debug('Result : ' + res.getBody());
        
        Map<String, Object> mapRecord = (Map<String, Object>) Json.deserializeUntyped(res.getBody());
        
         system.debug('mapRecord : ' + mapRecord.get('Order_Number__c'));
        
        List<SalesOrders__x> listSalesOrders = new List<SalesOrders__x>();
        listSalesOrders.add(new SalesOrders__x(Order_Number__c = String.valueOf(mapRecord.get('Order_Number__c')), Id = String.valueOf(mapRecord.get('Id'))));
        
        system.debug('listSalesOrders : ' + listSalesOrders[0].Id);
        
        listSalesOrders.add(new SalesOrders__x(Order_Number__c = '11273835', Id = listSalesOrders[0].Id));// WHERE Order_Number__c = '11273835'
        SalesOrderLineRecords.getSalesOrderLineRecords(listSalesOrders[0].Id, 2, 0);
        Test.stopTest();
    }
}