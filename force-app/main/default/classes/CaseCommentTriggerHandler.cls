/*
*******************************************************************************************
# FILE...CaseCommentTriggerHandler
# CREATED BY...Chirag Rathi
# CREATED DATE....22nd Jun 2022
# LAST MODIFIED BY...... 
# LAST MODIFIED DATE....
*******************************************************************************************
# AUTHOR...Chirag Rathi
# DESCRIPTION...Apex class for sending email notification when agent comment on the case to send email notification to customer
and cuatomer comment on the case send email notification to case agent(owner).
# CHANGE/ BUG FIX LOG...................:
******************************************************************************************
*/

public class CaseCommentTriggerHandler {
    public static void insertCaseCommment(List<CaseComment> commentList){
        //string sourceLink ;
        string subj;
        boolean isSandbox = false;
        system.debug('commentList==>'+commentList);
        Set<string> contactEmail = new Set<string>();
        Set<string> OwnerEmail = new Set<string>();
        string commentBody;
        Set<string> caseId = new Set<string>();
        
        /*isSandbox = [select IsSandbox from Organization limit 1].IsSandbox;
        if(isSandbox)
            sourceLink = 'https://qsc--qa.lightning.force.com/lightning/r/Case/';
        else
            sourceLink = 'https://qsc.lightning.force.com/lightning/r/Case/';//Production Link will be here.*/
        
        for(CaseComment caseCom : commentList){
            if(caseCom.ParentId != null && caseCom.IsPublished == true){
                caseId.add(caseCom.ParentId);
                commentBody = caseCom.CommentBody;
                system.debug('caseId==>'+caseId);
            }
        }
        
        // addded orgWideEmailAddress custom label
        String orgWideEmailAddressLabel = System.Label.OrgWideEmailAddress;
        
        String profileNameUserInfo = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
        set<string> IdSetOfAllUsers = new set<string>();
        //User usr1 =[select id, usertype, Name from user where usertype like '%Customer%' AND id in :IdSetOfAllUsers];
        System.debug('Profile name with User info in Query: ' + profileNameUserInfo);
        List<Case> caseList = [SELECT Id,ContactId,CaseNumber,Subject,Description,Contact.Email,Contact.Name,Account.Name,CreatedByid,
                               OwnerId,Owner.Email,Owner.type,Status,Product_If_No_Asset__r.Name,Product_If_No_Asset__c,Tier__c,
                               Account.Tier_Oracle__c FROM Case Where ContactId != null AND Id IN:caseId];
        EmailTemplate emailTemplate = [Select Id,Name,Body,Subject,HtmlValue,DeveloperName from EmailTemplate where DeveloperName = 'Agent_add_comment_on_a_case' LIMIT 1];
        
        EmailTemplate emailTemplateForAgent = [Select Id,Name,Body,Subject,HtmlValue,DeveloperName from EmailTemplate where DeveloperName = 'Customer_add_comment_on_a_case' LIMIT 1];
        
        /* ====== send email to contact ===================*/
        List<Messaging.SingleEmailMessage> listToSendMails = new List<Messaging.SingleEmailMessage>();
        string userId = userinfo.getUserId();
        User usr = [SELECT Id, Name,Title,UserType FROM User WHERE Id =:userId];
        for(Case cas :caseList){
            IdSetOfAllUsers.add(cas.CreatedById);
            system.debug('cas==>?'+cas);
            string bodyRec;
            bodyRec = emailTemplate.HtmlValue;
            bodyrec = bodyrec.replace('{{{Case.CaseNumber}}}', cas.CaseNumber);
            bodyrec = bodyrec.replace('{!Case.Last_Case_Comment}',commentBody);
            bodyrec = bodyrec.replace('{{{Sender.Name}}}',userinfo.getName());
            bodyrec = bodyrec.replace('{!Case.Id}',cas.Id);
            
            if(usr.Title!= null){
                bodyrec = bodyrec.replace('{{{Sender.Title}}}',usr.Title);
            }else{
                bodyrec = bodyrec.replace('{{{Sender.Title}}}',''); 
            }
            if( cas.Subject!= null)
                bodyRec = bodyrec.replace('{{{Case.Subject}}}', cas.Subject);
            else
                bodyRec = bodyrec.replace('{{{Case.Subject}}}','');
            
            if( cas.Description == null) {
                bodyRec = bodyrec.replace('{{{Case.Description}}}', '');  
            }else{
                bodyRec = bodyrec.replace('{{{Case.Description}}}', cas.Description);
            }
            if( cas.Status != null)
                bodyRec = bodyrec.replace('{{{Case.Status}}}', cas.Status);
            
            system.debug('>>>>htmlcaseid>>>'+bodyRec);
            subj = emailTemplate.Subject;
            subj = subj.replace('{!Case.CaseNumber}', cas.CaseNumber);
            list<string> emailList = new list<string>();
            if(cas.Contact.Email != null && !profileNameUserInfo.equalsIgnoreCase('HONU External User Profile') && !usr.UserType.contains('Customer')){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                contactEmail.add(cas.Contact.Email); 
                emailList.addAll(contactEmail);
                string cntactEmail = cas.Contact.Email;
                System.Debug('Split emailAddr>>>>'+ cntactEmail);
                mail.setOrgWideEmailAddressId(orgWideEmailAddressLabel);
                mail.setToAddresses(emailList);
                mail.setHtmlBody(bodyRec);
                mail.setSubject(subj);
                mail.setTargetObjectId(cas.ContactId);
                mail.setWhatId(cas.Id);
                mail.setTemplateId(emailTemplate.Id);
                listToSendMails.add(mail);
                system.debug('Contact mail==>'+listToSendMails);
            }
            
            /*=========== send email to case agent =========================*/
            bodyRec = emailTemplateForAgent.HtmlValue;
            bodyRec = bodyrec.replace('{!Case.CaseNumber}', cas.CaseNumber);
            bodyRec = bodyrec.replace('{!Case.Last_Case_Comment}',commentBody);
            bodyRec = bodyrec.replace('{!Case.Account}',cas.Account.Name);
            bodyrec = bodyrec.replace('{{{Sender.Name}}}',userinfo.getName());
            //bodyrec = bodyrec.replace('{!Case.Link}',sourceLink +cas.id +'/view' );
            bodyrec = bodyrec.replace('{!Case.Id}',cas.Id);
            if( cas.Subject!= null)
                bodyRec = bodyrec.replace('{{{Case.Subject}}}', cas.Subject);
            else 
                bodyRec = bodyrec.replace('{{{Case.Subject}}}', '');
            if( cas.Description == null) {
                bodyRec = bodyrec.replace('{{{Case.Description}}}', '');  
            }else{
                bodyRec = bodyrec.replace('{{{Case.Description}}}', cas.Description);
            }
            
            if(cas.Product_If_No_Asset__c != null)
                bodyRec = bodyrec.replace('{!Case.Product_Name_c__c}', cas.Product_If_No_Asset__r.Name);
            else
                bodyRec = bodyrec.replace('{!Case.Product_Name_c__c}', '');
            if(cas.ContactId != null)
                bodyRec = bodyrec.replace('{!Case.Contact}',cas.Contact.Name);
            if(usr.Title!= null){
                bodyrec = bodyrec.replace('{{{Sender.Title}}}',usr.Title);
            }else{
                bodyrec = bodyrec.replace('{{{Sender.Title}}}',''); 
            }
            if(cas.Account.Tier_Oracle__c != null){
                bodyrec = bodyrec.replace('{!Case.Tier__c}',cas.Account.Tier_Oracle__c);
            }else{
                bodyrec = bodyrec.replace('{!Case.Tier__c}',''); 
            }
            system.debug('>>>>htmlcaseid>>>'+bodyRec);
            subj = emailTemplateForAgent.Subject;
            List<string> ownerMailId = new List<String>();
            if(string.isNotBlank(cas.ownerId) && (profileNameUserInfo.equalsIgnoreCase('HONU External User Profile') || usr.UserType.contains('Customer')) ){
                Messaging.SingleEmailMessage mailToAgent = new Messaging.SingleEmailMessage();
                if(cas.Owner.type == 'QUEUE'){
                    List<user> queueMember = [select id, name, email from user where id in (select userorgroupid from groupmember where groupid = :cas.Owner.Id)];
                    for(user u: queueMember){
                        ownerMailId.add(u.email);
                        system.debug('ownerMailId==>'+ownerMailId);
                    }
                }else if(cas.Owner.type != 'QUEUE' && string.isNotBlank(cas.Owner.Email)){
                    ownerMailId.add(cas.Owner.Email); 
                    system.debug('cas.Owner.Email==>'+cas.Owner.Email);
                }
                system.debug('OwnerEmail==.'+ownerMailId);
                mailToAgent.setToAddresses(ownerMailId);
                mailToAgent.setOrgWideEmailAddressId(orgWideEmailAddressLabel);
                //mail.setTargetObjectId(cas.ContactId);
                mailToAgent.setHtmlBody(bodyRec);
                mailToAgent.setSubject(subj);
                mailToAgent.setWhatId(cas.Id);      
                mailToAgent.setTemplateId(emailTemplateForAgent.Id);
                mailToAgent.setSaveAsActivity(false);
                listToSendMails.add(mailToAgent);
                system.debug('Owner mail==>'+mailToAgent);
            }
        }
        system.debug('listToSendMails'+listToSendMails.size());
        if(listToSendMails.size()>0){
            try {
            	Messaging.sendEmail(listToSendMails);
            }catch(Exception ex) { 
                System.debug('>>>>>>>>>>>>>> Error generated when sending mail - ' +ex.getMessage());
            }
        }
        
        /*try {
results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { listToSendMails });
system.debug('results==>'+results);
if (!results.get(0).isSuccess())                      
System.debug('>>>>>>>>>>>>>> Error generated when sending mail - ' + results.get(0).getErrors()[0].getMessage());

}catch(Exception ex) {       

}*/
        
    }
}