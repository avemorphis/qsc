//=================================================================================================================
//  Object : NFRMockGenerator.cls
//  Company: Think AI
//  Author : Anand Vaidya
//  Comment: This class is used to generate mock response for NFR callout.
//=================================================================================================================
//          Date            Purpose
// Changes: 01/03/2021      Initial Version
//=================================================================================================================
@isTest
global class NFRMockGenerator implements HttpCalloutMock {
    Map<String, String> responseBodyMap = new Map<String, String>{'token'=>'{"access_token":"abcd"}', 
                                                                  'AddOrderRequest'=>'{"Result":true,"Message":"Success","Data":{"message":"Record successfully added to request Queue 0"}}'};
    
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(req.getEndpoint().contains('token')) {
            res.setBody(responseBodyMap.get('token'));
        } else if(req.getEndpoint().contains('AddOrderRequest')) {
            res.setBody(responseBodyMap.get('AddOrderRequest'));
        }
        
        res.setStatusCode(200);
        return res;
    }
}