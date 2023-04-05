/*
 * Copyright (c) 2020. 7summits Inc. All rights reserved.
 */

/*
@Class Name          : x7sGroupsControllerTest
@Created by          :
@Description         : Apex Test class for x7sGroupsController
*/
@IsTest
public class x7sGroupsControllerTest
{
	@IsTest
	static void test_Groups()
	{
		//Create Groups
		List<CollaborationGroup> cgroup = x7sGroupsUtility.createGroup(8);
		List<String> listGrp = new List<String>();
		for (Integer cnt = 0; cnt < 3; ++cnt)
		{
			listGrp.add(cgroup[cnt].Id);
		}

		x7sGroupsUtility.createGroupFeature(listGrp);

		//Fetch Groups with sort by as 'Latest Group Activity'
		x7sGroupsWrapper groupsWrapper = x7sGroupsController.getGroups(listGrp, 10, 'Latest Group Activity', null, null, null);
		System.assertEquals(listGrp.size(), 3);
		System.assertEquals(11, groupsWrapper.groupMembership.size());

		//Fetch Groups with sort by as 'Date Created : Oldest'
		x7sGroupsWrapper groupsWrapper1 = x7sGroupsController.getGroups(listGrp, 10, 'Date Created : Oldest', null, null, null);
		System.assertEquals(groupsWrapper1.groupsList.size(), 3);

		//Fetch Groups with Search Term as 'Test' and sort by as 'Date Created : Newest'
		x7sGroupsWrapper groupsWrapper2 = x7sGroupsController.getGroups(listGrp, 10, 'Date Created : Newest', null, 'Test', null);
		System.assertEquals(groupsWrapper2.groupsList.size(), 3);

		//Fetch My Groups
		x7sGroupsWrapper groupsWrapper3 = x7sGroupsController.getGroups(listGrp, 10, 'Date Created : Newest', 'My Groups', null, null);
		System.assertEquals(groupsWrapper3.groupsList.size(), 3);

		//Fetch Groups with filter of 'search term' and sort by as 'Date Created : Newest'
		x7sGroupsWrapper groupsWrapperSearch = x7sGroupsController.getGroups(listGrp, 10, null, null, 'Test Group1', null);
		System.assertEquals(1, groupsWrapperSearch.groupsList.size());

		//Fetch Groups to process next for pagination
		x7sGroupsWrapper groupsWrapperNext = x7sGroupsController.nextPage(listGrp, 2, 1, 'Recently Viewed', null, null, null);
		System.assertEquals(2, groupsWrapperNext.pageNumber);

		//Fetch Groups to process next for pagination
		x7sGroupsWrapper groupsWrapperNext1 = x7sGroupsController.nextPage(listGrp, 2, 2, 'Recently Viewed', null, null, null);
		System.assertEquals(1, groupsWrapperNext1.pageNumber);

		//Fetch Groups to process Previous for pagination
		x7sGroupsWrapper groupsWrapperPrev = x7sGroupsController.previousPage(listGrp, 2, 2, 'Number Of Members', null, null, null);
		System.assertEquals(1, groupsWrapperPrev.pageNumber);

		//call method to get sit Prefix
		String strSitePathPrefix = x7sGroupsController.getSitePrefix();
		System.assertEquals(strSitePathPrefix, System.Site.getPathPrefix());

		//call method to check if "display community nick name" is true or false in community
		x7sGroupsController.isNicknameDisplayEnabled();

		//call method to check if object is creatable to show hide "Add new" button on header in list view page
		x7sGroupsController.isObjectCreatable();
		x7sGroupsController.canCreateCheckProfile();
		x7sGroupsController.canCreateCheckPermissionSet();
		x7sGroupsController.canCreateCheckCMT();

		//Fetch Featured Groups
		x7sGroupsWrapper featuredGroupsWrapper = x7sGroupsController.getFeaturedGroups(cgroup[0].Id, cgroup[1].Id, cgroup[2].Id, cgroup[3].Id, cgroup[4].Id, cgroup[5].Id, cgroup[6].Id, cgroup[7].Id);
		System.assertEquals(featuredGroupsWrapper.groupsList.size(), 8);

		//Fetch Featured Groups with one invalid id
		x7sGroupsWrapper featuredGroupsWrapper1 = x7sGroupsController.getFeaturedGroups(cgroup[0].Id, cgroup[1].Id, cgroup[2].Id, cgroup[3].Id, cgroup[4].Id, cgroup[5].Id, cgroup[6].Id, '13212324');
		System.assertEquals(featuredGroupsWrapper1.groupsList.size(), 7);

		x7sGroupsWrapper msgTest = new x7sGroupsWrapper('message 1');
		System.assertEquals('message 1', msgTest.errorMsg);
	}

	@IsTest
	static void testGroupMembership()
	{
		User adminUser = x7sGroupsUtility.createAdminUser();
		System.runAs(adminUser)
		{
			List<CollaborationGroup> testGroups = x7sGroupsUtility.createGroup(8);
			Map<String, String> groupList = x7sGroupsController.getMembershipGroups(adminUser.Id);
			System.debug('Admin Groups: ' + groupList);
			System.assertNotEquals(null, groupList);
			System.assertEquals(8, groupList.size());

			CollaborationGroup testGroup = testGroups[0];
			User testUser = x7sGroupsUtility.usr;

			// Join
			String collaborationId = x7sGroupsController.joinGroup(testGroup.Id, testUser.Id);
			System.assertNotEquals(null, collaborationId);
			groupList = x7sGroupsController.getMembershipGroups(testUser.Id);
			System.debug('TestUser Groups: ' + groupList);
			System.assertEquals(1, groupList.size());

			// Leave
			x7sGroupsController.leaveGroup(testGroup.Id, testUser.Id);
			groupList = x7sGroupsController.getMembershipGroups(testUser.Id);
			System.debug('TestUser Groups: ' + groupList);
			System.assertEquals(0, groupList.size());
		}
	}

	@IsTest(SeeAllData=true)
	static void test_getMetaData()
	{
		String data = x7sGroupsController.getMetaDataGroupList('Default');
		System.assertNotEquals(null, data);
	}

	@IsTest(SeeAllData=true)
	static void getFieldType()
	{
		String data = x7sGroupsController.getFieldType('name', 'Contains', 'bar');
		System.assertEquals('String', data);
		String data1 = x7sGroupsController.getFieldType('name', 'Greater Than', 'bar');
		System.assertEquals('Invalid Operator', data1);
		String data2 = x7sGroupsController.getFieldType('nameaa', 'Greater Than', 'bar');
		System.assertEquals('Invalid Field', data2);
		String data3 = x7sGroupsController.getFieldType('membercount', 'Greater Than', 'test');
		System.assertEquals('Bad Value', data3);
		String data4 = x7sGroupsController.getFieldType('membercount', 'Greater Than', '1');
		System.assertEquals('Integer', data4);
		String data5 = x7sGroupsController.getFieldType('membercount', 'Contains', '1');
		System.assertEquals('Invalid Operator', data5);
		String data6 = x7sGroupsController.getFieldType('id', 'Contains', '1');
		System.assertEquals('Invalid Operator', data6);
		String data7 = x7sGroupsController.getFieldType('id', 'Equals', 'oofGTht');
		System.assertEquals('Bad Value', data7);
		String data8 = x7sGroupsController.getFieldType('id', 'Equals', '0F96g00000091HsCAI');
		System.assertEquals('Id', data8);
		String data9 = x7sGroupsController.getFieldType('isarchived', 'Equals', 'true');
		System.assertEquals('Boolean', data9);
		String data10 = x7sGroupsController.getFieldType('isarchived', 'Contains', 'true');
		System.assertEquals('Invalid Operator', data10);
		String data11 = x7sGroupsController.getFieldType('isarchived', 'Equals', 'test');
		System.assertEquals('Bad Value', data11);
		String data12 = x7sGroupsController.getFieldType('createddate', 'Equals', 'THIS_WEEK');
		System.assertEquals('DateTime', data12);
		String data13 = x7sGroupsController.getFieldType('createddate', 'Contains', 'THIS_WEEK');
		System.assertEquals('Invalid Operator', data13);
	}
}