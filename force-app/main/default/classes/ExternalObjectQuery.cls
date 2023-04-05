public virtual inherited sharing class ExternalObjectQuery 
{
	public static List<SObject> records(List<SObject> records)
   {
      return instance.passThrough(records);
   }

   static ExternalObjectQuery instance = new ExternalObjectQuery();
    
   @TestVisible static void setMock(ExternalObjectQuery mock) 
   { 
       instance = mock; 
   }

   protected virtual List<SObject> passThrough(List<SObject> records)
   {
      return records;
   }
}