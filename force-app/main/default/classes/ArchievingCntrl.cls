/**

* @description        : ArchievingCntrl class for fetching Chatter group and archieve and unarchieve group
* @Author             : aniruddha.vashishthe@qsc.com
* @Last Modified By   : aniruddha.vashishthe@qsc.com
* @Last Modified On   : 15/12/2022
* @Modification Log   : 
* Ver       Date            Author      		    		Modification
* 1.0    15/12/2022     aniruddha.vashishthe@qsc.com       Initial Version
**/
public class ArchievingCntrl {

    @AuraEnabled
    public static DefaultAndSelectedValues fetchGroupData()
    {
        List<Community> commData = [SELECT Id, NetworkId, Name FROM Community Where Id =: System.label.Dev_Com_Community_Id];
        set<Id> netIds = new set<Id>();
        for(Community com : commData)
        {
            netIds.add(com.NetworkId);
        }
        List<CollaborationGroup> groups = [SELECT Id, Name, NetworkId, IsArchived FROM CollaborationGroup where NetworkId IN: netIds];
        List<LabelValueWrapper> allLabelValuePair = new List<LabelValueWrapper>();
    	List<String> selectedValues = new List<String>();
        for(CollaborationGroup cg: groups)
        {
            LabelValueWrapper labelValueWrapper = new LabelValueWrapper();
            labelValueWrapper.label = cg.Name;
            labelValueWrapper.value = cg.Id;
            if(cg.IsArchived == true)
            {
                selectedValues.add(cg.Id);
            }
            allLabelValuePair.add(labelValueWrapper);
        }
        
        DefaultAndSelectedValues defaultAndSelectedValues = new DefaultAndSelectedValues();
        defaultAndSelectedValues.allLabelValuePair = allLabelValuePair;
        defaultAndSelectedValues.selectedValues = selectedValues;
        return defaultAndSelectedValues;
    }
    
    public class DefaultAndSelectedValues{
    @AuraEnabled public List<LabelValueWrapper> allLabelValuePair;
    @AuraEnabled public List<String> selectedValues;
}
    
    public class LabelValueWrapper {
    @AuraEnabled public String label;
    @AuraEnabled public String value;
}
    @AuraEnabled
    public static void setGroupData(List<String> archieveIds, List<String> unArchieveIds)
    {
        System.debug('archieveIds---'+archieveIds);
        List<String> unArchievedList = new List<String>();
        for(String strId : unArchieveIds)
        {
            if(!archieveIds.contains(strId))
            {
                unArchievedList.add(strId);
            }
        }
        List<CollaborationGroup> groupData = new List<CollaborationGroup>(); 
        //To UnArchieved non-selected groups
        List<CollaborationGroup> groupDt = [SELECT Id, Name, IsArchived FROM CollaborationGroup where Id IN: unArchievedList];
        for(CollaborationGroup cg : groupDt)
        {
            cg.IsArchived = false;
        }
        //To Archieve selected Groups
        if(archieveIds.isEmpty())
        {
            groupData = [SELECT Id, Name, IsArchived FROM CollaborationGroup where IsArchived = true];
            for(CollaborationGroup cg : groupData)
            {
                cg.IsArchived = false;
            }
        }
        else
        {
            groupData = [SELECT Id, Name, IsArchived FROM CollaborationGroup where Id IN: archieveIds];
            for(CollaborationGroup cg : groupData)
            {
                cg.IsArchived = true;
            }
        }
       
        try{
            if(groupData.size() > 0)
            {
                update groupData;
                update groupDt;
            }
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }

    }
}