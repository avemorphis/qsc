public class OpportunityHandlerTrigger {
	public static void createOpportunityRecord(List<Opportunity> opptyList){
        
        List<Opportunity_Default_Team__mdt> opptyTeam = [SELECT Label,IsActive__c,Role__c,UserId__c,Access__c,RecordTypeId__c from Opportunity_Default_Team__mdt];
        
        List<OpportunityTeamMember> optyTeamList = new List<OpportunityTeamMember>();  
        for(Opportunity opp:opptyList){
            for(Opportunity_Default_Team__mdt defaultTeam:opptyTeam){
               	if(opp.RecordTypeId == defaultTeam.RecordTypeId__c) {                    
                    OpportunityTeamMember teams = new OpportunityTeamMember();
                    teams.TeamMemberRole = defaultTeam.Role__c;
                    teams.OpportunityAccessLevel = defaultTeam.Access__c;
                    teams.OpportunityId = opp.Id;
                    teams.UserId = defaultTeam.UserId__c;
                    optyTeamList.add(teams);
                }
            }  
        }
        insert optyTeamList;   
    }
}