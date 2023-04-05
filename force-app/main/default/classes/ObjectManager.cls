public class ObjectManager 
{
    static MockInterface mockInstance = new MockInterface();
    
    public static List<SalesOrders__x> records(List<SalesOrders__x> records)
    {
        return mockInstance.passThrough(records);   
    }
    
    @TestVisible static void setMock(MockInterface mock)
    {
        mockInstance = mock;
    }
}