@isTest(SeeAllData=true)
public class TestContactTrigger {
    public static testMethod void testTriggers() {
        
       
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.Copy_Billing_Address_to_Shipping_Address__c = true;
        acc.Region_Oracle__c = 'LATAM';
        insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test Con';
        con.Email = 'BarneyRocksAllTheTime@barney.com';
        insert con;
        
        List<Campaign_member_Insert__mdt> memberMgtList = [SELECT CampaignId__c FROM Campaign_member_Insert__mdt WHERE Region_Oracle__c =: acc.Region_Oracle__c AND Isactive__c = true];
        
        CampaignMember objCampaignMember = new CampaignMember();
        objCampaignMember.CampaignId = memberMgtList[0].CampaignId__c;
        objCampaignMember.ContactId = con.Id;
        INSERT objCampaignMember;

         test.startTest();
        //Update Group Slugs
        con.Group_Slugs__c = 'tech-support;q-sys-developer;commHigherEd;cinema-community';
        update con;
        
        test.stopTest();
    }


}