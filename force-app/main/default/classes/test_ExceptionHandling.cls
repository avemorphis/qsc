//========================================================================
//  Object: test_ExceptionHandling
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: Exception Handling Test Class
//========================================================================
//          Date            Purpose
// Changes: 07/01/2018      Initial Version
//========================================================================

@isTest 
private class test_ExceptionHandling {


	/*************************************************************************************************
	New Exception Handling Record Created
		-Initial Test to get coverage
	
	Test Data Class/Method:  None
	
	Functional Test Logic
	-----------------------------------------------------------------------------
	1. Create Exception Record
	**************************************************************************************************/
	@isTest
	private static void createException() {

		//Build Exception Log Record
		Exception_Log__c el =  new Exception_Log__c();
			el.Apex_Component__c = 'Test Class';
			el.Apex_Method__c = 'Test Method';
			el.Exception_Message__c = 'Test Message';
			el.Exception_Type__c = 'DML';
			el.Line_Number__c = '1911';
		
		//Create
		insert el;

	}
}