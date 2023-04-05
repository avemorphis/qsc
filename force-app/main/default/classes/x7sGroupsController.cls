/*
 * Copyright (c) 2020. 7summits Inc. All rights reserved.
 */

/**
 * : Apex class used in Groups Lightning Components
 */
global with sharing class x7sGroupsController {
	//set default list size and page value for nextPage and previousPage methods of pagination
	private static final Integer DEFAULT_LIST_SIZE = 50;
	private static final Integer DEFAULT_PAGE_VALUE = 1;

	private static final String strObjectName = 'CollaborationGroup';
	private static String collaborationGroupType { get; set; }
	private static Boolean showArchivedGroups = false;

	//set of group fields to check access on and add in query
	private static final Set<String> groupAccessFields = new Set<String>{
		'id',
		'collaborationtype',
		'name',
		'description',
		'fullphotourl',
		'membercount',
		'networkid',
		'lastfeedmodifieddate',
		'ownerid',
		'InformationBody',
		'AnnouncementId'
	};

	//fetch system network Id
	public static Id networkId = System.Network.getNetworkId();

	/**
	 * :  used to set attributes of wrapper so that it can be used on components with proper data
	 *
	 * @param listGp
	 * @param numberOfGroups
	 * @param sortBy
	 * @param searchMyGroups
	 * @param searchString
	 * @param groupType
	 * @param filterQuery
	 * @param archivedGroups
	 *
	 * @return
	 */
	@AuraEnabled(Cacheable=true)
	global static x7sGroupsWrapper getGroups(
		List<String> listGp,
		Integer numberOfGroups,
		String sortBy,
		String searchMyGroups,
		String searchString,
		String groupType,
		String filterQuery,
		Boolean archivedGroups) {
		System.debug('GetGroups: ' + searchString + ', ' + filterQuery);

		collaborationGroupType = String.isNotBlank(groupType) ? String.escapeSingleQuotes(groupType.trim()) : '';
		showArchivedGroups = archivedGroups;

		return getGroups(listGp, numberOfGroups, sortBy, searchMyGroups,
			String.isNotBlank(searchString) ? String.escapeSingleQuotes(searchString.trim()) : '',
			String.isNotBlank(filterQuery) ? String.escapeSingleQuotes(filterQuery.trim()) : ''
		);
	}

	@AuraEnabled
	global static x7sGroupsWrapper getGroups(
		List<String> listGp,
		Integer numberOfGroups,
		String sortBy,
		String searchMyGroups,
		String searchString,
		String filterQuery) {
		try {
			searchString = String.isNotBlank(searchString) ? String.escapeSingleQuotes(searchString.trim()) : '';
			filterQuery = String.isNotBlank(filterQuery) ? String.escapeSingleQuotes(filterQuery.trim()) : '';

			//set limit for query from numberOfGroups entered by user in builder
			Integer intLimit = Integer.valueOf(numberOfGroups);
			//check with feature ids
			Boolean isIdCheck = false;
			//Initialise set of groups that contains set of group ids
			Set<String> groupIds = new Set<String>();
			//Initialise set of feature that contains set of group ids
			List<String> lstOfIds = new List<String>();
			for (String s : listGp) {
				lstOfIds.addAll(featuredGroupsIds(s));
			}
			Set<String> featureIds = new Set<String>();
			if (lstOfIds != null && lstOfIds.size() > 0) {
				isIdCheck = true;
				for (String s : lstOfIds) {
					featureIds.add(s);
				}
			}
			//fetch query string
			String Query = getGroupsQueryString();

			//check if query string is not blank
			if (String.isNotBlank(Query)) {

				if (searchMyGroups == 'My Groups') {
					for (CollaborationGroupMember member : [
						SELECT Id,CollaborationGroupId, CollaborationGroup.Name
						FROM CollaborationGroupMember
						WHERE MemberId = :UserInfo.getUserId()
						LIMIT 1000
					]) {
						groupIds.add(member.CollaborationGroupId);
						System.debug('List of groups without feature' + groupIds);
					}
					if (featureIds.size() > 0) {
						groupIds.retainAll(featureIds);
					}
					isIdCheck = true;
				}
				else {
					groupIds.addAll(featureIds);
				}
				Query += getWhereClause(isIdCheck, searchString, filterQuery);
				System.debug('Query after WHERE: ' + Query);

				if (String.isNotBlank(sortBy)) {
					//Apply sort by (order by) as selected
					if (sortBy == 'Latest Group Activity') {
						Query += ' ORDER BY LastFeedModifiedDate DESC';
					}
					else if (sortBy == 'Recently Viewed') {
						Query += ' ORDER BY LastViewedDate DESC';
					}
					else if (sortBy == 'Most Number Of Members') {
						Query += ' ORDER BY MemberCount DESC';
					}
					else if (sortBy == 'Least Number Of Members') {
						Query += ' ORDER BY MemberCount ASC';
					}
					else if (sortBy == 'Date Created : Oldest') {
						Query += ' ORDER BY CreatedDate';
					}
					else if (sortBy == 'Date Created : Newest') {
						Query += ' ORDER BY CreatedDate DESC';
					}
				}

				System.debug('Query: ' + Query);

				return new x7sGroupsWrapper(Query, intLimit, groupIds, false, null, null);
			}

			return null;
		}
		catch (Exception e) {
			System.debug('getGroups exception: ' + e.getMessage()); return new x7sGroupsWrapper(e.getMessage());
		}
	}

	@TestVisible
	private static String getWhereClause(Boolean myGroups, String searchString, String filterQuery) {
		System.debug('WHERE: ' + searchString + ', ' + filterQuery);

		String whereClause = '';
		List<String> whereItems = new List<String>();

		whereItems.add(networkId != null ? ' NetworkId = \'' + networkId + '\'' : ' NetworkId = NULL ');
		if (myGroups) {
			whereItems.add(' Id IN : groupIds ');
		}
		if (String.isNotBlank(filterQuery)) {
			whereItems.add(filterQuery.replace('\\', ''));
		}
		if (String.isNotBlank(searchString) && searchString.trim().length() > 0) {
			String searchQuery = searchString;
			String search = '';
			search += ' ( Name LIKE \'%' + searchQuery + '%\'';
			search += ' OR Description LIKE \'%' + searchQuery + '%\'';
			search += ' OR InformationTitle LIKE \'%' + searchQuery + '%\') ';
			System.debug('search' + search);
			whereItems.add(search);
		}

		if (String.isNotBlank(collaborationGroupType) && collaborationGroupType.trim().length() > 0 && collaborationGroupType != 'All Types') {
			whereItems.add('CollaborationType = \'' + collaborationGroupType + '\'');
		}

		if (showArchivedGroups == false) {
			whereItems.add('IsArchived = FALSE');
		}

		if (whereItems.size() > 0) {
			whereClause += ' WHERE ';
			whereClause += String.join(whereItems, ' AND ');
		}

		System.debug('whereClause: ' + whereClause);
		return whereClause;
	}

	/**
	 * :  Method used on click of "Next" in pagination to display groups records as per numberOfGroups
	 *
	 * @param listGp
	 * @param numberOfGroups
	 * @param pageNumber
	 * @param sortBy
	 * @param searchMyGroups
	 * @param searchString
	 * @param groupType
	 * @param filterQuery
	 * @param archivedGroups
	 *
	 * @return
	 */
	@AuraEnabled(Cacheable=true)
	global static x7sGroupsWrapper nextPage(
		List<String> listGp,
		Integer numberOfGroups,
		Integer pageNumber,
		String sortBy,
		String searchMyGroups,
		String searchString,
		String groupType,
		String filterQuery,
		Boolean archivedGroups) {
		showArchivedGroups = archivedGroups;
		collaborationGroupType = String.isNotBlank(groupType) ? String.escapeSingleQuotes(groupType.trim()) : '';
		return nextPage(listGp, numberOfGroups, pageNumber, sortBy, searchMyGroups, searchString, filterQuery);
	}

	@AuraEnabled
	global static x7sGroupsWrapper nextPage(
		List<String> listGp,
		Integer numberOfGroups,
		Integer pageNumber,
		String sortBy,
		String searchMyGroups,
		String searchString,
		String filterQuery) {
		Integer listSizeValue = numberOfGroups != null ? Integer.valueOf(numberOfGroups) : DEFAULT_LIST_SIZE ;
		Integer pageNumberValue = pageNumber != null ? Integer.valueOf(pageNumber) : DEFAULT_PAGE_VALUE ;

		x7sGroupsWrapper wrapperGroup = getGroups(
			listGp,
			listSizeValue,
			sortBy,
			searchMyGroups,
			String.isNotBlank(searchString) ? String.escapeSingleQuotes(searchString.trim()) : '',
			String.isNotBlank(filterQuery) ? String.escapeSingleQuotes(filterQuery.trim()) : '');

		wrapperGroup.pageNumber = pageNumberValue;
		wrapperGroup.nextPage();

		return wrapperGroup;
	}

	/**
	 * :  Method used on click of "Previous" in pagination to display groups records as per numberOfGroups
	 *
	 * @param listGp
	 * @param numberOfGroups
	 * @param pageNumber
	 * @param sortBy
	 * @param searchMyGroups
	 * @param searchString
	 * @param groupType
	 * @param filterQuery
	 * @param archivedGroups
	 *
	 * @return
	 */
	@AuraEnabled(Cacheable=true)
	global static x7sGroupsWrapper previousPage(
		List<String> listGp,
		Integer numberOfGroups,
		Integer pageNumber,
		String sortBy,
		String searchMyGroups,
		String searchString,
		String groupType,
		String filterQuery,
		Boolean archivedGroups) {
		showArchivedGroups = archivedGroups;
		collaborationGroupType = String.isNotBlank(groupType) ? String.escapeSingleQuotes(groupType.trim()) : '';
		return previousPage(listGp, numberOfGroups, pageNumber, sortBy, searchMyGroups, searchString, filterQuery);
	}

	@AuraEnabled
	global static x7sGroupsWrapper previousPage(List<String> listGp, Integer numberOfGroups, Integer pageNumber, String sortBy, String searchMyGroups, String searchString, String filterQuery) {
		Integer listSizeValue = numberOfGroups != null ? Integer.valueOf(numberOfGroups) : DEFAULT_LIST_SIZE ;
		Integer pageNumberValue = pageNumber != null ? Integer.valueOf(pageNumber) : DEFAULT_PAGE_VALUE ;

		x7sGroupsWrapper wrapperGroup = getGroups(listGp, listSizeValue, sortBy, searchMyGroups,
			String.isNotBlank(searchString) ? String.escapeSingleQuotes(searchString.trim()) : '',
			String.isNotBlank(filterQuery) ? String.escapeSingleQuotes(filterQuery.trim()) : '');

		wrapperGroup.pageNumber = pageNumberValue;
		wrapperGroup.previousPage();

		return wrapperGroup;
	}

	/**
	 * :  Method to fetch site prefix so that urls are redirected properly dynamically in any org.
	 *
	 * @return
	 */
	@AuraEnabled(Cacheable=true)
	global static String getSitePrefix() {
		return System.Site.getPathPrefix();
	}

	/**
	 * :  Method to fetch community setting for nick name to display users name or name as per setting.
	 *
	 * @return
	 */
	@AuraEnabled(Cacheable=true)
	global static Boolean isNicknameDisplayEnabled() {
		Boolean isNicknameDisplayEnabled = true;
		try {
			Network currNetwork = [SELECT Id, OptionsNicknameDisplayEnabled FROM Network WHERE Id = :networkId WITH SECURITY_ENFORCED LIMIT 1];
			isNicknameDisplayEnabled = currNetwork.OptionsNicknameDisplayEnabled;
		}
		catch (Exception e) {
			System.debug('isNicknameDisplayEnabled Exception: ' + e.getMessage());
		}

		return isNicknameDisplayEnabled;
	}

	@AuraEnabled(Cacheable=true)
	global static Boolean isObjectCreatable() {
		return Schema.SObjectType.CollaborationGroup.isCreateable() || canCreateCheckProfile() || canCreateCheckPermissionSet() || canCreateCheckCMT();
	}

	@TestVisible
	private static Boolean canCreateCheckProfile() {
		try {
			Profile userProfile = [SELECT Id,PermissionsChatterOwnGroups FROM Profile WHERE Id = :UserInfo.getProfileId() WITH SECURITY_ENFORCED ];
			return (userProfile.Id != null && userProfile.PermissionsChatterOwnGroups);
		} catch (Exception e) {
			System.debug('canCreateCheckProfile() : ' + e.getMessage() + ' line number: ' + e.getLineNumber());
		}

		return false;
	}

	@TestVisible
	private static Boolean canCreateCheckPermissionSet() {
		Boolean canCreate = false;

		for (PermissionSetAssignment assignment : [SELECT Id, PermissionSet.PermissionsChatterOwnGroups FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()]) {
			if (assignment.PermissionSet.PermissionsChatterOwnGroups) {
				canCreate = true;
			}
		}
		return canCreate;
	}

	@TestVisible
	private static Boolean canCreateCheckCMT() {
		Boolean authorized = false;
		try {
			X7S_Groups_Setting__mdt setting = [SELECT Permission_Set_Name__c FROM X7S_Groups_Setting__mdt WHERE DeveloperName = 'Default' WITH SECURITY_ENFORCED ];

			if (setting != null) {
				System.debug('userAuthorizedToCreate permission set name = ' + setting.Permission_Set_Name__c);
				authorized = [SELECT COUNT() FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()AND PermissionSet.Name = :setting.Permission_Set_Name__c] > 0;

				System.debug('    Authorized = ' + authorized);
			}
		}
		catch (Exception e) {
			System.debug(System.LoggingLevel.ERROR, 'x7SGroupsSettings__mdt not configured');
		}

		return authorized;
	}

	/**
	 * :  Method to fetch featured groups records to show on featured components.
	 *
	 * @param recordLabel
	 *
	 * @return
	 */
	@AuraEnabled(Cacheable=true)
	public static String getMetaDataGroupList(String recordLabel) {
		try {
			String groupList = '';

			System.debug(recordLabel);
			X7S_Groups_Setting__mdt setting = [SELECT Featured_Group_List__c FROM X7S_Groups_Setting__mdt WHERE DeveloperName = :recordLabel WITH SECURITY_ENFORCED ];

			if (setting != null) {
				groupList = setting.Featured_Group_List__c;
			}

			return String.isNotBlank(groupList) ? groupList : '';
		} catch (Exception e){
			System.debug('getMetaDataGroupList() : ' + e.getMessage() + ' line number: ' + e.getLineNumber());
			return '';
		}
	}

	/**
	 * :  Method to fetch featured groups records to show on featured components.
	 *
	 * @param recordId1
	 * @param recordId2
	 * @param recordId3
	 * @param recordId4
	 * @param recordId5
	 * @param recordId6
	 * @param recordId7
	 * @param recordId8
	 *
	 * @return
	 */
	@AuraEnabled
	global static x7sGroupsWrapper getFeaturedGroups(String recordId1, String recordId2, String recordId3, String recordId4, String recordId5, String recordId6, String recordId7, String recordId8) {
		Boolean isFeatured = true;

		//set groups ids to add filter condition of ids in query
		Set<String> groupIds = new Set<String>();
		List<String> lstOfIds = new List<String>();

		lstOfIds.addAll(featuredGroupsIds(recordId1));
		lstOfIds.addAll(featuredGroupsIds(recordId2));
		lstOfIds.addAll(featuredGroupsIds(recordId3));
		lstOfIds.addAll(featuredGroupsIds(recordId4));
		lstOfIds.addAll(featuredGroupsIds(recordId5));
		lstOfIds.addAll(featuredGroupsIds(recordId6));
		lstOfIds.addAll(featuredGroupsIds(recordId7));
		lstOfIds.addAll(featuredGroupsIds(recordId8));

		for (String fId : lstOfIds) {
			groupIds.add(fId);
		}

		/*system.debug('****lstOfIds*****'+lstOfIds);*/

		//get query string
		String Query = getGroupsQueryString();

		if (String.isNotBlank(Query)) {
			Query += ' Where Id IN : groupIds';

			if (networkId != null) {
				Query += ' And NetworkId = \'' + networkId + '\'';
			}

			return new x7sGroupsWrapper(Query, 8, groupIds, isFeatured, null, lstOfIds);
		}

		return null;
	}

	/**
	 * : Get a list of all the groups this user is a member of
	 *
	 * @param userId
	 *
	 * @return
	 */
	@AuraEnabled
	global static Map<String, String> getMembershipGroups(String userId) {
		Map<String, String> groups = new Map<String, String>();

		for (CollaborationGroupMember member : [
			SELECT CollaborationGroupId,
				CollaborationGroup.Name,
				CollaborationGroup.OwnerId,
				CollaborationGroup.CollaborationType
			FROM CollaborationGroupMember
			WHERE MemberId = :userId
			LIMIT 1000
		]) {
			groups.put(member.CollaborationGroupId, member.CollaborationGroup.OwnerId == userId ? 'Owner' : 'Member');
		}

		return groups;
	}

	@AuraEnabled
	global static String joinGroup(String groupId, String userId) {
		if (!CollaborationGroupMember.SObjectType.getDescribe().isUpdateable() &&
			!CollaborationGroupMember.SObjectType.getDescribe().isCreateable()){
			System.debug('joinGroup() : cannot insert/update CollaborationGroupMember' );
			return '';
		}

		CollaborationGroupMember groupMember = new CollaborationGroupMember(
			CollaborationRole = 'Standard',
			MemberId = userId,
			CollaborationGroupId = groupId);

		upsert groupMember;
		System.debug('joinGroup: ' + groupMember);
		return groupMember.Id;
	}

	@AuraEnabled
	global static Boolean leaveGroup(String groupId, String userId) {
		if (!CollaborationGroupMember.SObjectType.getDescribe().isDeletable()) {
			System.debug('leaveGroup() : cannot delete CollaborationGroupMember');
			return false;
		}

		Boolean result = false;
		CollaborationGroupMember membership = [SELECT Id FROM CollaborationGroupMember WHERE CollaborationGroupId = :String.escapeSingleQuotes(groupId) AND MemberId = :String.escapeSingleQuotes(userId)];

		if (membership != null) {
			delete membership;
			result = true;

		}

		System.debug('leaveGroup: ' + result);
		return result;
	}

	/**
	 * :  Method to add ids to map, created method as it was repeated.
	 *
	 * @param recordId
	 *
	 * @return
	 */
	static public List<String> featuredGroupsIds(String recordId) {
		List<String> lstOfIds = new List<String>();

		if (String.isNotBlank(recordId)) {
			String groupRecordId = validateId(recordId);

			if (String.isNotBlank(groupRecordId)) {
				lstOfIds.add(groupRecordId);
			}
		}

		return lstOfIds;
	}

	/**
	 * :  Method to validate id entered in featured groups component
	 *
	 * @param Idparam
	 *
	 * @return
	 */
	static public String validateId(String Idparam) {
		try {
			String recId = Idparam;
			return Id.valueOf(recId).getSobjectType() == CollaborationGroup.SObjectType ? recId : null;
		}
		catch (Exception e) {
			return null;
		}
	}

	/**
	 * : Method to getFieldType to use for a custom filter
	 *
	 * @param fieldFilter
	 * @param filterOperator
	 * @param filterValue
	 *
	 * @return : field type as a string
	 */
	@AuraEnabled(Cacheable=true)
	global static String getFieldType(String fieldFilter, String filterOperator, String filterValue) {
		try {
			System.debug('getFieldType (' + fieldFilter + ', ' + filterOperator + ', ' + filterValue + ')');
			String returnFieldType = 'Invalid Field';
			String simpleFilter = fieldFilter.toLowerCase();
			String simpleValue = filterValue.toLowerCase();
			String simpleOperator = filterOperator.toLowerCase();

			Set<String> set1 = new Set<String>{'true', 'false'};

			Set<String> objectFields = Schema.getGlobalDescribe()
				.get(strObjectName)
				.getDescribe()
				.fields
				.getMap().keySet();

			if (objectFields.contains(simpleFilter)) {
				Schema.DisplayType fieldDataType = Schema.getGlobalDescribe()
					.get(strObjectName)
					.getDescribe()
					.fields
					.getMap()
					.get(simpleFilter)
					.getDescribe()
					.getType();

				if (fieldDataType == Schema.DisplayType.STRING ||
					fieldDataType == Schema.DisplayType.TEXTAREA ||
					fieldDataType == Schema.DisplayType.PICKLIST ||
					fieldDataType == Schema.DisplayType.REFERENCE ||
					fieldDataType == Schema.DisplayType.PHONE ||
					fieldDataType == Schema.DisplayType.EMAIL ||
					fieldDataType == Schema.DisplayType.URL) {
					returnFieldType = 'String';

					if (simpleOperator != '' && (!(filterOperator == 'contains'
						|| filterOperator == 'equals'
						|| filterOperator == 'not equals'))) {
						returnFieldType = 'Invalid Operator';
					}
				}

				if (fieldDataType == Schema.DisplayType.INTEGER) {
					returnFieldType = 'Integer';
					if (simpleOperator != '' && simpleOperator == 'contains') {
						returnFieldType = 'Invalid Operator';
					}
					else if (simpleValue != '' && !simpleValue.isNumeric()) {
						returnFieldType = 'Bad Value';
					}
				}

				if (fieldDataType == Schema.DisplayType.ID) {
					returnFieldType = 'Id';
					if (simpleOperator != '' && simpleOperator != 'equals') {
						returnFieldType = 'Invalid Operator';
					}
					else if (simpleValue != '' && (simpleValue.length() != 18)) {
						if (simpleValue.length() != 15) {
							returnFieldType = 'Bad Value';
						}
					}
				}

				if (fieldDataType == Schema.DisplayType.BOOLEAN) {
					returnFieldType = 'Boolean';
					if (simpleOperator != '' && (!(simpleOperator == 'equals' || simpleOperator == 'not equals'))) {
						returnFieldType = 'Invalid Operator';
					}
					else if (simpleValue != '' && (!set1.contains(simpleValue) || simpleValue.isNumeric())) {
						returnFieldType = 'Bad Value';
					}
				}

				if (fieldDataType == Schema.DisplayType.DATETIME) {
					returnFieldType = 'DateTime';

					if (simpleOperator != '' && simpleOperator == 'contains') {
						returnFieldType = 'Invalid Operator';
					}
				}

				System.debug('----FieldType----' + fieldDataType + ' = ' + returnFieldType);
			}

			System.debug('return field type: ' + returnFieldType);
			return returnFieldType;
		}
		catch (Exception e) {
			System.debug('getFieldType Exception ' + e.getMessage()); return e.getMessage();
		}
	}

	/**
	 * : Method to check all fields used in query are accessible
	 *
	 * @return : List of accessible field for the groups query
	 */
	public static List<String> getAccessibleFields() {
		if (Schema.getGlobalDescribe().get(strObjectName).getDescribe().accessible) {
			//get all fields of strObj using getGlobalDescribe method
			Map<String, Schema.SObjectField> strFldNameToFldDesc = Schema.getGlobalDescribe().get(strObjectName).getDescribe().fields.getMap();

			List<String> objectAccessFields = new List<String>();

			//Iterate over all field map of object
			for (String fieldToCheck : strFldNameToFldDesc.keySet()) {
				//Add only those fields which are in set and accessible as we do not need all fields of object
				//if (groupAccessFields.contains(fieldToCheck)) {
				//check if field is accessible
				if (strFldNameToFldDesc.get(fieldToCheck).getDescribe().isAccessible()) {
					objectAccessFields.add(fieldToCheck);
				}
				//}
			}

			//As we need to Query Owner name,CommunityNickname and owner means user so check if user is accessible
			if (Schema.getGlobalDescribe().get('User').getDescribe().accessible) {
				Map<String, Schema.SObjectField> strUserFldNameToFldDesc = Schema.getGlobalDescribe().get('User').getDescribe().fields.getMap();

				//if user name is accessible, add owner.name to accessible fields
				if (strUserFldNameToFldDesc.get('Name').getDescribe().isAccessible()) {
					objectAccessFields.add('owner.name');
				}

				//if user CommunityNickname is accessible, add Owner.CommunityNickname to accessible fields
				if (strUserFldNameToFldDesc.get('CommunityNickname').getDescribe().isAccessible()) {
					objectAccessFields.add('Owner.CommunityNickname');
				}
			}

			return objectAccessFields;
		}
		else {
			return null;
		}
	}

	/**
	 * : Method to generate the query for the CollaborationGroup sObject.
	 *
	 * @return : Query string
	 */
	private static String getGroupsQueryString() {
		String query = null;
		List<String> objectAccessFields = getAccessibleFields();

		if (!objectAccessFields.isEmpty()) {
			query = 'SELECT ';
			query += String.join(objectAccessFields, ',');
			query += ' FROM ' + strObjectName ;
		}

		return query;
	}
}