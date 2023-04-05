/*
 * Copyright (c) 2020. 7Summits Inc.
 */

public with sharing class x7sEventsListWrapper
{

	@AuraEnabled
	public List<Event__c> objEventList { get; set; }

	@AuraEnabled
	public String detailsForAddToCalendar { get; set; }

	@AuraEnabled
	public String summaryForAddToCalendar { get; set; }

	@AuraEnabled
	public Boolean isEditable { get; set; }

	@AuraEnabled
	public Map <String, String> topicNameToId { get; set; }

	@AuraEnabled
	public Map<String, String> groupIdToName { get; set; }

	@AuraEnabled
	public List<ConnectApi.Topic> topicLst { get; set; }

	@AuraEnabled
	public Integer intDate { get; set; }

	@AuraEnabled
	public String strMonth { get; set; }

	@AuraEnabled
	public String strDay { get; set; }

	@AuraEnabled
	public String strMinute { get; set; }

	@AuraEnabled
	public Integer daysOfMultiDaysEvent { get; set; }

	@AuraEnabled
	public List<TopicAssignment> topicsOfRecord { get; set; }

	@AuraEnabled
	public String strStartDate { get; set; }

	@AuraEnabled
	public String strEndDate { get; set; }

	/* PAGINATION Variables */
	@AuraEnabled
	public Integer totalResults { get; set; }

	@AuraEnabled
	public Integer totalPages { get; set; }

	@AuraEnabled
	public String dtNow { get; set; }

	@AuraEnabled
	public Integer pageNumber { get; set; }

	@AuraEnabled
	public Boolean hasPreviousSet { get; set; }

	@AuraEnabled
	public Boolean hasNextSet { get; set; }

	@AuraEnabled
	public Integer listSizeValue { get; private set; }

	@AuraEnabled
	public Map<Id, List<TopicAssignment>> eventsToTopicsMap { get; set; }

	@AuraEnabled
	public String strTimeZone { get; set; }

	@AuraEnabled
	public String errorMsg { get; set; }

	@AuraEnabled
	public String field { get; set; }

	@AuraEnabled
	public Boolean languageEnabled { get; set; }

	@AuraEnabled
	public Boolean isGuestUser { get; set; }

	@AuraEnabled
	public String userLanguage { get; set; }

	private ApexPages.StandardSetController setController { get; set; }

	public static Id communityId = System.Network.getNetworkId();

	public x7sEventsListWrapper()
	{
		this.field = '';
		this.errorMsg = '';
		this.intDate = 0;
		this.dtNow = '';
		this.strTimeZone = '';
		this.strDay = '';
		this.strEndDate = '';
		this.strStartDate = '';
		this.strMinute = '';
		this.strMonth = '';
		this.isEditable = false;
		this.listSizeValue = 0;
		this.daysOfMultiDaysEvent = 0;
		this.hasNextSet = false;
		this.hasPreviousSet = false;
		this.pageNumber = 0;

		this.topicsOfRecord = new List<TopicAssignment>();
		this.eventsToTopicsMap = new Map<Id, List<TopicAssignment>>();
		this.topicLst = new List<ConnectApi.Topic>();
	}

	public x7sEventsListWrapper(String field, String errorMsg)
	{
		this.field = field;
		this.errorMsg = errorMsg;
	}

	public x7sEventsListWrapper(String QUERY, Set<String> LngIds, Integer listSize, Datetime fromDt, Datetime toDt, Date fromDate, Date toDate, Set<String> eventIds, String listViewMode, Boolean isFeatured, Map<String, String> featurdEventIds, String languageFlag, String userType)
	{
		this.executeQuery(QUERY, LngIds, listSize, fromDt, toDt, fromDate, toDate, eventIds, listViewMode, isFeatured, featurdEventIds, null, languageFlag, userType, null);
	}
	public x7sEventsListWrapper(String QUERY, Set<String> LngIds, Integer listSize, Datetime fromDt, Datetime toDt, Set<String> eventIds, String listViewMode, Boolean isFeatured, Map<String, String> featurdEventIds, String languageFlag, String userType)
	{
		this.executeQuery(QUERY, LngIds, listSize, fromDt, toDt, null, null, eventIds, listViewMode, isFeatured, featurdEventIds, null, languageFlag, userType, null);
	}

	// This function is used by the EventListController
	public x7sEventsListWrapper(String QUERY, Set<String> LngIds, Integer listSize, Datetime fromDt, Datetime toDt, Date fromDate, Date toDate, Set<String> eventIds, String listViewMode, Boolean isFeatured, Map<String, String> featurdEventIds, Set<String> groupEventIds, String languageFlag, String userType, List<String> audienceIds)
	{
		this.executeQuery(QUERY, LngIds, listSize, fromDt, toDt, fromDate, toDate, eventIds, listViewMode, isFeatured, featurdEventIds, groupEventIds, languageFlag, userType, audienceIds);
	}

	public x7sEventsListWrapper(String QUERY, Set<String> LngIds, Integer listSize, Datetime fromDt, Datetime toDt, Set<String> eventIds, String listViewMode, Boolean isFeatured, Map<String, String> featurdEventIds, Set<String> groupEventIds, String languageFlag, String userType)
	{
		this.executeQuery(QUERY, LngIds, listSize, fromDt, toDt, null, null, eventIds, listViewMode, isFeatured, featurdEventIds, groupEventIds, languageFlag, userType, null);
	}

	public void executeQuery(String QUERY, Set<String> LngIds, Integer listSize, Datetime fromDt, Datetime toDt, Date fromDate, Date toDate, Set<String> eventIds, String listViewMode, Boolean isFeatured, Map<String, String> featurdEventIds, Set<String> groupEventIds, String languageFlag, String userType, List<String> audienceIds)
	{
		//Initialise EventList
		strTimeZone = !Auth.CommunitiesUtil.isGuestUser() ? String.valueOf(UserInfo.getTimeZone()) : null;
		this.objEventList = new List<Event__c>();
		this.topicNameToId = new Map<String, String>();

		Set<String> multiLngIds = LngIds;
		System.debug(multiLngIds);

		// language flag check in CMT
		if (String.isNotBlank(languageFlag) && String.isNotEmpty(languageFlag))
		{
			this.languageEnabled = true;
			this.userLanguage = languageFlag;
		} else
		{
			this.languageEnabled = false;
		}
		this.isGuestUser = (userType == 'Guest') ? true : false;

		System.debug('Query');
		System.debug(QUERY);
		System.debug('***My Query END***');
		this.setController = new ApexPages.StandardSetController(Database.getQueryLocator(QUERY));

		if (listViewMode == 'CALENDAR')
		{
			this.listSizeValue = this.setController.getResultSize();
		} else
		{
			this.listSizeValue = listSize;
		}

		this.setController.setPageSize(listSizeValue);

		System.debug('call to update controller attributes');
		updateControllerAttributes(isFeatured, featurdEventIds);
	}

	/*
		 Method Name : nextPage
		 Description : Method for fetching values of next page
	*/
	public void nextPage()
	{
		this.setController.setPageNumber(this.pageNumber + 1 > 0 ? this.pageNumber + 1 : 1);
		updateControllerAttributes(false, null);
	}

	/*
		 Method Name : previousPage
		 Description : Method for fetching values of previous page
	*/
	public void previousPage()
	{
		this.setController.setPageNumber(this.pageNumber - 1 > 0 ? this.pageNumber - 1 : 1);
		updateControllerAttributes(false, null);
	}

	/*
		 Method Name : updateControllerAttributes
		 Description : Method for updating values of controlle attributes
	*/
	private void updateControllerAttributes(Boolean isFeatured, Map<String, String> featurdEventIds)
	{
		if (isFeatured == true)
		{
			List<Event__c> templist = this.setController.getRecords();

			Map<Id, Event__c> tempEventsMap = new Map<Id, Event__c>();

			for (Event__c event : templist)
			{
				tempEventsMap.put(event.Id, event);
			}

			for (String str : featurdEventIds.keySet())
			{
				if (tempEventsMap.containsKey(str))
				{
					this.objEventList.add(tempEventsMap.get(str));
				}
			}
		} else
		{
			//for all other objEventList list get records for set controller directly
			this.objEventList = this.setController.getRecords();
			System.debug('list = ' + this.objEventList.size());
		}

		/*if Record is updated with All day event  then it takes value for today's date else will take today's date with time*/
		if (this.objEventList.size() > 0)
		{
			if (this.objEventList[0].All_Day_Event__c)
			{
				this.dtNow = String.valueOf(Date.today());
			} else
			{
				this.dtNow = String.valueOf(Datetime.now());
			}
		}

		this.totalResults = this.setController.getResultSize();
		this.totalPages = Math.mod(this.setController.getResultSize(),
			this.setController.getPageSize()) == 0 ?
			this.setController.getResultSize() / this.setController.getPageSize() :
			this.setController.getResultSize() / this.setController.getPageSize() + 1;
		this.pageNumber = this.totalPages > 0 ? this.setController.getPageNumber() : 0;
		this.hasPreviousSet = this.setController.getHasPrevious();
		this.hasNextSet = this.setController.getHasNext();

		Set<String> eventsObjIds = new Set<String>();
		for (SObject events : this.setController.getRecords())
		{
			eventsObjIds.add(events.Id);
		}

		eventsToTopicsMap = new Map<Id, List<TopicAssignment>>();
		List<TopicAssignment> topics = new List<TopicAssignment>();

		String topicQuery = 'SELECT Id,EntityId,Topic.Id,Topic.Name FROM TopicAssignment WHERE EntityId IN :eventsObjIds';
		topicQuery += communityId != null ? ' AND NetworkId = :communityId' : ' AND NetworkId = null';

		List<TopicAssignment> assignments = Database.query(string.escapeSingleQuotes(topicQuery));

		for (TopicAssignment t : assignments)
		{
			this.topicNameToId.put(t.Topic.Name, t.Topic.Id);
			topics = new List<TopicAssignment>();
			if (eventsToTopicsMap.containsKey(t.EntityId))
			{
				topics.addAll(eventsToTopicsMap.get(t.EntityId));
			}

			topics.add(t);

			eventsToTopicsMap.put(t.EntityId, topics);
		}

		this.groupIdToName = x7sEventsListController.getAllGroups();
	}
}