/*
 * Copyright (c) 2020. 7Summits Inc.
 */

@IsTest
private class x7sIdeasSubscriptionTest {
	public static Network currNetwork;
	public static List<Community> currCommunity;
	public static List<Idea> currIdeaList;

	private static final String TestIdeaName = 'test_X7__1';

	static void testSetupQuery() {
		currCommunity = [SELECT Id, Name FROM Community WHERE IsActive = TRUE];
		currIdeaList = [SELECT Id FROM Idea WHERE Title = 'test_X7__1' ORDER BY CreatedDate DESC];
	}

	@TestSetup
	static void testSetupData() {
		x7sIdeasSubscriptionTest.testSetupQuery();
		System.assertNotEquals(null, x7sIdeasSubscriptionTest.currCommunity);
		System.assert(x7sIdeasSubscriptionTest.currCommunity.size() > 0);

		Idea currIdea1 = new Idea(CommunityId = currCommunity[0].Id, Title = TestIdeaName, Related_Topic_Name__c = 'test_X7__1');
		Idea currIdea2 = new Idea(CommunityId = currCommunity[0].Id, Title = TestIdeaName, Related_Topic_Name__c = 'test_X7__1');

		List<Idea> tmpIdeaList = new List<Idea>();
		tmpIdeaList.add(currIdea1);
		tmpIdeaList.add(currIdea2);

		insert tmpIdeaList;
		System.assertNotEquals(null, tmpIdeaList[0].Id);
		System.assertNotEquals(null, tmpIdeaList[1].Id);
	}

	@IsTest
	static void testIsSubscribed() {
		x7sIdeasSubscriptionTest.testSetupQuery();
		User u = x7sIdeasUtilityTest.createStandardTestUser();

		System.runAs(u) {
			Test.startTest();
			System.assertEquals(false, x7sIdeasSubscription.ideaIsSubscribed(u.Id, x7sIdeasSubscriptionTest.currIdeaList[0].Id));

			System.assertEquals(true, x7sIdeasSubscription.ideaSubscribe(u.Id, x7sIdeasSubscriptionTest.currIdeaList[0].Id));
			System.assertEquals(true, x7sIdeasSubscription.ideaIsSubscribed(u.Id, x7sIdeasSubscriptionTest.currIdeaList[0].Id));
            System.assertEquals(true, x7sIdeasSubscription.ideaSubscribeOnlySub(u.Id, x7sIdeasSubscriptionTest.currIdeaList[0].Id));
            x7sIdeasSubscription.sendSubscriptionNotificationOnlySub(u.Id, x7sIdeasSubscriptionTest.currIdeaList[0].Id);
            System.assertEquals(true, x7sIdeasSubscription.ideaSubscribeOnly(u.Id, x7sIdeasSubscriptionTest.currIdeaList[0].Id));
			System.assertEquals(true, x7sIdeasSubscription.ideaUnSubscribe(u.Id, x7sIdeasSubscriptionTest.currIdeaList[0].Id));
			System.assertEquals(false, x7sIdeasSubscription.ideaIsSubscribed(u.Id, x7sIdeasSubscriptionTest.currIdeaList[0].Id));

			Test.stopTest();
		}

	}
}