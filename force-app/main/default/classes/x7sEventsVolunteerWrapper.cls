/*
 * Copyright (c) 2020. 7Summits Inc.
 */

public with sharing class x7sEventsVolunteerWrapper {
    @AuraEnabled public Volunteer_Need__c volunteerNeed{get;set;}
    @AuraEnabled public Boolean currentUserRegistered{get;set;}
}