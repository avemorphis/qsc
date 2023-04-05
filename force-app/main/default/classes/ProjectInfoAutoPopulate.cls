public class ProjectInfoAutoPopulate {

public Opportunity op {get;set;}
public String recordId {get;set;}

public ProjectInfoAutoPopulate(ApexPages.StandardController controller) {
       if(recordId == null){
          recordId = ApexPages.currentPage().getParameters().get('id');
        }
          getData(recordId);
        }
        
 public void getData(String recordId){
 
  try{
       op = [SELECT Project_City__c,Projects__c,Project_ID__c,Project_US_State__c,Project_Country__c,Project_Regions__c,Budget__c,Est_Close_Date__c ,Bid_Date__c FROM opportunity WHERE id =: recordId  Limit 1];
                                        System.debug('XX:'+op);
                      
       }catch(Exception e){}
 }
}