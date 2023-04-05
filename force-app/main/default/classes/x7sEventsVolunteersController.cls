/*
 * Copyright (c) 2020. 7Summits Inc.
 */

public with sharing class x7sEventsVolunteersController {

    @AuraEnabled
    public static User getCurrentUser() {
        return [SELECT Id,SmallPhotoUrl,UserType FROM User WHERE Id = :UserInfo.getUserId()];
    }


    // All methods with just event ID to allow for running within current user context
    @AuraEnabled
    public static List<x7sEventsVolunteerWrapper> getEventVolunteerNeeds(String eventIdString) {
        List<x7sEventsVolunteerWrapper> resultsWrapper = getEventVolunteerNeeds(Id.valueOf(eventIdString), UserInfo.getUserId());
        return resultsWrapper;
    }

    @AuraEnabled
    public static Boolean registerVolunteerSingle(String needId) {
        return registerVolunteer(Id.valueOf(needId), UserInfo.getUserId());
    }

    // Hm, why doesn't signature overloading work from Lightning component... had to change this to removeVolunteerSingle even though getEventVolunteerNeeds overload works!
    @AuraEnabled
    public static Boolean removeVolunteerSingle(String needId) {
        return removeVolunteer(Id.valueOf(needId), UserInfo.getUserId());
    }

    // Get volunteer needs and sub-row of registrants for an Event
    @AuraEnabled
    public static List<x7sEventsVolunteerWrapper> getEventVolunteerNeeds(Id eventId, Id userId) {
        // Set up wrapper list
        List<x7sEventsVolunteerWrapper> wrapperList = new List<x7sEventsVolunteerWrapper>();

        try {
            // Query volunteer needs and assign to wrapper
            List<Volunteer_Need__c> volunteerNeeds = [
                    SELECT Event__c,Event__r.Volunteer_Description__c,Criteria__c, Id, Name,Volunteers_Needed__c, Volunteers_Registered__c, (SELECT User__r.Id,User__r.SmallPhotoUrl,User__r.Name FROM Volunteer_Registrations__r)
                    FROM Volunteer_Need__c
                    WHERE Event__c = :eventId
                    WITH SECURITY_ENFORCED
            ];

            // For each volunteer need, create wrapper and assign to wrapper list
            for (Volunteer_Need__c need : volunteerNeeds) {

                // Set up wrapper, assign current need to this wrapper, default registered to false
                x7sEventsVolunteerWrapper wrapper = new x7sEventsVolunteerWrapper();
                wrapper.volunteerNeed = need;
                wrapper.currentUserRegistered = false;

                // Check if user is in list of registrations
                for (Volunteer_Registration__c registration : need.Volunteer_Registrations__r) {
                    // User is in the list, break it!
                    if (registration.User__r.Id == userId) {
                        wrapper.currentUserRegistered = true;
                        break;
                    }
                }

                wrapperList.add(wrapper);
            }
        } catch (Exception e) {
            System.debug('getEventVolunteerNeeds() : ' + e.getMessage() + ' line number: ' + e.getLineNumber());
        }

        return wrapperList;
    }

    // Register a user for a volunteer need
    @AuraEnabled
    public static Boolean registerVolunteer(Id needId, Id userId) {
        if (!Volunteer_Registration__c.SObjectType.getDescribe().isCreateable()) {
            System.debug('registerVolunteer(): unable to create Volunteer_Registration__c');
            return false;
        }

        // Track success
        Boolean success = true;

        // Build registration from need and user IDs
        Volunteer_Registration__c newRegistration = new Volunteer_Registration__c(
                Volunteer_Need__c = needId,
                User__c = userId
        );

        try {
            insert newRegistration;
        } catch (Exception e) {
            // Oh no!
            success = false;
            System.debug(e.getMessage());
        }

        return success;
    }

    // Register a user for a volunteer need
    @AuraEnabled
    public static Boolean removeVolunteer(Id needId, Id userId) {
        if (!Volunteer_Registration__c.SObjectType.getDescribe().isDeletable()) {
            System.debug('registerVolunteer(): unable to delete Volunteer_Registration__c');
            return false;
        }

        // Track success
        Boolean success = true;

        // Find the need in question (in theory there'd only ever be one, but in case multiple were created, remove 'em all!
        List<Volunteer_Registration__c> registrationsToRemove = [SELECT Id FROM Volunteer_Registration__c WHERE Volunteer_Need__c = :needId AND User__c = :userId];

        try {
            delete registrationsToRemove;
        } catch (Exception e) {
            // Oh no!
            success = false;
            System.debug(e.getMessage());
        }

        return success;
    }

    // Create volunteer needs
    @AuraEnabled
    public static List<String> createVolunteerNeeds(Event__c event, List<Volunteer_Need__c> volunteerNeeds, List<Volunteer_Need__c> needsToRemove) {
        // Handle errors
        List<String> errors = new List<String>();

        if (!Volunteer_Need__c.SObjectType.getDescribe().isCreateable() ||
                !Volunteer_Need__c.SObjectType.getDescribe().isUpdateable() ||
                !Volunteer_Need__c.SObjectType.getDescribe().isDeletable()) {
            System.debug('createVolunteerNeeds(): Volunteer_Need__c access error.  isCreateable: '
                    + Volunteer_Need__c.SObjectType.getDescribe().isCreateable()  +
                    ' isUpdateable: ' + Volunteer_Need__c.SObjectType.getDescribe().isUpdateable() +
                    ' isDeletable: ' + Volunteer_Need__c.SObjectType.getDescribe().isDeletable());

            errors.add('Access error.  Volunteer_Need__c');

            return errors;
        }

        Savepoint savepoint = Database.setSavepoint();

        // Update the event - it already exists, so no upsert. We're only changing it's Volunteer Needs description field
        try {
            update event;
        } catch (Exception e) {
            // That didn't work.
            errors.add(e.getMessage());
        }

        // Two lists of Volunteer needs - one for insert and one for update since upsert is not available
        List<Volunteer_Need__c> needsToUpdate = new List<Volunteer_Need__c>();
        List<Volunteer_Need__c> needsToInsert = new List<Volunteer_Need__c>();

        // If Need has an ID, it exists and we should update it. Otherwise it's new and we should insert it
        for (Volunteer_Need__c volunteerNeed : volunteerNeeds) {
            if (volunteerNeed.Id == null) {
                needsToInsert.add(volunteerNeed);
            } else {
                needsToUpdate.add(volunteerNeed);
            }
        }

        // Now for each individual needs
        try {
            insert needsToInsert;
            update needsToUpdate;
            delete needsToRemove;
        } catch (Exception e) {
            // That didn't work.
            errors.add(e.getMessage());
        }

        // If there were errors, roll back DB
        if (errors.size() > 0) {
            Database.rollback(savepoint);
        }

        return errors;
    }

    @AuraEnabled
    public static Event__c initVolunteerNeeds(String eventIdString) {
        try {
            // Get event(s) and volunteer needs for event Id
            List<Event__c> events = [
                    SELECT Id, Volunteer_Description__c, (SELECT Name,Id,Criteria__c,Volunteers_Needed__c FROM Volunteer_Needs__r)
                    FROM Event__c
                    WHERE Id = :Id.valueOf(eventIdString)
                    WITH SECURITY_ENFORCED
            ];

            // If it's found
            if (events.size() > 0) {
                return events[0];
            }
        } catch (Exception e) {
            System.debug('initVolunteerNeeds(): ' + e.getMessage() + ' line number: ' + e.getLineNumber());
        }

        // Default to nothing
        return null;
    }

    @AuraEnabled
    public static String getSitePrefix() {
        return System.Site.getPathPrefix();
    }

}