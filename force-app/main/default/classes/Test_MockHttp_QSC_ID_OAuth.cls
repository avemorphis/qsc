//========================================================================
//  Object: Test_MockHttp_QSC_ID_OAuth
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: Class to add mock http response functionality to the main class QSC_ID_OAuth
//========================================================================
//          Date            Purpose
// Changes: 4/29/2020       Initial Version
//========================================================================
@isTest
global class Test_MockHttp_QSC_ID_OAuth implements HttpCalloutMock {
    
    //Loop counter will be usefull when we need to test loop callouts
    Integer loopCounter = 0;
    
    /******************************************************************************************************************************************************
    respond
    Method to create an HTTP Response
    -------------------------------------------------------------------------------------------------------------------------------------------------------
    @return   HTTPResponse          Response contains Body json with values, headers, and  status code
    ******************************************************************************************************************************************************/
    global HTTPResponse respond(HTTPRequest req) {   

        // Lets create a fake response json type
        HttpResponse res = new HttpResponse();

        //We set the content type to json
        res.setHeader('Content-Type', 'application/json');
        
        //Json construction section, based on the endpoint
        String jsonResponse = '';
        if(req.getEndpoint()==Test_QSC_ID_OAuth.ACCESS_TOKEN_URL){jsonResponse = jsonHandleCallback();}
        else if(req.getEndpoint()==Test_QSC_ID_OAuth.API_USER_URL){jsonResponse = jsonGetUserInfo();}
        
        //Add the fake response to the body, and return it
        res.setBody(jsonResponse); 

        //If is the the loop counter is les than 2 the the status code will be 300, so we can test loops
        Integer statusCode = loopCounter == 3 ? 200 : 300;

        //add one to the countes
        loopCounter++ ;
        res.setStatusCode(statusCode);
        if(loopCounter < 2){res.setHeader('Location', 'Location');}

        //return the result
        return res;
    }    
    
    
    /******************************************************************************************************************************************************
    jsonHandleCallback
    Method to create a json for the handleCallback method
    -------------------------------------------------------------------------------------------------------------------------------------------------------
    @return   String            Response contains json fake response
    ******************************************************************************************************************************************************/    
    public static string jsonHandleCallback() {

        String jsonResponse = '{';

        //Json of the fake response
        jsonResponse+='"access_token":"'+Test_QSC_ID_OAuth.OAUTH_TOKEN+'",';
        jsonResponse+='"token_type":"bearer",';
        jsonResponse+='"expires_in":15533126,';
        jsonResponse+='"refresh_token":"'+Test_QSC_ID_OAuth.REFRESH_TOKEN+'",';
        jsonResponse+='"scope":"user",';
        jsonResponse+='"created_at":1530161423,';
        jsonResponse+='"owner_id":"f0000d0d-0000-0000-9fb1-9d021221370d",';
        jsonResponse+='"owner_type":"users"';
        jsonResponse+='}';
        return jsonResponse;
    }
    

    /******************************************************************************************************************************************************
    jsonGetUserInfo
    Method to create a json for the getUserInfo method
    -------------------------------------------------------------------------------------------------------------------------------------------------------
    @return   String            Response contains json fake response
    ******************************************************************************************************************************************************/    
    public static string jsonGetUserInfo() {
        String jsonResponse = '{';
        //Json of the fake response
        jsonResponse+='"data":{';  
        jsonResponse+='"id":"af236db7-be79-4fe0-9083-13dcebaf07df",';
        jsonResponse+='"type":"users",';
        jsonResponse+='"attributes":{';
        jsonResponse+='"first_name":"'+Test_QSC_ID_OAuth.FIRST_NAME+'",';
        jsonResponse+='"last_name":"'+Test_QSC_ID_OAuth.LAST_NAME+'",';
        jsonResponse+='"email":"'+Test_QSC_ID_OAuth.EMAIL_ADDRESS+'",';
        jsonResponse+='"email_opt_in":false,';
        jsonResponse+='"phone":"4044044434",';
        jsonResponse+='"salesforce_identifier":"0032100000RZvThAAL",';
        jsonResponse+='"company_name":"Unspecified",';
        jsonResponse+='"company_email":null,';
        jsonResponse+='"account_number":"02011977",';
        jsonResponse+='"account_name":"Sample Account",';
        jsonResponse+='"group_slugs":["1","2"],';
        jsonResponse+='"country_code":"US"';
        jsonResponse+='},';
        jsonResponse+='"relationships":{';  
        jsonResponse+='"primary_address":{';  
        jsonResponse+='"data_z":{';  
        jsonResponse+='"id":"b350e0e3",';
        jsonResponse+='"type":"addresses"';
        jsonResponse+='}';
        jsonResponse+='}';
        jsonResponse+='}';
        jsonResponse+='},';
        jsonResponse+='"included":[';  
        jsonResponse+='{';  
        jsonResponse+='"id":"f9843dfd_4706_4442_9fb1_9d021221370d",';
        jsonResponse+='"type":"addresses",';
        jsonResponse+='"attributes":{';  
        jsonResponse+='"address_1":"PO Box 1",';
        jsonResponse+='"address_2":"",';
        jsonResponse+='"city":"Atlanta",';
        jsonResponse+='"state":"GA",';
        jsonResponse+='"postal_code":"30305",';
        jsonResponse+='"country":""';
        jsonResponse+='}';
        jsonResponse+='}';
        jsonResponse+=']';
        jsonResponse+='}';
        return jsonResponse;
    }    
}