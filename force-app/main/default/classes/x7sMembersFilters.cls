/*
 * Copyright (c) 2018. 7Summits Inc.
 */

/**
 * Members filter management
 */
public with sharing class x7sMembersFilters {
	private final static String FIELD_SEPARATOR = '\\.';
	private final static String MEMBER_RECORD = 'Member';
	private final static String FIELD_NAME = 'Name';
	private final static String FILTER_RECORD = 'x7sMembersFilterEntry__c';
	private final static String FILTER_PARENT = 'Filter__r.Name';
	private final Integer MAXCMTLIMIT = 100;

	// Filter set
	public List<x7s_Members_Filter__mdt> filters { get; set; }

	// Filter settings
	public Decimal PickList_Limit { get; set; }
	public Boolean SendNotification { get; set; }

	public x7sMembersFilters() {
		x7s_Members_Filter_Settings__mdt settings = [
			SELECT Filter_List_Limit__c, Send_Email_Notification__c
			FROM x7s_Members_Filter_Settings__mdt
			WHERE DeveloperName = 'Default'
			WITH SECURITY_ENFORCED
		];

		PickList_Limit = settings.Filter_List_Limit__c;
		SendNotification = settings.Send_Email_Notification__c;

		Map<Id, x7s_Members_Filter__mdt> allFilters = new Map<Id, x7s_Members_Filter__mdt>([
			SELECT Id, DeveloperName, Field_Name__c
			FROM x7s_Members_Filter__mdt
			WITH SECURITY_ENFORCED
			LIMIT :MAXCMTLIMIT
		]);

		filters = allFilters.values();
	}

	public x7s_Members_Filter__mdt getFilterByName(String name) {
		for (x7s_Members_Filter__mdt filter : filters) {
			if (filter.DeveloperName == name) {
				return filter;
			}
		}

		return null;
	}

	public x7s_Members_Filter__mdt getFilterByFieldName(String fieldName) {
		String fieldStringValue = String.escapeSingleQuotes(fieldName);
		String fieldString = fieldStringValue.startsWith(MEMBER_RECORD)
			? fieldStringValue
			: MEMBER_RECORD + '.' + fieldStringValue;


		for (x7s_Members_Filter__mdt filter : filters) {
			if (filter.Field_Name__c == fieldString) {
				return filter;
			}
		}

		return null;
	}

	public x7sMembersFilter__c clearFilter(String filterName) {
		List<x7sMembersFilter__c> filterItems = [SELECT Id, Name FROM x7sMembersFilter__c WHERE Name = :filterName WITH SECURITY_ENFORCED];

		if (filterItems.size() > 0) {
			if (x7sMembersFilter__c.sObjectType.getDescribe().isDeletable()) {
				delete filterItems;
			}
		}

		if (x7sMembersFilter__c.SObjectType.getDescribe().isCreateable()) {
			x7sMembersFilter__c newFilter = new x7sMembersFilter__c(Name = filterName);
			insert newFilter;
		}
		filterItems = [SELECT Id, Name FROM x7sMembersFilter__c WHERE Name = :filterName];
		return filterItems[0];
	}

	public List<String> getFieldRecords(x7s_Members_Filter__mdt filter) {
		List<String> records = new List<String>();
		List<String>fieldParts = filter.Field_Name__c.split(FIELD_SEPARATOR);

		for (Integer count = 0; count < fieldParts.size() - 1; count++) {
			records.add(fieldParts[count]);
		}

		return records;
	}

	public String getFieldName(x7s_Members_Filter__mdt filter) {
		List<String>fieldParts = filter.Field_Name__c.split(FIELD_SEPARATOR);
		String fieldName = fieldParts[fieldParts.size() - 1];

		return fieldName;
	}

	public List<String> getFilterValues(String fieldName, String searchString) {
		x7s_Members_Filter__mdt filter = getFilterByFieldName(fieldName);

		return getFilterValues(filter, searchString);
	}

	public List<String> getFilterValues(x7s_Members_Filter__mdt filter, String searchString) {
		List<String> values = new List<String>();
		Integer recordLimit = (Integer) this.PickList_Limit;

		String query = 'SELECT ' + FIELD_NAME;
		query += ' FROM ' + FILTER_RECORD;
		query += ' WHERE ' + FILTER_PARENT;
		query += ' = \'' + filter.DeveloperName + '\'';

		if (String.isNotBlank(searchString)) {
			query += ' AND  Name LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\'';
		}

		query += ' ORDER BY ' + FIELD_NAME;
		query += ' LIMIT ' + recordLimit;

		System.debug('getFilterValues from Filter object qry: ' + query);

		List<x7sMembersFilterEntry__c> results = Database.query(query);
		for (x7sMembersFilterEntry__c entry : results) {
			values.add(entry.Name);
		}

		System.debug('    found : ' + values.size());
		return values;

	}

	public List<x7sMembersFilterEntry__c> getFilterEntries(x7s_Members_Filter__mdt filter) {
		List<x7sMembersFilterEntry__c> entries = new List<x7sMembersFilterEntry__c>();
		Integer recordLimit = (Integer) this.PickList_Limit;

		String query = 'SELECT ' + FIELD_NAME;
		query += ' FROM ' + FILTER_RECORD;
		query += ' WHERE ' + FILTER_PARENT;
		query += ' = \'' + filter.DeveloperName + '\'';

		query += ' ORDER BY ' + FIELD_NAME;
		query += ' LIMIT ' + recordLimit;

		System.debug('getFilterEntries from Filter object qry: ' + query);

		entries = Database.query(query);

		return entries;
	}

	public void notifyBatchCompletion(Database.BatchableContext bc, x7sMembersFilter__c filter, Integer count) {
		if (!SendNotification) {
			return;
		}

		AsyncApexJob job = [
			SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
			FROM AsyncApexJob
			WHERE Id = :bc.getJobId()
			WITH SECURITY_ENFORCED
		];

		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

		String[] toAddresses = new String[]{job.CreatedBy.Email};
		email.setToAddresses(toAddresses);


		List<String> params = new String[]{
			filter.Name,
			String.valueOf(job.TotalJobItems),
			String.valueOf(job.JobItemsProcessed),
			String.valueOf(job.NumberOfErrors),
			String.valueOf(count)
		};

		email.setSubject(String.format(System.Label.x7sMemberBatchFilterSubject, params) + job.Status);
		email.setPlainTextBody(String.format(System.Label.x7sMembersBatchFilterBody, params));

		Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
	}
}