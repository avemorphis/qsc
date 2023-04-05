@isTest
public class CloneOpportunityController_Test{
    Public static testMethod void CreateCloneOpp(){
        NFR_API__c nfrSettingRecord = new NFR_API__c();
        nfrSettingRecord.Name = 'Case Trigger';
        nfrSettingRecord.EndPoint_url__c = 'https://web-apid01.qsc.com/api/Reflect/ExtendNFRDemoRequest';
        nfrSettingRecord.Password__c = 'test';
        nfrSettingRecord.QueueURL__c = 'https://web-apid01.qsc.com/api/Reflect/ExtendNFRDemoRequest';
        nfrSettingRecord.Token_url__c = 'https://web-apid01.qsc.com/token';
        nfrSettingRecord.Username__c = 'test';
        nfrSettingRecord.x_function_key__c = '100';
        insert nfrSettingRecord;
        Account acc= new account(name='testAccount', 
                                 Previous_2_FY__c= 100,
                                 FY_20__c=100,
                                 Previous_FY__c=200,
                                 FY_21__c=200
                                );
        insert acc;
        Id OppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Global Opportunity').getRecordTypeId();
        opportunity opp = new opportunity (name = 'testOpportunity',accountId = acc.id,stagename = 'Draft', CloseDate = system.today(), recordtypeid = OppRecordTypeId);
        insert opp;
        SBQQ__Quote__c quot = new SBQQ__Quote__c();
        quot.SBQQ__Partner__c = acc.Id;
        quot.SBQQ__Opportunity2__c = opp.Id;
        insert quot;
        CloneOpportunityController.CreateCloneOpp(opp.Id,acc.Id,'USD');
        ObjectClone.getAllFieldsFromMetaData('Opportunity');
        
    }

}