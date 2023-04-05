/*
 * Mock class for HTTP GET requests
 */
@isTest
global class X7sRepoAPIHTTPGETMock implements HttpCalloutMock {
    
    global Map<String, String> properties = new Map<String,String>();

    global HTTPResponse respond(HTTPRequest req) {
        // Only process GET requests
        System.assertEquals('GET', req.getMethod(), 'Mock class can only process GET requests');
        
        Integer responseStatusCode = 200;
        String responseStatus = 'OK';
        String endpoint = req.getEndpoint();
        String responsePayload = properties.get(endpoint);
        if(String.isEmpty(responsePayload)) {
            responseStatusCode = 404;
            responseStatus = 'Not Found';
        }

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(String.isNotEmpty(responsePayload)) {
            res.setBody(responsePayload);
        }
        res.setStatusCode(responseStatusCode);
        res.setStatus(responseStatus);
        return res;
    }

}