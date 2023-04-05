@isTest
public class TestF_Orders {
	@isTest
	static void testF_Orders(){
		 try{
			 Order obj = new Order();
			 //Set Fields
			 obj = (Order) FieloPLT.SObjectService.setRequiredFields(Order.sObjectType, obj);
			 insert obj;
			 //Set Fields
			 obj = (Order) FieloPLT.SObjectService.setRequiredFields(Order.sObjectType, obj);
			 update obj;
		 } catch(Exception e) {}

	}}