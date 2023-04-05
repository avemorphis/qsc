//==================================================================================================
//  Class : Accounthirarchyhandler
//  Author: Uday Kumar K
//  Purpose: Aggregating Point and Perspective Point on Account
//==================================================================================================
//          Date            Purpose
// Changes: 05/20/2021      Initial Version
//                          
//==================================================================================================


public class AccountHierarchyHandler {
    
    public static boolean isRunOnce=true;
    
    public static void upateAccountPointOnInsert(List<Account> triggernew,Map<Id,Account> triggerold){
        AccountHierarchyHandler.isRunOnce=false;
        Set<Id> parentAccountset=new Set<ID>();
        Map<Id,Decimal> currentAccountPoit=new Map<Id,Decimal>();
        Map<Id,Decimal> accoutWithTotal=new Map<Id,Decimal>();
        Map<Id,Decimal> accoutWithProspectiveTotal=new Map<Id,Decimal>();
        Map<Id,List<Account>> parentwithAllChildMap = new Map<Id,List<Account>>();
        List<Account> ac_update=new List<Account>();
        
        for(Account ac:triggernew){
            if(ac.ParentId != null ){
                parentAccountset.add(ac.ParentId);
            }
        }
        
        for(Account act:[SELECT Id,F_Points__c,Aggregated_Points__c,F_Prospective_Points__c,Agreggated_Prospective_Points__c,ParentId FROM Account WHERE ParentId in: parentAccountset]){
            if(!accoutWithTotal.containsKey(act.ParentId)){
                accoutWithTotal.put(act.ParentId,0);
                accoutWithProspectiveTotal.put(act.ParentId,0);
            }
            Decimal temp = act.F_Points__c + accoutWithTotal.get(act.ParentId);
            accoutWithTotal.put(act.ParentId,temp);
            accoutWithProspectiveTotal.put(act.ParentId, act.F_Prospective_Points__c + accoutWithProspectiveTotal.get(act.ParentId));
            
            if(parentwithAllChildMap.isEmpty() || parentwithAllChildMap.get(act.ParentId) == null){
                parentwithAllChildMap.put(act.ParentId,new List<Account>{act}); 
            }else{
                List<Account> oldAccounts = new List<Account>();
                oldAccounts = parentwithAllChildMap.get(act.ParentId);
                oldAccounts.add(act);
                parentwithAllChildMap.put(act.ParentId,oldAccounts);
            }
        }
        
        for(Id act:parentAccountset){
            Account ac=new Account();
            ac.Id=act;
            ac.Aggregated_Points__c=accoutWithTotal.get(act);
            ac.Agreggated_Prospective_Points__c = accoutWithProspectiveTotal.get(act);
            ac_update.add(ac);
            
            for(Account acc : parentwithAllChildMap.get(act)){
                acc.Aggregated_Points__c=accoutWithTotal.get(act);
                acc.Agreggated_Prospective_Points__c = accoutWithProspectiveTotal.get(act);
                ac_update.add(acc);
            }
        }
        if(!parentAccountset.isEmpty()){
            update ac_update;
        }
    }
    
    public static void upateAccountPointOnUpdate(List<Account> triggerold,List<Account> triggernew,Map<Id,Account> triggeroldMap,Map<Id,Account> triggernewMap){
        AccountHierarchyHandler.isRunOnce=false;
        Set<Id> updateOldParent=new Set<Id>();
        Set<Id> updateNewParent=new Set<Id>();
        Map<Id,Decimal> accoutWithTotal=new Map<Id,Decimal>();
        Map<Id,List<Account>> parentwithAllChildMap = new Map<Id,List<Account>>();
        Map<Id,Decimal> accoutWithProspectiveTotal=new Map<Id,Decimal>();
        
        for(Account ac:triggernew){
            if(ac.ParentId != null || triggeroldMap.get(ac.Id).ParentId != null){
                if(ac.ParentId != triggeroldMap.get(ac.Id).ParentId){
                    if(triggeroldMap.get(ac.Id).ParentId != null){
                        updateOldParent.add(triggeroldMap.get(ac.Id).ParentId);
                    }
                    if(ac.ParentId != null){
                        updateNewParent.add(ac.ParentId);
                    }
                }else if(ac.F_Loyalty_Member__c != triggeroldmap.get(ac.Id).F_Loyalty_Member__c){
                    updateNewParent.add(ac.ParentId);
                }
            }
        }
        
        
        
        if(!updateOldParent.isEmpty()){
            for(Account act:[SELECT Id,F_Points__c,Aggregated_Points__c, F_Prospective_Points__c,Agreggated_Prospective_Points__c,ParentId FROM Account WHERE ParentId in: updateOldParent]){
                if(!accoutWithTotal.containsKey(act.ParentId)){
                    accoutWithTotal.put(act.ParentId,0);
                    accoutWithProspectiveTotal.put(act.ParentId,0);
                }
                Decimal temp=act.F_Points__c+accoutWithTotal.get(act.ParentId);
                accoutWithTotal.put(act.ParentId,temp);
                accoutWithProspectiveTotal.put(act.ParentId, act.F_Prospective_Points__c + accoutWithProspectiveTotal.get(act.ParentId));
                
                if(  parentwithAllChildMap.isEmpty() || parentwithAllChildMap.get(act.ParentId) == null){
                    parentwithAllChildMap.put(act.ParentId,new List<Account>{act}); 
                }else{
                    List<Account> oldAccounts = new List<Account>();
                    oldAccounts = parentwithAllChildMap.get(act?.ParentId);
                    oldAccounts.add(act);
                    parentwithAllChildMap.put(act?.ParentId,oldAccounts);
                }
            }
        }
        
        if(!updateNewParent.isEmpty()){
            
            for(Account act:[SELECT Id,F_Points__c,Aggregated_Points__c,F_Prospective_Points__c,Agreggated_Prospective_Points__c,ParentId FROM Account WHERE ParentId in: updateNewParent]){
                if(!accoutWithTotal.containsKey(act.ParentId)){
                    accoutWithTotal.put(act.ParentId,0);
                    accoutWithProspectiveTotal.put(act.ParentId,0);
                }
                Decimal temp=act.F_Points__c+accoutWithTotal.get(act.ParentId);
                accoutWithTotal.put(act.ParentId,temp);
                accoutWithProspectiveTotal.put(act.ParentId, act.F_Prospective_Points__c + accoutWithProspectiveTotal.get(act.ParentId));
                
                
                if(parentwithAllChildMap.isEmpty() || parentwithAllChildMap.get(act.ParentId) == null){
                    parentwithAllChildMap.put(act.ParentId,new List<Account>{act}); 
                }else{
                    List<Account> oldAccounts = new List<Account>();
                    oldAccounts = parentwithAllChildMap.get(act.ParentId);
                    oldAccounts.add(act);
                    parentwithAllChildMap.put(act.ParentId,oldAccounts);
                }
            }
        }
        
        
        Map<Id,Account> ac_update=new Map<Id,Account>();
        if(!updateOldParent.isEmpty()){
            for(Id act:updateOldParent){
                Account ac=new Account();
                ac.Id=act;
                ac.Aggregated_Points__c=accoutWithTotal.get(act);
                ac.Agreggated_Prospective_Points__c = accoutWithProspectiveTotal.get(act);
                ac_update.put(ac.Id,ac);
                
                if(parentwithAllChildMap?.containskey(act)  && !parentwithAllChildMap.get(act)?.isEmpty() ){
                    for(Account acc : parentwithAllChildMap.get(act)){
                        acc.Aggregated_Points__c=accoutWithTotal.get(act);
                        acc.Agreggated_Prospective_Points__c = accoutWithProspectiveTotal.get(act);
                        ac_update.put(ac.Id,ac);
                    }
                }
            }
        }
        
        for(Id act:updateNewParent){
            Account ac=new Account();
            ac.Id=act;
            ac.Aggregated_Points__c=accoutWithTotal.get(act);
            ac.Agreggated_Prospective_Points__c = accoutWithProspectiveTotal.get(act);
            ac_update.put(ac.Id,ac);
            
            for(Account acc : parentwithAllChildMap.get(act)){
                acc.Aggregated_Points__c=accoutWithTotal.get(act);
                acc.Agreggated_Prospective_Points__c = accoutWithProspectiveTotal.get(act);
                ac_update.put(ac.Id,ac);
            }
        }
        
        if(!ac_update.isEmpty()){
            update ac_update.values();
        } 
    }
    
    public static void upateAccountPointOnDelete(Map<Id,Account> triggeroldMap){
 		AccountHierarchyHandler.isRunOnce=false;
        upateAccountPointOnDeleteFuture(triggeroldMap.KeySet());
        
    }    
    
    @Future
	  public static void upateAccountPointOnDeleteFuture(SET<ID> oldMapIds){
          
        Set<Id> parentAccountset=new Set<ID>();
        Map<Id,Decimal> currentAccountPoit=new Map<Id,Decimal>();
        Map<Id,Decimal> accoutWithTotal=new Map<Id,Decimal>();
        Map<Id,Decimal> accoutWithProspectiveTotal=new Map<Id,Decimal>();
        Map<Id,List<Account>> parentwithAllChildMap = new Map<Id,List<Account>>();
        List<Account> ac_update=new List<Account>();
        
        for(Account ac:[Select Id,ParentId FROM Account where Id IN: oldMapIds]){
            if(ac.ParentId != null ){
                parentAccountset.add(ac.ParentId);
            }
        }
        
        for(Account act:[SELECT Id,F_Points__c,Aggregated_Points__c,F_Prospective_Points__c,Agreggated_Prospective_Points__c,ParentId FROM Account WHERE ParentId in: parentAccountset]){
            if(!accoutWithTotal.containsKey(act.ParentId)){
                accoutWithProspectiveTotal.put(act.ParentId,0);
            }
            Decimal temp = act.F_Points__c + accoutWithTotal.get(act.ParentId);
            accoutWithTotal.put(act.ParentId,temp);
            accoutWithProspectiveTotal.put(act.ParentId, act.F_Prospective_Points__c + accoutWithProspectiveTotal.get(act.ParentId));
            
            if(parentwithAllChildMap.isEmpty() || parentwithAllChildMap.get(act.ParentId) == null){
                parentwithAllChildMap.put(act.ParentId,new List<Account>{act}); 
            }else{
                List<Account> oldAccounts = new List<Account>();
                oldAccounts = parentwithAllChildMap.get(act.ParentId);
                oldAccounts.add(act);
                parentwithAllChildMap.put(act.ParentId,oldAccounts);
            }
        }
        
        for(Id act:parentAccountset){
            Account ac=new Account();
            ac.Id=act;
            ac.Aggregated_Points__c=accoutWithTotal.get(act);
            ac.Agreggated_Prospective_Points__c = accoutWithProspectiveTotal.get(act);
            ac_update.add(ac);
            
            if(parentwithAllChildMap.get(act) != null){
                for(Account acc : parentwithAllChildMap.get(act)){
                    acc.Aggregated_Points__c=accoutWithTotal.get(act);
                    acc.Agreggated_Prospective_Points__c = accoutWithProspectiveTotal.get(act);
                    ac_update.add(acc);
                }
            }
        }
        
        if(!parentAccountset.isEmpty()){
            update ac_update;
        } 
       
      }
}