/*
 * Copyright (c) 2020. 7Summits Inc.
 */

public with sharing class x7sIdeasCommentController {

//	Public methods
//	----------------------------------------------------------

	@AuraEnabled (Cacheable=true)
	public static x7sIdeasCommon getCommonSettings(String zoneName, Boolean loadCustomFields, String fieldSetName) {
		x7sIdeasCommon settings = new x7sIdeasCommon('', loadCustomFields);

		settings.sitePath = System.Site.getPathPrefix();
		settings.nicknameEnabled = x7sIdeasUtility.isNicknameDisplayEnabled();
		settings.isAuthenticated = x7sIdeasUtility.isAuthenticated();
		settings.zoneId = x7sIdeasUtility.getZoneId(zoneName);

		if (String.isNotBlank(fieldSetName)) { settings.customFields = settings.getCustomFields(fieldSetName); }

		return settings;
	}

	@AuraEnabled
	public static Vote likeIdeaComment(String commentId) {
		System.debug('Like comment: ' + commentId);
		try 
		{
			if(Vote.SObjectType.getDescribe().isCreateable() &&
				Schema.SObjectType.Vote.fields.ParentId.isCreateable() &&
				Schema.SObjectType.Vote.fields.Type.isCreateable())
			{
				Vote v = new Vote();
				v.ParentId = commentId;
				v.Type = 'Up';
				insert v;
				return v;
			}
			return null;
		}
		catch (Exception ex) { System.debug('Error in likeIdeaComment:' + ex.getMessage() + ',Line number : ' + ex.getLineNumber()); return null; }
	}

	@AuraEnabled
	public static Boolean unlikeIdeaComment(String voteId) {
		System.debug('Unlike comment:' + voteId);
		Boolean result = false;
		try {
			Vote voteItem = [
				SELECT Id
				FROM Vote
				WHERE Parent.Type = 'IdeaComment' AND Id = :voteId AND Type = 'Up' AND CreatedById = :UserInfo.getUserId()
				LIMIT 1
			];

			if (voteItem != null && Vote.SObjectType.getDescribe().isDeletable()) 
			{
				delete voteItem;
				result = true;
			}
		} catch (Exception ex) {
            System.debug('unlikeIdeaComment() - Error :' + ex.getMessage() + ',Line number : ' + ex.getLineNumber());
		}
		return result;
	}

	@AuraEnabled
	public static IdeaComment addComment(String ideaId, String commentBody) {
		System.debug('addComment: ' + ideaId + ', ' + commentBody);
		try {
			if(IdeaComment.SObjectType.getDescribe().isCreateable() &&
				Schema.SObjectType.IdeaComment.fields.CommentBody.isCreateable() &&
				Schema.SObjectType.IdeaComment.fields.IdeaId.isCreateable())
			{
				IdeaComment newComment = new IdeaComment();

				newComment.CommentBody = commentBody;
				newComment.IdeaId = ideaId;

				insert newComment;
                system.debug('Comment id: '+newComment.id);
				x7sIdeasSubscription.ideaSubscribe(UserInfo.getUserId(), ideaId);
                newCommentNotification(ideaId, UserInfo.getName());
                x7sIdeasViewController.vote(ideaId, true);
				System.debug('new idea comment: ' + newComment);
				return newComment;
			}
			return null;
		} catch (Exception ex) { System.debug('unlikeIdeaComment() - Error :' + ex.getMessage() + ',Line number : ' + ex.getLineNumber()); return null; }
	}

    //Sending added comment notification to other Idea subscriber
    @AuraEnabled
    public static void newCommentNotification(String ideaId, String creatorName) {
        List<Idea> ideaData = [SELECT Id, CommunityId, CreatedById, CreatedBy.Name, Title FROM Idea Where Id =: ideaId];
        List<X7S_Ideas_Subscription__c> ideaSubData = [SELECT Id, ParentId__c, SubscriberId__c 
                                                       FROM X7S_Ideas_Subscription__c Where ParentId__c =: ideaId]; 
        // Create a new custom notification
        List<IdeaComment> IdCom =  [SELECT Id, IdeaId, CreatedById, CommunityId FROM IdeaComment 
                                    Where CommunityId =: ideaData[0].CommunityId
                                    ORDER BY createddate DESC limit 1];
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType 
                                                   WHERE DeveloperName='Other_Subscriber_Notifications'];
        Set<String> subscriberIdSet = new Set<String>();
        for(X7S_Ideas_Subscription__c ideaSub : ideaSubData)
        {
            System.debug('Entered in send subscriber notifications');
            Map<String, Object> pageRef = new Map<String, Object>{
                'type' => 'standard__webPage',
                    'attributes' => new Map<String, Object> {
                        'url' => '/QSCDeveloperCommunity/s/idea/' + ideaId + '/detail'
                            }
            };
                // Set the contents for the notification
            notification.setTitle('An idea you follow has a new comment!');
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetPageRef(JSON.serialize(pageRef));
            notification.setBody(creatorName+' left a comment on '+ideaData[0].Title+', an idea you follow in the Q-SYS Communities for developers.');
            if(IdCom[0].CreatedById != ideaSub.SubscriberId__c)
            {
                subscriberIdSet.add(ideaSub.SubscriberId__c);
            } 
        }
        try {
            if(subscriberIdSet.size() > 0)
            {
                notification.send(subscriberIdSet);
            }
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        } 
    }
    

    
	@AuraEnabled
	public static x7sIdeasCommentList getComments(
		String zoneName,
		String ideaId,
		Decimal pageSize,
		Decimal pageNumber,
		String sortOrder) {
		System.debug('zoneName:     ' + zoneName);
		System.debug('ideaId:       ' + ideaId);
		System.debug('pageSize:     ' + pageSize);
		System.debug('pageNumber:   ' + pageNumber);
		System.debug('sortOrder:    ' + sortOrder);

		x7sIdeasCommentList commentsList = new x7sIdeasCommentList();

		String zoneId = getZoneId(zoneName);

		if (String.isBlank(zoneId)) {
			commentsList.statusCode = 1;
			commentsList.statusMessage = 'ZoneId not found for ' + zoneName;
			System.debug(commentsList.statusCode + ' : ' + commentsList.statusMessage);

			return commentsList;
		}
		else {
			System.debug('ZoneId = ' + zoneId);
		}

		Decimal searchOffset = pageSize * (pageNumber - 1);

		String selectClause = getSelectClause();
		String fromClause = getFromClause();
		String whereClause = getWhereClause(zoneId, ideaId);
		String orderByClause = getOrderByClause(sortOrder);
		String limitClause = ' LIMIT ' + (Integer) pageSize;
		String offsetClause = searchOffset > 0 ? ' OFFSET ' + (Integer) searchOffset : '';

		Decimal total = getCommentCount(fromClause, whereClause);


		if (total < 1) {
			commentsList.statusCode = 2;
			commentsList.statusMessage = 'NO records found';
			System.debug(commentsList.statusCode + ' : ' + commentsList.statusMessage);

			return commentsList;
		}
		else {
			System.debug('Total comments found: ' + total);
		}

		String query = selectClause
			+ fromClause
			+ whereClause
			+ orderByClause
			+ limitClause
			+ offsetClause;

		System.debug('Comment query: ' + query);

		//PMD : False positive, All variables are checked
		List<IdeaComment> items = (List<IdeaComment>) Database.query(query); //NOPMD
		for (IdeaComment item : items) {
			commentsList.commentIds.add(item.Id);
		}

		Map<String, Vote> votes = getCommentVotes(commentsList.commentIds);

		for (IdeaComment item : items) {
			System.debug('    Item: ' + item.Id);
			x7sIdeasCommentModel model = new x7sIdeasCommentModel();

			model.id = item.Id;
			model.zoneId = item.CommunityId;
			model.createdDate = item.CreatedDate;
			model.creatorId = item.CreatedById;
			model.creatorName = item.CreatorName;
			model.nickName = item.CreatedBy.CommunityNickname;
			model.smallPhotoUrl = item.CreatorSmallPhotoUrl;
			model.fullPhotoUrl = item.CreatorFullPhotoUrl;
			model.isHtml = item.IsHtml;
			model.upVotes = item.UpVotes;
			model.commentBody = item.CommentBody;

			// voting
			model.likedByUser = votes.get(item.Id) != null;
			model.voteId = model.likedByUser ? votes.get(item.Id).Id : null;

			System.debug('Adding comment: ' + model);
			commentsList.items.add(model);
		}

		commentsList.total = total;
		commentsList.pageSize = pageSize;
		commentsList.pageCurrent = pageNumber;
		commentsList.pageHasPrevious = searchOffset > 0;
		commentsList.pageHasNext = (pageSize * pageNumber) < total;
		commentsList.pageCount = Math.max(Math.ceil(total / pageSize), 1);

		commentsList.sitePrefix = getSitePrefix();
		commentsList.useNickName = nickNameEnabled();

		return commentsList;
	}

//	 Private methods
//	-----------------------------------------------------------------
	@TestVisible
	private static String getSelectClause() {

		return 'SELECT Id'
			+ ', CommentBody'
			+ ', CommunityId'
			+ ', CreatorFullPhotoUrl'
			+ ', CreatorSmallPhotoUrl'
			+ ', CreatorName'
			+ ', CreatedById'
			+ ', CreatedBy.CommunityNickname'
			+ ', CreatedDate'
			+ ', UpVotes'
			+ ', IsHtml';
	}

	@TestVisible
	private static String getFromClause() {
		return ' FROM IdeaComment';
	}

	@TestVisible
	private static String getWhereClause(String zoneId, String ideaId) {
		return ' WHERE CommunityId = \'' + zoneId + '\'' + 'AND IdeaId = \'' + String.escapeSingleQuotes(ideaId) + '\'';

	}

	@TestVisible
	private static String getOrderByClause(String sortOrder) {
		String orderBy = '';

		if (String.isNotBlank(sortOrder)) {
			switch on sortOrder {
				when 'LatestComment' {
					orderBy += 'CreatedDate DESC';
				}
				when 'OldestComment' {
					orderBy += 'CreatedDate ASC';
				}
				when 'MostVotes' {
					orderBy += 'UpVotes DESC';
				}
				when 'LeastVotes' {
					orderBy += 'UpVotes ASC';
				}
			}
		}

		return String.isNotBlank(orderBy) ? ' ORDER BY ' + orderBy : '';
	}

	@TestVisible
	private static Decimal getCommentCount(String fromClause, String whereClause) {
		String countQuery = 'SELECT count()' + fromClause + whereClause;
		System.debug('Count query: ' + countQuery);

		Decimal total = Database.countQuery(countQuery);

		return total;
	}

	@TestVisible
	private static String getZoneId(String nameValue) {
		System.debug('GetZoneId(' + nameValue + ')');

		if (String.isNotBlank(nameValue)) {
			try {
				List<Community> currCommunity = [SELECT Id FROM Community WHERE Name = :nameValue WITH SECURITY_ENFORCED];

				if (currCommunity != null && currCommunity.size() > 0) {
					return currCommunity[0].Id;
				}
			} catch (Exception ex) {
				System.debug('getZoneId() - Error :' + ex.getMessage() + ',Line number : ' + ex.getLineNumber());
			}
		}
		return '';
	}

	@TestVisible
	private static String getSitePrefix() {
		String prefix = System.Site.getPathPrefix();
		return prefix;
	}

	@TestVisible
	private static Boolean nickNameEnabled() {
		Id networkId = System.Network.getNetworkId();
		Boolean nickName = false;

		try {
			Network currNetwork = [SELECT Id, OptionsNicknameDisplayEnabled FROM Network WHERE Id = :networkId WITH SECURITY_ENFORCED LIMIT 1];
			if (currNetwork != null) { nickName = currNetwork.OptionsNicknameDisplayEnabled; }
		}
		catch (Exception e) {
			nickName = false;
		}

		return nickName;
	}

	@TestVisible
	private static Map<String, Vote> getCommentVotes(List<Id> commentIds) {
		List<Vote> voteList = [
			SELECT CreatedById,CreatedDate,Id,ParentId,Type
			FROM Vote
			WHERE Parent.Type = 'IdeaComment' AND ParentId IN :commentIds
			AND Type = 'Up' AND CreatedById = :UserInfo.getUserId()
		];

		Map<String, Vote> voteMap = new Map<String, Vote>();
		for (Vote v : voteList) {
			voteMap.put(v.ParentId, v);
		}

		System.debug('Comment votes: ' + voteMap);
		return voteMap;
	}
}