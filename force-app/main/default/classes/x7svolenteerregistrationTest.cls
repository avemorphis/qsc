/*
@Class Name          : x7svolenteerregistrationTest
@Created by          :
@Description         : Apex Utility class used for creating test records
*/
@IsTest
global class x7svolenteerregistrationTest
{

static testmethod void myTestMethod1() {

List<Event__c> eventList = x7sEventsUtility.createEventsRecords(5);

Volunteer_Need__c vn = new Volunteer_Need__c ();
vn.Name = 'testneed';
vn.Event__c = eventList[0].Id;
Insert vn;


Volunteer_Registration__c vr = new Volunteer_Registration__c();
vr.Volunteer_Need__c = vn.Id;
Insert vr;


}

}