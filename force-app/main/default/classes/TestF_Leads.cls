@isTest
public class TestF_Leads {
	@isTest
	static void testF_Leads(){
		 try{
			 Lead obj = new Lead();
			 //Set Fields
			 obj = (Lead) FieloPLT.SObjectService.setRequiredFields(Lead.sObjectType, obj);
			 insert obj;
			 //Set Fields
			 obj = (Lead) FieloPLT.SObjectService.setRequiredFields(Lead.sObjectType, obj);
			 update obj;
		 } catch(Exception e) {}

	}}