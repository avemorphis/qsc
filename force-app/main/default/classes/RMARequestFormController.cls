public with sharing class RMARequestFormController {
    @AuraEnabled
    public static user getContactAccountDetails() {
        User userRecord = [Select Id,AccountId,ContactId,Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingCountry,Account.BillingPostalCode,Account.BillingAddress,Contact.Name,Account.Name FROM User WHERE ID =: UserInfo.getUserId() LIMIT 1];
        
        return userRecord;
    }
    @AuraEnabled
    public static string createCase(RMARequestWrapper rmaRequest){
        Case cs = new Case();
        if(rmaRequest!=null){
            try{
                Id rmaCaseRecordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('RMA Case').getRecordTypeId();
                cs.AccountId = rmaRequest.accountId;
                cs.ContactId = rmaRequest.contactId;
                cs.Customer_PO__c = rmaRequest.customerPO;
                cs.ShiptoContact__c = rmaRequest.rmaContactName;
                cs.Contact_Phone__c = rmaRequest.rmaContactPh;
                cs.Phone__c = rmaRequest.rmaContactPh;
                //cs.Origin ='Web';
                if(rmaRequest.rmaShippingAddress!=null){
                    cs.RMAShippingStreet__c = rmaRequest.rmaShippingAddress.street;
                    cs.RMAShippingCity__c = rmaRequest.rmaShippingAddress.city;
                    cs.RMAShippingCountry__c = rmaRequest.rmaShippingAddress.country;
                    cs.RMAShippingState__c = rmaRequest.rmaShippingAddress.state;
                    cs.RMAShippingPostalCode__c = rmaRequest.rmaShippingAddress.postalCode;
                }
                if(string.isNotBlank(rmaRequest.returnFor) && !rmaRequest.returnFor.equalsIgnoreCase('None')){
                    cs.Return_For__c = rmaRequest.returnFor;
                }
                cs.Request_Details__c = getRequestDetailsFormattedInString(rmaRequest);
                cs.Is_Business__c = rmaRequest.business;
                cs.Is_Residential__c = rmaRequest.residential;
                cs.Require_an_Estimate__c = rmaRequest.reqanEstimate;
                cs.Need_a_Box__c = rmaRequest.needaBox;
                cs.RecordTypeId = rmaCaseRecordTypeId;
                cs.Country_of_use_pl__c = 'Other';
                cs.Type = 'RMA Inquiry';
                database.insert(cs);
                Case c = [select id,CaseNumber from Case where Id=: cs.Id];
                Network myNetwork = [SELECT Id FROM Network WHERE Name ='cpp' ];
                string networkCaseUrl = Network.getLoginUrl(myNetwork.id).removeEnd('login');
                networkCaseUrl += 'case/'+c.Id;
                system.debug('networkCaseUrl>>>>>>>'+networkCaseUrl);
                return networkCaseUrl;
            }
            catch(Exception ex){
                system.debug('Exception+++'+ex+' '+ex.getlineNumber());
                String errorMsg = ex.getMessage();
                throw new AuraHandledException(errorMsg);
                //return 'Some error occured. Please contact system admin.';
            }
        }
        else{
            String errorMsg = 'Please input data to create a case.';
            throw new AuraHandledException(errorMsg);
        }
    } 
    public static string getRequestDetailsFormattedInString(RMARequestWrapper rmaRequest){
        string allrequests ='';
        if(rmaRequest!=null){
            if(rmaRequest.req1!=null){
                allrequests += formEachRequest(rmaRequest.req1,1);
            }
            if(rmaRequest.req2!=null){
                allrequests += formEachRequest(rmaRequest.req2,2);
            }
            if(rmaRequest.req3!=null){
                allrequests += formEachRequest(rmaRequest.req3,3);
            }
            if(rmaRequest.req4!=null){
                allrequests += formEachRequest(rmaRequest.req4,4);
            }
            if(rmaRequest.req5!=null){
                allrequests += formEachRequest(rmaRequest.req5,5);
            }
            if(rmaRequest.req6!=null){
                allrequests += formEachRequest(rmaRequest.req6,6);
            }
            if(rmaRequest.req7!=null){
                allrequests += formEachRequest(rmaRequest.req7,7);
            }
            if(rmaRequest.req8!=null){
                allrequests += formEachRequest(rmaRequest.req8,8);
            }
            if(rmaRequest.req9!=null){
                allrequests += formEachRequest(rmaRequest.req9,9);
            }
            if(rmaRequest.req10!=null){
                allrequests += formEachRequest(rmaRequest.req10,10);
            }
        }
        return allrequests;
    }
    public static string formEachRequest(Request req, Integer no){
        string reqDetails = '';
        if(string.isNotBlank(req.serial)){
            reqDetails += 'Serial # : '+req.serial+'\n';
        }
        if(string.isNotBlank(req.model)){
            reqDetails += 'Model # : '+req.model+'\n';
        }
        if(string.isNotBlank(req.description)){
            reqDetails += 'Description of Problem : '+req.description+'\n';
        }
        if(req.needbyDate!=null){
            reqDetails += 'Need by Date : '+string.valueOf(req.needbyDate)+'\n';
        }
        if(req.reqanEstimate){
            reqDetails += 'Require a repair estimate? : yes \n';
        }
        if(req.needaBox){
            reqDetails += 'Need a Box? : yes \n';
        }
        if(string.isNotBlank(reqDetails)){
            reqDetails = 'Request '+no+'\n'+reqDetails;
        }
        return reqDetails;
    }
    @AuraEnabled
    public static Case GetCaseRecord(Id CaseId){
        try {
            return [select id,AccountId,Account.Name,ContactId,Contact.Name,Customer_PO__c,RMA__c,RMA_Shipping_Address__c,Return_For__c,Request_Details__c,Is_Business__c,Is_Residential__c,Bill_to_Address__c from case where id =: CaseId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void SaveCaseRecord(Case caseRec){
        try {
            database.update(caseRec,false);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    // Method to fetch lookup search result   
    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName) {    
        List < sObject > returnList = new List < sObject > ();

        string sWildCardText = '%' + searchKey + '%';
        string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Name Like : sWildCardText order by lastmodifieddate DESC LIMIT 5';
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    // Method to fetch lookup default value 
    @AuraEnabled
    public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
        string sRecId = recordId;    
        string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
        for (sObject obj: database.query(sQuery)) {
            return obj;
        }
        return null;
    }
    public class RMARequestWrapper{
        @AuraEnabled
        public string contactName{get;set;}
        @AuraEnabled
        public string accountName{get;set;}
        @AuraEnabled
        public string contactId{get;set;}
        @AuraEnabled
        public string accountId{get;set;}
        @AuraEnabled
        public Address billingAddress{get;set;}
        @AuraEnabled
        public Address rmaShippingAddress{get;set;} 
        @AuraEnabled
        public boolean business{get;set;}
        @AuraEnabled
        public boolean residential{get;set;}
        @AuraEnabled
        public boolean reqanEstimate{get;set;}
        @AuraEnabled
        public boolean needaBox{get;set;}
        @AuraEnabled
        public string customerPO{get;set;} 
        @AuraEnabled
        public string returnFor{get;set;} 
        @AuraEnabled
        public String rmaContactName{get;set;} 
        @AuraEnabled
        public string rmaContactPh{get;set;}
        @AuraEnabled
        public Request req1{get;set;}
        @AuraEnabled
        public Request req2{get;set;}
        @AuraEnabled
        public Request req3{get;set;}
        @AuraEnabled
        public Request req4{get;set;}
        @AuraEnabled
        public Request req5{get;set;}
        @AuraEnabled
        public Request req6{get;set;}
        @AuraEnabled
        public Request req7{get;set;}
        @AuraEnabled
        public Request req8{get;set;}
        @AuraEnabled
        public Request req9{get;set;}
        @AuraEnabled
        public Request req10{get;set;}
    }
    public class Request{
        @AuraEnabled
        public string serial{get;set;} // Serial__c
        @AuraEnabled
        public string model{get;set;} // Model__c
        @AuraEnabled
        public string description{get;set;} //Description
        @AuraEnabled
        public date needbyDate{get;set;} //Need_By_Date__c
        @AuraEnabled
        public boolean reqanEstimate{get;set;}
        @AuraEnabled
        public boolean needaBox{get;set;}
    }
    public class Address{
        @AuraEnabled
        public string street{get;set;}
        @AuraEnabled
        public string city{get;set;}
        @AuraEnabled
        public string state{get;set;}
        @AuraEnabled
        public string country{get;set;}
        @AuraEnabled
        public string postalCode{get;set;}
    }
}