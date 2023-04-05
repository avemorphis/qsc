@isTest
global class MockExternalRecordResponseGenerator implements HttpCalloutMock
{
	global static HTTPResponse respond(HTTPRequest req) 
    {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Order_Number__c":"11273835","Id":"x03030000004vc5AAA"}');
        res.setStatusCode(200);
        return res;
    }
}