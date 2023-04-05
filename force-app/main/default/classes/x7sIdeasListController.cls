/*
* Copyright (c) 2020. 7Summits Inc.
*/

public with sharing class x7sIdeasListController {
    @AuraEnabled
    public static Id getUserId() {
        return UserInfo.getUserId();
    }
    
    @AuraEnabled (Cacheable=true)
    public static String getSitePrefix() {
        return System.Site.getPathPrefix();
    }
    
    @AuraEnabled
    public static Boolean isAuthenticated() {
        return !Auth.CommunitiesUtil.isGuestUser();
    }
    
    @AuraEnabled (Cacheable=true)
    public static Boolean isNicknameDisplayEnabled() {
        return x7sIdeasUtility.isNicknameDisplayEnabled();
    }
    
    @AuraEnabled (Cacheable=true)
    public static String getZoneId(String nameValue) {
        if (!String.isEmpty(nameValue)) {
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
    
    @AuraEnabled (Cacheable=true)
    public static x7sIdeasCommon getCommonSettings(String zoneName) {
        x7sIdeasCommon settings = new x7sIdeasCommon('', false);
        if (String.isNotBlank(zoneName)) { settings.zoneId = getZoneId(zoneName); }
        return settings;
    }
    
    @AuraEnabled
    public static x7sIdeasListWrapper getIdeas() {
        System.debug('getIdeas >>>');
        return getIdeas(50, null, null, 'Popular Ideas', false, false, null, false, null, false, false, 'My Ideas', '', '', '', '', false, false, '', false, '', false, '', false, '', false, '', false, '', false, '', false);
    }
    
    
    @AuraEnabled
    public static x7sIdeasViewController.VotingDetails getVotingDetails(String ideaId) {
        return x7sIdeasViewController.getVotingLimitsForAccount(ideaId);
    }
    
    @AuraEnabled
    public static Integer getIdeasAttributeCount(String zoneId, String type, String userId) {
        if (type == 'Voted On Ideas' && Vote.SObjectType.getDescribe().isAccessible()) {
            List<Vote> voteList = [SELECT ParentId FROM Vote WHERE CreatedById = :userId AND Parent.Type = 'Idea'];
            List<String> votedOnIdList = new List<String>();
            for (Vote v : voteList) {
                votedOnIdList.add(v.ParentId);
            }
            
            return [SELECT COUNT() FROM Idea WHERE CommunityId = :zoneId AND Id IN :votedOnIdList AND CreatedById != :userId];
        }
        else {
            return [SELECT COUNT() FROM Idea WHERE CreatedById = :userId AND CommunityId = :zoneId];
        }
    }
    
    @AuraEnabled
    public static x7sIdeasListWrapper getIdeas(
        Integer listSize,//1
        String categories,//2
        String zoneId,//3
        String sortBy,//4
        Boolean limitVoteToEmailDomain,//5
        Boolean filterByTopic,//6
        String topicNameAndFeatureList,//7
        Boolean filterBySearchTerm,//8
        String searchTerm,//9
        Boolean filterOnUserOwned,//10
        Boolean filterOnUserVoted,//11
        String searchMyIdeas,//12
        String searchByCategories,//13
        String searchByTopics,//14
        String searchByStatus,//15
        String searchByThemes,//16
        Boolean filterByMergeIdea,//17
        Boolean filterByMyVotedIdeas,//18
        String searchByMyVotedIdeas,//19
        Boolean filterMyCommentedIdeas,//20
        String searchMyCommentedIdeas,//21
        Boolean filterMySubscribedIdeas,//22
        String searchMySubscribedIdeas,//23
        Boolean filterMyCompanyIdeas,//24
        String searchMyCompanyIdeas,//25
        Boolean filterMyCompanyVotedIdeas,//26
        String searchMyCompanyVotedIdeas,//27
        Boolean filterMyCompanyCommentedIdeas,//28
        String searchMyCompanyCommentedIdeas,//29
        Boolean filterMyCompanySubscribedIdeas,//30
        String searchMyCompanySubscribedIdeas,//31
        Boolean filterIdeasIFollow//32
    ) {
        
        List<String> featuredIds = new List<String>();
        String topicName = '';
        
        if (String.isNotBlank(topicNameAndFeatureList)) {
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(topicNameAndFeatureList);
            System.debug('topicNameAndFeatureList' + m);
            
            topicName = (String) m.get('topicName');
            
            List<Object> idList = (List<Object>) m.get('featureids');
            if (idList != null) {
                for (Object a : idList) { featuredIds.add(String.escapeSingleQuotes(String.valueOf(a))); }
            }
        }
        
        System.debug('--- categories        ---' + categories);
        System.debug('--- zoneId            ---' + zoneId);
        System.debug('--- sortBy            ---' + sortBy);
        System.debug('--- limitVoteToEmailDomain ---' + limitVoteToEmailDomain);
        System.debug('--- filterByTopic     ---' + filterByTopic);
        System.debug('--- topicName         ---' + topicName);
        System.debug('--- filterBySearchTerm ---' + filterBySearchTerm);
        System.debug('--- searchTerm        ---' + searchTerm);
        System.debug('--- filterOnUserOwned ---' + filterOnUserOwned);
        System.debug('--- filterOnUserVoted ---' + filterOnUserVoted);
        System.debug('--- searchMyIdeas     ---' + searchMyIdeas);
        System.debug('--- searchByCategories ---' + searchByCategories);
        System.debug('--- searchByTopics    ---' + searchByTopics);
        System.debug('--- searchByStatus    ---' + searchByStatus);
        System.debug('--- searchByThemes    ---' + searchByThemes);
        System.debug('--- filterByMergeIdea ---' + filterByMergeIdea);
        System.debug('--- filterByMyVotedIdeas ---' + filterByMyVotedIdeas);
        System.debug('--- searchByMyVotedIdeas ---' + searchByMyVotedIdeas);
        System.debug('--- filterMyCommentedIdeas ---' + filterMyCommentedIdeas);
        System.debug('--- searchMyCommentedIdeas ---' + searchMyCommentedIdeas);
        System.debug('--- filterMySubscribedIdeas ---' + filterMySubscribedIdeas);
        System.debug('--- searchMySubscribedIdeas ---' + searchMySubscribedIdeas);
        System.debug('--- filterMyCompanyIdeas ---' + filterMyCompanyIdeas);
        System.debug('--- searchMyCompanyIdeas ---' + searchMyCompanyIdeas);
        System.debug('--- filterMyCompanyVotedIdeas ---' + filterMyCompanyVotedIdeas);
        System.debug('--- searchMyCompanyVotedIdeas ---' + searchMyCompanyVotedIdeas);
        
        System.debug('--- filterMyCompanyCommentedIdeas ---' + filterMyCompanyCommentedIdeas);
        System.debug('--- searchMyCompanyCommentedIdeas ---' + searchMyCompanyCommentedIdeas);
        System.debug('--- filterMyCompanySubscribedIdeas ---' + filterMyCompanySubscribedIdeas);
        System.debug('--- searchMyCompanySubscribedIdeas ---' + searchMyCompanySubscribedIdeas);
        System.debug('--- featuredIds ---' + featuredIds);
        System.debug('--- filterIdeasIFollow ---' + filterIdeasIFollow);
        
        if (!String.isEmpty(categories)) {
            categories = String.escapeSingleQuotes(categories);
        }
        if (!String.isEmpty(zoneId)) {
            zoneId = String.escapeSingleQuotes(zoneId);
        }
        if (!String.isEmpty(sortBy)) {
            sortBy = String.escapeSingleQuotes(sortBy);
        }
        if (!String.isEmpty(topicName)) {
            topicName = String.escapeSingleQuotes(topicName);
        }
        if (!String.isEmpty(searchTerm)) {
            searchTerm = String.escapeSingleQuotes(searchTerm);
        }
        
        List<String> categoryList = parseStringToList(categories);
        List<String> themesList = parseStringToList(searchByThemes);
        List<String> topicsList = parseStringToList(searchByTopics);
        System.debug('Topic list: ' + topicsList);
        
        Set<Id> ideasIds = new Set<Id>();
        Integer listSizeValue = listSize != null ? Integer.valueOf(listSize) : 50;
        
        Boolean limitVoteToEmailDomainValue = limitVoteToEmailDomain != null ? Boolean.valueOf(limitVoteToEmailDomain) : false;
        Boolean filterByTopicValue = filterByTopic != null ? Boolean.valueOf(filterByTopic) : false;
        Boolean filterBySearchTermValue = filterBySearchTerm != null ? Boolean.valueOf(filterBySearchTerm) : false;
        Boolean filterOnUserOwnedValue = filterOnUserOwned != null ? Boolean.valueOf(filterOnUserOwned) : false;
        Boolean filterOnUserVotedValue = filterOnUserVoted != null ? Boolean.valueOf(filterOnUserVoted) : false;
        Boolean filterOnMyVotedIdeas = searchByMyVotedIdeas != null ? Boolean.valueOf(filterByMyVotedIdeas) : false;
        Boolean filterOnMyCommentedIdeas = filterMyCommentedIdeas != null ? Boolean.valueOf(filterMyCommentedIdeas) : false;
        Boolean filterOnMySubscribedIdeas = filterMySubscribedIdeas != null ? Boolean.valueOf(filterMySubscribedIdeas) : false;
        Boolean filterOnMyCompanyIdeas = filterMyCompanyIdeas != null ? Boolean.valueOf(filterMyCompanyIdeas) : false;
        Boolean filterOnMyCompanyVotedIdeas = filterMyCompanyVotedIdeas != null ? Boolean.valueOf(filterMyCompanyVotedIdeas) : false;
        
        Boolean filterOnMyCompanyCommentedIdeas = filterMyCompanyCommentedIdeas != null ? Boolean.valueOf(filterMyCompanyCommentedIdeas) : false;
        Boolean filterOnMyCompanySubscribedIdeas = filterMyCompanySubscribedIdeas != null ? Boolean.valueOf(filterMyCompanySubscribedIdeas) : false;
        
        
        String QUERY = 'SELECT Id, Title, Status, CreatedBy.Name, CreatedBy.CommunityNickname, CreatedBy.Id, Related_Topic_Name__c,';
        QUERY += ' Body, CreatedDate, Categories, numComments, VoteTotal, attachmentName,';
        QUERY += ' X7S_Ideas_Extension__c, X7S_Ideas_Extension__r.Name, ';
        
        if (!String.isEmpty(sortBy) && sortBy == 'Recent Comments') {
            QUERY += ' LastComment.CreatedDate, LastComment.CreatedBy.Name, LastComment.CreatedBy.CommunityNickname, LastComment.CreatedBy.Id,LastComment.CommentBody,';
        }
        
        QUERY += ' (SELECT Type, CreatedById, CreatedBy.CommunityNickname FROM Votes WHERE CreatedById = \'' + UserInfo.getUserId() + '\'';
        
        if (limitVoteToEmailDomainValue) {
            String userEmail = UserInfo.getUserEmail();
            String domain = '%' + userEmail.split('@')[1];
            QUERY += ' OR CreatedBy.Email LIKE \'' + domain + '\' ORDER BY CreatedDate DESC)';
        }
        else {
            QUERY += ')';
        }
        
        QUERY += ' FROM Idea';
        
        if (String.isEmpty(zoneId)) {
            QUERY += ' WHERE CommunityId != null ';
        }
        else {
            QUERY += ' WHERE CommunityId = \'' + zoneId + '\' ';
        }
        // IsMerged
        if (filterByMergeIdea == true) { QUERY += ' AND IsMerged != true '; }
        
        //My Ideas
        if (!String.isEmpty(searchMyIdeas) && searchMyIdeas.indexOf('No') == -1 && searchMyIdeas.indexOf('Topic') == -1) {
            if (searchMyIdeas.indexOf('Ideas') != -1) {
                for (Idea lstIdeas : [SELECT Id,CreatedById FROM Idea WHERE CreatedById = :UserInfo.getUserId() LIMIT 1000]) {
                    ideasIds.add(lstIdeas.Id);
                }
            }
            
            if (searchMyIdeas.indexOf('Voted') != -1) { filterOnUserVotedValue = true; }
            
            QUERY += ' And Id IN : ideasIds' ;
        }
        
        if (featuredIds.size() > 0) { QUERY += ' And Id IN ' + '(\'' + String.join(featuredIds, '\',\'') + '\')' ; }
        
        System.debug('My Ideas : ' + QUERY);
        
        // Idea Themes
        if (themesList.size() > 0) { QUERY += ' AND ' + buildInQuery(themesList, 'IdeaTheme.Title'); }
        
        System.debug('Idea Themes: ' + QUERY);
        
        // Categories
        if (categoryList.size() > 0) {
            String categoriesJoined = '(\'' + String.join(categoryList, '\',\'') + '\')';
            
            QUERY += ' AND Categories INCLUDES ' + categoriesJoined;
        }
        
        System.debug('Categories: ' + QUERY);
        
        // Topics - handle '-' in topic name
        if (filterByTopicValue && !String.isEmpty(topicName)) {
            System.debug('Topic: ' + topicName);
            QUERY += ' AND Related_Topic_Name__c = \'' + getTopicNameFromId(topicName) + '\'';
        }
        
        // Search term
        if (String.isNotBlank(searchTerm)) {
            String searchQueryTerm = searchTerm.trim();
            
            if (String.isNotBlank(searchQueryTerm)) {
                QUERY += ' AND ( Title LIKE \'%' + searchQueryTerm + '%\' )';
                System.debug(QUERY);
            }
        }
        else if (filterBySearchTermValue && String.isEmpty(searchTerm)) {
            QUERY += ' AND Title = \'______\'';
        }
        
        System.debug('Search Term: ' + QUERY);
        
        //Ideas Picklist Filters
        if (filterOnUserOwnedValue) {
            QUERY += ' AND CreatedById = \'' + UserInfo.getUserId() + '\'';
        }
        else if (filterOnUserVotedValue || filterOnMyVotedIdeas) {
            //QUERY += ' AND CreatedById != \'' + UserInfo.getUserId() + '\'';
            QUERY += ' AND Id IN (SELECT ParentId FROM Vote WHERE CreatedById = \'' + UserInfo.getUserId() + '\' AND Parent.Type = \'Idea\')';
        }
        else if (filterOnMyCommentedIdeas) {
            QUERY += ' AND Id IN (SELECT IdeaId FROM IdeaComment WHERE CommunityId = \'' + zoneId + '\' AND CreatedById = \'' + UserInfo.getUserId() + '\')';
        }
        else if (filterOnMySubscribedIdeas) {
            QUERY += ' AND Id IN (SELECT ParentId__c FROM X7S_Ideas_Subscription__c WHERE CreatedById = \'' + UserInfo.getUserId() + '\')';
        }
        
        System.debug('Voted by Me: ' + QUERY.substring(25, QUERY.length() - 1));
        
        
        //Ideas Picklist Account Filters
        List<User> usr = (List<User>) Database.query('SELECT Id, AccountId FROM User WHERE Id = ' + '\'' + String.escapeSingleQuotes(UserInfo.getUserId()) + '\'');
        List<String> listOfUserIds = new List<String>();
        
        if (!usr.isEmpty() && usr[0].AccountId != null) {
            List<Account> acc = (List<Account>) Database.query('SELECT Id,Name, Account_Vote_Limit__c FROM Account WHERE Id = ' + '\'' + String.escapeSingleQuotes(usr[0].AccountId) + '\'');
            
            if (!acc.isEmpty()) {
                for (User userr : (List<User>) Database.query('SELECT Id,ContactId,AccountId FROM User WHERE AccountId = ' + '\'' + String.escapeSingleQuotes(acc[0].Id) + '\'')) {
                    listOfUserIds.add(userr.Id);
                }
            }
        }
        
        if (!listOfUserIds.isEmpty()) {
            if (filterOnMyCompanyIdeas) { QUERY += 'AND ' + buildInQuery(listOfUserIds, 'CreatedById'); }
            else if (filterOnMyCompanyVotedIdeas) { QUERY += 'AND Id IN (SELECT ParentId FROM Vote WHERE ' + buildInQuery(listOfUserIds, 'CreatedById') + ' AND Parent.Type = \'Idea\' )'; }
            else if (filterOnMyCompanyCommentedIdeas) { QUERY += ' AND Id IN (SELECT IdeaId FROM IdeaComment WHERE CommunityId = \'' + zoneId + '\' AND ' + buildInQuery(listOfUserIds, 'CreatedById') + ')'; }
            else if (filterOnMyCompanySubscribedIdeas) { QUERY += ' AND Id IN (SELECT ParentId__c FROM X7S_Ideas_Subscription__c WHERE ' + buildInQuery(listOfUserIds, 'CreatedById') + ')'; }
            
        }
        System.debug('My Account Filters: ' + QUERY.substring(30, QUERY.length() - 1));
        
        
        //change by sachin to make it csv instead of single value
        if (String.isNotBlank(searchByCategories)) { QUERY += ' AND Categories IN  ' + '(\'' + String.join(searchByCategories.split(','), '\',\'') + '\')'; }
        
        // Can't do filter and search together
        if (String.isEmpty(topicName) && String.isNotBlank(searchByTopics)) {
            List<String> topicFilterList = new List<String>();
            
            System.debug('topic filer: ' + topicsList);
            for (String topicEntry : topicsList) {
                if (topicEntry.indexOf('-') != -1) { topicFilterList.add(' Related_Topic_Name__c LIKE \'%' + topicEntry.replace('-', '%') + '%\''); }
                else { topicFilterList.add(' Related_Topic_Name__c = \'' + topicEntry + '\''); }
            }
            
            QUERY += ' AND ('; QUERY += String.join(topicFilterList, ' OR '); QUERY += ') ';
        }
        
        if (String.isNotBlank(searchByStatus)) {
            QUERY += ' AND Status IN ' + '(\'' + String.join(String.escapeSingleQuotes(searchByStatus).split(','), '\',\'') + '\')' ;
        }
        
        System.debug('Status Filter: ' + QUERY);
        
        //Idea I Follow Condition and it is changed by prakher.jain@qsc.com.
        If(filterIdeasIFollow)
        {
            String userRecordId = String.escapeSingleQuotes(UserInfo.getUserId());
            
            List<EntitySubscription> listEntitySubscriptions = [SELECT Id, ParentId, Parent.Name, SubscriberId, Subscriber.Name 
                                                                FROM EntitySubscription 
                                                                WHERE SubscriberId =: userRecordId
                                                                AND ParentId != null
                                                                LIMIT 1000
                                                               ];
            If(!listEntitySubscriptions.isEmpty())
            {
                Set<String> setTopicNames = new Set<String>();
                
                For(EntitySubscription objEntitySubscription : listEntitySubscriptions)
                {
                    setTopicNames.add(objEntitySubscription.Parent.Name.trim());
                }
                
                If(!setTopicNames.isEmpty())
                {
                    List<X7S_Ideas_Subscription__c> listIdeasSubscriptions = [SELECT Id, Name, ParentId__c, SubscriberId__c 
                                                                              FROM X7S_Ideas_Subscription__c 
                                                                              WHERE SubscriberId__c =: userRecordId 
                                                                              AND ParentId__c != null
                                                                             ];
                    
                    If(!listIdeasSubscriptions.isEmpty())
                    {
                        Set<Id> setIdeaIds = new Set<Id>();
                        
                        For(X7S_Ideas_Subscription__c objIdeasSubscription : listIdeasSubscriptions)
                        {
                            setIdeaIds.add(objIdeasSubscription.ParentId__c);
                        }
                        
                        String strTopicName = '';
                        
                        For(String st : setTopicNames)
                        {
                            strTopicName += st + ',';
                        }
                        system.debug('strTopicName : ' + strTopicName);
                        
                        String strIdeaId = '';
                        
                        For(String st : setIdeaIds)
                        {
                            strIdeaId += st + ',';
                        }
                        system.debug('strIdeaId : ' + strIdeaId);
                        
                        String relatedTopicName = String.escapeSingleQuotes(strTopicName.replace(' ','').removeEnd(',').trim());
                        String ideaIds = String.escapeSingleQuotes(strIdeaId.replace(' ','').removeEnd(',').trim());
                        QUERY += ' AND Related_Topic_Name__c IN ' + '(\'' + String.join(relatedTopicName.split(','), '\',\'') + '\')' + ' AND Id IN ' + '(\'' + String.join(ideaIds.split(','), '\',\'') + '\')';
                        system.debug('QUERY : ' + QUERY);
                    }
                }
            }
            
        }
        
        if (String.isNotBlank(sortBy)) {
            if (sortBy == 'Recent Ideas') {
                QUERY += ' ORDER BY CreatedDate DESC';
            }
            else if (sortBy == 'Top All-Time') {
                // R1 sort expression
                // QUERY += ' ORDER BY VoteTotal DESC, VoteScore DESC, Title ASC';
                QUERY += ' ORDER BY VoteTotal DESC, CreatedBy.Name ASC, Title DESC';
            }
            else if (sortBy == 'Recent Comments') {
                QUERY += ' ORDER BY LastComment.CreatedDate DESC, Title ASC'; //LastComment.CreatedDate DESC,
            }
            // Sort By Popular Ideas
            else {
                QUERY += ' ORDER BY VoteScore DESC, Title ASC';
            }
        }
        
        System.debug('Ideas QUERY: ' + QUERY);
        System.debug('listSizeValue: ' + listSizeValue);
        System.debug('ideasIds: ' + ideasIds);
        
        return new x7sIdeasListWrapper(QUERY, listSizeValue, ideasIds);
    }
    
    
    @AuraEnabled
    public static x7sIdeasListWrapper nextPage(
        Integer listSize,
        Integer pageNumber,
        String categories,
        String zoneId,
        String sortBy,
        Boolean limitVoteToEmailDomain,
        Boolean filterByTopic,
        String topicNameAndFeatureList,
        Boolean filterBySearchTerm,
        String searchTerm,
        Boolean filterOnUserOwned,
        Boolean filterOnUserVoted,
        String searchMyIdeas,
        String searchByCategories,
        String searchByTopics,
        String searchByStatus,
        String searchByThemes,
        Boolean filterByMergeIdea,
        Boolean filterByMyVotedIdeas,
        String searchByMyVotedIdeas,
        Boolean filterMyCommentedIdeas,
        String searchMyCommentedIdeas,
        Boolean filterMySubscribedIdeas,
        String searchMySubscribedIdeas,
        Boolean filterMyCompanyIdeas,
        String searchMyCompanyIdeas,
        Boolean filterMyCompanyVotedIdeas,
        String searchMyCompanyVotedIdeas,
        Boolean filterMyCompanyCommentedIdeas,
        String searchMyCompanyCommentedIdeas,
        Boolean filterMyCompanySubscribedIdeas,
        String searchMyCompanySubscribedIdeas) {
            
            Integer pageNumberValue = pageNumber != null ? Integer.valueOf(pageNumber) : 1;
            
            Boolean filterIdeasIFollow = false;
            If(!filterByMyVotedIdeas && !filterMyCommentedIdeas && !filterMySubscribedIdeas && !filterMyCompanyIdeas && !filterMyCompanyVotedIdeas)
            {
                filterIdeasIFollow = true;
            }
            
            x7sIdeasListWrapper ilw = getIdeas(
                listSize,
                categories,
                zoneId,
                sortBy,
                limitVoteToEmailDomain,
                filterByTopic,
                topicNameAndFeatureList,
                filterBySearchTerm,
                searchTerm,
                filterOnUserOwned,
                filterOnUserVoted,
                searchMyIdeas,
                searchByCategories,
                searchByTopics,
                searchByStatus,
                searchByThemes,
                filterByMergeIdea,
                filterByMyVotedIdeas,
                searchByMyVotedIdeas,
                filterMyCommentedIdeas,
                searchMyCommentedIdeas,
                filterMySubscribedIdeas,
                searchMySubscribedIdeas,
                filterMyCompanyIdeas,
                searchMyCompanyIdeas,
                filterMyCompanyVotedIdeas,
                searchMyCompanyVotedIdeas,
                filterMyCompanyCommentedIdeas,
                searchMyCompanyCommentedIdeas,
                filterMyCompanySubscribedIdeas,
                searchMyCompanySubscribedIdeas,
                filterIdeasIFollow
            );
            
            ilw.pageNumber = pageNumberValue;
            ilw.nextPage();
            
            System.debug('ilw: ' + ilw);
            
            return ilw;
        }
    
    @AuraEnabled
    public static x7sIdeasListWrapper previousPage(
        Integer listSize,
        Integer pageNumber,
        String categories,
        String zoneId,
        String sortBy,
        Boolean limitVoteToEmailDomain,
        Boolean filterByTopic,
        String topicNameAndFeatureList,
        Boolean filterBySearchTerm,
        String searchTerm,
        Boolean filterOnUserOwned,
        Boolean filterOnUserVoted,
        String searchMyIdeas,
        String searchByCategories,
        String searchByTopics,
        String searchByStatus,
        String searchByThemes,
        Boolean filterByMergeIdea,
        Boolean filterByMyVotedIdeas,
        String searchByMyVotedIdeas,
        Boolean filterMyCommentedIdeas,
        String searchMyCommentedIdeas,
        Boolean filterMySubscribedIdeas,
        String searchMySubscribedIdeas,
        Boolean filterMyCompanyIdeas,
        String searchMyCompanyIdeas,
        Boolean filterMyCompanyVotedIdeas,
        String searchMyCompanyVotedIdeas,
        Boolean filterMyCompanyCommentedIdeas,
        String searchMyCompanyCommentedIdeas,
        Boolean filterMyCompanySubscribedIdeas,
        String searchMyCompanySubscribedIdeas) {
            
            Integer pageNumberValue = pageNumber != null ? Integer.valueOf(pageNumber) : 1;
            
            Boolean filterIdeasIFollow = false;
            If(!filterByMyVotedIdeas && !filterMyCommentedIdeas && !filterMySubscribedIdeas && !filterMyCompanyIdeas && !filterMyCompanyVotedIdeas)
            {
                filterIdeasIFollow = true;
            }
            
            x7sIdeasListWrapper ilw = getIdeas(
                listSize,
                categories,
                zoneId,
                sortBy,
                limitVoteToEmailDomain,
                filterByTopic,
                topicNameAndFeatureList,
                filterBySearchTerm,
                searchTerm,
                filterOnUserOwned,
                filterOnUserVoted,
                searchMyIdeas,
                searchByCategories,
                searchByTopics,
                searchByStatus,
                searchByThemes,
                filterByMergeIdea,
                filterByMyVotedIdeas,
                searchByMyVotedIdeas,
                filterMyCommentedIdeas,
                searchMyCommentedIdeas,
                filterMySubscribedIdeas,
                searchMySubscribedIdeas,
                filterMyCompanyIdeas,
                searchMyCompanyIdeas,
                filterMyCompanyVotedIdeas,
                searchMyCompanyVotedIdeas,
                filterMyCompanyCommentedIdeas,
                searchMyCompanyCommentedIdeas,
                filterMyCompanySubscribedIdeas,
                searchMyCompanySubscribedIdeas,
                filterIdeasIFollow
            );
            
            ilw.pageNumber = pageNumberValue;
            ilw.previousPage();
            
            return ilw;
        }
    
    @AuraEnabled
    public static x7sIdeasListWrapper getPage(Integer listSize, Integer pageNumber, String categories, String zoneId, String sortBy, Boolean limitVoteToEmailDomain, Boolean filterByTopic, String topicNameAndFeatureList, Boolean filterBySearchTerm, String searchTerm, Boolean filterOnUserOwned, Boolean filterOnUserVoted, String searchMyIdeas, String searchByCategories, String searchByTopics, String searchByStatus, String searchByThemes, Boolean filterByMergeIdea, Boolean filterByMyVotedIdeas, String searchByMyVotedIdeas, Boolean filterMyCommentedIdeas, String searchMyCommentedIdeas, Boolean filterMySubscribedIdeas, String searchMySubscribedIdeas, Boolean filterMyCompanyIdeas, String searchMyCompanyIdeas, Boolean filterMyCompanyVotedIdeas, String searchMyCompanyVotedIdeas, Boolean filterMyCompanyCommentedIdeas, String searchMyCompanyCommentedIdeas, Boolean filterMyCompanySubscribedIdeas, String searchMyCompanySubscribedIdeas) {
        System.debug('>>> In Log 2');
        Integer listSizeValue = listSize != null ? Integer.valueOf(listSize) : 50;
        Integer pageNumberValue = pageNumber != null ? Integer.valueOf(pageNumber) : 1;
        Boolean limitVoteToEmailDomainValue = limitVoteToEmailDomain != null ? Boolean.valueOf(limitVoteToEmailDomain) : false;
        Boolean filterByTopicValue = filterByTopic != null ? Boolean.valueOf(filterByTopic) : false;
        Boolean filterBySearchTermValue = filterByTopic != null ? Boolean.valueOf(filterBySearchTerm) : false;
        Boolean filterOnUserOwnedValue = filterOnUserOwned != null ? Boolean.valueOf(filterOnUserOwned) : false;
        Boolean filterOnUserVotedValue = filterOnUserVoted != null ? Boolean.valueOf(filterOnUserVoted) : false;
        Boolean filterIdeasIFollow = false;
        If(!filterByTopicValue && !filterBySearchTermValue && !filterOnUserOwnedValue && !filterOnUserVotedValue)
        {
            filterIdeasIFollow = true;
        }
        x7sIdeasListWrapper ilw = getIdeas(listSizeValue, categories, zoneId, sortBy, limitVoteToEmailDomainValue, filterByTopicValue, topicNameAndFeatureList, filterBySearchTermValue, searchTerm, filterOnUserOwnedValue, filterOnUserVotedValue, searchMyIdeas, searchByCategories, searchByTopics, searchByStatus, searchByThemes, filterByMergeIdea, filterByMyVotedIdeas, searchByMyVotedIdeas, filterMyCommentedIdeas, searchMyCommentedIdeas, filterMySubscribedIdeas, searchMySubscribedIdeas, filterMyCompanyIdeas, searchMyCompanyIdeas, filterMyCompanyVotedIdeas, searchMyCompanyVotedIdeas, filterMyCompanyCommentedIdeas, searchMyCompanyCommentedIdeas, filterMyCompanySubscribedIdeas, searchMyCompanySubscribedIdeas, filterIdeasIFollow);
        System.debug('records-001' + ilw.ideaList);
        ilw.pageNumber = pageNumberValue;
        ilw.getPage();
        System.debug('records-002' + ilw.ideaList);
        return ilw;
    }
    
    @AuraEnabled
    public static x7sIdeasListWrapper submitVote(Id ideaId, String voteType) {
        Set<Id> ideasIds = new Set<Id>{ideaId};
            
            //ideasIds.add(ideaId);
            
            String QUERY = 'SELECT Id, Title, Status, CreatedBy.Name, CreatedBy.CommunityNickname, CreatedBy.Id, Related_Topic_Name__c,';
        QUERY += ' Body, CreatedDate, Categories, numComments, VoteTotal, attachmentName,';
        QUERY += ' (SELECT Type, CreatedById, CreatedBy.CommunityNickname FROM Votes WHERE CreatedById = \'' + UserInfo.getUserId() + '\'' + ')';
        QUERY += ' FROM Idea';
        QUERY += ' WHERE Id IN :ideasIds ';
        
        try {
            if (Vote.SObjectType.getDescribe().isCreateable()){
                Vote v = new Vote();
                v.ParentId = ideaId;
                v.Type = voteType;
                
                insert v;
            }
            x7sIdeasListWrapper wrapper = new x7sIdeasListWrapper(QUERY, 1, ideasIds);
            return wrapper;
            
        }
        catch (Exception e) {
            System.debug('submitVote failed: ' + e.getMessage());
        }
        
        return null;
    }
    
    //	UTILITY FUNCTIONS
    // ----------------------------------------------------------
    
    @TestVisible
    private static List<String> parseStringToList(String stringValue) {
        List<String> stringList = new List<String>();
        
        if (String.isNotBlank(stringValue)) {
            String parseString = String.escapeSingleQuotes(stringValue);
            stringList = parseString.split(',');
        }
        
        return stringList;
    }
    
    @TestVisible
    private static String buildInQuery(List<String> valueList, String fieldName) {
        String inQuery = '';
        List<String> fieldValues = new List<String>();
        
        for (String entry : valueList) {
            fieldValues.add('\'' + entry.trim() + '\'');
        }
        
        if (fieldValues.size() > 0) {
            inQuery = fieldName + ' IN (';
            inQuery += String.join(fieldValues, ',');
            inQuery += ') ';
        }
        
        return inQuery;
    }
    
    @TestVisible
    private static String getTopicNameFromId(String topicId) {
        String topicName = '';
        
        Topic foundTopic = [SELECT Id, Name FROM Topic WHERE Id = :topicId WITH SECURITY_ENFORCED ];
        if (foundTopic != null) {
            topicName = foundTopic.Name;
        }
        
        return topicName;
    }
}