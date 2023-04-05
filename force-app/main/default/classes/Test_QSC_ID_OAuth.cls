//========================================================================
//  Object: Test_QSC_ID_OAuth
// Company: Young Technology Group
//  Author: Barney Young Jr
// Comment: Class to test the main class QSC_ID_OAuth
//========================================================================
//          Date            Purpose
// Changes: 4/29/2020       Initial Version
//========================================================================
@isTest
public class Test_QSC_ID_OAuth {

    //Static variables for support the testing methods.
    private static final String CONSUMER_KEY = 'ConsumerKey';
    private static final String STATE_TO_PROPOGATE = 'testing'; 
    private static final String AUTH_URL = 'http://www.test.com/authurl';  
    private static final String REDIRECT_URL = 'http://www.test.com/redirecturl'; 
    private static final String CONSUMER_SECRET = 'ConsumerSecret';
    private static final String NAME = 'Name';

    //The next variables are public, because we use them in the mock http
    public static final String ACCESS_TOKEN_URL = 'http://www.test.com/accesstokenurl';
    public static final String OAUTH_TOKEN = 'OAuthToken';
    public static final String REFRESH_TOKEN = 'refreshToken';
    public static final String API_USER_URL = 'http://www.test.com/apiuserurl';
    public static final String FIRST_NAME = 'FirstName';
    public static final String LAST_NAME = 'LastName';
    public static final String FULL_NAME = 'FullName';
    public static final String EMAIL_ADDRESS = 'Email@email.com';
    public static final String PROVIDER = 'Provider';
    

    /******************************************************************************************************************************************************
    setupAuthProviderConfig
    Method to Create a custom Auth provider , In the real life this would be onbtained by the Custom MetadataType
    -------------------------------------------------------------------------------------------------------------------------------------------------------
    @return   Map<String,String>            Map of values simulation of Custom Metadatype
    ******************************************************************************************************************************************************/
    private static Map<String,String> setupAuthProviderConfig() { 
    
        //Initialize a new String String Map
        Map<String,String> authProviderConfiguration = new Map<String,String>(); 
        
        //We put some variables that we will use in the methods
        authProviderConfiguration.put('Consumer_Key__c', CONSUMER_KEY); 
        authProviderConfiguration.put('Auth_Url__c', AUTH_URL);
        authProviderConfiguration.put('redirectUrl__c',REDIRECT_URL); 
        authProviderConfiguration.put('Consumer_Secret__c', CONSUMER_SECRET); 
        authProviderConfiguration.put('Access_Token_Url__c', ACCESS_TOKEN_URL); 
        authProviderConfiguration.put('Name', NAME); 
        authProviderConfiguration.put('State_c', STATE_TO_PROPOGATE); 
        authProviderConfiguration.put('API_User_Url__c', API_USER_URL); 
        
        return authProviderConfiguration; 
    } 
    

    /******************************************************************************************************************************************************
    testInitiateMethod
    Method to test the QSC_ID_OAuth_Class.initiate method
    -------------------------------------------------------------------------------------------------------------------------------------------------------
    ******************************************************************************************************************************************************/
    static testMethod void testInitiateMethod() { 
    
        //Initiate a Map Sting,String, we called the method setupAuthProviderConfig to get its values.
        Map<String,String> authProviderConfiguration = setupAuthProviderConfig();
        
        //Create a new instanse of the class QSC_ID_OAuth
        QSC_ID_OAuth QSC_ID_OAuth_Class = new QSC_ID_OAuth(); 
        
        //Construct a page reference URl, so we can compare the desired result with the actual result.
        PageReference expectedUrl = new PageReference(authProviderConfiguration.get('Auth_Url__c') + '?client_id='+ 
                                                      authProviderConfiguration.get('Consumer_Key__c') +'&redirect_uri='+ 
                                                      authProviderConfiguration.get('redirectUrl__c') + '&state=' + 
                                                      STATE_TO_PROPOGATE+'&response_type=code&grant_type=authorization_code'); 
                                                      
        //We start testing here
        test.startTest();
        
        //Call the method QSC_ID_OAuth_Class.initiate and save the result of the pagereference returned
        PageReference actualUrl = QSC_ID_OAuth_Class.initiate(authProviderConfiguration, STATE_TO_PROPOGATE); 
        
        //ASSERT We validate that the expected result is the actual result.
        System.assertEquals(expectedUrl.getUrl(), actualUrl.getUrl());
        
        //Get the name of the real customMetadataType, it is a label so it could change. that is why we wont do an assert of this one.
        QSC_ID_OAuth_Class.getCustomMetadataType();
        
        //Stop the test
        test.stopTest();
    }
    

    /******************************************************************************************************************************************************
    testHandleCallback
    Method to test the QSC_ID_OAuth_Class.handleCallback method
    -------------------------------------------------------------------------------------------------------------------------------------------------------
    ******************************************************************************************************************************************************/
    static testMethod void testHandleCallback() { 
    
        //Initiate a Map Sting,String, we called the method setupAuthProviderConfig to get its values.
        Map<String,String> authProviderConfiguration = setupAuthProviderConfig(); 
        
        //Create a new instanse of the class QSC_ID_OAuth
        QSC_ID_OAuth QSC_ID_OAuth_Class = new QSC_ID_OAuth(); 
        
        //We set a Mock for the HTTP response from the class Test_MockHttp_QSC_ID_OAuth
        Test.setMock(HttpCalloutMock.class, new Test_MockHttp_QSC_ID_OAuth()); 
    
        //Initialize and construction of Map<String,String> to put the query params for callback state
        Map<String,String> queryParams = new Map<String,String>(); 
        queryParams.put('code','code'); 
        queryParams.put('state',authProviderConfiguration.get('State_c')); 
        
        //Set the params to the callback state
        Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(null,null,queryParams); 
        
        //Starting the test 
        test.startTest();
        
        //Calling the QSC_ID_OAuth_Class.handleCallback method and getting a response
        Auth.AuthProviderTokenResponse actualAuthProvResponse = QSC_ID_OAuth_Class.handleCallback(authProviderConfiguration, cbState); 
        
        //Creating an expected response, so we can do the validation
        Auth.AuthProviderTokenResponse expectedAuthProvResponse = new Auth.AuthProviderTokenResponse(NAME, OAUTH_TOKEN, REFRESH_TOKEN, authProviderConfiguration.get('State_c')); 
        
        //Asserts of the values obtained by the response
        System.assertEquals(expectedAuthProvResponse.provider, actualAuthProvResponse.provider); 
        System.assertEquals(expectedAuthProvResponse.oauthToken, actualAuthProvResponse.oauthToken); 
        System.assertEquals(expectedAuthProvResponse.oauthSecretOrRefreshToken, actualAuthProvResponse.oauthSecretOrRefreshToken); 
        System.assertEquals(expectedAuthProvResponse.state, actualAuthProvResponse.state); 
        
        //Stoping test
        test.stopTest();
    } 
    

    /******************************************************************************************************************************************************
    testGetUserInfo
    Method to test the QSC_ID_OAuth_Class.getUserInfo method
    -------------------------------------------------------------------------------------------------------------------------------------------------------
    ******************************************************************************************************************************************************/
    static testMethod void testGetUserInfo() { 
    
        //Initiate a Map Sting,String, we called the method setupAuthProviderConfig to get its values.
        Map<String,String> authProviderConfiguration = setupAuthProviderConfig(); 
        
        //Create a new instanse of the class QSC_ID_OAuth
        QSC_ID_OAuth QSC_ID_OAuth_Class = new QSC_ID_OAuth();  
    
        //We set a Mock for the HTTP response from the class Test_MockHttp_QSC_ID_OAuth
        Test.setMock(HttpCalloutMock.class, new Test_MockHttp_QSC_ID_OAuth()); 
        
        //starting the test
        test.startTest();
        
        //We create a token response to send to the method 
        Auth.AuthProviderTokenResponse response = new Auth.AuthProviderTokenResponse(NAME, OAUTH_TOKEN ,'sampleOauthSecret', STATE_TO_PROPOGATE); 
        
        //we send the method to obtain the user info
        Auth.UserData actualUserData = QSC_ID_OAuth_Class.getUserInfo(authProviderConfiguration, response) ; 
        
        //Lets create a fake response to validate against the real response
        Auth.UserData expectedUserData = new Auth.UserData('LOGIN_ID', FIRST_NAME, LAST_NAME, FULL_NAME, EMAIL_ADDRESS, null, EMAIL_ADDRESS, null, PROVIDER, null, null); 
        
        //Validation Asserts to check that everything is ok
        System.assertNotEquals(expectedUserData,null); 
        System.assertEquals(expectedUserData.firstName, actualUserData.firstName); 
        System.assertEquals(expectedUserData.lastName, actualUserData.lastName); 
        System.assertEquals(expectedUserData.email, actualUserData.email); 
        System.assertEquals(expectedUserData.username, actualUserData.username); 
        System.assertEquals(expectedUserData.siteLoginUrl, actualUserData.siteLoginUrl); 
        
        //stoping the test
        test.stopTest();
    }
}