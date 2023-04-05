@istest
public class shpNewCaseHelper_Test {
    Public static testMethod void test(){
       /* Account acc = new Account (name= 'TestAccountAcc');
        insert acc;
        system.debug('>>>>acc'+acc.id);
        
        Id CaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ProSvc').getRecordTypeId();
        Case ca = new case() */
        try{
        Product2 pro = new Product2();
        pro.Name = 'Other (No Product)';
        insert pro;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pro.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = pro.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;    
            
        Product2 p1 = new Product2();    
        String customLabelValue;
            
        ShpNewCaseHelper shp = new ShpNewCaseHelper();        
        shp.customLabelValue = System.Label.Other_No_Product;
        
        Test.startTest();
      //  System.debug(ShpNewCaseHelper.getDefaultProduct());
       p1 = ShpNewCaseHelper.getDefaultProduct();
      System.assertNotEquals(null, p1, 'The getDefaultProduct method should return a non-null Product2 object.');
     System.assertEquals('Other (No Product)', p1.Name, 'The getDefaultProduct method should return the correct Product2 object.');
   // public static testmethod void test2(){
       
        test.stopTest();
    }
        catch(exception e){
        system.debug('-->'+e);
    }
}
    public static testmethod void test2()
    {
        string DeveloperNm ='ProSvc'; 
      //  recordType rt = new recordType(); 
      //  rt.DeveloperNm ='ProSvc';   
       // insert rt;
         Id CaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ProSvc').getRecordTypeId();
            
        string proSvcId;
        proSvcId = CaseRecordTypeId;
         ShpNewCaseHelper.getRecordType();
    }
}