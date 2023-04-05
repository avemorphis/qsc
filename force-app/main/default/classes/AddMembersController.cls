public without sharing class AddMembersController {
    
    @AuraEnabled
    public static string createUser(string selectedId) {
        system.debug('Selected record id is '+ selectedId);
        Contact ct = [select id, firstName,LastName,email,Community_Access__c from contact where id = :selectedId];
        
        ct.Community_Access__c = 'TPP Community User';
        
        Update ct;
        
        
        Profile pf = [select id,name from profile where Name = 'External User CCP Member'];
        System.Domain d = System.DomainParser.parse(URL.getOrgDomainUrl());
        System.debug(d.getSandboxName());
        user u = new user();
        Organization org = [select id,name, isSandbox from organization where Name !=null ];
        u.firstName = ct.FirstName;
        u.lastName = ct.LastName;
        u.ContactId = ct.Id;
        if(org.isSandbox){
            u.Username = ct.Email+'.'+d.getSandboxName();
        }else{
            u.Username = ct.Email + 'tpp';
        }
        
        u.Email = ct.Email;
        
        if(ct.LastName.length()>7){
            u.CommunityNickname = ct.LastName.substring(8) + 'tpp';  
            u.Alias = ct.LastName.substring(8);  
        }else{
            u.Alias = ct.LastName;
            u.CommunityNickname = ct.LastName  + 'tpp';
        }
        
        u.TimeZoneSidKey = 'America/Phoenix'; // Required
        u.LocaleSidKey = 'en_US'; // Required
        u.EmailEncodingKey = 'ISO-8859-1'; // Required
        u.LanguageLocaleKey = 'en_US'; // Required
        u.ProfileId = pf.Id;
        Database.SaveResult srList = Database.insert(u, false);
        if(srList.isSuccess()){
            
            List<PermissionSet> permissionSetList = [SELECT Id,Name FROM PermissionSet WHERE Name = 'TPP_Permission_Set'];

            PermissionSetAssignment psa = new PermissionSetAssignment
			(PermissionSetId = permissionSetList[0].Id, AssigneeId = u.Id);
			Insert psa; 
            
            
            return 'true';
        }else{
            return srList.getErrors()[0].getMessage();
            
        }
    }
}