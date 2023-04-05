/**

* @description        : BatchClass for updating No_Of_Days_Until_Resolved__c by +1 everyday  when status is not closed
* @Author             : prakhar.jain@qsc.com
* @Last Modified By   : prakhar.jain@qsc.con
* @Last Modified On   : 06/02/2023
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    06/02/2023     prakhar.jain@qsc.com       Initial Version
**/
@isTest
public class Qsc_BatchUpdatingCaseTest {
    
      
    public static testmethod void getData(){
        Product2 objPro= new Product2(Name='Zen', ProductCode='Zen12', IsActive=true, Cases__c= true);
        insert objPro;
        
        Account objAcc =new Account(Name='Ray', CurrencyIsoCode='EUR');
        insert objAcc;
        
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
        
        date d = system.today();
        Case objCase = new Case(AccountId = objAcc.id, Country_of_use_pl__c='United Kingdom', CurrencyIsoCode='EUR', Type='Feature Request', Origin='Phone', Status='New',Product_If_No_Asset__c=objPro.id, Date_When_Entered_L3__c=d, No_Of_Days_Until_Resolved__c=0);
        insert objCase;
        
        test.startTest();
       
        String schTime = '0 0 0 '+date.today().day()+' '+date.today().month()+' ? 2029';
        system.schedule('jobQSC_BatchUpdatingCase', schTime, new Qsc_scheduleBatchUpdatingCase());
        test.stopTest();
    }

}