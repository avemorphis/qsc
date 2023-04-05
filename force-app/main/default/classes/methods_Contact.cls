//=================================================================================================================
//  Object: methods_Contact.cls
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: Contact Methods Clas
//=================================================================================================================
//          Date            Purpose
// Changes: 06/14/2018      Initial Version
//          06/03/2021      Removing references to createContactAccount as that is handled by Process Builder and
//                          flow
//=================================================================================================================

public class methods_Contact  {
    
    
     public static boolean runOncePPC = true;
     public static string PARTNERSHIP_PROGRAM_MANAGER ='Partnership Program Manager';

    /**************************************************************************************************************
    insertDeletePSAs
    Method to update current PermissionSetAssignment records if Group_Slugs__c updated.  This method deletes the 
    current PermissionSetAssignment records with the exception of Self Help Portal and ads them back.
    *Future method to avoid Mixed DML 
    ---------------------------------------------------------------------------------------------------------------
    @param    userIds    ids of Community_User__c field from Contacts
    @return   void
    **************************************************************************************************************/
    @Future
    public static void insertDeletePSAs(Set<Id> userIds, Set<Id>contactIds){
        
        //Get Group Slug Defaults.  
        Group_Slug__mdt shp = globalHelper.getGroupSlugs('Self_Help_Portal');  //Self Help Portal
        
        //Containers
        List<PermissionSetAssignment> psaToDelete = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> psaToInsert = new List<PermissionSetAssignment>();
        List<Contact> contactsUpdated = new List<Contact>();
        
        //Populate Container
        contactsUpdated = [select Id, community_user__c, group_slugs__c FROM Contact WHERE id in: contactIds];
        
        //PermissionSetAssignment records to delete 
        psaToDelete = [select id from PermissionSetAssignment 
                       WHERE PermissionSetId != :shp.Permission_Set_Id__c
                       AND AssigneeId in :userIds
                       AND PermissionSetId IN (SELECT Id 
                                               FROM PermissionSet
                                               WHERE IsOwnedByProfile =false)];
        
        //Insert
        //Create PermissionSetAssignment Records
        for(Contact cUp : contactsUpdated ) {
            
            //Check if Group_Slugs__c is null
            Boolean gsIsBlank = String.isBlank(cUp.Group_Slugs__c);
            Boolean gsIsEmpty = String.isEmpty(cUp.Group_Slugs__c);
            
            if(!gsIsBlank || !gsIsEmpty) {
                //Cinema
                if(cUp.Group_Slugs__c.Contains('cinema-community')){
                    
                    //Get Permission Set Id
                    Group_Slug__mdt cin = globalHelper.getGroupSlugs('Cinema_Community');  //Cinema
                    
                    //Build Permission Set
                    PermissionSetAssignment psa1 = new PermissionSetAssignment();
                    psa1.AssigneeId = cUp.Community_User__c;
                    psa1.PermissionSetId = cin.Permission_Set_Id__c;
                    psaToInsert.add(psa1);
                }
                
                //QSYS Dev
                if(cUp.Group_Slugs__c.Contains('q-sys-developer')){
                    
                    //Get Permission Set Id
                    Group_Slug__mdt qd = globalHelper.getGroupSlugs('QSYS_Dev_Community');  //QSYS Dev
                    
                    //Build Permission Set                    
                    PermissionSetAssignment psa2 = new PermissionSetAssignment();
                    psa2.AssigneeId = cUp.Community_User__c;
                    psa2.PermissionSetId = qd.Permission_Set_Id__c;
                    psaToInsert.add(psa2);
                }
               
                 //commdev
                if(cUp.Group_Slugs__c.Contains('commdev')){
                    
                    //Get Permission Set Id
                    Group_Slug__mdt qd = globalHelper.getGroupSlugs('commdev');  //commdev
                    
                    //Build Permission Set                    
                    PermissionSetAssignment psa2 = new PermissionSetAssignment();
                    psa2.AssigneeId = cUp.Community_User__c;
                    psa2.PermissionSetId = qd.Permission_Set_Id__c;
                    psaToInsert.add(psa2);
                }
               
                //Technical Support
                if(cUp.Group_Slugs__c.Contains('tech-support')){
                    
                    //Get Permission Set Id
                    Group_Slug__mdt ts = globalHelper.getGroupSlugs('Technical_Support_Portal');  //Technical Support
                    
                    //Build Permission Set                    
                    PermissionSetAssignment psa4 = new PermissionSetAssignment();
                    psa4.AssigneeId = cUp.Community_User__c;
                    psa4.PermissionSetId = ts.Permission_Set_Id__c;
                    psaToInsert.add(psa4);
                }
                
                //Rewards
                if(cUp.Group_Slugs__c.Contains('commHigherEd')){
                    
                    //Get Permission Set Id
                    Group_Slug__mdt he = globalHelper.getGroupSlugs('commHigherEd'); //commHigherEd
                    
                    //Build Permission Set                    
                    PermissionSetAssignment psaHE = new PermissionSetAssignment();
                    psaHE.AssigneeId = cUp.Community_User__c;
                    psaHE.PermissionSetId = he.Permission_Set_Id__c;
                    psaToInsert.add(psaHE);
                }                  
            }
        }
        
        //DML Operation
        try {
            //Delete PermissionSetAssignment Records
            if (!psaToDelete.isEmpty()) {
                delete psaToDelete;
            }
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
            
            //set friendly message
            //e.setMessage(System.Label.Exception_Message);
            
            //Log Exception
            if(System.IsBatch() == false && System.isFuture() == false){ 
                globalExceptionHandlers.logInsertORUpdateException(runningClass, runningMethod, String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
            }
        }
    }
    
    
    /**************************************************************************************************************
    updateUserGroupSlug
    Method to Update User Record with updated Contact Group Slub
    *Future method to avoid Mixed DML and to capture contactId on User. Can't be a formula field because of initial 
    population of record.
    ---------------------------------------------------------------------------------------------------------------
    @param    Users    List of Users from trigger to be inserted with ContactId populated
    @return   void
    **************************************************************************************************************/
    @Future
    public static void updateUserGroupSlug(Set<Id> cIds) {
        
        //Containers
        List<Contact> contactsCreated = new List<Contact>();
        List<User> usersToUpdate = new List<User>();
        
        contactsCreated = [select id, Community_User__c, Group_Slugs__c from Contact where id in :cIds];
        
        //Build Contact Record to Update 
        for(Contact c1 : contactsCreated) {
            
            //Check if Null
            if(c1.Community_User__c != null) {
                //Update Contact Record with User Id
                User nU = new User();
                nU.id = c1.Community_User__c;
                nU.Group_Slugs__c = c1.Group_Slugs__c;
                //Update Contact with Community User Id
                usersToUpdate.add(nU);
            }
        }
        
        //DML Operation
        try {
            if (!usersToUpdate.isEmpty()) {
                update usersToUpdate;
            }
        }
        catch (Exception e) {
            
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
    
    /**************************************************************************************************************
    getAllCampaignMembers
    Method to retrieve all existing Campaign members and also deletes if attribute is not tehre on COntact
    ---------------------------------------------------------------------------------------------------------------
    @param    newContacts,
    @return   CampaignMember to insert
    **************************************************************************************************************/
    public static List<CampaignMember> getAllCampaignMembers(MAP<Id,Contact> newContacts,Set<String> OracleRegions){
      
        SET<CampaignMember> CampaignMembersList = new SET<CampaignMember>();
        Map<Id,CampaignMember> DeleteCampaignMembersMap = new Map<Id,CampaignMember>();
        MAP<String,Campaign_Members_Management__mdt> CampaignIdsMap = new MAP<String,Campaign_Members_Management__mdt>();    
        MAP<Id,MAP<Id,CampaignMember>> existingCmembers = new MAP<Id,MAP<Id,CampaignMember>>();
        List<Campaign_Members_Management__mdt> Campaign_Members_list = new List<Campaign_Members_Management__mdt>();
        //get active Campaigns from Custom Meta Data
        
       if(!OracleRegions.isEmpty()){
          Campaign_Members_list  = [SELECT MasterLabel,Account_SubRegion__c, Account_Price_Book_Id__c, 
                                                                     Account_Type__c ,Business_Unit__c,CampaignId__c,Community_Attribute__c,IsActive__c,
                                                                     Partner_Category__c,Region_Oracle__c FROM Campaign_Members_Management__mdt WHERE IsActive__c = TRUE 
                                                                     AND Account_SubRegion__c IN: OracleRegions
                                                                    ];
        }
        
        for (Campaign_Members_Management__mdt threatMapping : Campaign_Members_list) {
            CampaignIdsMap.put(threatMapping.CampaignId__c,threatMapping);
        }
        
        system.debug('CampaignIdsMap' + CampaignIdsMap.size());
        
        if(!CampaignIdsMap.isEmpty()){
        
            for(CampaignMember cmember : [Select Id,ContactId,CampaignId from CampaignMember WHERE  CampaignId IN: CampaignIdsMap.keySet() AND ContactId IN: newContacts.keySet()]){
                System.debug('cmember>>>>>>>>>.'+cmember);
                MAP<Id,CampaignMember> contactIds = new MAP<Id,CampaignMember>();
                
                // get CampaignMembers into MAP to handle insert and delete CampaignMembers
                if(!existingCmembers.isEmpty() && existingCmembers.get(cmember.CampaignId) != null){
                    contactIds = existingCmembers.get(cmember.CampaignId);
                    contactIds.put(cmember.contactid,cmember);
                    existingCmembers.put(cmember.CampaignId,contactIds);
                }else{
                    contactIds.put(cmember.contactid,cmember);          
                    existingCmembers.put(cmember.CampaignId,contactIds);
                }
                
            }
           
                
            for(Contact con: newContacts.values()){
                if(con.Status__c != 'Inactive'){
                    //getting multiselect picklist values to MAP
                    Map<String,String> commattributemap = new Map<String,String>();
                    if(con.Communication_Attributes__c != null){
                        for(String s: con.Communication_Attributes__c.split(';')){
                            commattributemap.put(s,s);
                        }
                        
                        for (Campaign_Members_Management__mdt threatMapping : Campaign_Members_list) {
                            if(con.Account_Type_F__c == threatMapping.Account_Type__c && con.Region_Oracle_F__c == threatMapping.Region_Oracle__c && !commattributemap.isEmpty() && commattributemap.containsKey(threatMapping.Community_Attribute__c) && con.Partner_Category_F__c == threatMapping.Partner_Category__c && con.Business_Unit_F__c == threatMapping.Business_Unit__c && (threatMapping.Account_Price_Book_Id__c ==null || (threatMapping.Account_Price_Book_Id__c !=null && con.Account_Pricebook_F__c == threatMapping.Account_Price_Book_Id__c)) && (threatMapping.Account_Price_Book_Id__c ==null ||(threatMapping.Account_SubRegion__c !=null && con.Account_Territory_F_Oracle__c == threatMapping.Account_SubRegion__c))){
                                system.debug('commattributemap.containsKey(threatMapping.Community_Attribute__c)'+commattributemap.containsKey(threatMapping.Community_Attribute__c));
                                if( existingCmembers.isEmpty() || (!existingCmembers.isEmpty() && ((existingCmembers.get(threatMapping.CampaignId__c)==null )|| (existingCmembers.get(threatMapping.CampaignId__c) != null && existingCmembers.get(threatMapping.CampaignId__c).get(con.Id)== null)))){
                                    system.debug('threatMapping.CampaignId__c'+threatMapping.CampaignId__c+ ' '+existingCmembers.get(threatMapping.CampaignId__c));
                                    CampaignMember cm = new CampaignMember();
                                    cm.ContactId = con.Id;
                                    cm.CampaignId= threatMapping.CampaignId__c;
                                    cm.Status = 'New';
                                    CampaignMembersList.add(cm);
                                    
                                }else if( (commattributemap == null || !commattributemap.containsKey(threatMapping.Community_Attribute__c)) && !existingCmembers.isEmpty() && existingCmembers.get(threatMapping.CampaignId__c) != null && existingCmembers.get(threatMapping.CampaignId__c).get(con.Id)!= null){
                                    DeleteCampaignMembersMap.put(existingCmembers.get(threatMapping.CampaignId__c).get(con.Id).Id,existingCmembers.get(threatMapping.CampaignId__c).get(con.Id));
                                
                                }
                            }else if( (commattributemap == null || !commattributemap.containsKey(threatMapping.Community_Attribute__c)) && !existingCmembers.isEmpty() && existingCmembers.get(threatMapping.CampaignId__c) != null && existingCmembers.get(threatMapping.CampaignId__c).get(con.Id)!= null){
                                DeleteCampaignMembersMap.put(existingCmembers.get(threatMapping.CampaignId__c).get(con.Id).Id,existingCmembers.get(threatMapping.CampaignId__c).get(con.Id));
                                
                            }
                            
                        }
                    }else{
                        system.debug('came here');
                        for(MAP<Id,CampaignMember> campmemberId : existingCmembers.values()){
                            if(campmemberId.get(con.Id)!= null){
                                DeleteCampaignMembersMap.put(campmemberId.get(con.Id).Id,campmemberId.get(con.Id));
                            }
                        }
                        
                    }
                    
                }
            }
                
            //Detele the Campaign members where the Contact Attribute is removed
            if(!DeleteCampaignMembersMap.isEmpty()){
                try{
                Delete DeleteCampaignMembersMap.Values();
                }   catch (Exception e) {
                    System.debug('Exception>>>>>>>>>.'+e);
                    //Get running Class and Method
                    String sTrace = e.getStackTraceString().substringAfter('\n');
                    
                    //Log Exception
                    globalExceptionHandlers.logInsertORUpdateException(globalExceptionHandlers.getClassName(sTrace), globalExceptionHandlers.getMethod(sTrace), String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
                }
         
            }
        }
        List<CampaignMember> CampaignMembersLists = new List<CampaignMember>();
        CampaignMembersLists.addAll(CampaignMembersList);
       return CampaignMembersLists;
        
    }
    
    /**************************************************************************************************************
    insertCampaignMembers
    Method to update Campaign members based on Attributes in Contact
    **************************************************************************************************************/

    public static void insertCampaignMembers(MAP<Id,Contact> newContacts, Map<Id,Contact> oldContacts) {
        
        List<CampaignMember> CampaignMembersList = new List<CampaignMember>();
        List<Contact> contactsList = new List<Contact>();
        MAP<Id,Contact> contactsMap = new MAP<Id,Contact>();
        Set<String> OracleRegions = new Set<String>();
        
        if(oldContacts != null){
            for(Contact con: newContacts.values()){
                if(con.Communication_Attributes__c != oldContacts.get(con.Id).Communication_Attributes__c ){
                    contactsMap.put(con.id,con);
                    system.debug('Account_Territory_F_Oracle__c'+con.Account_Territory_F_Oracle__c);
                    OracleRegions.add(con.Account_Territory_F_Oracle__c);
                }
            }
            
            if(!contactsMap.isEmpty()){
                CampaignMembersList =  getAllCampaignMembers(contactsMap,OracleRegions);
            }
        }else{
            CampaignMembersList =  getAllCampaignMembers(newContacts,OracleRegions);
        }
        
        if(!CampaignMembersList.isEmpty()){
            Insert CampaignMembersList;
           }
        
    }
 
    /**************************************************************************************************************
    updateAccountsPartnershipProgramContact
    Method to update PPM field on Account if the Contact is having attribute named Partnership Program Manager
    **************************************************************************************************************/
    
    public static void updateAccountsPartnershipProgramContact(Map<Id,Contact> newContacts,Map<Id,Contact> OldContacts){
        runOncePPC = false;
        SET<Id> accountSet = new SET<Id>();
        Map<Id,Contact> contactsMap = new Map<Id,Contact>();
        Map<Id,Account> accountMap = new Map<Id,Account>();
        MAP<Id,Contact> UpdateaccountContactMAP = new MAP<Id,Contact>();
        MAP<Id,Contact> DeleteaccountContactMAP = new MAP<Id,Contact>();
        
        for(Contact con: newContacts.values()){
         
            //Null check for Communication_Attributes__c field
            if(con.Communication_Attributes__c != null) {
                if((con.Communication_Attributes__c).contains(PARTNERSHIP_PROGRAM_MANAGER)){
                    UpdateaccountContactMAP.put(con.AccountId,con);
                    accountSet.add(con.AccountId);
                }
                if(!(con.Communication_Attributes__c).contains(PARTNERSHIP_PROGRAM_MANAGER) && !(OldContacts.get(con.Id).Communication_Attributes__c==null) && (OldContacts.get(con.Id).Communication_Attributes__c).contains(PARTNERSHIP_PROGRAM_MANAGER) ){
                    DeleteaccountContactMAP.put(con.AccountId,con);
                    accountSet.add(con.AccountId);
                }
            }
            else if(con.Communication_Attributes__c == null && (OldContacts.get(con.Id).Communication_Attributes__c!=null && OldContacts.get(con.Id).Communication_Attributes__c.contains(PARTNERSHIP_PROGRAM_MANAGER))){
                DeleteaccountContactMAP.put(con.AccountId,con);
                accountSet.add(con.AccountId);
            }
        }
        
        for(Account acc: [SELECT Id,PPM__c, (Select Id,Communication_Attributes__c FROM contacts where Communication_Attributes__c includes('Partnership Program Manager')) FROM Account WHERE Id IN: accountSet]){
            
            if(UpdateaccountContactMAP.get(acc.id) != null){
                acc.PPM__c = UpdateaccountContactMAP.get(acc.Id).Id;
                accountMap.put(acc.Id,acc);
            }
            
            for (Contact con : acc.Contacts) {
                if(!newContacts.containsKey(con.Id) && string.isNotBlank(con.Communication_Attributes__c)){
                    List<string> lstPicklistValues = con.Communication_Attributes__c.split(';');
                    if(lstPicklistValues!=null && lstPicklistValues.contains(PARTNERSHIP_PROGRAM_MANAGER)){
                       lstPicklistValues.remove(lstPicklistValues.indexOf(PARTNERSHIP_PROGRAM_MANAGER));
                       con.Communication_Attributes__c = String.join(lstPicklistValues,';');
                       contactsMap.put(con.id,con);
                    }
                }
            }
            
            if(DeleteaccountContactMAP.get(acc.id) != null && !UpdateaccountContactMAP.containsKey(acc.id)){
                acc.PPM__c = null;
                accountMap.put(acc.id,acc);
            }
        }
        
        if(!accountMap.isEmpty()){
            update accountMap.values();
        }
        
        if(!contactsMap.isEmpty()){
           update contactsMap.values();
        }
        
    }
    /**************************************************************************************************************
    updateActiveInactiveValues
    Method to update Inactive or Active lookup account values so that it will display in related list
    **************************************************************************************************************/
    public static void updateActiveInactiveValues(List<Contact> newContacts) {    
        
       for(Contact c: newContacts){
       system.debug('Contact >>> 437'+c);
            if(c.Status__c == 'Active' || c.Status__c == null){
                system.debug('Contact >>> 439'+c);
                 c.Active_Lookup__c = c.AccountId;
                 c.Inactive_Lookup__c = null;
             }else{
                system.debug('Contact >>> 443'+c);
                 c.Inactive_Lookup__c = c.AccountId;
                 c.Active_Lookup__c = null;
                 c.Communication_Attributes__c = null;
             }
        }
             
    }
   
    /**************************************************************************************************************
    removeAllAttributesandCampainMembers
    Method to remove campaingmembers if the contact is in Inactive status.
    **************************************************************************************************************/
     public static void removeAllAttributesandCampainMembers(List<Contact> newContacts) {    
        
         MAP<Id,Contact> inactiveContactsMap = New MAP<Id,Contact>();
         
         for(Contact c : newContacts){
               if(c.Status__c == 'Inactive'){
                   inactiveContactsMap.put(c.Id,c);
               }
         }
         
         if(!inactiveContactsMap.isEmpty()){
             
             List<CampaignMember> CampaignMembersList = new List<CampaignMember>();
             CampaignMembersList = [SELECT Id FROM CampaignMember where ContactId IN:inactiveContactsMap.KeySet()];
             
             if(!CampaignMembersList.isEmpty()){
                 Delete CampaignMembersList;
             }
             
         }
         
    }
    /**************************************************************************************************************
    validateCommunityAccessTransition
    Method to check if a contact's Account is portal enabled

    ---------------------------------------------------------------------------------------------------------------
    @param    trigger.new, trigger.newmap   Set of Contact IDs to be updated with Account
    @return   void
    **************************************************************************************************************/
    public static void validateCommunityAccessTransition(List<Contact> newContacts, Map<Id,Contact> newContactsMap, Map<Id,Contact> oldContactsMap) {
      list<Community_Access_transition__mdt> lstCommTransitions = Community_Access_transition__mdt.getAll().values();
        map<string,Community_Access_transition__mdt> mapCommunityTransition = new map<string,Community_Access_transition__mdt>(); 
        for(Community_Access_transition__mdt CATM : lstCommTransitions){
          mapCommunityTransition.put(CATM.label,CATM);    
        }
        list<Messaging.SingleEmailMessage> lstEmails = new list<Messaging.SingleEmailMessage>();
        for(Contact ct : newContacts){
            Contact oldContact = oldContactsMap.get(ct.Id);
            if(ct.Community_Access__c !=null && oldContact.Community_Access__c !=null){
              
                if(mapCommunityTransition.containsKey(oldContact.Community_Access__c) && mapCommunityTransition.get(oldContact.Community_Access__c).Possible_Transitions__c!=null && !mapCommunityTransition.get(oldContact.Community_Access__c).Possible_Transitions__c.contains(ct.Community_Access__c)){
                    ct.addError(system.label.UserTransitionError);
                    // Processes and actions involved in the Apex transaction occur next,
                    // which conclude with sending a single email.
                    
                    // Now create a new single email message object
                    // that will send out a single email to the addresses in the To, CC & BCC list.
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    
                    // Strings to hold the email addresses to which you are sending the email.
                    String[] toAddresses = new String[] {'uday.kumar@qsc.com'}; 
                       // toAddresses.add('nmonapati@gmail.com');
                    //String[] ccAddresses = new String[] {'smith@gmail.com'};
                      
                    
                    // Assign the addresses for the To and CC lists to the mail object.
                    mail.setToAddresses(toAddresses);
                    //mail.setCcAddresses(ccAddresses);
                    
                    // Specify the address used when the recipients reply to the email. 
                    //mail.setReplyTo('Donotreply@acme.com');
                    
                    // Specify the name used as the display name.
                    mail.setSenderDisplayName('Salesforce Support');
                    
                    // Specify the subject line for your email address.
                    mail.setSubject('Need help updating user : ' + ct.Id);
                    
                    // Set to True if you want to BCC yourself on the email.
                    mail.setBccSender(false);
                    
                    // Optionally append the Salesforce email signature to the email.
                    // The email address of the user executing the Apex Code will be used.
                    mail.setUseSignature(false);
                    
                    // Specify the text content of the email.
                    mail.setPlainTextBody('User is tring to update a contact which needs your help. Contact Id is ' + ct.Id );
                    
                    mail.setHtmlBody('User is tring to update a contact which needs your help. Contact Id is <b> ' + ct.Id +' </b>');
                    
                    // Send the email you have created.
                    lstEmails.add(mail);
                    
                }    
            }
          
        } 
        if(lstEmails !=null && !lstEmails.isEmpty()){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(lstEmails);

            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
          //Messaging.sendEmail(lstEmails);    
        }
        
    }
    /**************************************************************************************************************
    checkPartnerEnabled
    Method to check if a contact's Account is portal enabled

    ---------------------------------------------------------------------------------------------------------------
    @param    trigger.new, trigger.newmap   Set of Contact IDs to be updated with Account
    @return   void
    **************************************************************************************************************/
    public static void checkPartnerEnabled(List<Contact> newContacts, Map<Id,Contact> newContactsMap, Map<Id,Contact> oldContactsMap) {
        Map<Id,Account> mapAccounts = new Map<Id,Account>();
        list<Id> lstContactIds = new list<Id>();
        for(contact ct: newContacts){
            if(String.isNotBlank(ct.Community_Access__c)){
                lstContactIds.add(ct.AccountId);    
            }
        }
        if(lstContactIds!=null && !lstContactIds.isEmpty()){
            mapAccounts.putAll([select id,Name,IsPartner,IsCustomerPortal from Account where id IN: lstContactIds]);
            for(contact ct: newContacts){
                if(String.isNotBlank(ct.Community_Access__c) && (oldContactsMap == null || (oldContactsMap!=null && oldContactsMap.containsKey(ct.Id) && oldContactsMap.get(ct.Id).Community_Access__c != ct.Community_Access__c))){
                    Account ctmap = mapAccounts.get(ct.AccountId); 
                    //if((!ctmap.IsPartner && ct.Community_Access__c.containsIgnoreCase('CPP')) || (!ctmap.IsCustomerPortal && ct.Community_Access__c.containsIgnoreCase('TPP'))){
                      if(!ctmap.IsPartner && ct.Community_Access__c.containsIgnoreCase('CPP')){  
                        if(!Test.isRunningTest()){
                            ct.addError('The associated account is not enabled as a partner or customer. Contact cannot be created or updated.');
                        }
                    }    
                }
            }   
        }
    }
    /**************************************************************************************************************
    checkContactDupe
    Method to check if a contact is a duplicate

    Contact Needs to be checked 4 times.  If any fails, it will fall out.
    1.  Check for Email Match
    2.  Check for Account # Match
    3.  Check for Domain Match
    4.  Check generic email domains

    ---------------------------------------------------------------------------------------------------------------
    @param    cIDs   Set of Contact IDs to be updated with Account
    @return   void
    **************************************************************************************************************/
    public static void checkContactDupe(List<Contact> newContacts, String UpdateInsert) {
        
        
        MAP<Id,Contact> contactsforSC = new Map<ID,Contact>();
        for(Contact c: [Select Id,Staging_Contact__r.Group_Slugs__c from Contact where id IN: newContacts]){
            contactsforSC.put(c.Id,c);
        }
            
        //Containers
        map<string,contact> dEmailsMap = new map<string,contact>();
        //List<Contact> dEmails =  new List<Contact>();
        List<Account> dAcctNum = new List<Account>(); 
        List<Account> dDomain = new List<Account>();                   
        List<Contact> updateContacts = new List<Contact>();
        Boolean matched = false;
        Boolean companyMatch = false;
        Boolean domainMatch = false;
        
        //Duplicate Sets
        Set<Id> contactIds = new Set<Id>();
        Set<String> dupeEmails = new Set<String>();                   
        Set<String> dupeAcctNum = new Set<String>(); 
        Set<String> dupeDomain = new Set<String>();                   
        Set<String> dupeGenericEmail = new Set<String>();
        String domainSearch = '';
        Integer  count = 0;
        //Populate Sets
        for(Contact c: newContacts) {
            count++;
            //Get email into a string
            String cEmail = String.valueOf(c.Email);
            
            //Ids
            contactIds.add(c.id);
            
            //Account Num
            if(String.isNotBlank(c.Customer_Number__c)) {
                dupeAcctNum.add(c.Customer_Number__c);
            }
            
            //Emails
            dupeEmails.add(c.Email);
            
            //Domain & Generic Email
            String eDomain = cEmail.substringAfter('@');
            dupeDomain.add(eDomain);
            dupeGenericEmail.add(eDomain);
            if(count != newContacts.size()){
                domainSearch = domainSearch + eDomain + ' OR ';
            }
            else{
                domainSearch = domainSearch+eDomain;
            }
        }
        system.debug('domainSearch'+domainSearch);
        //Populate Containers
        for(contact c: [select id, email, AccountId,Staging_Contact__r.Group_Slugs__c from contact where email in: dupeEmails]){ //1st - Email Match
            dEmailsMap.put(c.email,c);
        }
        dAcctNum = [select id, Customer_Number__c from Account where Customer_Number__c in: dupeAcctNum LIMIT 1];  //2nd - Account Number Match
        //dDomain = [select id, Domain_s__c from Account where Domain_s__c in: dupeDomain LIMIT 1];  //3rd - Domain Match
        
        //updated the dDomain to capture the duplicate domains like dysem.com,dys.com Account will be choosen over an Account which is just having dysem.com
        List<List<Sobject>> sobjectList = [ FIND :domainSearch IN ALL FIELDS RETURNING Account(Id,NAME,Domain_s__c where  Domain_s__c!=null) ];
        
        if(sobjectList!=null){
            dDomain = (Account[])sobjectList[0];
        }
        System.debug('dDomain'+dDomain);
        
        //Check for Matches
        try {
            system.debug('matched'+matched);
            //#1 - Email (Caught by Dup-Checking)
            if(UpdateInsert == 'Insert' && !dEmailsMap.isEmpty() && !matched) {
                //Cycle and Update
                for(Contact cu1: newContacts) {
                    
                    //Get Domain
                    String contactEmail = String.valueOf(cu1.Email);
                    String contactDomain = contactEmail.substringAfter('@');
                    
                   if(cu1.Group_Slugs__c != null && cu1.Group_Slugs__c.contains('commdev')){
                        cu1.Group_Slugs__c = ';SHP;LMS;commdev';
                    }else{
                         cu1.Group_Slugs__c = ';SHP;LMS';
                    }
                    cu1.sync_Domain__c = contactDomain;
                    if(dEmailsMap.containsKey(contactEmail) && dEmailsMap.get(contactEmail).AccountId!=null){
                        matched = true;
                        cu1.AccountId = dEmailsMap.get(contactEmail).AccountId;
                    }
                }
            }
            system.debug('matched'+matched);
            //#2 - Account Number Match
            If (dAcctNum.size() > 0 && !matched) {
                
                matched = true;
                companyMatch = true;
                
                //Get Customer Number
                Map<String,Account> acctNumMap = new Map<String,Account>();
                
                for(Account da2 : dAcctNum){
                    acctNumMap.put(da2.Customer_Number__c,da2);
                }                   
                
                //Cycle and Update
                for(Contact cu2: newContacts) {
                    
                    //GetAccountId
                    Account anAccount = acctNumMap.get(cu2.Customer_Number__c);
                    
                    //Get Domain
                    String contactEmail = String.valueOf(cu2.Email);
                    String contactDomain = contactEmail.substringAfter('@');
                    
                    //Update New Contact
                    cu2.AccountId = anAccount.Id;
                     if( cu2.Group_Slugs__c != null && cu2.Group_Slugs__c.contains('commdev')){
                        cu2.Group_Slugs__c = ';SHP;LMS;commdev';
                    }else{
                         cu2.Group_Slugs__c = ';SHP;LMS';
                    }
                    cu2.sync_Domain__c = contactDomain; 
                    
                }
            }
            system.debug('matched'+matched);
            //#3 - Domain Match
            if (dDomain.size() > 0 && !matched) {
                
                Boolean isGenericEmailDomain = false;
                
                //Get Domain
                Map<String,Account> domainMap = new Map<String,Account>();
                
                for(Account da1 : dDomain){
                    domainMap.put(da1.Domain_s__c,da1);
                }           
                //Cycle and Update
                for(Contact cu3: newContacts) {
                    system.debug('cu3:::'+cu3);
                    //Get Domain
                    String contactEmail = String.valueOf(cu3.Email);
                    String contactDomain = contactEmail.substringAfter('@');
                    
                    //GetAccountId
                                    
                    for(Account da1 : dDomain){
                          if(contactDomain == da1.Domain_s__c){
                                cu3.AccountId = da1.Id;
                                matched = true;
                                domainMatch = true;
                          }
                          else if(da1.Domain_s__c.contains(contactDomain)){
                                if(string.isNotBlank(da1.Domain_s__c) && da1.Domain_s__c.contains(',')){
                                    Set<String> domainName = new Set<String>(da1.Domain_s__c.split(','));
                                    system.debug('domainName::::'+domainName);
                                    if(domainName.contains(contactDomain)){
                                       cu3.AccountId = da1.Id;
                                       matched = true;
                                       domainMatch = true;
                                       break;
                                    }
                                }
                          }
                    
                    }  
                    //Update New Contact
                    if(cu3.Group_Slugs__c != null && cu3.Group_Slugs__c.contains('commdev')){
                        cu3.Group_Slugs__c = ';SHP;LMS;commdev';
                    }else{
                         cu3.Group_Slugs__c = ';SHP;LMS';
                    }
                    cu3.sync_Domain__c = contactDomain;
                }
                
            }
            system.debug('matched'+matched);
            //#4 - No Match:  Individual or Company Account
            if (!matched) {
                
                //Individual Account
                for(Contact cu4: newContacts) {
                    
                    //Match Boolean
                    Boolean isGenericEmail = false;
                    
                    //Get Domain
                    String contactEmail = String.valueOf(cu4.Email);
                    String contactDomain = contactEmail.substringAfter('@');
                    String contactName;
                    
                    
                    //Check if Email is generic
                    isGenericEmail = globalHelper.validateGenericEmail(contactDomain);
                    
                    //Generic email Found
                    If(isGenericEmail) {
                        
                        //Update New Contact - Create Individual Account
                        if(cu4.Group_Slugs__c != null && cu4.Group_Slugs__c.contains('commdev')){
                            cu4.Group_Slugs__c = ';SHP;LMS;commdev';
                        }else{
                             cu4.Group_Slugs__c = ';SHP;LMS';
                        }
                        cu4.createNewAccount__c = 'Individual';
                    }
                    
                    //No Generic Email - Build Company Account
                    else {
                        //Build ContactName
                        if(String.isEmpty(cu4.FirstName)){
                            contactName = cu4.LastName;
                        }
                        else {
                            contactName = cu4.FirstName + ' ' + cu4.LastName;
                        }
                        
                        //Update Company Name if populated
                        if(String.isEmpty(cu4.Company__c) || cu4.Company__c == 'self'){
                            
                            //Set to contactName variable
                            cu4.Company__c = contactName;
                        }
                        
                        //Update New Contact
                        if(cu4.Group_Slugs__c != null && cu4.Group_Slugs__c.contains('commdev')){
                            cu4.Group_Slugs__c = ';SHP;LMS;commdev';
                        }else{
                             cu4.Group_Slugs__c = ';SHP;LMS';
                        }
                        cu4.createNewAccount__c = 'Company';    
                        cu4.sync_Domain__c = contactDomain;
                    }
                    system.debug('cu4.createNewAccount__c'+cu4.createNewAccount__c);
                }
            }
            if(matched){
                methods_Contact.updateActiveInactiveValues(newContacts);
            }
            
        }
        
        catch(Exception e) {
            //Get running Class and Method
            String sTrace = e.getStackTraceString().substringAfter('\n');
            String runningClass = globalExceptionHandlers.getClassName(sTrace);
            String runningMethod = globalExceptionHandlers.getMethod(sTrace);
            
            //Log in Debug Log
            system.debug(runningClass + '-->' + runningMethod +' Exception: ' + e.getMessage());
            
            //set friendly message
            e.setMessage(System.Label.Exception_Message);
            
            //Log Exception
            globalExceptionHandlers.logInsertORUpdateException(runningClass, runningMethod, String.valueOf(e.getLineNumber()), e.getMessage(), e.getStackTraceString(), e.getTypeName());
        }
    }
    
    public static void mergeContacts(Map<Id,Contact> newContacts) {
        
        Map<String,Contact> newContactEmails = new Map<String,Contact>();
        Map<String,Contact> OldContactEmails = new Map<String,Contact>();
        
        for(Contact c : newContacts.values()){
          
          newContactEmails.put(c.Email,c);  
            
        }
        
        for(Contact c2 : [SELECT Id,Email,Type_of_Institution__c,Terms_Conditions__c,Group_Slugs__c,Department,Speced_installed_managed_a_QSYS_system__c,Room_Types__c,Size_of_the_campus__c,Current_installed_AV_platforms__c,School_Name__c FROM Contact where Id IN: NewContactEmails.keySet()]){
          
          OldContactEmails.put(c2.Email,c2);  
            
        }
        
         for(Contact con : newContacts.values()){
          
            if(OldContactEmails.get(con.Email) != null){
                 
                con.Type_of_Institution__c = OldContactEmails.get(con.Email).Type_of_Institution__c;
                con.Department = OldContactEmails.get(con.Email).Department;
                
                con.Speced_installed_managed_a_QSYS_system__c = OldContactEmails.get(con.Email).Speced_installed_managed_a_QSYS_system__c;
                con.Room_Types__c = OldContactEmails.get(con.Email).Room_Types__c;
                con.Size_of_the_campus__c = OldContactEmails.get(con.Email).Size_of_the_campus__c;
                con.Current_installed_AV_platforms__c = OldContactEmails.get(con.Email).Current_installed_AV_platforms__c;
                con.School_Name__c = OldContactEmails.get(con.Email).School_Name__c;
                
                Database.MergeResult des= Database.merge(con, OldContactEmails.get(con.Email), false);
                
               if (des.isSuccess()) {
                    System.debug('Master record ID: ' + des.getId());
                    System.assertEquals(con.Id, des.getId()); 
                }else{
                    System.debug('Master record ID: ' + des.getErrors());
                }
            }
        }
    }
    /*** 
    Description : This method is used to update user profile to CPP or TPP
    ***/
    public static void updateUserProfile(boolean isInsert,Map<Id,contact> contOldMap,List<contact> contactList){
        map<Id,string> contactIdCommunityAccessMap = new map<Id,string>();
        for(Contact con: contactList){
            if(isInsert && String.isNotBlank(con.Community_Access__c)){
                contactIdCommunityAccessMap.put(con.id,con.Community_Access__c);
            } else if(!isInsert && (contOldMap.get(con.Id).Community_Access__c != con.Community_Access__c) && String.isNotBlank(con.Community_Access__c)){
                contactIdCommunityAccessMap.put(con.id,con.Community_Access__c);
            }
        }
        if(!contactIdCommunityAccessMap.isEmpty()){
            updateUser(contactIdCommunityAccessMap); // future method to avoid Mixed DML operation
        }
    }
    public static string generateRandomNo(Integer len){
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        return str.substring(0, len);
    }
    @future
    public static void  updateUser(map<Id,string> contactIdCommunityAccessMap){
        List<user> uList = new List<user>();
        List<PermissionSetAssignment> psAssignmentList = new List<PermissionSetAssignment>();
        List<PermissionSetLicenseAssign> psLicenseAssignmentList = new List<PermissionSetLicenseAssign>();
        List<GroupMember> groupmemberList = new List<GroupMember>();
        Map<string,Community_Access__mdt> cAmdt = new Map<string,Community_Access__mdt>();
        for(Community_Access__mdt ca: [select id,PublicGroup__c,Network_ID__c,Profile_Id__c,MasterLabel,Permission_set_name__c,Permission_set__c,Permission_Set_License_Assignments__c from Community_Access__mdt]){
            cAmdt.put(ca.MasterLabel,ca);
        }
        //Code Added for user creation
        map<id,id> mapContactIdToUserID = new map<id,id>();
        map<id,Contact> mapContacts = new map<id,Contact>();
        mapContacts.putAll([select id,FirstName,LastName,Email from Contact where id IN : contactIdCommunityAccessMap.KeySet()]);
        for(User u : [select id,ProfileId,contactId from user where contactId IN: contactIdCommunityAccessMap.KeySet()]){
            mapContactIdToUserID.put(u.ContactId,u.Id);
        }
        list<user> lstUsers = new list<User>();
        System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
        for(Id cid : contactIdCommunityAccessMap.KeySet()){
            Contact ct = mapContacts.get(cid);
            if(!mapContactIdToUserID.containskey(cid)){
                user u = new user();
                Organization org = [select id,name, isSandbox from organization where Name !=null ];
                u.firstName = ct.FirstName;
                u.lastName = ct.LastName;
                u.ContactId = ct.Id;
                if(org.isSandbox){
                    u.Username = ct.Email+'.'+d.getSandboxName();
                }else{
                    u.Username = ct.Email+'qscportal';
                }
                
                u.Email = ct.Email;
               
                if(ct.LastName.length()>5){
                    u.CommunityNickname = ct.LastName.substring(0,4)+ generateRandomNo(6);
                    u.Alias = ct.LastName.substring(0,4)+ generateRandomNo(2);
                }
                else{
                    u.CommunityNickname = ct.LastName + generateRandomNo(6);
                    u.Alias = ct.LastName + generateRandomNo(2);
                }
                
                u.CommunityNickname = ct.LastName.substring(3)+ generateRandomNo(6);
                u.TimeZoneSidKey = 'America/Phoenix'; // Required
                u.LocaleSidKey = 'en_US'; // Required
                u.EmailEncodingKey = 'ISO-8859-1'; // Required
                u.LanguageLocaleKey = 'en_US'; // Required
                u.ProfileId = cAmdt.get(contactIdCommunityAccessMap.get(cid)).Profile_Id__c;  
                lstUsers.add(u);
            }
            
        }
        if(lstUsers !=null && !lstUsers.isEmpty()){
            Database.insert(lstUsers, false);   
        }
        
        
        //Code ended 
        PermissionSetAssignment psa;
        PermissionSetLicenseAssign psla;
        for(User u : [select id,ProfileId,contactId from user where contactId IN: contactIdCommunityAccessMap.KeySet()]){
            if(string.isNotBlank(contactIdCommunityAccessMap.get(u.contactId)) && !cAmdt.isEmpty() && cAmdt.containsKey(contactIdCommunityAccessMap.get(u.contactId)) && String.isNotBlank(cAmdt.get(contactIdCommunityAccessMap.get(u.contactId)).Profile_Id__c)){
                u.ProfileId = cAmdt.get(contactIdCommunityAccessMap.get(u.contactId)).Profile_Id__c;
                uList.add(u);
                if(String.isNotBlank(cAmdt.get(contactIdCommunityAccessMap.get(u.contactId)).Permission_Set_License_Assignments__c)){
                    for(string pslId: cAmdt.get(contactIdCommunityAccessMap.get(u.contactId)).Permission_Set_License_Assignments__c.split(';')){
                        psla = new PermissionSetLicenseAssign(PermissionSetLicenseId = pslId, AssigneeId = u.Id);
                        psLicenseAssignmentList.add(psla);
                    }
                }
                if(String.isNotBlank(cAmdt.get(contactIdCommunityAccessMap.get(u.contactId)).Permission_set__c)){
                    for(string psId: cAmdt.get(contactIdCommunityAccessMap.get(u.contactId)).Permission_set__c.split(';')){
                        psa = new PermissionSetAssignment(PermissionSetId = psId, AssigneeId = u.Id);
                        psAssignmentList.add(psa);
                    }
                }
                
                if(String.isNotBlank(cAmdt.get(contactIdCommunityAccessMap.get(u.contactId)).PublicGroup__c)){
                    GroupMember gma = new GroupMember(GroupId = cAmdt.get(contactIdCommunityAccessMap.get(u.contactId)).PublicGroup__c,UserOrGroupId = u.Id);
                    groupmemberList.add(gma);
                }
            }
        }
        if(!uList.isEmpty()){
            database.update(uList,false);
        }
        if(!psLicenseAssignmentList.isEmpty()){
            database.insert(psLicenseAssignmentList,false);
        }
        if(!psAssignmentList.isEmpty()){
            database.insert(psAssignmentList,false);
        }
        
        if(!groupmemberList.isEmpty()){
            database.insert(groupmemberList,false);
        }
    }
    /*** 
    Description : This method is used to map the agent id on contact
    ***/
    public static void assignAgentIDonContact(List<contact> contactList){
       CTI_Assigned_Agent_Metadata__mdt[] AssingedAgentMap= [SELECT MasterLabel,PinCode__c, Region__c,Assigned_Agent_ID__c,City__c,State__c FROM CTI_Assigned_Agent_Metadata__mdt];   
       system.debug('AssingedAgentMap' +AssingedAgentMap);
       for(Contact con: contactList){
           if(con.AccountId != null  && string.isNotBlank(con.Account_Loyalty_Level__c) && con.Account_Loyalty_Level__c == 'DIAMOND' && string.isNotBlank(con.Account_Assigned_Agent__c )){      
               con.Assigned_Agent__c = con.Account_Assigned_Agent__c;  
               //If it is Diamond we dont populate the Contact Subregion, case routing is not dependent on Subregion so we dont need to populate 
               //contact subregion for Diamond accounts if there is Assigned agent at Account Level.
               break;
           } 
           else{
               for (CTI_Assigned_Agent_Metadata__mdt AssingedAgentMaping : AssingedAgentMap) { 
                   if(con.AccountId != null && con.Assign_Agent_Manually__c == false){
                       if(AssingedAgentMaping.PinCode__c!=null && con.MailingPostalCode!=null && AssingedAgentMaping.PinCode__c.contains(con.MailingPostalCode)){
                           con.Assigned_Agent__c = AssingedAgentMaping.Assigned_Agent_ID__c;                    
                           con.Contact_Subregion_queue_agent_assignment__c = AssingedAgentMaping.Region__c;
                           break;
                       }
                       else if(AssingedAgentMaping.City__c!=null && con.MailingCity!=null && AssingedAgentMaping.City__c.contains(con.MailingCity)){
                           con.Assigned_Agent__c = AssingedAgentMaping.Assigned_Agent_ID__c;                    
                           con.Contact_Subregion_queue_agent_assignment__c = AssingedAgentMaping.Region__c; 
                           break;
                       }
                       else if(AssingedAgentMaping.State__c!=null && con.MailingState!=null && AssingedAgentMaping.State__c.contains(con.MailingState)){
                           con.Assigned_Agent__c = AssingedAgentMaping.Assigned_Agent_ID__c;                    
                           con.Contact_Subregion_queue_agent_assignment__c = AssingedAgentMaping.Region__c;  
                       }
                   }               
               }
           }
       }
    }
}