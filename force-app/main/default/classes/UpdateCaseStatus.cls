/*
*******************************************************************************************
# FILE...UpdateCaseStatus
# VERSION...............................:
# CREATED BY...Juli Kumari
# CREATED DATE....4th May 2022
# LAST MODIFIED BY......................:
# LAST MODIFIED DATE....................:
*******************************************************************************************
# AUTHOR...Juli Kumari
# DESCRIPTION...Apex class for Update case status to Open when file attach to case and case satus is pending clouser and 
                pending clouser date is less than 5.
# CHANGE/ BUG FIX LOG...................:
******************************************************************************************
*/


public class UpdateCaseStatus {
    public static void caseStatusToOpen(List<ContentDocumentLink> attchList){
        system.debug('attchList==>'+attchList);
        Set<Id> stCaseIds =  new Set<Id>();
        List<Case> lstCasesToUpdate = new List<Case>();
        string pClose;
        string clsp;
        
        for(ContentDocumentLink att : attchList){
            String parentId=String.valueOf(att.LinkedEntityId);
            If(parentId != null && String.valueOf(parentId).startsWith('500')){
                stCaseIds.add(parentId);
                system.debug('stCaseIds'+stCaseIds);
            }  
        }
        
        if(!stCaseIds.isEmpty()){
            //string userProfileId=userinfo.getProfileId();
            Profile userProfile = [SELECT Id FROM Profile WHERE Name='External User CCP Login'];
            if(userProfile.Id != UserInfo.getProfileId())
                return;
            for(Case cas:[SELECT Id, ContactId,Pending_Customer_Response_DurationV2__c,Case_Status_Date__c,Status 
                          FROM Case WHERE Id IN: stCaseIds AND Status = 'Pending Closure' AND New_Attachment__c = true]){
                          // if(userProfileId=='00e4X000002OtWc'){
                              system.debug('cas==>'+cas);
                              //cas.Toggle__c = true;
                              cas.status = 'Open'; 
                              lstCasesToUpdate.add(cas);
                             system.debug('lstCasesToUpdate'+lstCasesToUpdate);
                           //}
                       }        
        }
        system.debug('lstCasesToUpdate>'+lstCasesToUpdate);
        if(!lstCasesToUpdate.isEmpty()){
            update lstCasesToUpdate; 
            system.debug('lstCasesToUpdate>'+lstCasesToUpdate);
        }
    }
    
}