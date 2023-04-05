public with sharing class ShpNewCaseHelper {
    public string customLabelValue {Get; Set;}
    public ShpNewCaseHelper() {

    }
    @AuraEnabled(cacheable=true)
    public static Product2 getDefaultProduct(){
        String customLabelValue =System.Label.Other_No_Product;
        system.debug('test===>'+customLabelValue);
        Product2 prodList = [Select id, Name from Product2 WHERE Id = :customLabelValue];
        return prodList; 
    }
    @AuraEnabled
    public static string getRecordType(){ 
        try {
            string proSvcId;
   			string recordtypeName;
           	string DeveloperNm ='ProSvc';
            recordType RT;
            RT = [select id from recordtype where developername =: DeveloperNm limit 1];
            
            proSvcId = RT.id;
            return proSvcId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}