public class CreateStagingContactHandler {
    public Map<Id,Higher_Ed__c> higherEdMap=new Map<Id,Higher_Ed__c>();
    public List<Higher_Ed__c> updateHigherEd = new List<Higher_Ed__c>();
    public Map<Id,Staging_Contact__c> map_higherEdtoStagingContact = new Map<Id,Staging_Contact__c>();
    public CreateStagingContactHandler(Map<Id,Higher_Ed__c> higherEdMap){
        this.higherEdMap = higherEdMap;
        mapFields();
    }
    //map higher ed fields to staging contact
    public void mapFields(){
           for(Higher_Ed__c hed : this.higherEdMap.values()){
                Staging_Contact__c  newSc = new Staging_Contact__c (); 
                newSc.Company__c = hed.Company__c;
                newSc.Email_Opt_In__c = hed.Email_Opt_In__c;
                newSc.First_Name__c = hed.First_Name__c;
                newSc.Last_Name__c = hed.Last_Name__c;
                newSc.Email__c = hed.Email_Address__c;
                newSc.Mailing_Country__c = hed.Country__c;
                newSc.Phone__c = hed.Phone_Number__c;
                map_higherEdtoStagingContact.put(hed.id, newSc);
           }
        if(map_higherEdtoStagingContact!=null && map_higherEdtoStagingContact.values().size()>0)
            insert map_higherEdtoStagingContact.values(); //staging contact inserted, staging process starts, contact record will get created.
        List<Higher_Ed__c> lstHigherEd = [select id,name,Staging_Contact__c from Higher_Ed__c where id in:this.higherEdMap.keyset()];
        for(Higher_Ed__c hed : lstHigherEd){
            //linking higher ed record to respective staging contact.
            hed.Staging_Contact__c = map_higherEdtoStagingContact.get(hed.id).id;
            updateHigherEd.add(hed);
        }
        if(updateHigherEd!=null && updateHigherEd.size()>0)
            update updateHigherEd;
      mapHigherEdtoContact(map_higherEdtoStagingContact.values());
    }
    //map higher ed's remaining fields to contact and link higher ed to the respective contact.
    public void mapHigherEdtoContact(List<Staging_Contact__c> lstContact){
        
        List<Id> lstRecId = new List<Id>();
        List<Contact> updateCon = new List<Contact>();
        List<higher_ed__c> updateHigherEd = new List<higher_ed__c>();
        for(Staging_Contact__c stg : lstContact){
            if(stg.id!=null){
                lstRecId.add(stg.id);
            }
        }
        if(lstRecId!=null && lstRecId.size()>0){
            List<Staging_Contact__c> lstStgContact = [select id, (select id, Staging_Contact__c, Job_Title__c, Installed_managed_Q_SYS_system_in_past__c, Preferred_Language__c,Live_Sound__c,Cinema__c,Systems__c from Higher_Ed__r),(select id, title, languages__c,Installed_managed_Q_SYS_system_in_past__c, Self_Identified_Interests__c, Systems_Self_Identified_Interests__c, Self_Identified_Interests_Cinema__c,Contact_Attributes__c from Contacts__r) from Staging_Contact__c where id=:lstRecId];
            for(Staging_Contact__c sc : lstStgContact){
                system.debug('>>>> h '+sc.higher_ed__r);
                system.debug('>>>> c'+sc.contacts__r);
                if(sc.Contacts__r!=null && sc.Contacts__r.size()>0){
                    Contact c = sc.Contacts__r[0];
                    if(sc.higher_ed__r!=null && sc.higher_ed__r.size()>0){
                        Higher_Ed__c h = sc.higher_ed__r[0];
                        c.Title = h.Job_Title__c;
                        c.Installed_managed_Q_SYS_system_in_past__c = h.Installed_managed_Q_SYS_system_in_past__c;
                        c.Languages__c = h.Preferred_Language__c;
                        c.Self_Identified_Interests__c = h.Live_Sound__c;
                        c.Self_Identified_Interests_Cinema__c = h.Cinema__c;
                        c.Systems_Self_Identified_Interests__c = h.Systems__c;
                        if (c.Contact_Attributes__c!=null && !c.Contact_Attributes__c.contains('Higher Education')){
                            c.Contact_Attributes__c+='; Higher Education';
                        }else if(c.Contact_Attributes__c==null){
                            c.Contact_Attributes__c='Higher Education';
                        }
                        h.Contact__c = c.id;
                        updateCon.add(c);
                        updateHigherEd.add(h);
                    }
                }
            }
            if(updateCon!=null && updateCon.size()>0)
                update updateCon;
            if(updateHigherEd!=null && updateHigherEd.size()>0)
                update updateHigherEd;
        }
    }
    
}