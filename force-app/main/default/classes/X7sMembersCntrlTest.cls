/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*/
@isTest
private class X7sMembersCntrlTest {
    
 /*   @IsTest
    static void testGetMembers() {
        List<User> communityUsers = X7sTestUtils.createCommunityUserQSC(3);
        Profile ccpluProfile = [SELECT Id FROM Profile WHERE Name='Customer Community Plus User Custom'];        
        List<X7sMembersCntrl.MemberWrapper> wrappers;
        Test.startTest();
        System.runAs(communityUsers[0]){
            //Checking as a community user who has no custom permission IsCommunityManager
            wrappers = X7sMembersCntrl.getMembers();
            System.assertEquals(0, wrappers.size(), 'Expected no wrapper record');
            
        }
        System.runAs(getAdminUser()){
            // Assigning Community Managers permission set to a community user
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Community_Managers'];
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = communityUsers[0].Id;
            psa.PermissionSetId = ps.Id;
            insert psa;
        }
        Integer activeCount= 0;
        System.runAs(communityUsers[0]){
            //Checking as a community user who has custom permission IsCommunityManager
            wrappers = X7sMembersCntrl.getMembers();
            for(X7sMembersCntrl.MemberWrapper wrp: wrappers){
                if(wrp.communityStatus){
                    activeCount++;
                }
            }
            System.assertEquals(3, wrappers.size(), 'Expected three wrapper records containing all three community user details');
            System.assertEquals(3, activeCount, 'Expected three wrapper records which have active community status');
            
        }
        System.runAs(getAdminUser()){
            //Changing profile and deleting permission set to remove user from community
            communityUsers[1].ProfileId = ccpluProfile.Id;
            update communityUsers;
            DELETE [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId=:communityUsers[1].Id AND PermissionSet.IsOwnedByProfile = FALSE];
        }
        System.runAs(communityUsers[0]){
            activeCount = 0;
            wrappers = X7sMembersCntrl.getMembers();
            for(X7sMembersCntrl.MemberWrapper wrp: wrappers){
                if(wrp.communityStatus){
                    activeCount++;
                }
            }
            System.assertEquals(3, wrappers.size(), 'Expected three wrapper records containing all three community user details');
            System.assertEquals(3, activeCount, 'Expected three wrapper records which have active community status');
            
        }
        Test.stopTest();     
    }
    */
    @IsTest
    static void testInvite() {
        List<User> communityUsers = X7sTestUtils.createCommunityUserQSC(1);        
        system.runAs(getAdminUser()){
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Community_Managers'];
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = communityUsers[0].Id;
            psa.PermissionSetId = ps.Id;
            insert psa;
        }
        system.runAs(communityUsers[0]){
            Test.startTest();
            X7sMembersCntrl.invite('testname',communityUsers[0].Email,'testMesssage');
            Test.stopTest();
        }
        
    }

  /*  @IsTest
    static void testDeactivate() {

        List<User> communityUsers = X7sTestUtils.createCommunityUserQSC(2);        
        system.runAs(getAdminUser()){
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Community_Managers'];
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = communityUsers[0].Id;
            psa.PermissionSetId = ps.Id;
         //   insert psa;
        }

        system.runAs(communityUsers[0]){
            Test.startTest();
            X7sMembersCntrl.deactivate(communityUsers[1].Id, 'Left Company', 'test note');
            Test.stopTest();
        }
        Contact conRec = [SELECT Status__c,Inactive_Reason__c,Note__c FROM Contact WHERE Id=:communityUsers[1].ContactId];
		System.assertEquals('Inactive', conRec.Status__c, 'Expected contact status as Inactive');
        System.assertEquals('Left Company', conRec.Inactive_Reason__c, 'Expected inactive reason as left company');
        System.assertEquals('test note', conRec.Note__c, 'Expected contact notes set to test note');
    }
    */
    private static User getAdminUser(){
        return [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
    }
}