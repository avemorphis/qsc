@isTest
public class OpportunityHandlerTrigger_Test {
    public static testMethod void OpportunityTestData(){      
        List<Opportunity> opptyList = new List<Opportunity>();
        List<OpportunityTeamMember> teamsList = new List<OpportunityTeamMember>();
        Opportunity opp = new Opportunity(Name='Test Opportunity',CloseDate=System.today(),StageName='Closed/Won Commissioning');
        insert opp;
        
        User u=[SELECT Id, Name FROM User where alias='ukuma'];
        
       list< Opportunity_Default_Team__mdt>mdt=new list<Opportunity_Default_Team__mdt>();
         Opportunity_Default_Team__mdt metadata = new Opportunity_Default_Team__mdt();
        metadata.Access__c = 'Read';
        metadata.Role__c = 'Sales Manager';
        metadata.UserId__c = u.Id;
        mdt.add(metadata);
        List<Opportunity_Default_Team__mdt> opptyTeam = [SELECT Label,IsActive__c,Role__c,UserId__c,Access__c,RecordTypeId__c from Opportunity_Default_Team__mdt where ID IN:mdt];
        
       
        //insert metadata;
        
        OpportunityTeamMember teams = new OpportunityTeamMember();
        teams.TeamMemberRole = 'Sales Manager';
        teams.OpportunityId = opp.Id;
        teams.OpportunityAccessLevel = 'Read';
        teams.UserId = u.Id;
        insert teams;
               
        test.startTest();
        OpportunityHandlerTrigger.createOpportunityRecord(opptyList);
        test.stopTest();
    }
    @testVisible static List<Opportunity_Default_Team__mdt> customMetadata { 
    	get {
        	if ( customMetadata == null )
            	customMetadata = [SELECT Label,IsActive__c,Role__c,UserId__c,Access__c,RecordTypeId__c from Opportunity_Default_Team__mdt];
        		return customMetadata;
    	} set; }
    
}