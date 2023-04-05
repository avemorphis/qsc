//=================================================================================================================
//  Object: methods_Case.cls
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: Case Methods Class
//=================================================================================================================
//          Date            Purpose
// Changes: 07/16/2019      Initial Version
//          08/05/2019      Modified to look at Custom Metadata Object.  
//=================================================================================================================


public class methods_Case  {
    
    /**************************************************************************************************************
checkContactDupe
Method to check if a Case Created from an email is a bounced email

Email Subject is Checked based on values in Bounced Email Messages Custom Metadata Object

---------------------------------------------------------------------------------------------------------------
@param    cIDs   Set of Case IDs to be checked if they are from bounced emails
@return   void
**************************************************************************************************************/
    public static void checkEmailBounce(List<Case> newCases) {
        
        //Collections
        Set<String> setAllName = new Set<String>();
        Map<String,String> messageMap = new Map<String,String>();
        String cSubject;
        
        //Populate Collections
        for(Bounced_Email_messages__mdt obj : [Select DeveloperName,Error_Message__c,Email_Subject__c from Bounced_Email_messages__mdt]){
            setAllName.add(obj.Email_Subject__c.toupperCase());
            messageMap.put(obj.Email_Subject__c.toupperCase(),obj.Error_Message__c);
        }
        
        //Cycle through New Cases
        for(Case nCase : newCases) {
            
            //Check if Case Originated from Email
            if(nCase.Origin == 'Email') {
                
                //1.  If Subject is Blank
                if(String.isEmpty(nCase.Subject)) {
                    nCase.Subject.addError(System.Label.Duplicate_Subject_Text);
                }
                
                //2.  Check for Bounce Conditions
                if(String.isNotEmpty(nCase.Subject)) {
                    
                    //Convert to All Upper
                    cSubject = nCase.Subject.toUpperCase();
                    
                    //Cycle through set of bounced email subjects
                    for(String bSubjects : setAllName){
                        
                        //Subject contains email subject
                        if(cSubject.contains(bSubjects)){
                            //Raise Error
                            nCase.Subject.addError(messageMap.get(bSubjects));
                        }
                    }
                }
            }
        }
    }
    
    /**************************************************************************************************************
callWebApi
Method to call webAPI
Developed By ThinkAI corp
Checks Opportunity status and calls a WebAPI

---------------------------------------------------------------------------------------------------------------
@param    caseIds   Set of Case IDs to be checked
@param    accountIds   Set of Account IDs to get 
@return   void
**************************************************************************************************************/
    @future (callout=true)
    public static void callWebApi(Set<Id> caseIds,Set<Id> accountIds, String nfrCustomSettingString){ 
        
        //Variables
        string opportunityTypeId;
        string opportunityStatus;
        Boolean flag = false;
        
        //Populate collection
        List<filterCriteriaForCase__c> opportunityTypes = [Select Record_type_Id__c,Record_type_name__c,Opportunity_status__c from filterCriteriaForCase__c where Object_name__c='Opportunity'];
        
        //Cycle through filterCriteriaForCase__c
        for(filterCriteriaForCase__c opportunitytype : opportunityTypes)
        {
            
            //Check recordType id and status is not null
            if(opportunitytype.Record_type_Id__c != null && opportunitytype.Opportunity_status__c != null){
                opportunityTypeId = opportunitytype.Record_type_Id__c;
                opportunityStatus=opportunitytype.Opportunity_status__c;
            }
        }
        
        //Populate collection
        List<Account> accountList =  [SELECT Id, name, Attributes__c, (SELECT Id FROM Cases) FROM 
                                      Account WHERE Id IN : accountIds];
        
        // cycle thorygh Account list
        for(Account acc : accountList){
            
            // Match account Attribute
            if(acc.Attributes__c.contains('Reflect NFR Extension Approved')){
                flag = true;
            }
        }
        System.debug('Calling API');
        
        //Populate collection
        List<Opportunity> opptunityList =  [SELECT Id, name, Subscription_ID__c FROM Opportunity WHERE AccountId IN : accountIds and RecordTypeId=:opportunityTypeId and status__c=:opportunityStatus];
        
        //Variable
        string SubscriptionID;
        //Cycle thorugh opportunity list
        for(Opportunity opp : opptunityList){
            SubscriptionID = opp.Subscription_ID__c;
        }
        
        //Check subscription id is not blank and flag
        if(!string.isBlank(SubscriptionID) && flag == true)
        {
            //Variable
            string endpointurl;
            string tokenurl;
            string password;
            string username;
			
            // Deserialize the NFR custom setting JSON string
			NFR_API__c nfrCustomSettingRecord = (NFR_API__c)JSON.deserialize(nfrCustomSettingString, NFR_API__c.class);    
            
            endpointurl = nfrCustomSettingRecord.EndPoint_url__c;
            tokenurl = nfrCustomSettingRecord.Token_url__c;
            password = nfrCustomSettingRecord.Password__c;
            username = nfrCustomSettingRecord.Username__c;
            
            // Commented below code
            /*
            //Populate collection
            List<NFR_API__c> nfrdetails=[select EndPoint_url__c,Password__c,Token_url__c,Username__c from NFR_API__c];
            
            //cycle through list of NFR_API__c
            for(NFR_API__c nfrdetail : nfrdetails)
            {
                endpointurl=nfrdetail.EndPoint_url__c;
                tokenurl=nfrdetail.Token_url__c;
                password=nfrdetail.Password__c;
                username=nfrdetail.Username__c;
            }
			*/
            
            // Preaparing HTTP Request
            HTTP h = new HTTP();
            HTTPRequest r = new HTTPRequest();
            r.setEndpoint(tokenurl);
            r.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            r.setBody('username='+username+'&password='+password+'&grant_type=password');
            r.setMethod('POST'); 
            //Web Callout
            HTTPResponse response = h.send(r);
            Map < String,Object > resultsMap = (Map < String, Object > )JSON.deserializeUntyped(response.getBody());
            System.debug('resultsMap:--> ' + resultsMap.get('access_token'));
            object Token = resultsMap.get('access_token');
            HTTP hUpdate = new HTTP();
            HTTPRequest reqUpdate = new HTTPRequest();
            reqUpdate.setEndpoint(endpointurl);
            reqUpdate.setHeader('Content-Type','application/json');  
            reqUpdate.setHeader('Authorization','Bearer '+Token);
            reqUpdate.setMethod('POST');
            String body = '{"SubscriptionID":"'+SubscriptionID+'"}';
            reqUpdate.setBody(body);
            httpResponse responseUpdate = hUpdate.send(reqUpdate);
            System.debug('response:--> ' + responseUpdate.getBody());
        }
    }
    
    /**************************************************************************************************************
callAddRequestQueue
Method to call Request queue API
Developed By ThinkAI corp on 23 July 2020
calls request queue API 

---------------------------------------------------------------------------------------------------------------
@param    accountId   Id of the account
@param    contactEmail   Email of the admin
@param    queueRequestUrl   Url to be used as endpoint
@return   void
**************************************************************************************************************/
    @future (callout=true)
    public static void callAddRequestQueue(Id accountId, String contactEmail, String queueRequestUrl, String functionKey){
        // Preaparing HTTP Request
        HTTP h = new HTTP();
        HTTPRequest r = new HTTPRequest();
        r.setEndpoint(queueRequestUrl);
        r.setHeader('x-functions-key', functionKey);
        r.setBody('{ "Source":"Salesforce", "TemplateName":"NFR5: Denied Extended Trial", "RequestType":"DeniedExtendedTrial","RequestCategory":"Emails", "CustomerEmail":"'+contactEmail+'", "AccountId":"'+accountId+'" }');
        r.setMethod('POST');
        //Web callout
        HTTPResponse response = h.send(r);
        system.debug('Response'+response.getBody());
    }
    
    /*public static void updateAccountAttribute(Set<Id> accountIds){
List<Account> accountList =  [SELECT Id, name, Attributes__c, (SELECT Id FROM Cases) FROM 
Account WHERE Id IN : accountIds]; 
for(Account acc : accountList){
acc.Attributes__c = 'NFR Approved';
}
update accountList;
}*/
}