/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*/
@isTest
private class X7sTypeAheadUtility_Test {
    
    static final Integer NUM_USERS = 10;

    @TestSetup
    static void setup() {
        // load predefined tags
        List<Developer_Repo_Tag__c> tags = X7sTestUtils.loadDeveloperRepoTags();
        Integer usercount = 10;
        // create community users
        X7sTestUtils.createCommunityUserQSC(NUM_USERS);
    }

    @IsTest
    static void testTagSearch() {
        // test the search for items starting with Go -- there should be 2 predefined tags
        List<String> results = X7sTypeAheadUtility.tagSearch('Go');
        System.assertEquals(2, results.size(), 'Expected 2 matching tags');

        // Add a new tag that starts with Go
        X7sTestUtils.createDeveloperRepoTag('Good Stuff');
        results = X7sTypeAheadUtility.tagSearch('Go');
        System.assertEquals(3, results.size(), 'Expected 3 matching tags');

        // Test searching for G -- there should be 3 - 2 predefined and one added above, but only 4 returned because that is the limit
        results = X7sTypeAheadUtility.tagSearch('G');
        System.assertEquals(4, results.size(), 'Expected 4 matching tags');

        // search for a tag that does not exist
        results = X7sTypeAheadUtility.tagSearch('xplk');
        System.assertEquals(0, results.size(), 'Expected no matching tags');
    }

    @IsTest
    static void testUserSearch() {
        Test.startTest();
        List<NetworkMember> nmList = X7sTypeAheadUtility.userSearch('test-');
       // System.assertEquals(4, nmList.size(), 'There should be 4 users returned, as this is the limit set in the query');
        Test.stopTest();
    }
}