//=================================================================================================================
//  Object: OrderTriggerHandler.cls
//  Company: Think AI
//  Author: Anand Vaidya
// Comment: This class is used to make callout to NFR API when the Order status is changed from Draft to Activated.
//=================================================================================================================
//          Date            Purpose
// Changes: 12/22/2020      Initial Version
//=================================================================================================================
public class OrderTriggerHandler {
    // Class Variable Declarations
    public static final String STATUS_DRAFT = 'Draft';
    public static final String STATUS_ACTIVATED = 'Activated';
    
    /**************************************************************************************************************
    filterOrders
    Method to filter order records whose status is changed from Draft to Activated.
    
    ---------------------------------------------------------------------------------------------------------------
    @param    newOrderList   List of new version of Order records(Trigger.new)
	@param 	  orderOldMap	 Map of old version of Order recors(Trigger.oldMap)
    @return   void
    **************************************************************************************************************/
    public static void filterOrders(List<Order> newOrderList, Map<Id, Order> orderOldMap) {
        //Variable Declarations
        List<Order> filteredOrderList = new List<Order>();
        
        // Iterate over new version of Orders
        for(Order orderRecord: newOrderList) {
            // Check if the Order status is changed from "Draft" to "Activated"
            if(!orderOldMap.isEmpty() && STATUS_DRAFT.equalsIgnoreCase(orderOldMap.get(orderRecord.Id).Status) &&
               STATUS_ACTIVATED.equalsIgnoreCase(orderRecord.Status)) {
                   filteredOrderList.add(orderRecord);
               } // End of if
        } // End of for    
        
        if(!filteredOrderList.isEmpty()) {
            // Call method in order to make callout
            addOrderToNFR(JSON.serialize(filteredOrderList));
        }
    }
    /**************************************************************************************************************
    getNFRAPISetting
    Method to fetch the NFP API custom setting record.
    
    ---------------------------------------------------------------------------------------------------------------
    @param    instanceName   Record name of NFP API custom setting
    @return   NFR_API__c
    **************************************************************************************************************/
    public static NFR_API__c getNFRAPISetting(String instanceName) {
        // Variable Declarations
        NFR_API__c nfrApiSettingRecord = NFR_API__c.getInstance(instanceName);
        return nfrApiSettingRecord;
    }
    /**************************************************************************************************************
    addOrderToNFR
    Method to make callout to NFR API to add the order request.
    
    ---------------------------------------------------------------------------------------------------------------
    @param    newOrderListString   JSON string that contains Order data.
    @return   void
    **************************************************************************************************************/
    @future(callout=true)
    public static void addOrderToNFR(String newOrderListString) {
        
        List<Order> newOrderList = (List<Order>)JSON.deserialize(newOrderListString, List<Order>.class);
        NFR_API__c nfrApiSettingRecord =  getNFRAPISetting('Order Success Trigger');
        String accessToken = getNFRAccessToken(nfrApiSettingRecord.Username__c
                                               , nfrApiSettingRecord.Password__c
                                               , nfrApiSettingRecord.Token_url__c);
        System.debug('accessToken ------ '+ accessToken);
        
        if(String.isNotBlank(accessToken)) {
            
         	for(Order orderObj : newOrderList) {
            
                makeCalloutToNFR(accessToken
                                 , nfrApiSettingRecord.EndPoint_url__c
                                 , orderObj
                                );
            }   
        }
    }
    /**************************************************************************************************************
    getNFRAccessToken
    Method to fetch the access token for NFR API callout.
    
    ---------------------------------------------------------------------------------------------------------------
    @param    username       Username for callout that is made to get the access token.
	@param    password       Password for callout that is made to get the access token.
	@param    tokenEndpoint  Endpoint URL for callout that is made to get the access token.
    @return   String
    **************************************************************************************************************/
    public static String getNFRAccessToken(String username, String password, String tokenEndpoint) {
        
        // Preaparing HTTP Request
        HTTP h = new HTTP();
        HTTPRequest reqObj = new HTTPRequest();
        reqObj.setEndpoint(tokenEndpoint);
        reqObj.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        reqObj.setBody('username='+username+'&password='+password+'&grant_type=password');
        reqObj.setMethod('POST'); 
        //Web Callout
        HTTPResponse response = h.send(reqObj);
        Map < String,Object > resultsMap = (Map < String, Object > )JSON.deserializeUntyped(response.getBody());
        System.debug('resultsMap:--> ' + resultsMap.get('access_token'));
        String accessToken = String.valueOf(resultsMap.get('access_token'));
        return accessToken;
    }
    /**************************************************************************************************************
    makeCalloutToNFR
    Method to fetch the access token for NFR API callout.
    
    ---------------------------------------------------------------------------------------------------------------
    @param    accessToken    Access token for callout that is made to post the order request.
	@param    endpoint       Endpoint URL for callout that is made to post the order request.
	@param    orderObj       Order record for which the callout is made.
    @return   void
    **************************************************************************************************************/
    public static void makeCalloutToNFR(String accessToken, String endpoint, Order orderObj) {
	
		System.debug('accessToken ===== ' +accessToken);    
        System.debug('endpoint ===== ' +endpoint);    
		System.debug('orderObj ===== ' +orderObj);
        Http httpObj = new Http();
        HttpRequest httpReqObj = new HttpRequest();
        httpReqObj.setHeader('Content-Type', 'application/json');
        httpReqObj.setHeader('Authorization', 'Bearer ' + accessToken);
        httpReqObj.setMethod('POST');
        httpReqObj.setEndpoint(endpoint);
        string RequestType = 'ReflectProcessSalesOrder';
        if(orderObj.Type=='TPP')
        {
        RequestType = 'TPPProcessSalesOrder';
        }
        NFRCalloutWrapper nfrCalloutWrapperObj = new NFRCalloutWrapper(RequestType, String.valueOf(orderObj.Id), String.valueOf(orderObj.CreatedDate), String.valueOf(orderObj.EffectiveDate));
        
        String nfrBody = JSON.serialize(nfrCalloutWrapperObj);
        
        System.debug('nfrBody ========== ' + nfrBody);
        httpReqObj.setBody(nfrBody);
        
        HttpResponse httpRespObj = httpObj.send(httpReqObj);
        System.debug('httpRespObj ======= ' + httpRespObj.getBody());
    }
    
    public class NFRCalloutWrapper {
        
        public String RequestType;
        public String OrderId;
        public String Created;
        public String OrderStartDate;
        
        public NFRCalloutWrapper(String RequestType, String OrderId, String Created, String OrderStartDate) {
            
            this.RequestType = RequestType;
            this.OrderId = OrderId;
            this.Created = Created;
            this.OrderStartDate = OrderStartDate;
        }
    }
}