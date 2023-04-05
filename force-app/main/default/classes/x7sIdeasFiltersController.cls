/*
 * Copyright (c) 2020. 7Summits Inc.
 */

public with sharing class x7sIdeasFiltersController {

	@AuraEnabled
	public static Boolean isAuthenticated() {
		return !Auth.CommunitiesUtil.isGuestUser();
	}

	@AuraEnabled (Cacheable=true)
	public static String getSitePrefix() {
		return System.Site.getPathPrefix();
	}

	@AuraEnabled
	public static Boolean showAccountFilter() {
		x7sIdeasCommon common = new x7sIdeasCommon('', false);
		String permissionSetName = common.accountFilterPermissions;
		String userId = UserInfo.getUserId();

		return x7sIdeasUtility.permissionSetMember(userId, permissionSetName);
	}

	@AuraEnabled
	public static List<String> getThemeValues(String zoneName) {
		List<String> lstFieldValues = new List<String>();

		List<IdeaTheme> themeList = [SELECT Id, Title FROM IdeaTheme WHERE Community.Name = :zoneName WITH SECURITY_ENFORCED ORDER BY Title];
		for (IdeaTheme themeItem : themeList) {
			lstFieldValues.add(themeItem.Title);
		}

		return lstFieldValues;
	}

	/*
		* MethodName        : getTopicNamesList
		* param             :
		* Description       : Method for fetching all Topics values from any sObject.
	*/
	@AuraEnabled
	public static List<String> getTopicNamesList() {
		return x7sIdeasTopicController.getTopicNamesList();
	}

	@AuraEnabled
	public static List<String> getStatusValues() {
		return x7sIdeasUtility.getIdeaStatusValues();
	}

	@AuraEnabled
	public static List<String> getCategoryValues(String themeName) {
		return String.isBlank(themeName) ? x7sIdeasUtility.getIdeaCategoryValues() : x7sIdeasUtility.getThemeCategories(themeName);
	}
}