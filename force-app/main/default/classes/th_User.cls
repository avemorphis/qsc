//==================================================================================================
//  Object: th_User.cls
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: User Trigger Handler Class
//==================================================================================================
//          Date            Purpose
// Changes: 03/10/2021      Initial Version
//==================================================================================================

public class th_User {

	//TH Variables
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
	//Constructor
    public th_User(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

	/**************************************************************************************************************
	OnAfterInsert
	Booleans:
	insertPSAs - Creates new PermissionSetAssignment records for Community Users

	Methods:
    insertPSAUser:  Inserts Persmission Set Assignment Record for New Community User based on if Group_Slugs__c 
					custom field on User record is populated
	UpdateContactCommunityUser:  Populates Contact Record with corresponding Community User Id
    ---------------------------------------------------------------------------------------------------------------
    @param    newUsers    List of Users from trigger.
    **************************************************************************************************************/
    public void OnAfterInsert(User[] newUsers){

		//Booleans
		Boolean insertPSAs = false;  //Insert PermissionSetAssignment for new Community User

		//Containers
		List<User> insertPSA = new List<User>();
		List<User> updateConCUser = new List<User>();
		Set<Id> newCCuserIds = new Set<Id>(); //New Customer Community Users 
        
        for(User u : newUsers){

			//Insert PSA if Group Slugs is populated
			if(u.Community_User__c) {

				//Boolean
				insertPSAs = true;

				//Populate Containers
					//PermissionSetAssignments
					insertPSA.add(u);
					//Update Customer_Community_User__c on Contact
					newCCuserIds.add(u.id);
			}
        }

		//Process Boolean -  insertPSAs
		if(insertPSAs) {
			//insertPSAUser
			methods_User.insertPSAUser(newUsers);
			//UpdateContactCommunityUser 
			methods_User.updateContactCommunityUser(newCCuserIds);
		}
   }
}