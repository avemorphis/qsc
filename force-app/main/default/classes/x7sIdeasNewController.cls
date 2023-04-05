/*
* Copyright (c) 2020. 7Summits Inc.
*/

public without sharing class x7sIdeasNewController {
    private static final Integer TOPIC_LOAD_LIMIT = 2000;
    private static final Decimal MAX_UPLOAD_FILE_SIZE = 4248;
    private static final Integer MAX_USERS_LOAD_LIMIT = 7;
    
    
    
    @AuraEnabled (Cacheable=true)
    public static x7sIdeasCommon getCommonSettings(String zoneName) {
        x7sIdeasCommon settings = new x7sIdeasCommon('', false);
        
        settings.sitePath = getSitePrefix();
        settings.zoneId = getZoneId(zoneName);
        settings.isAuthenticated = isAuthenticated();
        settings.nicknameEnabled = x7sIdeasUtility.isNicknameDisplayEnabled();
        
        return settings;
    }
    
    @AuraEnabled (Cacheable=true)
    public static x7sIdeasNewModel getIdeasNewModel(String zoneName, String fieldSetName, Boolean useTopics, Boolean useCategories, Boolean useStatus) {
        System.debug('Get New Model for ' + zoneName);
        x7sIdeasNewModel model = new x7sIdeasNewModel();
        
        model.settings = getCommonSettings(zoneName);
        model.themes = getThemeList(zoneName);
        model.topics = useTopics ? getTopicNamesList(true) : null;
        model.categories = useCategories ? x7sIdeasUtility.getIdeaCategoryValues() : null;
        model.statusus = useStatus ? x7sIdeasUtility.getIdeaStatusValues() : null;
        model.defaultStatus = getDefaultStatus();
        
        getMaxFileSize(model);
        
        if (String.isNotBlank(fieldSetName)) {
            x7sIdeasCommon settings = new x7sIdeasCommon('', false);
            model.settings.customFields = settings.getCustomFields(fieldSetName);
        }
        
        System.debug('getIdeasNewModel: ' + model);
        
        return model;
    }
    
    @TestVisible
    private static void getMaxFileSize(x7sIdeasNewModel model) {
        Decimal maxFileSizeKb = MAX_UPLOAD_FILE_SIZE;
        String allowedExtensions = '.pdf, .jpeg, .png';
        String networkId = Network.getNetworkId();
        List<Network> networkList;
        Network curNetwork;
        
        if (Test.isRunningTest()) {
            networkId = [SELECT Id FROM Network LIMIT 1][0].Id;
        }
        
        networkList = [SELECT Id, MaxFileSizeKb, AllowedExtensions FROM Network WHERE Id = :networkId WITH SECURITY_ENFORCED];
        
        if (networkList != null && networkList.size() > 0) {
            curNetwork = networkList[0];
            
            if (curNetwork.MaxFileSizeKb != null && curNetwork.MaxFileSizeKb != 0 && curNetwork.MaxFileSizeKb < MAX_UPLOAD_FILE_SIZE) { maxFileSizeKb = curNetwork.MaxFileSizeKb;}
            
            if (curNetwork.AllowedExtensions != null) { allowedExtensions = curNetwork.AllowedExtensions;}
        }
        
        model.allowedExtensions = allowedExtensions;
        model.maxFileSizeKb = maxFileSizeKb;
    }
    
    @AuraEnabled
    public static Boolean isAuthenticated() {
        return !Auth.CommunitiesUtil.isGuestUser();
    }
    
    @AuraEnabled (Cacheable=true)
    public static String getSitePrefix() {
        return System.Site.getPathPrefix();
    }
    
    
    @AuraEnabled (Cacheable=true)
    public static String getZoneId(String nameValue) {
        String zoneId = '';
        
        if (String.isNotEmpty(nameValue)) {
            List<Community> currCommunity = [SELECT Id FROM Community WHERE Name = :nameValue WITH SECURITY_ENFORCED];
            
            if (currCommunity != null && currCommunity.size() > 0) {
                zoneId = currCommunity[0].Id;
            }
        }
        
        return zoneId;
    }
    
    public class RelatedFiles {
        @AuraEnabled public List<RelatedFile> files;
    }
    
    public class RelatedFile {
        @AuraEnabled public String name;
        @AuraEnabled public String fileName;
        @AuraEnabled public String dataString;
    }
    
    /*
Name : createIdeaNew
Description: This method is used to get the Id of idea records which is going to insert and
if any error occurs it passes the error message.
Visibility: AllUsers,
*/
    @AuraEnabled
    public static String createIdeaNew(List<Idea> currIdeaList, String imageString, String relatedFileString, String visibility, String customFieldSetName, String buttonName) {
        System.debug('Create New Idea:'+buttonName);
        System.debug('    relatedJSON: ' + relatedFileString);
        List<RelatedFile> relatedFiles = new List<RelatedFile>();
        Boolean createIdea = true;
        If(currIdeaList != Null && currIdeaList.size() > 0 && currIdeaList[0].id != null)
        {
            createIdea = false; 
        }
        if (String.isNotBlank(relatedFileString)) {
            RelatedFiles relatedFileItems = (RelatedFiles) JSON.deserialize(relatedFileString, RelatedFiles.class);
            System.debug('    related files: ' + relatedFileItems);
            
            if (relatedFileItems != null) {
                System.debug('Related file count: ' + relatedFileItems.files.size());
                for (RelatedFile entry : relatedFileItems.files) {
                    System.debug('    adding related file: ' + entry.name + ', ' + entry.fileName);
                    relatedFiles.add(entry);
                }
            }
        }
        
        String ideaId = null;
        String ideaExtId = null;
        
        try {
            if (currIdeaList != null && currIdeaList.size() > 0) {
                System.debug(currIdeaList[0].Title);
                System.debug(currIdeaList[0].AttachmentName);
                System.debug(currIdeaList[0].AttachmentContentType);
                
                if (String.isNotBlank(imageString)) { currIdeaList[0].AttachmentBody = EncodingUtil.base64Decode(imageString);}
                
                if(!Test.isRunningTest() && buttonName == 'ConvertToIdea')
                {
                    currIdeaList[0].CreatedById = currIdeaList[0].Requested_By__c;
                }
                system.debug('Rec : ' + currIdeaList);
                //system.debug('Cat : ' + currIdeaList[0].Categories);
                /*If(currIdeaList[0].Categories != null)
                {
                    system.debug('categories : ' + currIdeaList[0].Categories);
                    Set<String> categories = new Set<String>();
                    categories.addAll(currIdeaList[0].Categories.split(';'));
                     system.debug('@@@@@@@@ : ' + categories);
                    //Now update the field.
                    List<String> productsList = new List<String>();
                    productsList.addAll(categories);
                    system.debug('productsList : ' + productsList);
                    currIdeaList[0].Categories = String.join(productsList, ';');
                    system.debug('############## : ' + currIdeaList[0].Categories);
                }*/
                system.debug('currIdeaList : ' + currIdeaList);
                upsert currIdeaList;
                System.debug('Testing sub Idea--'+currIdeaList[0].CreatedById+' --'+currIdeaList[0].Id);
                
                
                // get the idea details
                Idea createdIdea = currIdeaList[0];
                ideaId = String.valueOf(createdIdea.Id);
                System.debug('New created idea: ' + createdIdea);
                
                //send Notifications Methods
                if(buttonName == 'ConvertToIdea')
                {
                    System.debug('Entered in convert to an Idea');
                    x7sIdeasNewController.sendIdeaConvertNotifications(currIdeaList[0].Id);
                    x7sIdeasNewController.sendQueToIdeaMail(currIdeaList[0].Id);
                }
                else
                {
                    System.debug('Entered in create Idea');
                    if(createIdea == true)
                    {
                        x7sIdeasNewController.sendIdeaCreateNotifications(currIdeaList[0].Id);
                        x7sIdeasNewController.sendIdeaCreationMail(currIdeaList[0].Id);
                        List<Idea> ideaData = [Select Id, CreatedById FROM Idea Where Id =: currIdeaList[0].Id];
                        x7sIdeasSubscription.ideaSubscribeOnly(ideaData[0].CreatedById, ideaData[0].Id);
                    }
                }
                
                x7sIdeasNewController.sendOtherSubscribers(currIdeaList[0].Id);
                x7sIdeasListWrapper wrapper = x7sIdeasViewController.getIdeaRecord(
                    createdIdea.CommunityId, createdIdea.Id, customFieldSetName);
                Idea newIdea = wrapper.ideaList[0];
                System.debug('New retrieved Idea: ' + newIdea);
                ideaExtId = String.valueOf(newIdea.X7S_Ideas_Extension__c);
                System.debug('ideaExtId: ' + ideaExtId);
                
                // add related files
                if (ideaExtId != null
                    && relatedFiles != null
                    && relatedFiles.size() > 0) {
                        
                        if(ContentVersion.SObjectType.getDescribe().isCreateable() &&
                           Schema.SObjectType.ContentVersion.fields.Title.isCreateable() &&
                           Schema.SObjectType.ContentVersion.fields.PathOnClient.isCreateable() &&
                           Schema.SObjectType.ContentVersion.fields.ContentLocation.isCreateable() &&
                           Schema.SObjectType.ContentVersion.fields.VersionData.isCreateable()) {
                               List<ContentVersion> contentVersions = new List<ContentVersion>();
                               
                               System.debug('    --- Create content versions');
                               for (RelatedFile related : relatedFiles) {
                                   System.debug('   related file: ' + related);
                                   
                                   ContentVersion content = new ContentVersion();
                                   
                                   content.Title = related.name;
                                   content.PathOnClient = related.fileName;
                                   content.ContentLocation = 'S';
                                   content.VersionData = EncodingUtil.base64Decode(related.dataString);
                                   
                                   contentVersions.add(content);
                               }
                               insert contentVersions;
                               
                               List<String> contentIds = new List<String>();
                               for (ContentVersion content : contentVersions) {
                                   contentIds.add(content.Id);
                               }
                               System.debug('    --- Create related links');
                               // link to the Idea
                               if(ContentDocumentLink.SObjectType.getDescribe().isCreateable() &&
                                  Schema.SObjectType.ContentDocumentLink.fields.ContentDocumentId.isCreateable() &&
                                  Schema.SObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable() &&
                                  Schema.SObjectType.ContentDocumentLink.fields.ShareType.isCreateable() &&
                                  Schema.SObjectType.ContentDocumentLink.fields.Visibility.isCreateable()) {
                                      
                                      List<ContentDocumentLink> relatedLinks = new List<ContentDocumentLink> ();
                                      List<ContentVersion> insertedContent = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :contentIds];
                                      
                                      for (ContentVersion currentVersion : insertedContent) {
                                          ContentDocumentLink relatedLink = new ContentDocumentLink();
                                          
                                          relatedLink.ContentDocumentId = currentVersion.ContentDocumentId;
                                          relatedLink.LinkedEntityId = ideaExtId;
                                          relatedLink.ShareType = 'I';
                                          relatedLink.Visibility = visibility;
                                          
                                          relatedLinks.add(relatedLink);
                                      }
                                      insert relatedLinks;
                                  }
                           }
                    }
            }
            
            return ideaId;
            
        }
        catch (Exception e) { System.debug('createNewIdea Apex exception: ' + e); throw e;}
    }
    
    @AuraEnabled
    public static x7sIdeasListWrapper getIdeaRecord(String zoneId, String recordId, String customFieldSetName) {
        x7sIdeasListWrapper objx7sIdeasListWrapper = x7sIdeasViewController.getIdeaRecord(zoneId, recordId, customFieldSetName);
        system.debug('Wrapper Records : ' + objx7sIdeasListWrapper);
        return objx7sIdeasListWrapper;
    }
    
    @AuraEnabled
    public static Boolean deleteIdea(String ideaId) {
        Boolean result = true;
        
        if (!String.isEmpty(ideaId) && Schema.sObjectType.Idea.isDeletable()) {
            try {
                Idea currIdea = new Idea(Id = ideaId);
                delete currIdea;
            }
            catch (Exception e) {
                result = false;
            }
        }
        
        return result;
    }
    
    @AuraEnabled
    public static List<Idea> checkDuplicateIdeas(String title, String zoneId, Integer simIdeasLimit, String statusList) {
        Integer simIdeasLimitValue = Integer.valueOf(simIdeasLimit);
        
        List<Idea> ideasList = new List<Idea>();
        List<Idea> ideasListSOSL = new List<Idea>();
        
        if (!String.isEmpty(title)) {
            List<String> keywordList = title.replace('%', '').replace('*', '').split(' ');
            Set<String> keywordSet = new Set<String>();
            Set<String> keywordSetSOSL = new Set<String>();
            
            for (String s : keywordList) {
                if (s.trim().length() > 1) {
                    keywordSet.add(s.trim());
                    keywordSetSOSL.add('*' + s.trim() + '*');
                }
            }
            
            if (keywordSet.size() > 0) {
                keywordList = new List<String>(keywordSet);
                String keywordStringSOSL = '("' + String.join(new List<String>(keywordSetSOSL), '") OR ("') + '")';
                System.debug('checkDuplicateIdeas: key word SOSL: ' + keywordStringSOSL);
                
                if (String.isBlank(statusList)) {
                    ideasListSOSL = (List<Idea>) [FIND :keywordStringSOSL RETURNING Idea(Id, Title, VoteTotal WHERE CommunityId = :zoneId) LIMIT :simIdeasLimitValue][0];
                }
                else {
                    List<String> statusEntries = statusList.split(',');
                    ideasListSOSL = (List<Idea>) [FIND :keywordStringSOSL RETURNING Idea(Id, Title, VoteTotal WHERE CommunityId = :zoneId AND (Status IN :statusEntries)) LIMIT :simIdeasLimitValue][0];
                }
                ideasList = [SELECT Id, Title, VoteTotal FROM Idea WHERE CommunityId = :zoneId AND Title IN :keywordList AND (NOT Id IN :ideasListSOSL) ORDER BY VoteScore DESC LIMIT :simIdeasLimitValue];
                ideasList.addAll(ideasListSOSL);
                
                if (ideasList.size() > simIdeasLimitValue) {
                    List<Idea> tmpIdeasList = new List<Idea>();
                    for (Idea currIdea : ideasList) {
                        if (tmpIdeasList.size() < simIdeasLimitValue) {
                            tmpIdeasList.add(currIdea);
                        }
                        else {
                            break;
                        }
                    }
                    
                    ideasList = tmpIdeasList;
                }
                
            }
        }
        
        return ideasList;
    }
    
    @AuraEnabled
    public static List<IdeaTheme> getThemeList(String ideaZoneName) {
        try {
            Community c = [SELECT Id FROM Community WHERE Name = :ideaZoneName WITH SECURITY_ENFORCED LIMIT 1];
            return c.Id != null ? [SELECT Id, Title FROM IdeaTheme WHERE CommunityId = :c.Id ORDER BY Title] : null;
        }
        catch (QueryException e) {
            System.debug('cannot load themes for ' + ideaZoneName);
            return null;
        }
    }
    
    @AuraEnabled
    public static List<Topic> getTopicNamesList(Boolean managedType) {
        Id networkId = System.Network.getNetworkId();
        
        List<Topic> topicList = new List<Topic>();
        
        if (managedType) {
            if (networkId != null) { topicList = [SELECT CreatedById, CreatedDate, Description, Id, Name, NetworkId, TalkingAbout FROM Topic WHERE NetworkId = :networkId AND ManagedTopicType LIKE '%Navigational%'  WITH SECURITY_ENFORCED ORDER BY Name LIMIT :TOPIC_LOAD_LIMIT];
                                   }
            else {
                topicList = [SELECT CreatedById, CreatedDate, Description, Id, Name, NetworkId, TalkingAbout FROM Topic WHERE NetworkId = NULL AND ManagedTopicType LIKE '%Navigational%' WITH SECURITY_ENFORCED  ORDER BY Name LIMIT :TOPIC_LOAD_LIMIT];
            }
        }
        else {
            if (networkId != null) { topicList = [SELECT CreatedById, CreatedDate, Description, Id, Name, NetworkId, TalkingAbout FROM Topic WHERE NetworkId = :networkId WITH SECURITY_ENFORCED ORDER BY Name LIMIT :TOPIC_LOAD_LIMIT];
                                   }
            else {
                topicList = [SELECT CreatedById, CreatedDate, Description, Id, Name, NetworkId, TalkingAbout FROM Topic WHERE NetworkId = NULL WITH SECURITY_ENFORCED ORDER BY Name LIMIT :TOPIC_LOAD_LIMIT];
            }
            
        }
        return topicList;
    }
    
    @AuraEnabled
    public static List<String> getStatusValues() {
        return x7sIdeasUtility.getIdeaStatusValues();
    }
    
    @AuraEnabled
    public static List<String> getCategoryValues(String themeName) {
        return String.isBlank(themeName) ? x7sIdeasUtility.getIdeaCategoryValues() : x7sIdeasUtility.getThemeCategories(themeName);
    }
    
    @AuraEnabled
    public static String getDefaultStatus() {
        String defaultValue = '';
        
        try {
            Schema.DescribeFieldResult fieldResult = Idea.Status.getDescribe();
            List <Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
            
            if (picklistValues != null) {
                for (Schema.PicklistEntry picklistValue : picklistValues) {
                    if (picklistValue.isDefaultValue()) {
                        defaultValue = picklistValue.getValue();
                    }
                }
            }
            
            if (String.isBlank(defaultValue) && picklistValues != null && picklistValues.size() > 0) {
                defaultValue = picklistValues[0].getValue();
            }
        }
        catch (Exception e) {
            System.debug('getDefaultStatus exception: ' + e.getMessage());
        }
        
        return defaultValue;
    }
    
    @AuraEnabled
    public static List<User> fetchUsers(String inputKeyword) {
        Integer userLimit = MAX_USERS_LOAD_LIMIT;
        String userInput = '%' + String.escapeSingleQuotes(inputKeyword) + '%';
        
        List<User> returnList = [
            SELECT Id, Username, LastName, FirstName, Name, CompanyName, Title
            FROM User
            WHERE Name LIKE :userInput
            WITH SECURITY_ENFORCED
            LIMIT :userLimit
        ];
        Security.stripInaccessible(AccessType.READABLE, returnList);
        
        return returnList;
    }
    
    @AuraEnabled
    public static User getRequestedByRecord(String userId) {
        try {
            return [SELECT Id, Name, FirstName, LastName FROM User WHERE Id = :userId WITH SECURITY_ENFORCED];
        } catch (Exception ex) { System.debug('Error :' + ex.getMessage() + ',Line number : ' + ex.getLineNumber());return null;}
    }
    
    @AuraEnabled
    public static QuestionDetail getQuestionDetail(String recordId) {
        QuestionDetail questionDetail = new QuestionDetail();
        try {
            List<FeedItem> listOfFeedItems = [SELECT Id,ParentId,Body,Title,CreatedById FROM FeedItem WHERE Id = :recordId WITH SECURITY_ENFORCED];
            
            if (!listOfFeedItems.isEmpty()) {
                questionDetail.Body = String.isEmpty(listOfFeedItems[0].Body) ? '' : listOfFeedItems[0].Body;
                questionDetail.Title = String.isEmpty(listOfFeedItems[0].Title) ? '' : listOfFeedItems[0].Title;
                
                if (!String.isEmpty(listOfFeedItems[0].ParentId)) {
                    List<User> feedUsers = [SELECT Id,Name,FirstName, LastName FROM User WHERE Id = :listOfFeedItems[0].CreatedById WITH SECURITY_ENFORCED];
                    
                    if (!feedUsers.isEmpty()) {
                        questionDetail.requestedBy = feedUsers[0];
                    }
                }
            }
            return questionDetail;
            
        } catch (Exception ex) { System.debug('getQuestionDetail() - Error :' + ex.getMessage() + ',Line number : ' + ex.getLineNumber());return null;}
    }
    
    public class QuestionDetail {
        @AuraEnabled public String Body;
        @AuraEnabled public String Title;
        @AuraEnabled public User requestedBy;
    }
    //Notification for Idea creation
    public static void sendIdeaCreateNotifications(String IdeaId)
    {
        System.debug('Entered in Idea Creation Notification');
        Map<String, Object> pageRef = new Map<String, Object>{
            'type' => 'standard__webPage',
                'attributes' => new Map<String, Object> {
                    'url' => '/QSCDeveloperCommunity/s/idea/' + ideaId + '/detail'
                        }
        };
            
            CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Converted_to_Idea']; 
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        
        // Set the contents for the notification
        
        try {
            List<Idea> thisIdea = [select id, CreatedById, Requested_By__c, Title from idea where id =:ideaId limit 1];
            Id recipientsIds = thisIdea[0].Requested_By__c != null ? thisIdea[0].Requested_By__c : thisIdea[0].CreatedById;
            notification.setTitle('Idea '+thisIdea[0].Title+' creation Notification');
            //notification.setBody('Your Idea1 has been created Successfully!');
            
            // Set the notification type and target
            notification.setNotificationTypeId(notificationType.Id);
            //notification.setTargetId(targetId);
            notification.setTargetPageRef(JSON.serialize(pageRef));
            // Actually send the notification
            //notification.send(new Set<string>{recipientsIds});
            
            notification.setBody('Your Idea '+thisIdea[0].Title+' has been created successfully!.');
            notification.send(new Set<string>{UserInfo.getUserId()});
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        } 
    }
    //Notification for question to Idea conversion
    public static void sendIdeaConvertNotifications(String IdeaId)
    {
        System.debug('Entered in Idea Conversion Notification');
        Map<String, Object> pageRef = new Map<String, Object>{
            'type' => 'standard__webPage',
                'attributes' => new Map<String, Object> {
                    'url' => '/QSCDeveloperCommunity/s/idea/' + ideaId + '/detail'
                        }
        };
            
            CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType 
                                                       WHERE DeveloperName='Converted_to_Idea']; 
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        
        // Set the contents for the notification
        
        try {
            List<Idea> thisIdea = [select id, CreatedById, Requested_By__c, Title, Body, CreatorName, CreatedBy.Name  from idea where id =:IdeaId limit 1];
            x7sIdeasSubscription.ideaSubscribeOnlySub(UserInfo.getUserId(), IdeaId);
            Id recipientsIds = thisIdea[0].Requested_By__c != null ? thisIdea[0].Requested_By__c : thisIdea[0].CreatedById;
            notification.setTitle('Your question was converted into an Idea!');
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetPageRef(JSON.serialize(pageRef));
            notification.setBody('Your question '+thisIdea[0].title +' on Q-SYS Communities for Developers was converted into an Idea by '+UserInfo.getName()+'.');
            notification.send(new Set<string>{thisIdea[0].CreatedById});
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        } 
    }
    
    //Email Notifications for Idea creations
    public static void sendIdeaCreationMail(String IdeaId)
    {
        boolean isSandbox = false;
        string sourceLink = 'https://qsc--qa.sandbox.my.site.com/QSCDeveloperCommunity/s/idea/';
        
        isSandbox = [select IsSandbox from Organization limit 1].IsSandbox;
        if(isSandbox)
        {
            sourceLink = 'https://qsc--qa.sandbox.my.site.com/QSCDeveloperCommunity/s/idea/';
        }
        else{
            sourceLink = 'https://developers.qsc.com/s/idea/';
        }
        System.Debug('Entered in idea creation');
        List<Idea> thisIdea = [select id, CreatedById, Requested_By__c, Title, Body, CreatorName, CreatedBy.Name  from idea where id =:IdeaId limit 1];
        String orgWideEmailAddressLabel = System.Label.for_QSC_communities;
        List<Messaging.SingleEmailMessage> listToSendMails = new List<Messaging.SingleEmailMessage>();
        
        String emailBody = 'Hello '+thisIdea[0].CreatedBy.Name+',<br/><br/>';
        emailBody += ' Your Idea '+thisIdea[0].Title+' has been created successfully <br/><br/>'+'<a href='+ sourceLink + thisIdea[0].Id + '/detail>'+ thisIdea[0].Title +'</a> <br/><br/>';
        emailBody += '<br/>Best Regards,<br/> Q-SYS Communities for Developers';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Your Idea '+thisIdea[0].Title+' has been Created.');
        mail.setHtmlBody(emailBody);
        mail.setToAddresses(new List<string>{UserInfo.getUserEmail()});
        mail.setOrgWideEmailAddressId(orgWideEmailAddressLabel);
        listToSendMails.add(mail);
        
        try{
            if(listtosendmails.size()>0){
                Messaging.sendEmailResult[] sendEmailResults = Messaging.sendEmail(listtosendmails);
                for(Messaging.SendEmailResult sendEmailResult: sendEmailResults){
                    if(sendEmailResult.isSuccess()){
                        system.debug('email sent succesfully');
                    }
                    else {
                        for (Messaging.Sendemailerror sendEmailError : 
                             sendEmailResult.getErrors()){
                                 system.debug('error msg '+ sendEmailError.Message);                                                   
                             }
                    }
                    
                }
            }
        }catch(Exception e){
            System.debug('Exception while sending mail....'+e.getMessage());
        }
    }
    //Email Notifications for question to Idea conversion
    public static void sendQueToIdeaMail(String IdeaId)
    {
        
        boolean isSandbox = false;
        string sourceLink = 'https://qsc--qa.sandbox.my.site.com/QSCDeveloperCommunity/s/idea/';
        
        isSandbox = [select IsSandbox from Organization limit 1].IsSandbox;
        if(isSandbox)
        {
            sourceLink = 'https://qsc--qa.sandbox.my.site.com/QSCDeveloperCommunity/s/idea/';
        }
        else{
            sourceLink = 'https://developers.qsc.com/s/idea/';
        }	
        
        List<Idea> ideaData = [SELECT Id, Title, Body, CreatorName, CreatedById, CreatedBy.Name, CreatedBy.Email FROM Idea Where Id =: IdeaId];
        String orgWideEmailAddressLabel = System.Label.for_QSC_communities;
        List<Messaging.SingleEmailMessage> listToSendMails = new List<Messaging.SingleEmailMessage>();
        
        String emailBody = 'Hello '+ideaData[0].CreatedBy.Name +'!<br/><br/>';
        
        emailBody += 'Your question '+ideaData[0].Title+' on Q-SYS Communities for Developers was converted into an Idea by '+UserInfo.getName()+' <br/><br/>';
        emailBody += 'You will not receive more notifications from this Idea unless you subscribe to it, so go comment and on'+'<a href='+ sourceLink + ideaData[0].Id + '/detail>'+ ideaData[0].Title +'</a>'+' and keep the momentum going!<br/><br/>';
        emailBody += '<br/>Best Regards,<br/> Q-SYS Communities for Developers';
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Your Question '+ideaData[0].Title+' on Q-SYS Communities for Developers was converted into an Idea.');
        mail.setHtmlBody(emailBody);
        mail.setToAddresses(new List<string>{ideaData[0].CreatedBy.Email});
        mail.setOrgWideEmailAddressId(orgWideEmailAddressLabel);
        listToSendMails.add(mail);
        
        
        try{
            if(listtosendmails.size()>0){
                Messaging.sendEmailResult[] sendEmailResults = Messaging.sendEmail(listtosendmails);
                for(Messaging.SendEmailResult sendEmailResult: sendEmailResults){
                    if(sendEmailResult.isSuccess()){
                        system.debug('email sent succesfully');
                    }
                    else {
                        for (Messaging.Sendemailerror sendEmailError : 
                             sendEmailResult.getErrors()){
                                 system.debug('error msg '+ sendEmailError.Message);                                                   
                             }
                    }
                    
                }
            }
        }catch(Exception e){
            System.debug('Exception while sending mail....');
        }
    }
    public static void sendOtherSubscribers(String IdeaId)
    {
        boolean isSandbox = false;
        string sourceLink = 'https://qsc--qa.sandbox.my.site.com/QSCDeveloperCommunity/s/idea/';
        
        isSandbox = [select IsSandbox from Organization limit 1].IsSandbox;
        if(isSandbox)
        {
            sourceLink = 'https://qsc--qa.sandbox.my.site.com/QSCDeveloperCommunity/s/idea/';
        }
        else{
            sourceLink = 'https://developers.qsc.com/s/idea/';
        }
        
        List<Idea> ideaData = [SELECT Id, Related_Topic_Name__c, Title, CreatedDate, CreatedById, CreatedBy.Name, CreatedBy.Email FROM Idea Where Id =: IdeaId LIMIT 1];
        List<String> topicNames = new List<String>();// Changed by prakhar.jain@ThinkaiCorp.com
        for(Idea i : ideaData)
        {
            topicNames.add(i.Related_Topic_Name__c);
        }
        System.debug('topicNames--'+topicNames);
        //list of topics - 
        List<topic> topicData = [SELECT Id, NetworkId, Name, Description, CreatedDate, CreatedById, 
                                 TalkingAbout, ManagedTopicType, SystemModstamp FROM Topic
                                 Where Name IN: topicNames];
        Map<Integer, set<String>> mapOfSubIds = new Map<Integer, set<String>>();
        System.debug('topicData---'+topicData);
        Set<Id> topicIds = new Set<Id>();
        for(topic T : topicData)
        {
            topicIds.add(T.id);
            System.debug('Topic id: '+topicIds);
        }
        //List<entity> where parent Id IN topic
        List<EntitySubscription> entitySubData = [SELECT Id, ParentId, Parent.Name, SubscriberId, Subscriber.Name, Subscriber.Email, CreatedById, 
                                                  CreatedDate, IsDeleted, NetworkId 
                                                  FROM EntitySubscription Where ParentId IN: topicIds];
        
        System.debug('entitySubData==='+entitySubData.size());
        
        Set<String> subscriberIdSet = new Set<String>();
        
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType 
                                                   WHERE DeveloperName='Other_Subscriber_Notifications']; 
        
        for(EntitySubscription ent : entitySubData)
        {
            
            System.debug('Entered in send subscriber notifications');
            Map<String, Object> pageRef = new Map<String, Object>{
                'type' => 'standard__webPage',
                    'attributes' => new Map<String, Object> {
                        'url' => '/QSCDeveloperCommunity/s/idea/' + ideaId + '/detail'
                            }
            };
                
                // Set the contents for the notification
                notification.setTitle('New '+ideaData[0].Title+'!');
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetPageRef(JSON.serialize(pageRef));
            notification.setBody('A new Idea was created: '+ideaData[0].title+' associated with the Topic of '+topicData[0].Name);
            if(ideaData[0].CreatedById != ent.SubscriberId)
            {
                subscriberIdSet.add(ent.SubscriberId);
                System.debug('Topic Id: '+ent.ParentId + ', SubscriberId: '+ent.SubscriberId);
            }            
        }
        
        System.debug('subscriberIdSet--'+subscriberIdSet);
        Integer subSize = subscriberIdSet.size();//2
        Double numberOfNoti = subSize/500;//0.004
        system.debug('Decimal value: '+numberOfNoti);
        Decimal numOfNoti= Decimal.valueOf(numberOfNoti);
        Long maxCountOfNoti = numOfNoti.round(System.RoundingMode.CEILING);//1
        Integer countOfNoti = Integer.valueOf(maxCountOfNoti) + 1;// Changed by prakhar.jain@ThinkaiCorp.com
        system.debug('Round value maxCountOfNoti: '+maxCountOfNoti);
        List<String> subList = new List<String>(subscriberIdSet);//2 id
        for(Integer i = 1; i <= countOfNoti; i++)
        {
            Integer k = i * 500;//500
            Integer z = k - 500;//0
            set<String> subIdSet = new set<String>();
            if(k > subSize)
            {
                k = subSize;//2
            }
            for(Integer j = z; j < k; j++)
            {
                subIdSet.add(subList[j]);
                system.debug('SubIdSet: '+subIdSet);
            }
            mapOfSubIds.put(i, subIdSet);
            System.debug('Map of Sub Id: '+mapOfSubIds);
        }
        try {
            for(Integer subId : mapOfSubIds.keySet())
            {
               set<String> subIdstr =  mapOfSubIds.get(subId);
                //notification.send(subIdstr);
                System.debug('Notification sent to : '+subIdstr);
            }
            
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        } 
    }
    
}