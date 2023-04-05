@isTest
public class FeatureKnowledgeablePersonTest {
    
    @isTest
    public static void knowledgeDataTest()
    {
        CollaborationGroup cg = new CollaborationGroup(Name = 'Test', CollaborationType = 'Public');
        INSERT cg;
        FeedItem FI = new FeedItem(Body = 'Test', ParentId = cg.Id);
        INSERT FI;
        String str = cg.Id;
        FeatureKnowledgeablePerson.getKnowledgeData(str);
    }
}