public without sharing class FeatureKnowledgeablePerson {

    @AuraEnabled
    public static List<user> getKnowledgeData(string recordId)
    {
        List<CollaborationGroupFeed> groupFeedList = New List<CollaborationGroupFeed>();
		groupFeedList = [SELECT Id, ParentId, RelatedRecordId, CommentCount, 
                                                      LikeCount, Title, Body, BestCommentId
                								      FROM CollaborationGroupFeed 
                                                      where ParentId =: recordId AND BestCommentId != null];
        Set<Id> bestCommentIds = new Set<Id>();
        For(CollaborationGroupFeed gFeed : groupFeedList)
        {
            bestCommentIds.add(gFeed.BestCommentId);
        }
        List<AggregateResult> feedComments = New List<AggregateResult>();
        feedComments = [SELECT count(Id) num, CreatedById FROM FeedComment 
                                          	where Id IN: bestCommentIds
                                          	group by CreatedById 
                                            ORDER BY count(Id) DESC LIMIT 3];
        Set<Id> userIds = new Set<Id>();
		for(AggregateResult ar: feedComments)
        {
            userIds.add((String)ar.get('CreatedById'));
        }
        List<user> userList = New List<user>();
        userList = [select Id, Name, FullPhotoUrl from user 
                               where Id IN: userIds];
		return userList;
    }
}