public virtual inherited sharing class MockInterface
{
	 public static List<SObject> records(List<SObject> records)
   {
      return instance.passThrough(records);
   }

   static MockInterface instance = new MockInterface();
   @TestVisible static void setMock(MockInterface mock) { instance = mock; }

   protected virtual List<SObject> passThrough(List<SObject> records)
   {
      return records;
   }
}