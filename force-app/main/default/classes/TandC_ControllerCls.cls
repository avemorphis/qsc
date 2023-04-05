/**
* @File Name          : TandC_ControllerCls.cls
* @description        : Class for TandCForCommunity Component
* @Author             : prakhar.jain@QSC.com
* @Group              : 
* @Last Modified By   : prakhar.jain@QSC.com
* @Last Modified On   : 10/06/2022
* @Modification Log   : 
* Ver       Date            Author                  Modification
* 1.0    11/04/2022   prakhar.jain@QSC.com     Initial Version
**/
public class TandC_ControllerCls
{
    //To check if the user is login for the first time and returning T&C for community
    @AuraEnabled
    public static String validateUser()
    {
        Id userId = UserInfo.getUserId();
        String commId = Network.getNetworkId();
        User u = [SELECT Id, T_C_For_Communities__c FROM User WHERE Id =: userId]; 
        String TandCDetails = '';
        system.debug('commId'+commId);
        List<Terms_And_Conditions__c> tandCondList = [SELECT id,Order__c,Terms_Data__c,Community_ID__c from Terms_And_Conditions__c where  Community_ID__c =: commId order by Order__c ASC];
        If(tandCondList!=null && !tandCondList.isEmpty() && (String.isBlank(u.T_C_For_Communities__c) || (String.isNotBlank(u.T_C_For_Communities__c) && !(u.T_C_For_Communities__c).contains(commId))))
        {
           for(Terms_And_Conditions__c tandc : tandCondList){
                TandCDetails += tandc.Terms_Data__c+'\n';
           } 
        }
        return TandCDetails;
    }
    
    //When user accepts terms and condition it will update community name on user
    @AuraEnabled
    public static String updateUser()
    {
        Id userId = UserInfo.getUserId();
        String commId = Network.getNetworkId();
        if(Test.isRunningTest()){
            commId = [SELECT Id,Name FROM Network WHERE name ='cpp'].Id;
        }
        List<Network> netList = [SELECT Id,Name FROM Network WHERE Id =: commId];
        User u = [SELECT Id, T_C_For_Communities__c FROM User WHERE Id =: userId];
        if(netList!=null && !netList.isEmpty()){
            If(String.isNotBlank(u.T_C_For_Communities__c))
            {
                String str = u.T_C_For_Communities__c;
                If(!str.contains(netList[0].Id))
                {
                    u.T_C_For_Communities__c = str+';'+netList[0].Id;
                }
            }
            else If(String.isBlank(u.T_C_For_Communities__c) )
            {
                u.T_C_For_Communities__c = netList[0].Id; 
            }
            Update u;
        }
        
        system.debug('u.T_C_For_Communities__c'+u.T_C_For_Communities__c);
        return u.T_C_For_Communities__c;  
    }
}