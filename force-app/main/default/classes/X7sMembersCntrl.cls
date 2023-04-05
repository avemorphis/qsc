public with sharing class X7sMembersCntrl {
    @AuraEnabled(Cacheable = true)
    public static List<MemberWrapper> getMembers(){
        Set<Id> memberIds = new Set<Id>();
        List<MemberWrapper> wrapperRecs = new List<MemberWrapper>();
        
        if(FeatureManagement.checkPermission('IsCommunityManager')){
            User loggedInUser = [SELECT Id,ContactId,Contact.AccountId FROM User WHERE Id =:UserInfo.getUserId() LIMIT 1];
            if(String.isBlank(loggedInUser.ContactId) || String.isBlank(loggedInUser.Contact.AccountId)){
                return wrapperRecs;
            }
            //Contact ids of all the users present in the community
            Set<Id> communityContactIds = new Set<Id>();
            
            //List of community users present in the community with same account as of logged in user
            List<User> communityUsers = [SELECT Id,FirstName,LastName,Email,ContactId FROM User WHERE 
                                         Contact.AccountId =: loggedInUser.Contact.AccountId AND 
                                         Id IN (SELECT MemberId FROM NetworkMember WHERE Network.Name=:getSetting('DefaultNetworkName')) AND IsActive = TRUE AND Contact.Inactive_Reason__c = null]; 
            
            for(User communityUser: communityUsers){
                communityContactIds.add(communityUser.ContactId);
            }
            
            //Contact list which is not part of community, but present in the same account of logged in user
            List<Contact> contactRecs = [SELECT Id,FirstName,LastName,Email FROM Contact WHERE AccountId =:loggedInUser.Contact.AccountId
                                         AND Id NOT IN: communityContactIds];
            
            for(User communityUser: communityUsers){
                wrapperRecs.add(createMemberWrapperInstance(communityUser.ContactId, communityUser.Id, communityUser.Email, 
                                                            communityUser.FirstName+' '+communityUser.LastName, true));
            }
            
            for(Contact contactRec: contactRecs){
                wrapperRecs.add(createMemberWrapperInstance(contactRec.Id, null, contactRec.Email, 
                                                            contactRec.FirstName+' '+contactRec.LastName, false));
            }
        }
        return wrapperRecs;
        
    }
    
    @AuraEnabled
    public static void deactivate(Id userid, String reason, String notes){
        if(FeatureManagement.checkPermission('IsCommunityManager')){
            Contact communityCon = new Contact(Id=[SELECT ContactId FROM User WHERE Id=:userId].ContactId);
            communityCon.Status__c = 'Inactive';
            communityCon.Inactive_Reason__c = reason;
            communityCon.Note__c = notes;
            update communityCon;
        }


    }
    
    @AuraEnabled
    public static void invite(String name, String email, String message){
        if(FeatureManagement.checkPermission('IsCommunityManager')){
            X7s_Invitation_email__mdt metadataRec = getEmailContent('Dev');
            Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
            emailMsg.setSubject(metadataRec.Email_Subject__c);
            emailMsg.setPlainTextBody(message);
            emailMsg.toAddresses = new String[] {email};
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {emailMsg});
        }
        
    }
    
    //helper method to get email content from X7s_Invitation_email__mdt custom metadata
    private static X7s_Invitation_email__mdt getEmailContent(String name) {
        return [SELECT Email_body__c,Email_Subject__c FROM X7s_Invitation_email__mdt WHERE DeveloperName = :name LIMIT 1];
    }
    
    //helper method to get setting's value from X7sDeveloperRepoSetting__mdt custom metadata
    private static String getSetting(String name) {
        String value = null;
        List<X7sDeveloperRepoSetting__mdt> settings = [SELECT Label,Value__c FROM X7sDeveloperRepoSetting__mdt WHERE Label = :name LIMIT 1];
        if(settings.size() == 1) {
            value = settings[0].Value__c;
        }
        return value;
    }
    
    private static MemberWrapper createMemberWrapperInstance(String contactId, String userId, String email, String name, Boolean communityStatus){
        MemberWrapper wrapper = new MemberWrapper();
        wrapper.contactId = contactId;
        wrapper.email = email;
        wrapper.userId = userId;
        wrapper.name = name;
        wrapper.communityStatus = communityStatus;
        return wrapper;
    }
    
    public class MemberWrapper {
        @AuraEnabled
        public String userId{get;set;}
        
        @AuraEnabled
        public String contactId {get;set;}
        
        @AuraEnabled
        public String name{get;set;}
        
        @AuraEnabled
        public String email{get;set;}
        
        @AuraEnabled
        public Boolean communityStatus{get;set;}
    }
}