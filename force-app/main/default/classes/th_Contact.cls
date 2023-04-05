//==================================================================================================
//  Object: th_Contact.cls
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: Contact Trigger Handler Class
//==================================================================================================
//          Date            Purpose
// Changes: 06/14/2018      Initial Version
//          04/27/2018      Reverting Reflect Changes to before trigger
//==================================================================================================

public class th_Contact {

    //TH Variables
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    //Constructor
    public th_Contact(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
        dlrs.RollupService.triggerHandler();      
    }


    /**************************************************************************************************************
    OnAfterUpdate
    Booleans:
    updateGroupSlug - If Group_Slug__c on Contact Record got updated

    Methods:
    insertDeletePSAs:  Deletes existing PermissionSetAssignment Records and Inserts new values based on updated
                       Group_Slugs__c field values; 
    updateUserGroupSlug:  Updates Group_Slugs__c value on Contact's User Record to match contact.
    **************************************************************************************************************/
    public void OnAfterUpdate(Contact[] oldContacts, Contact[] newContacts, map<Id, Contact> oldMap, map<Id, Contact> newMap){
        
        //Booleans
        Boolean updateGroupSlug = false;  //Group_Slug__c Updated
        
        //Group Slug Update Sets
        Set<Id> gsContactIds = new Set<Id>();                   
        Set<Id> gsUserIds = new Set<Id>(); 

        for(Contact ct : newMap.values()){

            if(ct.Number_of_Certifications__c != 0 && ct.Number_of_Certifications__c != oldMap.get(ct.id).Number_of_Certifications__c){
                break;
            }
            //Check if it is a Community User and Group_Slugs has change
            if((Test.isRunningTest() || ct.Community_User__c != null) && (ct.Group_Slugs__c != oldMap.get(ct.id).Group_Slugs__c)) {
                
                //Update Boolean
                updateGroupSlug = true;

                //Populate Group Slug
                gsContactIds.add(ct.id);
                gsUserIds.add(ct.Community_User__c);
            }
        } 

        //Process Boolean -  Group Slug Update
        if(updateGroupSlug){            
            //Update PermissionSetAssigments
            methods_Contact.insertDeletePSAs(gsUserIds, gsContactIds);

            //Update User Record
            methods_Contact.updateUserGroupSlug(gsContactIds);
        }
        AutoInsertCampaignMembers.InsertCampaignMember(newContacts,oldMap,newMap);
        methods_Contact.insertCampaignMembers(newMap,oldMap);
       /* if(methods_Contact.runOncePPC){ commented on Jul 5th
        methods_Contact.updateAccountsPartnershipProgramContact(newMap,oldMap);
        }*/
        methods_Contact.insertCampaignMembers(newMap,null);
        methods_Contact.mergeContacts(newMap);
        methods_Contact.removeAllAttributesandCampainMembers(newMap.values());
        methods_Contact.updateUserProfile(false,oldMap,newContacts);
    }

    /**************************************************************************************************************
    OnAfterInsert
    **************************************************************************************************************/
    
    
    
    public void OnAfterInsert(List<contact>newContacts, map<Id, Contact> newMap){
        AutoInsertCampaignMembers.InsertCampaignMember(newContacts,null,newMap);
        methods_Contact.insertCampaignMembers(newMap,null);
        methods_Contact.mergeContacts(newMap);
        methods_Contact.updateUserProfile(true,null,newContacts);
        //methods_Contact.updateActiveInactiveValues(newMap.values());
    }

    /**************************************************************************************************************
    OnBeforeInsert
        1. Check Contact for Dupe

    Methods:
    checkContactDupe:  Checks Contact for Duplicate
    **************************************************************************************************************/
    public void OnBeforeInsert(Contact[] newContacts, map<Id, Contact> newMap){
        
        
        //Check Contact for Dupe
        methods_Contact.checkContactDupe(newContacts, 'Insert');
        methods_Contact.checkPartnerEnabled(newContacts,newMap,null);
        //assign agent id
        methods_Contact.assignAgentIDonContact(newContacts);
    }   

        
    /**************************************************************************************************************
    OnBeforeUpdate

    Order
    1. Check if Company on contact is null and wasn't null before
    2. Roll-up helper

    Booleans:
    updateContact- Updates Contact if Company got updated

    Methods:
    checkContactDupe:  Checks Contact for Duplicate
    **************************************************************************************************************/
    public void OnBeforeUpdate(Contact[] newContacts, map<Id, Contact> oldMap, map<Id, Contact> newMap){
        
      
        //Booleans
        Boolean updateContact = false;  //AccountId is empty
        
        //Contact Update Sets
        List<Contact> CAdd = new List<Contact>();                   

        for(Contact ct : newContacts){

            String acctId = String.valueOf(ct.AccountId);

            //Get old contact
            Contact oldContact = oldMap.get(ct.id);
            String oldAcctId = String.valueOf(oldContact.AccountId);

            //2. Roll-up helper
            if(ct.Number_of_Certifications__c != 0 && ct.Number_of_Certifications__c != oldMap.get(ct.id).Number_of_Certifications__c){
                break;
            }

            //1.  Check if Company on contact is null and wasn't null before
            if(String.isBlank(acctId) && (String.isNotBlank(oldAcctId))) {
                //Update Boolean
                updateContact = true;

                //Populate reflectOpportunityIds
                CAdd.add(ct);
            }

        } 

        if(updateContact){          
            
            //1. Run Contact Duplicate Logic
            methods_Contact.checkContactDupe(CAdd, 'Update');
            
        }  
        methods_Contact.validateCommunityAccessTransition(newContacts,newMap,oldMap);
        methods_Contact.checkPartnerEnabled(newContacts,newMap,oldMap);
        methods_Contact.updateActiveInactiveValues(newContacts);
        //assign agent id
        methods_Contact.assignAgentIDonContact(newContacts);
    }   
}