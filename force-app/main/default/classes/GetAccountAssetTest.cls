@isTest
public class GetAccountAssetTest {
    
    @testSetup
    public static void testData(){
        Account acc = new Account(Name = 'Account Asset 1');
        insert acc;
        Asset assetRecord = new Asset(Name = 'Asset 1' ,AccountId = acc.Id);
        insert assetRecord;
        Id assetid = assetRecord.id;
        Contract conRec = new Contract(AccountId = acc.Id , Status ='Draft',StartDate = system.today(),
                                       Certification__c = 5,Verification__c=5,Scoping__c=3);
        insert conRec;
        conRec.Status = 'Activated';
        update conRec;
        NFR_API__c apiCS=new NFR_API__c();
        apiCS.EndPoint_url__c='https://web-api02.qsc.com/api/Reflect/ExtendNFRDemoRequest';
        apiCS.Token_url__c='https://web-api02.qsc.com/token';
        apiCS.Name='Case trigger';
        apiCS.Password__c='test123';
        apiCS.Username__c='test123';
        apiCS.QueueURL__c='https://qschttptriggerdev.azurewebsites.net/api/v1/addrequesttoqueue';
        apiCS.x_function_key__c='testing';
        apiCS.Name = 'Case Trigger';
        insert apiCS;

    }
       
    public static testmethod void getAssetData(){
        Asset  assetrec = [Select Id, Name , AccountId From Asset where Name = 'Asset 1' ];
        Id assetid = assetrec.Id;
        test.startTest();
        Contract returnedConList = GetAccountAsset.getAsset(assetid);
        system.debug('ReturnedList :  ' + returnedConList);
        test.stopTest();
    }
    public static testmethod void updateContractRecTest(){
         
        Asset  assetrec = [Select Id, Name , AccountId From Asset where Name = 'Asset 1' ];
       // Account accRec = [Select Id, Name From Account where Name = 'Ac ];
        Contract conRec = [Select Id, Name , AccountId From Contract where AccountId = : assetrec.AccountId];
        test.startTest();
        GetAccountAsset.updateContractRec('2','3','6',conRec);
        //GetAccountAsset.updateContractRec('4','9','8',conRec);
        //GetAccountAsset.updateContractRec('7','9','10',conRec);
        test.stopTest();
       // system.assertEquals(returnedRecord.Verification__c, 3);
    }
    
    private static testmethod void createOpportunityOnSaveTest(){
      
        
         Asset  assetrec = [Select Id, Name , AccountId From Asset where Name = 'Asset 1' ];
        Contract conRec = [Select Id, Name , AccountId, Certification__c,Verification__c , Scoping__c  From Contract where AccountId = : assetrec.AccountId];
        
        test.startTest();
        Contract ReturnedconRec = GetAccountAsset.createOpportunityOnSave('38',conRec,'Certification');
       Contract ReturnedconRec2 = GetAccountAsset.createOpportunityOnSave('5',conRec,'Verification');
       Contract ReturnedconRec3 = GetAccountAsset.createOpportunityOnSave('6',conRec,'Scoping');
        Contract ReturnedconRec4 = GetAccountAsset.createOpportunityOnSave('0',conRec,'Certification');
        Contract ReturnedconRec5 = GetAccountAsset.createOpportunityOnSave('0',conRec,'Verification');
       Contract ReturnedconRec6 = GetAccountAsset.createOpportunityOnSave('0',conRec,'Scoping');
        test.stopTest();
        //system.assertEquals(37,ReturnedconRec.Verification__c);
        system.debug('end' );
    }    
}