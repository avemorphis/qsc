public class ObjectClone {
   public static List<sObject> cloneObjects(String ObjectName,string recordId,list<Id> recordidList){   
    string fields = getAllFieldsDynamically(ObjectName);
    if(string.isNotBlank(fields)){
        String allSObjectFieldsQuery ='';
        if(String.isNotBlank(recordId)){
            allSObjectFieldsQuery = 'SELECT ' + fields +' from '+ObjectName +' where Id='+'\''+recordId+'\''; 
        }
        else if(recordidList != null && !recordidList.isEmpty()){
            allSObjectFieldsQuery = 'SELECT ' + fields +' from '+ObjectName +' where Id IN: recordidList'; 
        }
        if(string.isNotBlank(allSObjectFieldsQuery)){
            List<sObject> recordDataList = new List<sObject>();
            for(sObject recordData : Database.query(allSObjectFieldsQuery)){
                recordData.Id = null;
                recordDataList.add(recordData.clone(true,true,false,false));
            }
            return recordDataList;
        }
        return null;
    }else{
        return null;
    }
  }
  public static String getAllFieldsDynamically(String sobjectname){
    Set<String> SobjectFields = Schema.getGlobalDescribe().get(sobjectname).getDescribe().fields.getMap().keySet();    
    List<String> fieldsInList = new List<String>(SobjectFields);
    string objFields ='';
    for(String field: fieldsInList ){
        if(String.isNotBlank(objFields)){
            objFields+= ',' + field;
        }
        else{
            objFields = field;
        }
    }
    return objFields;
  }
  public static String getAllFieldsFromMetaData(String sobjectname){
      Object_Clone__mdt objClone = [select MasterLabel,Fields__c from Object_Clone__mdt where MasterLabel =:sobjectname];
      return objClone.Fields__c;
  }
}