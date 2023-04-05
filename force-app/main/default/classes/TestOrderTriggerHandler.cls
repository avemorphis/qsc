//=================================================================================================================
//  Object : TestOrderTriggerHandler.cls
//  Company: Think AI
//  Author : Anand Vaidya
//  Comment: This class is test the functionality of OrderTriggerHandler apex class.
//=================================================================================================================
//          Date            Purpose
// Changes: 01/02/2021      Initial Version
//=================================================================================================================
@isTest
public class TestOrderTriggerHandler {
    @testsetup
    public static void testSetup() {
        // Insert Account record
        Account accountRecord = new Account();
        accountRecord.Name = 'Test Account';
        Insert accountRecord;
        
        // Insert Product record
        Product2 productRecord = new Product2();
        productRecord.Name = ' Test Product ';
        productRecord.Description='Test Product Entry 1';
        productRecord.productCode = 'ABC';
        productRecord.isActive = true;
        insert productRecord;
        
        // Fetch Standard Pricebook record
        //Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];
        Id pricebookId = Test.getStandardPricebookId();
        
        // Insert Pricebook Entry record
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = pricebookId;
        standardPrice.Product2Id = productRecord.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        
        // Insert Order record
        Order orderRecord = new Order();
        orderRecord.Name = 'Test Order ';
        orderRecord.Status = 'Draft';
        orderRecord.EffectiveDate = system.today();
        orderRecord.EndDate = system.today() + 4;
        orderRecord.AccountId = accountRecord.id;
        orderRecord.Pricebook2Id =  pricebookId;
        insert orderRecord;
        
        // Insert Order Item
        OrderItem orderItemRecord = new OrderItem();
        orderItemRecord.OrderId = orderRecord.id;
        orderItemRecord.Quantity = 24;
        orderItemRecord.UnitPrice = 240;
        orderItemRecord.Product2id = productRecord.id;
        orderItemRecord.PricebookEntryId = standardPrice.Id;
        insert orderItemRecord;
        
        // Create Custom Setting record
        NFR_API__c nfrSettingRecord = new NFR_API__c();
        nfrSettingRecord.Name = 'Order Success Trigger';
        nfrSettingRecord.EndPoint_url__c = 'https://web-apid01.qsc.com/api/Reflect/AddOrderRequest';
        nfrSettingRecord.Password__c = 'test';
        nfrSettingRecord.QueueURL__c = '';
        nfrSettingRecord.Token_url__c = 'https://web-apid01.qsc.com/token';
        nfrSettingRecord.Username__c = 'test';
        insert nfrSettingRecord;
    }
	@isTest
    public static void testNFRcallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NFRMockGenerator());
        
		List<Order> listOrder = new List<Order>();
        listOrder = [SELECT Id,
                  		    Status
                       FROM Order
                      LIMIT 1];
        
        if(!listOrder.isEmpty()) {
            // Update Order status from "Draft" to "Activated"
            Test.startTest();
            //orderRecord.StatusCode = 'Activated';
            listOrder[0].Status = 'Activated';
            update listOrder[0];
            Test.stopTest();
        }
    }
}