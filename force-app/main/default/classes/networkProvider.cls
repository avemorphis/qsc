/**

* @description        : networkProvider class for fetching network and storing related data in custom setting
* @Author             : prakhar.jain@qsc.com
* @Last Modified By   : prakhar.jain@qsc.com
* @Last Modified On   : 30/12/2022
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    30/12/2022     prakhar.jain@qsc.com       Initial Version
**/

public with sharing class networkProvider {
    //Method for fetching all the network id which are active in community
    @AuraEnabled(Cacheable=true)
    public static List<Network> getCommunity()
    {
        return [SELECT Id,Name FROM Network WHERE STATUS =:'Live'];
    }
    
    //*****************************************************************************************************//
    
    //Method  for inserting/updating Dynamic fields in custom setting dynamic_field__c object
    @AuraEnabled
    public static string saveFields( Id strRecordType, Id strCommunity, string strCaseField){
        
        //Checking if all the fields have value, if not then return false
        if(!string.isBlank(strRecordType) && !string.isBlank(strCommunity) && !string.isBlank(strCaseField))
        {
            string recordTypeName = [SELECT Name, Id FROM RecordType WHERE ID=:strRecordType].NAME;
            string communityName = [SELECT Id,Name FROM Network WHERE ID =:strCommunity].NAME;
            
            //Combining Record Type Name and Community Name to create new abbrevation for Name in Dynamic Field
            string abbreName = recordTypeName.substring(0,3) + communityName.substring(0,3);
            system.debug('DataSet Name: '+abbreName);
            
            //Querying all the records of Dynamic Fields Custom setting with same Name field
            List<dynamic_field__c> existingRecord =[SELECT Id, Name, Record_Type__c, Community_Type__c, Selected_Case_Fields__c from dynamic_field__c WHERE Name =:abbreName+' DataSet'];
            system.debug('Existing record found: '+existingRecord);
            
            //Checking if above query has existing custom record or not
            IF(existingRecord.isEmpty())
            {
                //If list is empty then insert Record
                dynamic_field__c objDynamic = new dynamic_field__c(Name= abbreName+' DataSet', Record_Type__c= recordTypeName, 	Community_Type__c=communityName, 	Selected_Case_Fields__c= strCaseField);
                INSERT objDynamic;
                system.debug('Custom setting: '+objDynamic);
                return 'Custom Record Created Successfully';
            }
            ELSE
            {
                //If list consist existing reocord then update record
                FOR(dynamic_field__c obj:existingRecord )
                {
                    obj.Selected_Case_Fields__c = strCaseField;
                    
                }
                UPDATE existingRecord;
                
                return 'Custom Record Updated Successfully....!';
            }
        }
        Else 
        {
            return 'False';
        }
    }
    //*****************************************************************************************************//
    
    //Method called by LWC for showing Dynamic Field Datatable stored in custom  setting
    @AuraEnabled
    public static string fetchRecievedField(string strRecordType){
        
        
        Map<string, string> returnMap = new Map<string, string>();// creating map for returning fields, labels, and data
        List<string> fieldLabelLst = new List<string>();//Creating list for storing field's label
        
        string networkName;
        string caseFields;
        
        //When Test class is running fetch network Name
        if(Test.isRunningTest())
        {
            networkName= [SELECT Id, Name, Network.Name FROM Community where networkId='0DB4X000000wkLpWAI'].Network.Name;
            system.debug('Network Name: '+networkName);
        }
        ELSE
        {
            //Fetching Network Name from current network id in community
            networkName= [SELECT Id, Name, Network.Name FROM Community where networkId=:Network.getNetworkId()].Network.Name;
            system.debug('Network Name: '+networkName);
        }   
        
        //Querying Selected_Fields field from Dynamic_Field custom setting object
        
        if(Test.isRunningTest())
        {
            string caseFieldTest = 'CaseNumber,Status,RecordTypeId,Request_RMA__c,CreatedDate';
            system.debug('network name: '+networkName);
            system.debug('Record Name name: '+strRecordType);
            
            caseFields = [SELECT Selected_Case_Fields__c from dynamic_field__c WHERE Community_Type__c=:networkName and Record_Type__c=:strRecordType].Selected_Case_Fields__c;
            system.debug('#####: '+caseFields);
        }   
        else
        {
            caseFields = [SELECT Selected_Case_Fields__c from dynamic_field__c WHERE Community_Type__c=:networkName and Record_Type__c=:strRecordType].Selected_Case_Fields__c;
            system.debug('#####: '+caseFields);
        }
        //0DB4X000000wkLzWAI
        // converting received string type caseFields into array
        string[] fieldLst = caseFields.split(',');
        system.debug('Seperated list: '+fieldLst);
        
        //Creating Dynamic Query case fields based on recieved caseFields
        //*************************************
        string query = 'SELECT ';
        
        // Adding all the fields recieved from custom setting
        for( integer i=0; i<fieldLst.size(); i++)
        {
            //Getting Field Label from the field list
            string fieldLabel2 =(String)Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap().get(fieldLst[i]).getDescribe().getLabel();
            
            fieldLabelLst.add(fieldLabel2);
            system.debug('Field Label: '+fieldLabel2);
            
            
            if(fieldLst[i]=='RecordTypeId')
            {
                query += 'Case_Record_Type__c, ';
            }
            else
            {
                query += fieldLst[i] +', ';
            }
            
        }
        
        //Adding the object and condition
        query += 'Id From Case WHERE Case_Record_Type__c = \''+ strRecordType+'\'ORDER BY CreatedDate DESC  ';
        //*******************************************************
        
        //Querying the dynamic query and storing result in list
        system.debug('Final query: '+query);
        List<SObject> lstRecord = database.query(query);
        //system.debug('Record Type Name: '+lstRecord[0]);
        
        //Adding field list, field label list and data to the map
       
        returnMap.put('FIELD_LIST', json.serialize(fieldLst));
        returnMap.put('RECORD_LIST', json.serialize(lstRecord));
        returnMap.put('FIELD_LABEL', json.serialize(fieldLabelLst));
        
        //Returning map in string format to the js Controller
        return json.serialize(returnMap);
    }
}