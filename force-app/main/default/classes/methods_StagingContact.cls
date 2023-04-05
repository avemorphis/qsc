//=================================================================================================================
//  Object: methods_StagingContact.cls
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: Contact Methods Clas
//=================================================================================================================
//          Date            Purpose
// Changes: 12/14/2018      Initial Version
//=================================================================================================================

public class methods_StagingContact  {


    /**************************************************************************************************************
    buildContactRecord
    Method to create Contact records from Staging Contacts
    ---------------------------------------------------------------------------------------------------------------
    @param    stgContacts   Staging Contact Records
    @return   newContacts   New Contacts to be inserted
    **************************************************************************************************************/
    public static List<Contact> createContactsFromStaging(List<Staging_Contact__C> stgContacts) {


        //Containers & Variabkes
        List<Contact> contactsStaging = new List<Contact>();  //Staging Contact Records
        Id contactRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(System.Label.Default_Contact_Record_Tyoe).getRecordTypeId();
        
        //Build Contact Record
        for(Staging_Contact__c sc : stgContacts){

            Contact nC = new Contact();
                nC.RecordTypeId = contactRT; //QSCId Recordtype
                nC.Company__c = sc.Company__c;
                nC.Email_Opt_In__c = sc.Email_Opt_In__c;
                nC.FirstName = sc.First_Name__c;
                nC.LastName = sc.Last_Name__c;
                nC.Email = sc.Email__c;
                nC.Group_Slugs__c = sc.Group_Slugs__c;
                nC.MailingStreet = sc.Mailing_Address_1__c + '\n' + sc.Mailing_Address_2__c;
                nC.MailingCity = sc.Mailing_City__c;
                nC.MailingState = sc.Mailing_State__c;
                nC.MailingPostalCode = sc.Mailing_Postal_Code__c;
                nC.MailingCountry = sc.Mailing_Country__c;
                nC.Mailing_US_State__c = sc.Mailing_US_State__c;
                nC.Phone = sc.Phone__c;
                nC.QSC_ID_Last_Access__c = sc.QSC_ID_Last_Access__c;
                nC.QSC_ID_Last_Login__c = sc.QSC_ID_Last_Login__c;
                nC.Customer_Number__c = sc.Customer_Number__c;  //Account Identifier
                nC.Domain__c = sc.Domain__c;  //Account Identifier
                nC.QSCID__c = sc.QSCId__c; //QSCID Identifier
                nC.Staging_Contact__c = sc.Id;
            //nC.Vertical_Market_C_PL__c = sc.Vertical_Market_C_PL__c;
           // nC.Sub_Vertical_C_PL__c = sc.Sub_Vertical_C_PL__c;
            nC.Vertical_Market_C_txt__c = sc.Vertical_Market_C_txt__c;
            nC.Sub_Vertical_C_txt__c = sc.Sub_Vertical_C_txt__c;
            nC.Type_of_Organization_C_PL__c = sc.Type_of_Organization_C_PL__c;
            nC.Job_Function_C_PL__c = sc.Job_Function_C_PL__c;
                /*nc.Type_of_Institution__c = sc.Type_of_Institution__c;
                nc.Department = sc.Department__c;
                nc.Speced_installed_managed_a_QSYS_system__c = sc.Speced_installed_managed_a_QSYS_system__c;
                nc.Room_Types__c = sc.Room_Types__c;
                nc.Size_of_the_campus__c = sc.Size_of_the_campus__c;
                nc.Current_installed_AV_platforms__c = sc.Current_installed_AV_platforms__c;
                nc.School_Name__c = sc.School_Name__c; 
            if(sc.Converted_Lead_Account__c != null){
                nc.Active_Lookup__c = sc.Converted_Lead_Account__c;
                nc.AccountId = sc.Converted_Lead_Account__c;
                }*/
            //Populate Container
            contactsStaging.add(nc);
        }

        //Return Contacts from Staging
        return contactsStaging;
    }

    /**************************************************************************************************************
    insertContacts
    Method to insert Contact records from Staging Contacts
    ---------------------------------------------------------------------------------------------------------------
    @param    iContacts   Contacts to be inserted
    @return   void
    **************************************************************************************************************/
    public static void insertContacts(List<Contact> iContacts) {
        
        //Inserting same Contact List that was checked for duplicates

        //DML Operation
        try {
            if (!iContacts.isEmpty()) {
                insert iContacts;
            }
        }
        catch (DMLexception e) {
            //Log in Debug Log
            system.debug('methods_StagingContact-->insertContacts Exception: ' + e.getMessage());

            //set friendly message
            e.setMessage(System.Label.Exception_Message);

            //Log Exception
            globalExceptionHandlers.logInsertORUpdateException('methods_StagingContact', 'insertContacts', String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
        }
    }


    /**************************************************************************************************************
    upsertContacts
    Method to upsert Contact records if Staging Contact is a duplicate
    ---------------------------------------------------------------------------------------------------------------
    @param    uContacts   Contacts to be inserted
    @return   void
    **************************************************************************************************************/
    public static void upsertContacts(List<Contact> uContacts) {
        
        //Upserting Contact List that was checked for duplicates

        //DML Operation
        try {
            if (!uContacts.isEmpty()) {
                upsert uContacts Contact.Email;
            }
        }
        catch (DMLexception e) {
            //Get running Class and Method
            String sTrace = e.getStackTraceString().substringAfter('\n');
            String runningClass = globalExceptionHandlers.getClassName(sTrace);
            String runningMethod = globalExceptionHandlers.getMethod(sTrace);

            //Log in Debug Log
            system.debug(runningClass + '-->' + runningMethod +' Exception: ' + e.getMessage());

            //set friendly message
            //e.setMessage(System.Label.Exception_Message);

            //Log Exception
            globalExceptionHandlers.logInsertORUpdateException(runningClass, runningMethod, String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
        }
    }


    ///**************************************************************************************************************
    //updateDuplicateContacts
    //Method to update duplicate contact records with count and flag
    //---------------------------------------------------------------------------------------------------------------
    //@param    updatedContactIds   ContactIds to be Updated
    //@return   void
    //**************************************************************************************************************/
    //public static void updateDuplicateContacts(List<Contact> updatedContactIds) {


        ////Containers & Variabkes
        //List<Contact> upDupContact  = new List<Contact>();  //Records to be updated 
        //Integer numDupes = updatedContactIds.size();
        //Id contactRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(System.Label.Default_Contact_Record_Tyoe).getRecordTypeId();
        //Set<Id> ucID = new Set<Id>();

        //for(Contact cc :updatedContactIds){
            //ucID.add(cc.id);
        //}

        ////Move to my own list because dup checking only checks Id
        //List<Contact> updateContactDup = [select  id, Group_Slugs__c, Company__c, Email_Opt_In__c, FirstName, LastName,Email,Mailing_Address_1__c,Mailing_Address_2__c,
                                                    //Mailing_City__c,Mailing_State__c,Mailing_Postal_Code__c,Mailing_Country__c,Mailing_US_State__c,Phone,QSC_ID_Last_Access__c,
                                                    //QSC_ID_Last_Login__c,Customer_Number__c,Domain__c,QSCID__c,Staging_Contact__c from contact where id in: ucID];
        //if( updateContactDup.size() > 0) {

            ////Build Contact Record
            //for(Contact sc : updateContactDup){
            
                ////If Duplicate Match then update Group Slug
                //Contact nc = new Contact();
                    //nc.Id = sc.Id;
                    //nc.Group_Slugs__c = 'SHP;LMS;';
                    //nc.Company__c = sc.Company__c;
                    //nc.Email_Opt_In__c = sc.Email_Opt_In__c;
                    //nc.FirstName = sc.FirstName;
                    //nc.LastName = sc.LastName;
                    //nc.Email = sc.Email;
                    //nc.Group_Slugs__c = '';
                    //nc.Mailing_Address_1__c = sc.Mailing_Address_1__c;
                    //nc.Mailing_Address_2__c = sc.Mailing_Address_2__c;
                    //nc.Mailing_City__c = sc.Mailing_City__c;
                    //nc.Mailing_State__c = sc.Mailing_State__c;
                    //nc.Mailing_Postal_Code__c = sc.Mailing_Postal_Code__c;
                    //nc.Mailing_Country__c = sc.Mailing_Country__c;
                    //nc.Mailing_US_State__c = sc.Mailing_US_State__c;
                    //nc.Phone = sc.Phone;
                    //nc.QSC_ID_Last_Access__c = sc.QSC_ID_Last_Access__c;
                    //nc.QSC_ID_Last_Login__c = sc.QSC_ID_Last_Login__c;
                    //nc.Customer_Number__c = sc.Customer_Number__c;  //Account Identifier
                    //nc.Domain__c = sc.Domain__c;  //Account Identifier
                    //nc.QSCID__c = sc.QSCId__c; //QSCID Identifier
                    //nc.Staging_Contact__c = sc.Id;    
                ////Populate Container
                //upDupContact.add(nc);
            //}
        //}

        ////DML Operation
        //try {
            //if (!upDupContact.isEmpty()) {
                //update upDupContact;
            //}
        //}
        //catch (DMLexception e) {
            ////Log in Debug Log
            //system.debug('methods_StagingContact-->updateDuplicateContacts Exception: ' + e.getMessage());

            ////set friendly message
            //e.setMessage(System.Label.Exception_Message);

            ////Log Exception
            //globalExceptionHandlers.logInsertORUpdateException('methods_StagingContact', 'updateDuplicateContacts', String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
        //}
    //}


    /**************************************************************************************************************
    checkDuplicateContacts
    Method to check if staging contact is a duplicate
    ---------------------------------------------------------------------------------------------------------------
    @param    stgContacts   Staging Contacts converted to Contact
    @return   dupContacts   Duplicate Contacts
    **************************************************************************************************************/
    public static List<Contact> checkDuplicateContacts(List<Contact> stgContacts) {

        //Containers
        List<Datacloud.FindDuplicatesResult> dupContacts = new List<Datacloud.FindDuplicatesResult>();  //List of Duplicate Contacts
        List<Contact> dContacts = new List<Contact>();

        //Populate Container
        dupContacts = Datacloud.FindDuplicates.findDuplicates(stgContacts);

        //Dupes exist
        if(dupContacts.size() > 0) {

            //Cycle through results
            for(Datacloud.FindDuplicatesResult findDupeResult : dupContacts) {

                //Get Dupe Match
                for(Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {

                    //Match to record
                    for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {

                        //build result set
                        for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                            Contact dupC = (Contact) matchRecord.getRecord();
                            dContacts.add(dupC);
                        }
                    }
                }
            }
        }

        //Return Duplicates 
        return dContacts;
    }


}