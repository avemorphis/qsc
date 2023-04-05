global class mockNfrUrl implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        if(request.getEndpoint()=='https://web-api02.qsc.com/token')
        {
            response.setHeader('contentType', 'application/json');
            response.setBody('{"access_token": "b9k3Dc-U9YDPZv588vVHAGY9F5X7IOriq0zAmilYvLdC7UwxUaYW_szRgURCmf2ZjOO_XLlumDGL8LLR_qco2ztC77g8FopZiC5xDbcaDXvrnQ_zPNLAtkpLwrvfnZ48FW8KaJD5HJmVfKtVchu5KBiMjhaXaaG0NJ04bGXvY0sxVlKr-aoM7Esj-2aeNz74hkCEwgs6ouoOzX-EXFmYzHDxQj7SdNKxIr_rMh4PQuGfKig0NOE-oMqCwMUWYcBZ6khHzzZRlbwDJY_OS8qDr_ig1qCUUNaSds4BjjF1gSNwUaodowSkZSLYolVHJ0o4","token_type": "bearer","expires_in": 3599,"refresh_token": "W7s9ubDjuenO_syD7vqZSonUnYH-lxamWs1CqHo87IR4SfMEcsJGwsriKyPICMDsPlIXCFVmcTwflvMV9B9XbgDi7UjbJIcEuqV-5Qaf7jzazyRgqaUyqPmdvnlyqRKnsylRktIGP41ExFqPk-7ilIiMz6HXZyG2Yfc-DBB3wMSqePSEgpw60NrIg9BJysZgOPEdCn69EyAKl2kauH0uC1x3BpOJzN3kx9vLdoHqm5tCYGzkQnfhos6DfuNdmapQ0TA9JjMT1_cYhXtbI0mN6OS-z-ATfEtHY0jdmfgqKFgDIAVoFH3EDPvowZxEbWng"}');
            response.setStatusCode(200);
        }
        else if(request.getEndpoint()=='https://web-api02.qsc.com/api/Reflect/ExtendNFRDemoRequest')
        {
            response.setHeader('contentType', 'application/json');
            response.setBody('{"Result":true,"Message":"Extend NFR demo request submitted","Data":"RF0030505"}');
            response.setStatusCode(200);
        }
        return response;
    }
}