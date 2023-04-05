//==================================================================================================
//  Object: th_StagingContact.cls
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: Staging Contact Trigger Handler Class
//==================================================================================================
//          Date            Purpose
// Changes: 12/14/2018      Initial Version
//==================================================================================================


public class th_StagingContact  {

    //TH Variables
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    //Constructor
    public th_StagingContact(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }


	/**************************************************************************************************************
	OnAfterInsert
	This should run on ALL Contact Staging records ALL the time and doesn't need to be filtered.

	Methods:
	createContactsFromStaging - Converts Contacts from Staging records
	checkDuplicateContacts - Checks converted contacts for duplicates
	updateDuplicateContacts - Updates contacts if they are duplicates
	insertContacts - Inserts converted contacts
    ---------------------------------------------------------------------------------------------------------------
    @param    newStagingContacts    List of Staging_Contact__c records from trigger.
    **************************************************************************************************************/
    public void OnAfterInsert(Staging_Contact__c[] newStagingContacts, map<Id, Staging_Contact__c> newMap){

		//Containers
		List<Contact> contactsStaging = new List<Contact>();  //Staging Contact Records as Contacts
		List<Contact> dupContacts = new List<Contact>();  //Duplicate Contact IDs 

		//Build Contact records and Check for Duplicates
			//Build Contact records from Contact Staging
			contactsStaging = methods_StagingContact.createContactsFromStaging(newStagingContacts);

			//Check for Duplicates
			dupContacts = methods_StagingContact.checkDuplicateContacts(contactsStaging);

		//Insert New Contact or Update Existing Contact

			//Update Contacs if Duplicates are returned
			if(dupContacts.size() > 0){
		
				//Upsert Contacts
				methods_StagingContact.upsertContacts(contactsStaging);
				//methods_StagingContact.updateDuplicateContacts(dupContacts);
			} 

			//Insert Contacts if no Duplicates are returned
			else {
				
				//Insert Contacts
				methods_StagingContact.insertContacts(contactsStaging);
			}
   }

}