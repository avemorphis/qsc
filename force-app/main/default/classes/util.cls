/*
This class is to populate the project information-related fields on the opportunity.
Author : Anil Madithati 

*/

Public without Sharing class util{
public static boolean firstRun = true;
public static void OpptyProjfieldsAutoPopulate(Map<id,Opportunity>optyMap){
system.debug('optyLst***'+optyMap);
List<Opportunity> updOpptyLst = new List<Opportunity>();
Set<ID> pids=new Set<ID>();
Set<ID> oids=new Set<ID>();
for(Opportunity o1 : optyMap.values()){ 
pids.add(o1.Projects__c);
oids.add(o1.id);
system.debug('projectid***'+o1.Projects__r.id);
}
Map<id, Projects__c> ProjMap = new Map<id, Projects__c> ([Select id,City__c,Project_US_State__c,Country__c,Project_region__c, Estimated_Budget__c,Estimated_Close_Date__c,Estimated_Bid_Date__c from Projects__c where id IN: pids]);
Map<id, Opportunity> OptyMap1 = new Map<id, Opportunity > ([Select id,Projects__c from Opportunity  where id IN:oids]);
system.debug('Map***'+ProjMap);
 for(id oid: oids){ 
 Opportunity o= OptyMap1.get(oid);
 system.debug('Project***'+ProjMap.get(o.Projects__c));
  o.Project_City__c = ProjMap.get(o.Projects__c).City__c;
  o.Project_US_State__c = ProjMap.get(o.Projects__c).Project_US_State__c;
  o.Project_Country__c = ProjMap.get(o.Projects__c).Country__c;
  o.Project_Regions__c = ProjMap.get(o.Projects__c).Project_region__c;
  o.Budget__c = ProjMap.get(o.Projects__c).Estimated_Budget__c;
  o.Est_Close_Date__c = ProjMap.get(o.Projects__c).Estimated_Close_Date__c;
  o.Bid_Date__c = ProjMap.get(o.Projects__c).Estimated_Bid_Date__c;
  updOpptyLst.add(o);
 }
 if(updOpptyLst.size()>0){
    firstRun = false;
    Database.update(updOpptyLst);}
}

public static void updateContactOwner(set<ID>acIds,Map<ID,Account> acMap){

List<Contact> updateList = new List<Contact>();
List<Contact> conList=[select ID,AccountID,OwnerID from contact where AccountID in : acIds];
//Map<ID,Account> acMap=new Map<ID,Account>();
if(conList.size()>0){

for(Contact con : conList) {
   con.ownerID = acMap.get(Con.AccountID).OwnerID;
   updateList.add(con);
    }
    if(updateList.size()>0){update updateList;}
    }
    }

}