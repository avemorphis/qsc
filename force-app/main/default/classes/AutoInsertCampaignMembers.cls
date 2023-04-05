public class AutoInsertCampaignMembers {
    Public static void InsertCampaignMember(List<Contact> newContacts,map<id,contact> oldMap,map<id,contact> newMap)
    {
        Set<String>Regions = new Set<String>();
        Set<Id> accountIds = new Set<Id>();
        for(Contact con: newContacts)
        {
            accountIds.add(con.accountId);
            Regions.add(con.Region_Oracle_F__c);
        }
        List<account> accList = [SELECT Id,Account_Type__c,Region_Oracle__c,Customer_Class__c,Account_Pricebook__c,Territory_Oracle__c,Subregion_Oracle__c,Suggested_Auth_Price_List__c FROM account WHERE Id IN: accountIds];
        Map<ID,Account> conAccountMap = new Map<ID,Account>();
        for(Contact con: newContacts)
        {
            for(Account acc: accList)
            {
                IF(acc.id == con.AccountId)
                {
                    conAccountMap.put(con.id,acc);
                    break;
                }
            }
        }
        map<id,List<Campaign_member_Insert__mdt>> mapCampIdmdt = new map<id,List<Campaign_member_Insert__mdt>>();
        Set<ID> CampaignmembersId = new Set<ID>();
        List<Campaign_member_Insert__mdt> memberMgtList = [SELECT Account_SubRegion__c, Account_Price_Book_Id__c,Account_Type__c ,Business_Unit__c,CampaignId__c,Community_Attribute__c,IsActive__c,Region_Oracle__c,Suggested_Auth_Price_List__c,Account_Territory__c FROM Campaign_member_Insert__mdt WHERE Region_Oracle__c IN:Regions AND Isactive__c = true];
        for(Campaign_member_Insert__mdt mml: memberMgtList)
        {
            CampaignmembersId.add(mml.CampaignId__c);
        }
        for(Id cId : CampaignmembersId)
        {
            List<Campaign_member_Insert__mdt> mgtList = new List<Campaign_member_Insert__mdt>();
            for(Campaign_member_Insert__mdt mml: memberMgtList)
            {
                if(cId == mml.CampaignId__c)
                {
                    mgtList.add(mml);
                }
            }
            mapCampIdmdt.put(cId,mgtList);
        }
        
        MAP<id,LIST<CampaignMember>> conCamMemberMap = new MAP<id,LIST<CampaignMember>>();
        
        system.debug('Contact : ' + newContacts);
        List<CampaignMember> allCampaignmembers = [Select Id,ContactId,CampaignId from CampaignMember WHERE  CampaignId IN: CampaignmembersId AND ContactId IN: newMap.keySet()];
        system.debug('CampaignMember : ' + allCampaignmembers);
        For(Contact con : newContacts)
        {
            List<CampaignMember>camList = new List<CampaignMember>();
            For(CampaignMember cm : allCampaignmembers)
            {
                IF(cm.contactid == con.id)
                {
                    camList.add(cm);
                }
            }
            If(camList.Size()>0)
            {
                conCamMemberMap.put(con.id,camList);
            }
        }
        List<CampaignMember> insertList = new List<CampaignMember>();
        List<CampaignMember> deleteList = new List<CampaignMember>();
        For(Contact con : newContacts)
        {
            For(Id CamID : mapCampIdmdt.keyset())
            {
                List<Campaign_member_Insert__mdt> mgtList = mapCampIdmdt.get(CamID);
                Integer camListSize = mgtList.size();
                List<CampaignMember> alreadyCam = new List<CampaignMember>();
                integer count=0;
                IF(conCamMemberMap.containsKey(con.id))
                {
                    alreadyCam = conCamMemberMap.get(con.id);
                    for(CampaignMember cam : alreadyCam)
                    {
                        IF(cam.CampaignId == CamID && cam.ContactId == con.Id)
                        {
                            count++;
                            Integer NotIncluded = 0;
                            For(Campaign_member_Insert__mdt cmi : mgtList)
                            {
                                IF(con.Communication_Attributes__c== NULL || !con.Communication_Attributes__c.contains(cmi.Community_Attribute__c))
                                {
                                    NotIncluded ++;
                                }
                            }
                            IF(NotIncluded == camListSize)
                            {
                                deleteList.add(cam);
                            }
                        }
                    }
                }
                system.debug('count '+count);
                If(count == 0)
                {
                    INTEGER accType=0,accReg=0,accClass=0,accPrice = 0,accTerr=0;
                    INTEGER accSub=0,accsug=0,conComm=0;
                    For(Campaign_member_Insert__mdt cmi : mgtList)
                    {
                        //added null checks below for mainAcc
                        Account mainAcc = conAccountMap.get(con.id);
                        If(cmi.Account_Type__c == NULL || (mainAcc!=null && mainAcc.Account_Type__c == cmi.Account_Type__c))
                        {
                            accType = 1;
                        }
                        If(cmi.Region_Oracle__c == NULL || (mainAcc!=null && mainAcc.Region_Oracle__c == cmi.Region_Oracle__c))
                        {
                            accReg = 1;
                        }
                        If(cmi.Business_Unit__c == NULL || (mainAcc!=null && mainAcc.Customer_Class__c == cmi.Business_Unit__c))
                        {
                            accClass = 1;
                        }
                        If(cmi.Account_Price_Book_Id__c == NULL || (mainAcc!=null && mainAcc.Account_Pricebook__c == cmi.Account_Price_Book_Id__c))
                        {
                            accPrice = 1;
                        }
                        If(cmi.Account_Territory__c == NULL || (mainAcc!=null && mainAcc.Territory_Oracle__c == cmi.Account_Territory__c))
                        {
                            accTerr = 1;
                        }
                        If(cmi.Account_SubRegion__c == NULL || (mainAcc!=null && mainAcc.Subregion_Oracle__c == cmi.Account_SubRegion__c))
                        {
                            accSub = 1;
                        }
                        If(cmi.Suggested_Auth_Price_List__c == NULL ||(mainAcc!=null &&  mainAcc.Suggested_Auth_Price_List__c == cmi.Suggested_Auth_Price_List__c))
                        {
                            accsug = 1;
                        }
                        If( con.Communication_Attributes__c != NULL && (cmi.Community_Attribute__c == NULL || con.Communication_Attributes__c.contains(cmi.Community_Attribute__c)) )
                        {
                            conComm = 1;
                        }
                    }
                    If(accType == 1 && accReg == 1 && accClass == 1 && accPrice == 1 && accTerr == 1 && accSub == 1 && accsug == 1 && conComm == 1)
                    {
                        CampaignMember camMem = new CampaignMember();
                        camMem.CampaignId = CamID;
                        camMem.ContactId = con.Id;
                        camMem.Status = 'New';
                        insertList.add(camMem);
                    }
                }
            }
        }
        Delete deleteList;
        Insert insertList;
    }
}