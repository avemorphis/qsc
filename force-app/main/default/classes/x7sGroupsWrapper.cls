/*
 * Copyright (c) 2020. 7summits Inc. All rights reserved.
 */

/*
@Class Name		  : x7sGroupsWrapper
@Created by		  :
@Description		 : Wrapper Apex class used by x7sGroupsController Apex class
					   Mainly this class was created for implementing pagination using setcontroller.
*/
global with sharing class x7sGroupsWrapper
{
	@AuraEnabled
	global String currentUserId { get; set; }

	@AuraEnabled
	global List<CollaborationGroup> groupsList { get; set; }

	@AuraEnabled
	global Map<String, String> groupMembership {get; set;}

	@AuraEnabled
	global Integer totalResults { get; set; }

	//Total number of pages in pagination as per total results
	@AuraEnabled
	global Integer totalPages { get; set; }

	//Page number for all total number of pages
	@AuraEnabled
	global Integer pageNumber { get; set; }

	@AuraEnabled
	global Boolean hasPreviousSet { get; set; }

	@AuraEnabled
	global Boolean hasNextSet { get; set; }

	//Integer listSizeValue to define limit in query as per design attributes
	@AuraEnabled
	global Integer listSizeValue { get; private set; }

	@AuraEnabled
	global String errorMsg { get; set; }

	private ApexPages.StandardSetController setController { get; set; }

	global x7sGroupsWrapper() {
		System.debug('Default ctor');
	}

	/*
	@Name		  :  x7sGroupsWrapper
	@parameters	:  String errorMsg
	@Description   :  constructor for wrapper
	*/
	global x7sGroupsWrapper(String errorMsg) {
		this.errorMsg = errorMsg;
	}

	/*
	@Name		  :  x7sGroupsWrapper
	@parameters	:  QUERY(query string to query records), intLimit is the limit to query ,groupsIds to get records of specified Groups,
					  isFeatured and lstOfIds are used for featured component (featurdGroupsIds not in use can not remove as we created manage package it throw exception).
	@Description   :  constructor for wrapper
	*/
	global x7sGroupsWrapper(String QUERY, Integer intLimit, Set<String> groupIds, Boolean isFeatured, Map<String, String> featurdGroupsIds, List<String> lstOfIds) {
		this.groupsList = new List<CollaborationGroup>();

		//set limit to query
		this.listSizeValue = intLimit;

		//Query Groups records as per query string from parameters
		this.setController = new ApexPages.StandardSetController(Database.getQueryLocator(QUERY));
		
		//setting page size for position based on listSizeValue
		this.setController.setPageSize(listSizeValue);

		//call updateControllerAttributes method
		updateControllerAttributes(isFeatured, lstOfIds);
	}

	/*
	@Name		  :  nextPage
	@Description   :  used in pagination on click on next button
	*/
	global void nextPage() {

		//set page number for next page in pagination
		this.setController.setPageNumber(this.pageNumber + 1 > 0 ? this.pageNumber + 1 : 1);

		//call updateControllerAttributes method
		updateControllerAttributes(false, null);
	}

	/*
	@Name		  :  previousPage
	@Description   :  used in pagination on click on previous button
	*/
	global void previousPage() {

		//set page number for previous page in pagination
		this.setController.setPageNumber(this.pageNumber - 1 > 0 ? this.pageNumber - 1 : 1);

		//call updateControllerAttributes method
		updateControllerAttributes(false, null);
	}

	/*
	@Name		  :  updateControllerAttributes
	@parameters	:  isFeatured boolean , lstOfIds is list of string that contains ids in order it is entered in property editor
	@Description   :  used to set attributes of wrapper so that it can be used on components with proper data
	*/
	private void updateControllerAttributes(Boolean isFeatured, List<String> lstOfIds) {

		/*
		Fetch groups list for featured group component in order it is entered in property editor
		isFeatured identifies that this featured component,
		lstOfIds is list of string that contains ids in order it is entered in property editor,so
		we query records that gives random data and by this list we get order of groups to display on featured component
		*/

		//check if featured
		if (isFeatured == true) {

			//query and get record in temporary list
			List<CollaborationGroup> templist = this.setController.getRecords();
			Map<Id, CollaborationGroup> tempGroupsMap = new Map<Id, CollaborationGroup>();

			//fill temporary map of group id and group object
			for (CollaborationGroup cgroup : templist) {
				tempGroupsMap.put(cgroup.Id, cgroup);
			}

			//iterate on map that gives order and check if temporary map contains that id then add it to group list
			for (String str : lstOfIds) {
				if (tempGroupsMap.containsKey(str)) {

					//add groups to list in order in which it is added in community builder
					this.groupsList.add(tempGroupsMap.get(str));
				}
			}
		} else {
			//for all other Groups list get records for set controller directly
			this.groupsList = this.setController.getRecords();
		}

		this.errorMsg		= '';
		this.currentUserId   = UserInfo.getUserId();
		this.groupMembership = x7sGroupsController.getMembershipGroups(UserInfo.getUserId());

		//set totalResults from query result
		this.totalResults = this.setController.getResultSize();

		this.totalPages = Math.mod(this.setController.getResultSize(), this.setController.getPageSize()) == 0
				? this.setController.getResultSize() / this.setController.getPageSize()
				: this.setController.getResultSize() / this.setController.getPageSize() + 1;
		this.pageNumber = this.totalPages > 0 ? this.setController.getPageNumber() : 0;

		this.hasPreviousSet = this.setController.getHasPrevious();
		this.hasNextSet = this.setController.getHasNext();
	}
}