//========================================================================
//  Object: QSCID_regHandler
// Company: Dysem
//  Author: Barney Young Jr.
// Comment: Class to implement Auth.RegistrationHandler abstract class
//      to create User for QSCId
//========================================================================
//          Date            Purpose
// Changes: 12/10/2017      Initial Version
//          04/12/2021		Hyphen Fix
//			04/26/2021		Hyphen Duplicate Email Fix
//========================================================================

global class QSCID_regHandler implements Auth.RegistrationHandler {

	//Class Variables
	private static final String ORG_SUFFIX = System.label.Org_Id;  
	private static final String DEFAULT_ACCOUNTNAME = System.label.Default_Account;
	private static final String EXTERNAL_USER_PROFILE = System.label.CCPL;


    /******************************************************************************************************************************************************
    canCreateUser
    Method to check if the user can be created
    -------------------------------------------------------------------------------------------------------------------------------------------------------
    @param    data      Auth.Userdata from Callback
    @return   yesIcan    Boolean confirming if user can be created
    ******************************************************************************************************************************************************/
	global boolean canCreateUser(Auth.UserData data) {

		//Check if Auth.UserData returns something
		Boolean yesIcan = (data != null && data.email != null && data.lastName != null && data.firstName != null);

		//Return True of Fales    
		return yesIcan;
	}


    /******************************************************************************************************************************************************
    createUser
    GLOBAL Method that either creates a new Community User or checks if one already exists
    -------------------------------------------------------------------------------------------------------------------------------------------------------
    @param    portalId    Site Id supplied by Salesforce based on Community you are trying to access
	@param    data      Auth.Userdata from Callback
    @return   u        New or Existing User record
    ******************************************************************************************************************************************************/
	global User createUser(Id portalId, Auth.UserData data){
    
		//Can Create?
		if(!canCreateUser(data)) {
		  // Returning null signals the auth framework we can't create the user
		  return null;
		}
		
		//Build Email
		String cuEmailAddress;
		cuEmailAddress = data.email;
		String eAdd = cuEmailAddress.substringBefore('@');
		String eDomain = cuEmailAddress.substringAfter('@');
		//Put Hyphens Back
		eDomain = eDomain.replace('_', '-');	
		cuEmailAddress = eAdd + '@' + eDomain;

		// Create Community User
        Id contactId;

        // Checking to see if the email address is already used by another Contact
        // If so, use that contact and user
        List<Contact> existingContacts = [select id, email from Contact where email =: cuEmailAddress];
        if (existingContacts.size() > 0){
            // Use the first Contact with matching email
            Contact existingContact = existingContacts[0];
            contactId = existingContact.Id;
            List<User> existingUsers = [select id from User where ContactId =: contactId];
            if (existingUsers.size() == 1){
                // Use this User instead of creating a new one
                // The Registration Handler system will assoicate the Auth Provider
                // with this user
                return existingUsers[0];
            }
        } else {
            // Create Contact if one not found, but theoretically one is created by QSCId.
            // So we create one
            // To keep things modular, we're creating the Contact in a separate method
            contactId = createContact(data);
        }
        
		// Assign Profile
			Profile p = [SELECT Id FROM profile WHERE name=:EXTERNAL_USER_PROFILE];

			//Create User Record
			User u = createUser(data,p);
        
		//Return new User
			u.contactId = contactId;
			return u;
    }


	/******************************************************************************************************************************************************
	updateUser
	Method that updates email and name of user if a user record is already existing when createUser method executes
	-------------------------------------------------------------------------------------------------------------------------------------------------------
	@param    userId    User Id returned from createUser Method
	@param    portalId    Site Id supplied by Salesforce based on Community you are trying to access
	@param    data      Auth.Userdata from Callback
	@return   void
	******************************************************************************************************************************************************/
	global void updateUser(Id userId, Id portalId, Auth.UserData data){
 
 		//Variables
		String eAddress = data.email;
		String lastName = data.lastName;
		eAddress = eAddress.replace('_','-');
		lastName = lastName.replace('_','-');
    
		//Update User Info
		User u = new User(id=userId);
			u.email = eAddress;
			u.lastName = lastName;
			u.firstName = data.firstName;
		update(u);
	}


    /******************************************************************************************************************************************************
    createContact
    Method that either creates a new contact for Community User record if one doesn't already exist
    -------------------------------------------------------------------------------------------------------------------------------------------------------
	@param    data      Auth.Userdata from Callback
    @return   contact.id  Id of created Contact record
    ******************************************************************************************************************************************************/
    private Id createContact(Auth.UserData data){

		//Variables
		String eAddress = data.email;
		String lastName = data.lastName;
		String firstName = data.firstName;

		//Get email domain
		String emailAdd = eAddress.substringBefore('@');
		String emailDomain = eAddress.substringAfter('@');

		//Put Hyphens Back
		emailDomain = emailDomain.replace('_', '-');
		lastName = lastName.replace('_','-');
		if(String.isNotBlank(firstName)) { firstName = firstName.replace('_', '-'); }		
		
		//Build email address
		eAddress = emailAdd + '@' + emailDomain;

		Contact contact = new Contact();
		contact.LastName = lastName;
		contact.FirstName = firstName;
		contact.Email = eAddress;
        
		//Set Account Id
		List<Account> accounts = [select Id from Account where Name =:DEFAULT_ACCOUNTNAME];
		contact.accountId = accounts[0].Id;            

		//Insert Contact and return Contact Id
			insert contact;
			return contact.id; 
    }

 
    /******************************************************************************************************************************************************
    createUser
    PRIVATE Method that is called by Global record to physically create new User record
    -------------------------------------------------------------------------------------------------------------------------------------------------------
	@param    data      Auth.Userdata from Callback
	@param    p			Profile Id of Customer Community Plus Login Profile.  Note, the value is Community_User_Defaults__mdt is used for this method
						and the parameter can be passed null
    @return   u			New or Existing User record
    ******************************************************************************************************************************************************/ 
    private User createUser(Auth.UserData data, Profile p) {

		//Variables
		String eAddress = data.email;
		String lastName = data.lastName;
		String firstName = data.firstName;
		String gSlugs = data.attributeMap.get('group_slugs');

		//Get email domain
		String emailAdd = eAddress.substringBefore('@');
		String emailDomain = eAddress.substringAfter('@');

		//Put Hyphens Back
		emailDomain = emailDomain.replace('_', '-');
		lastName = lastName.replace('_','-');
		if(String.isNotBlank(firstName)) { firstName = firstName.replace('_', '-'); }		
		
		//Build email address
		eAddress = emailAdd + '@' + emailDomain;
		
		//Get User Defaults
		Community_User_Defaults__mdt ed  = getCommUserDefaults();

		//Create User
		User u = new User();
			u.username = data.email + ORG_SUFFIX;
			u.email = eAddress;
			u.lastName = lastName;
			u.firstName = firstName;
			String alias = data.firstName + data.lastName;
        
			//Alias must be 8 characters or less
			if(alias.length() > 8) {
				alias = alias.substring(0, 8);
			}
			u.alias = alias;
			u.languagelocalekey = ed.LanguageLocaleKey__c;
			u.localesidkey = ed.LocaleSidKey__c;
			u.emailEncodingKey = ed.EmailEncodingKey__c;
			u.timeZoneSidKey = ed.TimeZoneSidKey__c;
			
			//Populate Profile
			if(String.isNotBlank(gSlugs) && gSlugs.contains('commDev')) {
				//commDev
				u.profileId = ed.commDev_Profile__c;
			}
			else 
				u.ProfileId = ed.Profile_Id__c;

			//QSCID Values
			u.Community_User__c = true;
			u.Group_Slugs__c = data.attributeMap.get('group_slugs');
			u.Phone = data.attributeMap.get('phone');
			u.Country = data.attributeMap.get('country');

			System.debug('User: ' + u);
		return u;
    }  

    /**************************************************************************************************************
    getCommunityUserDefaults
    Method to return Community User Default Values
    ---------------------------------------------------------------------------------------------------------------
    @param    GSName    String name of Group Slug
    @return   gs        Group_Slug__mdt object and attributes of name
    **************************************************************************************************************/
    public static Community_User_Defaults__mdt getCommUserDefaults() {
        
        //Variables
        Community_User_Defaults__mdt cd;
        list<Community_User_Defaults__mdt> cdList;
        
        String SobjectApiName = 'Community_User_Defaults__mdt';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
        String query = 'select ' + commaSepratedFields + ' from ' + SobjectApiName + ' limit 1';
        cdList = Database.query(query);
        cd = cdList[0];
        
        //Return Group Slub record
        return cd;
    }
}