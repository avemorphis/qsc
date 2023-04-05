//=================================================================================================================
//  Object: methods_User.cls
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: Contact Methods Clas
//=================================================================================================================
//          Date            Purpose
// Changes: 03/12/2021      Initial Version
//=================================================================================================================


public class methods_User  {

    /**************************************************************************************************************
    insertPSAUser
    Method to create a PermissonSetAssignment record to grant access to communities based on group_slugs value
    ---------------------------------------------------------------------------------------------------------------
    @param    Users    List of Users from trigger.  ONLY NEW USERS ASSIGNED TO DEFAULT ACCOUNT!!!!
    @return   void
    **************************************************************************************************************/
    public static void insertPSAUser(List<User> Users){

        //Container
        List<PermissionSetAssignment> psaToInsert = new List<PermissionSetAssignment>();

       //Create PermissionSetAssignment Records
        for(User u : Users) {
            
            //Every New QSCId user gets access to Self Help Portal
			Group_Slug__mdt shp = globalHelper.getGroupSlugs('Self_Help_Portal'); //Self Help Portal 
			PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.AssigneeId = u.Id;
                psa.PermissionSetId = shp.Permission_Set_Id__c;
            psaToInsert.add(psa);

			//Check if Group_Slugs__c is null
			Boolean gsIsBlank = String.isBlank(u.Group_Slugs__c);

			if(!gsIsBlank) {

				//Cinema
				if(u.Group_Slugs__c.Contains('cinema-community')){
				
					//Get Permission Set Id
					Group_Slug__mdt cin = globalHelper.getGroupSlugs('Cinema_Community'); //Cinema

					//Build PermissionSetAssignment Record
					PermissionSetAssignment psa1 = new PermissionSetAssignment();
						psa1.AssigneeId = u.Id;
						psa1.PermissionSetId = cin.Permission_Set_Id__c;
					psaToInsert.add(psa1);
				}

				//QSYS Dev
				if(u.Group_Slugs__c.Contains('q-sys-developer')){

					//Get Permission Set Id
					Group_Slug__mdt qd = globalHelper.getGroupSlugs('QSYS_Dev_Community'); //QSYS Dev

					//Build PermissionSetAssignment Record
					PermissionSetAssignment psa2 = new PermissionSetAssignment();
						psa2.AssigneeId = u.Id;
						psa2.PermissionSetId = qd.Permission_Set_Id__c;
					psaToInsert.add(psa2);
				}

				//Service Center
                if(u.Group_Slugs__c.Contains('service-partner')){

					//Get Permission Set Id
					Group_Slug__mdt sc = globalHelper.getGroupSlugs('Service_Center'); //Service Center

					//Build PermissionSetAssignment Record
					PermissionSetAssignment psa3 = new PermissionSetAssignment();
						psa3.AssigneeId = u.Id;
						psa3.PermissionSetId = sc.Permission_Set_Id__c;
					psaToInsert.add(psa3);
				}

				//commDev
				if(u.Group_Slugs__c.contains('commDev')){

					//Get Permission Set Id
					Group_Slug__mdt cd = globalHelper.getGroupSlugs('commDev'); //commDev

					//Build PermissionSetAssignment Record
					PermissionSetAssignment psa8 = new PermissionSetAssignment();
					psa8.AssigneeId = u.id;
					psa8.PermissionSetId = cd.Permission_Set_Id__c;
					psaToInsert.add(psa8);
                }
			}
        }

        //DML Operation
        try {
            //Insert PermissionSetAssignment Records
            if (!psaToInsert.isEmpty()) {
                insert psaToInsert;
            }
        }
        catch (Exception e) {
            
            //Get running Class and Method
            String sTrace = e.getStackTraceString().substringAfter('\n');
            String runningClass = globalExceptionHandlers.getClassName(sTrace);
            String runningMethod = globalExceptionHandlers.getMethod(sTrace);
            
            //Log in Debug Log
            system.debug(runningClass + '-->' + runningMethod +' Exception: ' + e.getMessage());
            
            //Log Exception
            if(System.IsBatch() == false && System.isFuture() == false){ 
                globalExceptionHandlers.logInsertORUpdateException(runningClass, runningMethod, String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
			}
        }
    }



    /**************************************************************************************************************
    updateContactCommunityUser
    Method to Update Contact Record with User Id of Customer Community User
	Future method to avoid Mixed DML and to capture contactId on User
    ---------------------------------------------------------------------------------------------------------------
    @param    Users    List of Users from trigger to be inserted with ContactId populated
    @return   void
    **************************************************************************************************************/
	@Future
    public static void updateContactCommunityUser(Set<Id> Users){
        
		//Containers
        List<Contact> contactsToUpdate = new List<Contact>();
		List<User> usersCreated = new List<User>();
		usersCreated = [select id, ContactId from user where id in :Users];
        
        //Build Contact Record to Update 
        for(User u2 : usersCreated) {
			
			//Check if Null
			if(u2.ContactId != null) {
				//Update Contact Record with User Id
				Contact uC = new Contact();
					uC.Id = u2.ContactId;
					uC.Community_User__c = u2.Id;
				//Update Contact with Community User Id
				contactsToUpdate.add(uC);
			}
        }

        //DML Operation
        try {
            if (!contactsToUpdate.isEmpty()) {
                update contactsToUpdate;
            }
        }
        catch (DMLexception e) {

			//Get running Class and Method
			String sTrace = e.getStackTraceString().substringAfter('\n');
			String runningClass = globalExceptionHandlers.getClassName(sTrace);
			String runningMethod = globalExceptionHandlers.getMethod(sTrace);

			//Log in Debug Log
			system.debug(runningClass + '-->' + runningMethod +' Exception: ' + e.getMessage());

			//Log Exception
			globalExceptionHandlers.logInsertORUpdateException(runningClass, runningMethod, String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
        }
    }

}