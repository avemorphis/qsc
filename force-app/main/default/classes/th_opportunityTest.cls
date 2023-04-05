@isTest
public class th_opportunityTest {
    Public static testMethod void test(){
        date closedt = date.today();
        Account acc = new Account (name= 'TestAccountAcc');
        insert acc;
        system.debug('>>>>acc'+acc.id);
        
        Id OppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Professional Services Opportunity').getRecordTypeId();
        opportunity opp = new opportunity (name = 'testOpportunity',accountId = acc.id,stagename = 'Draft', CloseDate = closedt, recordtypeid = OppRecordTypeId);
        insert opp;
        system.debug('>>>>opp'+opp.id);
        
         opportunity Opp1 = new opportunity (id=opp.id,stageName= 'Quote Accepted SOW Signed');
        update opp1;
    }

}