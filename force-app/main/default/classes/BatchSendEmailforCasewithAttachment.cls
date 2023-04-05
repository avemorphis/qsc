/*
*******************************************************************************************
# FILE...BatchSendEmailforCasewithAttachment
# CREATED BY...Chirag Rathi
# CREATED DATE....4th Feb 2022
# LAST MODIFIED BY......Chirag Rathi 
# LAST MODIFIED DATE....13th Feb 2022
*******************************************************************************************
# AUTHOR...Meha Mathur
# DESCRIPTION...Batch class for sending multiple new attachments attached on Case.
# CHANGE/ BUG FIX LOG...................:
******************************************************************************************
*/


Global class BatchSendEmailforCasewithAttachment implements Database.Batchable<sObject> {
    public Set<Id> caseIDList=new Set<Id>();
    public map<id,List<id>> contentIdMAP = new map<id,List<id>>();//Map to associate caseId to its ContentDocument.
    Public map<id,id> contentDocToCaseMAP = new map<id,id>(); // Map to associate contentDocument(key) to case(value)    
    Public map<id,String> messageBodyMap = new map<id,String>(); // Map to associate each case to messagebody as it includes file names
    Public list<id> ContentIdlist=  new list<id>();
    public Set<Id> userIDList=new Set<Id>();
    public Set<string> emailSet=new Set<String>();
    public set<id> docNameid = new  set<id>();
    Public list<case> updateCaselst = new list<case>();
    set<id> caseID = new set<id>();
    public String messageBody =' ';
    List<ID> cdlList = new List<ID>();
    Messaging.SingleEmailMessage mail ;
    global string bodyrec; 
    global string subj;
    //set<id> caseID = new set<id>();
    
    //Query to get the case details for the new attachments attached to case.
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('>>>>>inside >>>   batch');
        return Database.getQueryLocator([SELECT Id,CaseNumber,New_Attachment__c, Subject, Owner.Name, Contact.Name, Owner.Email, Owner.Type, contact.email, ownerid, createdbyid,Description FROM Case WHERE New_Attachment__c =true]);
    }
    
    public static boolean isSandbox = false;
    public static string sourceLink = 'https://qa-qscprod.cs220.force.com/selfhelpportal/s/';
    global void execute(Database.BatchableContext BC, List<case> caseList){ 
        system.debug('>>>>caseList>>'+caseList);
        set<id> IdSetOfAllUsers = new Set<id>();
        isSandbox = [select IsSandbox from Organization limit 1].IsSandbox;
        if(isSandbox)
            sourceLink = 'https://qa-qscprod.cs220.force.com/selfhelpportal/s/';
        else
            sourceLink = 'https://qscprod.force.com/selfhelpportal/s/';//Self Help Portal Link will be here.
        for(case cas: caseList)
        {
            caseID.add(cas.id);
            
            IdSetOfAllUsers.add(cas.createdbyid);
        }
        system.debug('>>>>caseID>>'+caseID);
        mail = new Messaging.SingleEmailMessage();
        Messaging.SingleEmailMessage mailToOwner = new Messaging.SingleEmailMessage();
        Double contentSizeAtt =0; 
        set<ContentVersion> cvList= new set<ContentVersion>() ;  
       
        // addded orgWideEmailAddress custom label
        String orgWideEmailAddressLabel = System.Label.OrgWideEmailAddress;
        
        map<id,list<Messaging.EmailFileAttachment>> caseToAttachmentMap = new map<id,list<Messaging.EmailFileAttachment>>(); // Map to associate case to its attachments
        for (ContentDocumentLink cd : [SELECT ContentDocumentId,SystemModstamp,ContentDocument.ContentSize,ContentDocument.title,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: caseID])
        {
            ContentIdlist.add(cd.ContentDocumentId);
            if(!contentIdMAP.containsKey(cd.LinkedEntityId))
                contentIdMAP.put(cd.LinkedEntityId, new List<id>());
            contentIdMAP.get(cd.LinkedEntityId).add(cd.ContentDocumentId);
            if(!contentDocToCaseMAP.containsKey(cd.ContentDocumentId))
                contentDocToCaseMAP.put(cd.ContentDocumentId, cd.LinkedEntityId);
            //contentDocToCaseMAP.get(cd.ContentDocumentId).add(cd.LinkedEntityId);
        }
        // Boolean attachmentSent = false;
        Map<id, double> caseIdContentSizeMap = new Map<id, double>();
        Map<id, List<ContentVersion>> idCVMap = new Map<id, List<ContentVersion>>();
        System.debug('>>>contentDocToCaseMAP>>'+contentDocToCaseMAP.keyset());
        for(ContentVersion cv: [SELECT id,ContentDocumentId, VersionData,Attachment_sent__c,ContentSize ,Title, FileExtension, createdbyId FROM ContentVersion WHERE ContentDocumentId IN:contentDocToCaseMAP.keyset() AND IsLatest = true AND Attachment_sent__c =False order by createddate desc ])
        {   
            System.debug('>>>Insideloop82>>');
            IdSetOfAllUsers.add(cv.createdbyId);
            messageBody = '';
            Messaging.EmailFileAttachment emlAtt = new Messaging.EmailFileAttachment();
            if(!caseIdContentSizeMap.containsKey(cv.id))
                caseIdContentSizeMap.put(cv.id, cv.ContentSize);
            /*
            else{
                contentSizeAtt = caseIdContentSizeMap.get(cv.id);
                contentSizeAtt += cv.ContentSize;
                caseIdContentSizeMap.put(cv.id, contentSizeAtt);
            }*/
            system.debug('>>>>>'+caseIdContentSizeMap.get(cv.id));
            //cv.ContentSize < 5000000 && caseIdContentSizeMap.get(cv.id) < 25000000
            if(true)//cv.ContentSize < 5000000 && contentSizeAtt < 25000000 
            {
                messageBody += '<html><body>File Name: ' + cv.Title + '</body></html><br/>';
                Blob fileData = cv.VersionData;
                system.debug ('>>>>debug attachment1>>>>'+ cv.FileExtension);
                if (cv.FileExtension != null)
                {
                    system.debug('>>>insideif102>>>>');
                if(cv.FileExtension.contains('zip') || cv.FileExtension.contains('rar')  )
                        emlAtt.setFilename( cv.Title+'.'+cv.FileExtension + '.txt');
                else
                    emlAtt.setFilename( cv.Title+'.'+cv.FileExtension);}
                
                emlAtt.setBody(fileData);
                //system.debug ('>>>>debug attachment2>>>>'+ cv.FileExtension);
                // emlAttList.add(emlAtt);
                if(!caseToAttachmentMap.containsKey(contentDocToCaseMAP.get(cv.ContentDocumentId))){
                    caseToAttachmentMap.put((contentDocToCaseMAP.get(cv.ContentDocumentId)), new list<Messaging.EmailFileAttachment>());
                    idCVMap.put(contentDocToCaseMAP.get(cv.ContentDocumentId), new List<contentVersion>());
                }   
                caseToAttachmentMap.get(contentDocToCaseMAP.get(cv.ContentDocumentId)).add(emlAtt);
                idCVMap.get(contentDocToCaseMAP.get(cv.ContentDocumentId)).add(cv);
                //attachmentSent = True;
                system.debug('>>>>ctv>>'+cv.Attachment_sent__c);
                System.debug('>>>>>>>CV ID: ' + cv.ContentDocumentId);
                cv.Attachment_sent__c = True;
                ContentVersion ctv = new ContentVersion(id=cv.id,Attachment_sent__c =true);
                cvList.add(ctv);
                if(!messageBodyMap.containsKey(contentDocToCaseMAP.get(cv.ContentDocumentId)))
                    messageBodyMap.put(contentDocToCaseMAP.get(cv.ContentDocumentId),messageBody);
                else {
                    String msg = messageBodyMap.get(contentDocToCaseMAP.get(cv.ContentDocumentId));
                    system.debug('>>>>//>>Not Have Body: ' + msg);
                    msg += messageBody;
                    system.debug('>>>>//>>After Update: ' + msg);
                    messageBodyMap.put(contentDocToCaseMAP.get(cv.ContentDocumentId),msg);
                }
                
                system.debug('>>>>>messagebofy>>'+messageBody);
                system.debug('>>>>cvList>>'+cvList);
                system.debug('>>>>'+emlAtt);
                // system.debug('emailSt>>>>'+ emlAttList);
            }
            /*
            else{
                
                if(true)//cv.ContentSize > 5000000
                {
                    if(cv.FileExtension.contains('zip') || cv.FileExtension.contains('rar'))
                        emlAtt.setFilename( cv.Title+'.'+cv.FileExtension + '.txt');
                    else
                    emlAtt.setFilename( cv.Title+'.'+cv.FileExtension);
                    Blob dummyAttachment = Blob.valueOf(cv.Title+'.'+cv.FileExtension);
                    emlAtt.setBody(dummyAttachment);
                    
                    messageBody += '<html><body>File Name: ' + cv.Title + '</body></html><br/>';
                    if(!caseToAttachmentMap.containsKey(contentDocToCaseMAP.get(cv.ContentDocumentId)))
                        caseToAttachmentMap.put((contentDocToCaseMAP.get(cv.ContentDocumentId)), new list<Messaging.EmailFileAttachment>());
                    caseToAttachmentMap.get(contentDocToCaseMAP.get(cv.ContentDocumentId)).add(emlAtt);
                    
                    if(!messageBodyMap.containsKey(contentDocToCaseMAP.get(cv.ContentDocumentId)))
                        messageBodyMap.put(contentDocToCaseMAP.get(cv.ContentDocumentId),messageBody);
                    else {
                        String msg = messageBodyMap.get(contentDocToCaseMAP.get(cv.ContentDocumentId));
                        system.debug('>>>>//>>Not Have Body: ' + msg);
                        msg += messageBody;
                        system.debug('>>>>//>>After Update: ' + msg);
                        messageBodyMap.put(contentDocToCaseMAP.get(cv.ContentDocumentId),msg);
                    }
                    ContentVersion ctv = new ContentVersion(id=cv.id,Attachment_sent__c =true);
                    cvList.add(ctv);
                    System.debug('>>>>>>>CV ID: ' + cv.ContentDocumentId);
                    system.debug('>>>>>MSG>>'+messageBody);
                    system.debug('>>>>CVL>>'+cvList); 
                    
                }else
                    System.debug('File Skipped: Less Than 5 MB');
                //  attachmentSent = False;
                
            }*/
            System.debug('>>>>Content Size>>>' + caseIdContentSizeMap);
            system.debug('>>>>Size'+ contentDocToCaseMAP.get(cv.ContentDocumentId) + '>>>' + caseToAttachmentMap.get(contentDocToCaseMAP.get(cv.ContentDocumentId)).size());
        }
        List<Messaging.SingleEmailMessage> listToSendMails = new List<Messaging.SingleEmailMessage>();
        Map<Id, List<Messaging.SingleEmailMessage>> caseIdMailListMap = new Map<Id, List<Messaging.SingleEmailMessage>>();
        System.debug('>>>///>>Case List Size>>>>'  + caselist.size());
        System.debug('>>>///>>Message Body Size>>' + messageBodyMap.size());
        set<id> customerUserIdSet = new Set<id>();
        for(User u: [select id from user where usertype like '%Customer%' and id in :IdSetOfAllUsers]){
            customerUserIdSet.add(u.id);
        }
       EmailTemplate emailTemplate =  [Select Id,Body,Subject,HtmlValue from EmailTemplate where developername =: system.label.template_for_customer_email];
       //bodyrec = emailTemplate.HtmlValue;
        system.debug('>>>>emaiTemp>>'+emailTemplate); 
        for(case c: caselist){
            if(!caseToAttachmentMap.containskey(c.id))
                continue;
            listToSendMails = new List<Messaging.SingleEmailMessage>();
            System.debug('>>>///>>Message Body>>' + messageBodyMap.get(c.id));
            emailSet = new Set<String>();
            mail = new Messaging.SingleEmailMessage();
            mailToOwner = new Messaging.SingleEmailMessage();
            system.debug('>>>>>Owner.Name'+c.Owner.Name);
            system.debug('>>>>>Contact.Name'+c.Contact.Name);
            system.debug('>>>>>contact.email'+c.contact.email);
            system.debug('>>>>>Owner.Id'+c.Owner.Id);
            system.debug('>>>>>Owner.Name'+c.Owner.Name);
            system.debug('>>>>>Owner.Email'+c.Owner.type);
            system.debug('>>>>>Owner.Email'+c.Owner.email);
            String UserSign = '';
            if(c.owner.type != 'Queue')
            UserSign = [select id, signature from user where id =:c.OwnerId limit 1].signature;
            if(string.isNotBlank(c.contact.email)){
                emailSet.add(c.contact.email);  
            }
            if(usersign !=null){
                System.debug('>>>>>oldSign' + usersign);
                if(userSign.contains('\n'))
                    System.debug('>>>>>Has New Line');
                else
                    system.debug('>>>>>Don\'t Have New Line');
                usersign = usersign.replaceAll('\n', '<br/>');
                System.debug('>>>>>newSign' + usersign);
            }else{
                usersign =  '<br/>Thank You!<br/><br/> QSC';
            }
           /**AAA***/
           // EmailTemplate emailTemplate =  [Select Id,Body,Subject,HtmlValue from EmailTemplate where developername = 'Case_4_Auto2Customer_AttachmentUploadedByAgent_1654708160101'];
           bodyrec = emailTemplate.HtmlValue;
            bodyrec = bodyrec.replace('{{{Case.CaseNumber}}}', c.CaseNumber);
           if( c.Subject!= null)
            bodyrec = bodyrec.replace('{{{Case.Subject}}}', c.Subject);
            else {
                bodyrec = bodyrec.replace('{{{Case.Subject}}}', '');
            }
            if( c.Description != null) 
            bodyrec = bodyrec.replace('{{{Case.Description}}}', c.Description);
            else {
                bodyrec = bodyrec.replace('{{{Case.Description}}}', '');
            }
            //string url = '<a href="https://qscprod.force.com/selfhelpportal/s/case'+c.id+ 'style="text-align: center; text-transform: uppercase; color: #ffffff; display: block; text-decoration: none; outline: none !important; outline-offset: 2px; font-family: Arial, Helvetica; margin: 0; padding: 0; border: none !important;"><strong>View or Update Case </strong></a>';
            bodyrec = bodyrec.replace('{{{Case.Id}}}', c.id);
            //bodyrec = bodyrec.replace('{{{Case.Ref_id__c}}}', c.Ref_id__c);
            system.debug('>>>>htmlcaseid>>>'+bodyrec);
             subj = emailTemplate.Subject;
            subj = subj.replace('[case.number]', c.CaseNumber);	
                  system.debug('emailTemplate==>'+emailTemplate); 
            
            list<string> emailList = new list<string>();
            emailList.addAll(emailSet); 
            //list<string> emailList = new list<string>{'mohnish.p@kcloudtechnologies.com','meha.mathur@kcloudtechnologies.com'};
            mail.setToAddresses(emailList);
            //added here org wide email address
            mail.setOrgWideEmailAddressId(orgWideEmailAddressLabel);//'0D28H000000005GSAQ'
            system.debug('email list--'+emailList);
           String link = sourcelink + 'case/' + c.id;
            /*string messagebody = 'Hi '+ c.contact.Name+',<br/><br/>Attachments have been added to case <a href = '+link+'>#'+c.CaseNumber+'</a>. Please review.<br/><br/>';
            messagebody += 'Subject: '+ c.subject +'<br/>'; 
            messagebody += 'Description: '+ c.Description+'<br/><br/>';
            system.debug('messagebody'+messagebody);
            System.debug('>>>>>>//>>Contains Key' + caseToAttachmentMap.containskey(c.id) + ' Case ID: ' + c.id);*/
            if(caseToAttachmentMap.get(c.id).size() > 0)
                mail.setFileAttachments(caseToAttachmentMap.get(c.id));
            //messagebody += usersign+ '<br/><br/>';
            //messagebody += messageBodyMap.get(c.id); 
            mail.setUseSignature(false);
            mail.setHtmlBody(bodyrec);
            mail.setSubject(subj);
            mail.setTemplateID(emailTemplate.Id);
            mail.setTargetObjectId(c.ContactId);
            mailToOwner.setSaveAsActivity(false);
            //mail.setCcAddresses(new List<String> {'dysem@kcloudtechnologies.com'});
            if(emailList.size()>0){
                system.debug('>>>>email szie>>>');
                if(idCvMap.containsKey(c.id)){
                    system.debug('>>>idCvMap.containsKey(c.id)>>>>');
                    //if(idCvMap.get(c.id).createdById == c.CreatedById)
                    for(contentVersion cv: idcvmap.get(c.id)){
                        System.debug('>>>>>>Checking CreatedByDate: ');
                        System.debug('T: ' + (cv.createdById != c.CreatedById));
                        System.debug('T: ' + customerUserIdSet.contains(c.CreatedById));
                        System.debug('T: ' + (cv.createdById != c.contactid));
                        System.debug('T: ' + !customerUserIdSet.contains(cv.createdById));
                        if(cv.createdById != c.CreatedById && customerUserIdSet.contains(c.CreatedById)){
                            System.debug('>>>>>>Content Version and Case Match');
                            listToSendMails.add(mail);
                            break;
                        }else if(cv.createdById != c.contactid && !customerUserIdSet.contains(cv.createdById)){
                            System.debug('>>>>>>Content Version and Case Match');
                            listToSendMails.add(mail);
                            break;
                        }
                    }   
                }           
            }
            
            List<string> ownerMailId = new List<String>();
            String OwnerMessageBody = '';
            if(string.isNotBlank(c.owner.email)){
                ownerMailId.add(c.owner.email);
                if(caseToAttachmentMap.get(c.id).size() > 0){
                    mailToOwner.setFileAttachments(caseToAttachmentMap.get(c.id));
                    for(Id caseId: caseToAttachmentMap.keySet())
                        System.debug('Name: ' + caseToAttachmentMap.get(caseId).size());
                }
                mailToOwner.setToAddresses(ownerMailId);
                //added here org wide email address
                mailtoowner.setOrgWideEmailAddressId(orgWideEmailAddressLabel);//'0D28H000000005GSAQ'
                OwnerMessageBody = 'Hi '+ c.owner.Name+',<br/><br/>Attachments have been added to case <a href = '+link+'>#'+c.CaseNumber+'</a>. Please review.<br/><br/>';
                if( c.Subject!= null)
                OwnerMessageBody += 'Subject: '+ c.subject +'<br/>'; 
                else {
                OwnerMessageBody += 'Subject: '+ '' +'<br/>';
            	}
                if( c.Description!= null)
            	OwnerMessageBody += 'Description: '+ c.Description+'<br/><br/>';
                else {
                OwnerMessageBody += 'Description: '+ '' +'<br/>';
            	}
                ownerMessageBody += usersign + '<br/><br/>';
                ownerMessageBody += messageBodyMap.get(c.id);
                mailtoowner.setUseSignature(false);
                mailToOwner.setHtmlBody(ownermessagebody);
                mailToOwner.setSubject('Owner Mail: Document has been uploaded');
                //mailToOwner.setCcAddresses(new List<String> {'dysem@kcloudtechnologies.com'});
                if(idCvMap.containsKey(c.id))
                for(contentVersion cv: idcvmap.get(c.id)){
                    System.debug('>>>>>>Owner Checking CreatedByDate: ');
                    System.debug('T: ' + (cv.createdById == c.CreatedById));
                    System.debug('T: ' + customerUserIdSet.contains(c.CreatedById));
                    System.debug('T: ' + (cv.createdById != c.CreatedById));
                    System.debug('T: ' + customerUserIdSet.contains(cv.createdById));
                        if(cv.createdById == c.CreatedById && customerUserIdSet.contains(c.CreatedById)){
                             System.debug('>>>>>>Owner Content Version and Case Match');
                            listToSendMails.add(mailToOwner);
                            break;
                        }else if(cv.createdById != c.CreatedById && customerUserIdSet.contains(cv.createdById)){
                            System.debug('>>>>>>Owner Content Version and Case Match');
                            listToSendMails.add(mailToOwner);
                            break;
                        }
                }
                
            }else if(c.owner.type == 'Queue'){
                usersign =  '<br/> Thank You..<br/><br/> QSC';
                // Codes stopped for testing purpose [select id, name, email from user where id in (select userorgroupid from groupmember where groupid = :c.Owner.Id)]
                List<user> queueMember = [select id, name, email from user where id in (select userorgroupid from groupmember where groupid = :c.Owner.Id) and email in ('bob.bingham@qsc.com','rahul@dysem.com', 'kirk.fyvie@qsc.com')];
                for(user u: queueMember){
                    ownerMailId = new List<String>();
                    mailToOwner = new Messaging.SingleEmailMessage();
                    ownerMailId.add(u.email);
                if(caseToAttachmentMap.get(c.id).size() > 0){
                    mailToOwner.setFileAttachments(caseToAttachmentMap.get(c.id));
                    for(Id caseId: caseToAttachmentMap.keySet())
                        System.debug('Name: ' + caseToAttachmentMap.get(caseId).size());
                }
              //added here org wide email address
                mailToOwner.setOrgWideEmailAddressId(orgWideEmailAddressLabel);
                    
                mailToOwner.setToAddresses(ownerMailId);
                OwnerMessageBody = 'Hi '+ u.Name+',<br/><br/>Attachments have been added to case <a href = '+link+'>#'+c.CaseNumber+'</a>. Please review.<br/>';
                OwnerMessageBody += 'Subject: '+ c.subject +'<br/>'; 
            	OwnerMessageBody += 'Description: '+ c.Description+'<br/><br/>';
                ownerMessageBody += usersign + '<br/><br/>';
                ownerMessageBody += messageBodyMap.get(c.id);
                mailtoowner.setUseSignature(false);
                mailToOwner.setHtmlBody(ownermessagebody);
                mailToOwner.setSubject('Queue: Document has been uploaded');
                //mailToOwner.setCcAddresses(new List<String> {'dysem@kcloudtechnologies.com'});
                if(idCvMap.containsKey(c.id))
                for(contentVersion cv: idcvmap.get(c.id)){
                    System.debug('>>>>>>Owner Checking CreatedByDate: ');
                    /*
                        if(cv.createdById == c.CreatedById){
                             System.debug('>>>>>>Owner Content Version and Case Match');
                            listToSendMails.add(mailToOwner);
                            break;
                        }
						*/
                    if(cv.createdById == c.CreatedById && customerUserIdSet.contains(c.CreatedById)){
                             System.debug('>>>>>>Owner Content Version and Case Match');
                            listToSendMails.add(mailToOwner);
                            break;
                        }else if(cv.createdById != c.CreatedById && customerUserIdSet.contains(cv.createdById)){
                            System.debug('>>>>>>Owner Content Version and Case Match');
                            listToSendMails.add(mailToOwner);
                            break;
                        }
                }
                }
            }
            if(!caseIdMailListMap.containsKey(c.id)){
                caseIdMailListMap.put(c.id, listToSendMails);
                
            } 
            else{
                caseIdMailListMap.get(c.id).addAll(listToSendMails);
            }
            
        }
        List<Messaging.SingleEmailMessage> finalMailListToSend = new List<Messaging.SingleEmailMessage>();
        for(id i : caseIdMailListMap.keyset()){
            finalMailListToSend.addAll(caseIdMailListMap.get(i));
            for(Messaging.SingleEmailMessage y : caseIdMailListMap.get(i)){
                System.debug('Email ID:' + y.getToAddresses());
            }
        }
        
        //for(id cid: caseIdMailListMap.keySet()){
            try{
                //System.debug('>>>>>>MailToSend size: ' + caseIdMailListMap.get(cid).size());
                set<id> markedAsUpdated = new Set<id>();
                Messaging.sendEmailResult[] sendEmailResults = Messaging.sendEmail(finalMailListToSend);
                system.debug('>>>>sendEmailResults>>>'+ sendEmailResults);
                for(Messaging.SendEmailResult sendEmailResult: sendEmailResults){
                    system.debug('>>>>sendEmailResults>>>'+ sendEmailResult);
                    if(sendEmailResult.isSuccess()){
                        if(caseToAttachmentMap.size()>0) {
                            for(id cid: caseIdMailListMap.keySet()){
                            case cas = new case(id=cid,New_Attachment__c = false);
                            if(!markedAsUpdated.contains(cid)){
                                updateCaselst.add(cas);
                                markedAsUpdated.add(cid);
                            }
                            }
                        }
                        system.debug('email sent succesfully');
                    }
                    else {
                        for (Messaging.Sendemailerror sendEmailError : 
                             sendEmailResult.getErrors()){
                                 system.debug('error msg '+ sendEmailError.Message);                                                   
                             }
                    }
                }
            } catch(System.Exception ex){
                // Exceptions are passed to here.
                System.debug('Exception Found: ' + ex);
            }
        //}
        //Commented for Testing to avoid multiple time file upload...
        
        List<ContentVersion> contversList = new List<ContentVersion>();
        contversList.addAll(cvList);
        if(contversList.size()>0)
            system.debug('>>>>>cont>>>'+contversList);
        database.update (contversList,false);
        if(updateCaselst.size()>0)
            system.debug('>>>>>updateCaselst>>>'+updateCaselst);
        database.update (updateCaselst,false);
        
    }
  	 global void finish(Database.BatchableContext BC){
        
        Datetime dt = system.now().addMinutes(15);
        String day = string.valueOf(dt.day());
        String month = string.valueOf(dt.month());
        String hour = string.valueOf(dt.hour());
        String minute = string.valueOf(dt.minute());
        String second = '00';
        String year = string.valueOf(system.now().year());
        String strJobName = 'BatchScheduleCase  -' + year + '-' + month + '-' + day+ ' ' + hour + ':' + minute + ':' + second;
        String strSchedule = '00 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        if(!Test.isRunningTest())
            System.schedule(strJobName, strSchedule, new BatchScheduleCase());
        
    }
}