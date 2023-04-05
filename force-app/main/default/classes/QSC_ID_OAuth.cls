//========================================================================
//  Object: QSC_ID_OAuth
// Company: Dysem
//  Author: Barney Young Jr.
// Comment: Class to extend Auth.AuthProviderPluginClass abstract class
//          to create a custom authentication provider for SSO
//========================================================================
//          Date            Purpose
// Changes: 12/10/2017      Initial Version
//          06/24/2018      Revision to handle QSC User IS API Payload  
//========================================================================

global class QSC_ID_OAuth extends Auth.AuthProviderPluginClass {
    

    //Class Variables From Custom Metadata
    private String key; 
    private String secret;   
    private String authUrl;
    private String userAPIUrl; 
    private String authProv;
    private String accessTokenUrl;
    private String aProvider;
    private String redirectUrl;

    //Class Callback Variables
    private String access_token;
    private String token_type;
    public Integer expires_in;
    private String refresh_token;
    private String ret_scope;
    private Integer created_at;
    private String owner_id;
    private String owner_type;
    
    //Custom Metadata Object
    private String customMetadataTypeApiName;

    //Get Custom Metadata Type Values
    global String getCustomMetadataType() {
        
        //Get Custom Label
        customMetadataTypeApiName = System.Label.Custom_Metadata_Object;

        return customMetadataTypeApiName;
    } 

    
    /******************************************************************************************************************************************************
    Initiate
    Method to create request URL to get initial authorization
    -------------------------------------------------------------------------------------------------------------------------------------------------------
    @param    authProviderConfiguration     QSCID Auth Provider 
    @param    stateToPropagate              state parameter to hold a value for verification
    @return   Request URL                   Initial Request to provide Access Token
    ******************************************************************************************************************************************************/
    global PageReference initiate(Map<string,string> authProviderConfiguration, String stateToPropagate) { 
       
        //Get QSCId AuthProvider Values
        String authUrl = authProviderConfiguration.get('Auth_Url__c'); 
        String key = authProviderConfiguration.get('Consumer_Key__c'); 
        String redirectUrl = authProviderConfiguration.get('redirectUrl__c');
        
        // Build request URL
        String url = authUrl + '?client_id='+ key +'&redirect_uri='+ redirectUrl + '&state=' + stateToPropagate + 
                    '&response_type=code&grant_type=authorization_code'; 
            
        return new PageReference(url); 
    }


    /******************************************************************************************************************************************************
    handleCallback
    Method to process Authorization response and to perform callback
    -------------------------------------------------------------------------------------------------------------------------------------------------------
    @param    authProviderConfiguration     QSCID Auth Provider 
    @param    state                         state parameter to hold a value for verification
    @return   AuthProviderTokenResponse     Callback to get refresh token
    ******************************************************************************************************************************************************/
    global Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState state ) {
        
        //Get QSCId AuthProvider Values
        key = authProviderConfiguration.get('Consumer_Key__c'); 
        secret = authProviderConfiguration.get('Consumer_Secret__c'); 
        accessTokenUrl = authProviderConfiguration.get('Access_Token_Url__c'); 
        aProvider = authProviderConfiguration.get('Name'); 
        redirectUrl = authProviderConfiguration.get('redirectUrl__c');

        //Get Code and State from URL
        Map<String,String> queryParams = state.queryParameters;
        String code = queryParams.get('code');
        String sfState = queryParams.get('state');

        //Build Body with JSON
        JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField ('client_id', key);
            gen.writeStringField ('client_secret', secret);
            gen.writeStringField ('grant_type', 'authorization_code');
            gen.writeStringField ('code', code);
            gen.writeStringField ('redirect_uri', redirectUrl);
            gen.writeEndObject();
        String coBody = gen.getAsString();

        //Build Callout Request
        HttpRequest req = new HttpRequest();
            String callbackURL = accessTokenUrl;
            req.setEndpoint(callbackURL);
            req.setHeader('Content-Type','application/json'); 
            req.setMethod('POST');
            req.setBody(coBody);

        //Callout
        Http callBack = new Http();
        HttpResponse res = callBack.send(req);
        String responseBody = res.getBody();
        System.debug ('Response:  ' + responseBody);

        //Handle Redirect - Probably not needed but what the heck...
        boolean redirect = false;
        if(res.getStatusCode() >=300 && res.getStatusCode() <= 307 && res.getStatusCode() != 306) {
            do {
                redirect = false; // reset the value each time
                String loc = res.getHeader('Location'); // get location of the redirect
                if(loc == null) {
                    redirect = false;
                    continue;
                }
                req = new HttpRequest();
                req.setEndpoint(loc);
                req.setMethod('POST');
                res = callBack.send(req);
                if(res.getStatusCode() != 500) { // 500 = fail
                    if(res.getStatusCode() >=300 && res.getStatusCode() <= 307 && res.getStatusCode() != 306) {
                        redirect= true;
                    }
                }
            } while (redirect && Limits.getCallouts() != Limits.getLimitCallouts());
        }

        //Parse Response
        parseResponse pr = parseResponse.parse(responseBody);
            //Populate Response Variables
            access_token = pr.access_token;
            token_type = pr.token_type;
            ret_scope = pr.scope;
            expires_in = pr.expires_in;
            refresh_token = pr.refresh_token;
            created_at = pr.created_at;
            owner_id = pr.owner_id;
            owner_type = pr.owner_id;

        //Return Tokem Response
        return new Auth.AuthProviderTokenResponse(aProvider, access_token, 'refreshToken', sfState);
    }
    //NOTE:  Refresh not needed because named credentials are not being used


    /******************************************************************************************************************************************************
    getUserInfo
    Method to process call to QSC ID user API to get user information for Auth.UserData callout
    -------------------------------------------------------------------------------------------------------------------------------------------------------
    @param    authProviderConfiguration     QSCID Auth Provider 
    @param    response                      Refresh Token
    @return   Auth.UserData                 Process QSCID_regHandler (Registration Handler)
    ******************************************************************************************************************************************************/
    global Auth.UserData getUserInfo(Map<string,string> authProviderConfiguration, Auth.AuthProviderTokenResponse response) { 
        
        //Build Callout to User API
        String token = response.oauthToken; 
        HttpRequest req = new HttpRequest(); 
        userAPIUrl = authProviderConfiguration.get('API_User_Url__c');
        req.setHeader('Authorization', 'Bearer ' + token); 
        req.setEndpoint(userAPIUrl); 
        req.setHeader('Content-Type','application/json'); 
        req.setMethod('GET'); 

        //Make Callout to User API
        Http http = new Http(); 
        HTTPResponse res = http.send(req); 
        String responseBody = res.getBody(); 
		System.debug ('getUserInfo Request:  ' + req);
		System.debug ('getUserInfo Response:  ' + responseBody);

        //remove hyphens
        String byResponse = responseBody.replace('-','_');

        //Parse Response
        parseAuthUserData pAUD = parseAuthUserData.parse(byResponse);

        //Process Group Slugs
        String GrpSlugs;
        //Check if Group Slugs are populated
        if(!pAUD.data.attributes.group_slugs.isEmpty()) {
                GrpSlugs = String.join(pAUD.data.attributes.group_slugs,'; '); // Semi-colon delimited
                GrpSlugs = GrpSlugs.replace('_','-');  //replace hyphens
        }
        
        //Populate Auth.UserData and other Variables
        String Qid = pAUD.data.id;
        String fname = pAUD.data.attributes.first_name; 
        String lname = pAUD.data.attributes.last_name; 
        String fullname = fname + ' ' + lname; 
        String uEmail = pAUD.data.attributes.email; 
         system.debug('User Email: '+uEmail);
        String link = userAPIUrl;
        String locale = System.label.UserData_Locale;
        String Provider = System.label.UserData_Provider;  
        String siteLoginUrl = null;  //Null because site login is disabled
        String phone =  pAUD.data.attributes.phone;
        String account_name = pAUD.data.attributes.account_name;
        String company_name = pAUD.data.attributes.company_name;
        String company_email = pAUD.data.attributes.company_email;
        system.debug('Company Email: '+company_email);
        String account_number = pAUD.data.attributes.account_number;

        //Replace Hyphens
        if(String.isNotBlank(phone)) { phone = phone.replace('_', '-'); }
        if(String.isNotBlank(account_name)) { account_name = account_name.replace('_', '-'); }
        if(String.isNotBlank(company_name)) { company_name = company_name.replace('_', '-'); }
        //if(String.isNotBlank(company_email)) { company_email = company_email.replace('_', '-'); }
        if(String.isNotBlank(account_number)) { account_number = account_number.replace('_', '-'); }
        if(String.isNotBlank(fullname)) { fullname = fullname.replace('_', '-'); }
        if(String.isNotBlank(Qid)) { Qid = Qid.replace('_', '-'); }

        //Build Map with Additional QSCId Values
        Map<String,String> qscidMap = new Map<String,String>(); 
        qscidMap.put('email_opt_in', pAUD.data.attributes.email_opt_in); 
        qscidMap.put('phone', phone); 
        qscidMap.put('salesforce_identifier', pAUD.data.attributes.salesforce_identifier); 
        qscidMap.put('company_name', company_name); 
        qscidMap.put('company_email', company_email); 
        qscidMap.put('account_number', account_number); 
        qscidMap.put('account_name', account_name); 
        qscidMap.put('group_slugs', GrpSlugs); 
        qscidMap.put('country_code', pAUD.data.attributes.country_code); 
        qscidMap.put('country', pAUD.data.attributes.country);

        //Call Registration Handler
        return new Auth.UserData(Qid, fname, lname, fullname, uEmail, link, uEmail, locale, Provider, siteLoginUrl, qscidMap); 
    }

}