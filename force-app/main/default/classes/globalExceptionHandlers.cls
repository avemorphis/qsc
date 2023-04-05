//========================================================================
//  Object: globalExceptionHandlers
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: Global helper class for exception logging for QSC org
//========================================================================
//          Date            Purpose
// Changes: 06/15/2018      Initial Version
//========================================================================


public class globalExceptionHandlers  {


	/**************************************************************************************************************
	logException Insert/Update Record
	Creates record in Exception Log Object to capture exceptions for Update/Insert DML Operations
	---------------------------------------------------------------------------------------------------------------
	@param	  cName			Class Name 
	@param    aMethod		Method Name
	@param    LineNum		Exception Line Number
	@param	  errMessage	Error Message
	@param	  stackTrce		Exception Stack Trace
	@return   void      
	**************************************************************************************************************/
	@Future
	public static void logInsertORUpdateException (String cName, String aMethod, String LineNum, String errMessage, String stackTrce, String eType) {
        
		//Create Exception Record
		Exception_Log__c el = new Exception_Log__c();                
		el.Exception_Message__c  = errMessage;
		el.Apex_Component__c = cName;
		el.Apex_Method__c  = aMethod;
		el.Line_Number__c = LineNum;
		el.log_time__c = System.now();
		el.Running_User__c = UserInfo.getUserId();
		el.Stack_Trace__c = stackTrce;
		el.Exception_Type__c = eType;
               
		//Insert Record    
		Database.insert(el,false);
	}


	/**************************************************************************************************************
	Get Running Class
	Returns current running class from exception Stacktrace
	---------------------------------------------------------------------------------------------------------------
	@param		sTrace		Stacktrace Value
	@return		String		Current Running Class        
	**************************************************************************************************************/
	public static String getClassName(String sTrace) {
		if (sTrace.startsWith('Class.'))
			sTrace = sTrace.substringAfter('Class.');
		return sTrace.substringBefore(':').substringBeforeLast('.');
	}


	/**************************************************************************************************************
	Get Running Method
	Returns current running class from exception Stacktrace
	---------------------------------------------------------------------------------------------------------------
	@param		sTrace		Stacktrace Value
	@return		String		Current Running Method      
	**************************************************************************************************************/	    
	public static String getMethod(String sTrace) {
		return sTrace.substringBefore(':').substringAfterLast('.');
	}
}