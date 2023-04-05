public class MockInterfaceOverride extends MockInterface
{
    final List<SObject> objectList;

    MockInterfaceOverride(List<SObject> mockRecords)
    {
        this.objectList = mockRecords;
    }

    public override List<SObject> passThrough(List<SObject> records)
    {
        return objectList;
    }
}