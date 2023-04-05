/**
 * @description       : 
 * @author            : Chirag Rathi
 * @group             : 
 * @last modified on  : 01-27-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class MassReassignOpportunitiesControllerTest {
    @isTest
	public static void testReassign(){
		
		Account testAccount = new Account();
		testAccount.Name = 'test';
		insert testAccount;
		List<Opportunity> testOptyLst = new List<Opportunity>();
		Opportunity testOpty = new Opportunity();
		testOpty.StageName = 'Discover';
		testOpty.CloseDate = System.today()+1;
		testOpty.AccountId=testAccount.Id;
		testOpty.Name='testOpty';
		testOpty.Type = 'testType';
        testOptyLst.add(testOpty);
        
        Opportunity testOpty2 = new Opportunity();
		testOpty2.StageName = 'Discover2';
		testOpty2.CloseDate = System.today()+1;
		testOpty2.AccountId=testAccount.Id;
		testOpty2.Name='testOpty2';
		testOpty2.Type = 'testType';
		 testOptyLst.add(testOpty2);
		
		insert testOptyLst;
        MassReassignOpportunitiesController.cOpty wrplst = new MassReassignOpportunitiesController.cOpty(testOpty);
		MassReassignOpportunitiesController.cOpty wrplst2 = new MassReassignOpportunitiesController.cOpty(testOpty2);
		wrplst2.selected = true;
        system.debug('>>>>wrpl1'+wrplst);
        system.debug('>>>>wrpl'+wrplst2);
       // controller.Assign();
		Test.startTest();
        system.debug('>>>>testOptyA1'+testOpty);
		MassReassignOpportunitiesController controller = new MassReassignOpportunitiesController();
		controller.refreshOptyList();
		controller.filterId = controller.listviewoptions[1].getValue();
		system.debug('>>>>TestA'+testOpty);
        controller.Assign();
        controller.refreshOptyList();
        
		controller.searchRecord.stageName = 'Discover';
		controller.helperRecord.ClosedDate_From__c=System.today();
		controller.helperRecord.ClosedDate_To__c=System.today()+2;
		controller.helperRecord.From__c=System.today();
		controller.helperRecord.To__c=System.today()+1;
		controller.searchRecord.Type = 'testType';
        system.debug('>>>>B'+testOpty);
		controller.refreshOptyListBySearch();
        system.debug('>>>>TestC'+testOpty);
		
		System.assert(controller.optyList.size()>0);
		list<opportunity> optyList = new list <opportunity>();
		optyList = [select id, name from opportunity  where id =:testOpty2.id limit 10 ];
		system.debug('Rocket==>'+optyList.size());
        controller.filterId='';
		controller.optyList[0].selected = true;
		controller.helperRecord.Assign_to__c = UserInfo.getUserId();
		controller.Assign();
		
		Test.stopTest();
		
	}
}