public class CloneOpportunityController {
    @AuraEnabled
    public static void CreateCloneOpp(string oppId, string accId,string currencyCode) {
        System.debug('oppId'+ oppId + ' '+' accId'+accId+ currencyCode);
        if(oppId !=null){
            Account acc = new Account();
            if(accId!=null){
                acc = [select id,name,Account_Pricebook__c from account where id =:accId];
            }
            List<Opportunity> OppList = (List<Opportunity>)ObjectClone.cloneObjects('Opportunity',oppId,null);
            Id oppGlobalRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Global Opportunity').getRecordTypeId();
            if(OppList!=null && !OppList.isEmpty()){
                OppList[0].currencyISOCode = currencyCode;
                OppList[0].AccountId = accId;
                OppList[0].Pricebook2Id = acc.Account_Pricebook__c;
                OppList[0].Subscription_ID__c ='';
                OppList[0].RecordTypeId = oppGlobalRT;
                OppList[0].Global_Parent_Opportunity__c = oppId;
                insert OppList;
                List<SBQQ__Quote__c> quoteRList = [select id,Name from SBQQ__Quote__c where SBQQ__Opportunity2__c =:oppId limit 1 ];
                if(quoteRList!=null && !quoteRList.isEmpty()){
                    List<SBQQ__Quote__c> quoteRCList = (List<SBQQ__Quote__c>)ObjectClone.cloneObjects('SBQQ__Quote__c',quoteRList[0].Id,null);
                    if(quoteRCList!=null && !quoteRCList.isEMpty()){
                        quoteRCList[0].SBQQ__Opportunity2__c = OppList[0].Id;
                        quoteRCList[0].SBQQ__Account__c = accId;
                        quoteRCList[0].SBQQ__Partner__c = accId;
                        quoteRCList[0].SBQQ__PriceBook__c = acc.Account_Pricebook__c;
                        insert quoteRCList ;
                        SBQQ__Quote__c qt = [select id,Name from SBQQ__Quote__c where id =:quoteRCList[0].Id limit 1 ];
                        System.debug('qt'+qt);
                        List<Id> qliIdList = new List<Id>();
                        for(SBQQ__QuoteLine__c qli :[select id,Name from SBQQ__QuoteLine__c where SBQQ__Quote__c =: quoteRList[0].Id]){
                            qliIdList.add(qli.Id);
                        }
                        if(qliIdList!=null && !qliIdList.isEmpty()){
                            List<SBQQ__QuoteLine__c > qliRecCloneInsert = (List<SBQQ__QuoteLine__c>)ObjectClone.cloneObjects('SBQQ__QuoteLine__c',null,qliIdList);
                            for(SBQQ__QuoteLine__c sqli: qliRecCloneInsert){
                                sqli.SBQQ__Quote__c = quoteRCList[0].Id;
                                sqli.Price_Book__c = acc.Account_Pricebook__c;
                                sqli.CurrencyIsoCode = currencyCode;
                            }
                            database.insert(qliRecCloneInsert,false);
                        }
                    }
                }
            }
        }
    }
}