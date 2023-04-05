//========================================================================
//  Object: globalHelper
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: Global helper class for QSC org
//========================================================================
//          Date            Purpose
// Changes: 06/15/2018      Initial Version
//========================================================================


public class globalHelper {


    /**************************************************************************************************************
    getGroupSLugs
    Method to return Group Slug Default Values
    ---------------------------------------------------------------------------------------------------------------
    @param    GSName    String name of Group Slug
    @return   gs        Group_Slug__mdt object and attributes of name
    **************************************************************************************************************/
    public static Group_Slug__mdt getGroupSlugs (String GSName) {
        
        //Variables
        Group_Slug__mdt gs;
        list<Group_Slug__mdt> gsList;
        
        String SobjectApiName = 'Group_Slug__mdt';
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
        String query = 'select ' + commaSepratedFields + ' from ' + SobjectApiName + ' where DeveloperName = :GSName limit 1';
        gsList = Database.query(query);
        gs = gsList[0];
        
        //Return Group Slub record
        return gs;
    }


	/**************************************************************************************************************
    validateGenericEmail
    Returns if email domain is a generic email
    ---------------------------------------------------------------------------------------------------------------
    @param    Contact Domain Name
    @return   boolean	True(Generic Email)  False(Not a Generic Email)
    **************************************************************************************************************/
	public static Boolean validateGenericEmail(String cDomain) {

		//Variables & Containers
		QSC_ID_Generic_Email__mdt genEmail;
		List<QSC_ID_Generic_Email__mdt> geList = new List<QSC_ID_Generic_Email__mdt>(); 
		Boolean genericMatch = false;

		//Quick Query
		String gEQuery = 'select Id, Domain__c from QSC_ID_Generic_Email__mdt where Domain__c = :cDomain limit 1';
		geList = database.Query(gEQuery);

		if(geList.size() > 0) {
			
			//MATCH
			genericMatch = true;
		}

		//Return Boolean
		return genericMatch;
	}


	
	/**************************************************************************************************************
    generateRandomString
    Creates Random String of X Characters
    ---------------------------------------------------------------------------------------------------------------
    @param    len		length of string you need
    @return   randStr	Random String     
    **************************************************************************************************************/
	public static String generateRandomString(Integer len) {
		
		final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
		String randStr = '';
		
		while (randStr.length() < len) {
			Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
			randStr += chars.substring(idx, idx+1);
		}
		return randStr; 
	}


	/**************************************************************************************************************
    getAccountbyDomain
    Returns Id of Account with Domain
    ---------------------------------------------------------------------------------------------------------------
    @param    aDomain	Domain you are searching Account Object
    @return   actId		matching Account Id
    **************************************************************************************************************/
	public static Id getAccountbyDomain(String aDomain) {

		//Variables & Containers
		Account Act;
		Id AccountId;
		List<Account> actList;

		//Quick Query
		String aDQuery = 'select Id from Account where Domain_s__c like : %' + aDomain + '%';
		actList = database.Query(aDQuery);

		if(actlist.size() > 0) {
			Act = actList[0]; 
			AccountId = Act.Id;
		}
		return AccountId;

	}


	/**************************************************************************************************************
    getAccountbyONumber
    Returns Id of Account with ActNumber
    ---------------------------------------------------------------------------------------------------------------
    @param    aNumber	Oracle Account Number you are searching Account Object
    @return   actId		matching Account Id
    **************************************************************************************************************/
	public static Id getAccountbyONumber(String aNumber) {

		//Variables & Containers
		Account Act;
		Id AccountId;
		List<Account> actList;

		//Quick Query
		String aDQuery = 'select Id from Account where Customer_Number__c = :' + aNumber;
		actList = database.Query(aDQuery);

		if(actlist.size() > 0) {
			Act = actList[0]; 
			AccountId = Act.Id;

		}
			return AccountId;
	}
}