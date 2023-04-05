/*
*******************************************************************************************
# FILE...BatchSendEmailforContractwithAttachment
# CREATED BY...Meha Mathur
# CREATED DATE....8th Feb 2022
# LAST MODIFIED BY....Meha Mathur
# LAST MODIFIED DATE....9th Feb 2022
*******************************************************************************************
# AUTHOR...Meha Mathur
# DESCRIPTION...Batch class for sending multiple new attachments attached on Contract.
******************************************************************************************
*/
global class BatchSendEmailforContractwithAttachment implements database.Batchable<sObject> {
    public Set<Id> contractIDList=new Set<Id>();
    public map<id,List<id>> contentIdMAP = new map<id,List<id>>();//Map to associate contractId to its ContentDocument.
	Public list<id> ContentIdlist=  new list<id>();
    public Set<Id> userIDList=new Set<Id>();
    public Set<string> emailSet=new Set<String>();
    public set<id> docNameid = new  set<id>(); 
    Public list<contract> updateContractlst = new list<contract>();
    
    public String messageBody;
    List<ID> cdlList = new List<ID>(); 
    Messaging.SingleEmailMessage mail ;
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('>>>>>inside >>>   batch');
        return Database.getQueryLocator([SELECT id,ContractNumber,RecordTypeId, StartDate,ContractCountry__c,LegalEntity__c, ContractType__c, ContractTerritory__c, Description,   Account.name, Account.Owner.name from contract WHERE New_Attachment__c =true ]);
         }
    
    global void execute(Database.BatchableContext BC, List<contract> contractList){ 
        mail = new Messaging.SingleEmailMessage(); 
        Double contentSizeAtt =0; 
		set<ContentVersion> cvList= new set<ContentVersion>() ;  
        List<string> emailList=new List<String>{'julia.joseph@qsc.com','erik.wijgman@qsc.com','karen.stritt@qsc.com','erica.richmond@qsc.com'};
        //list<string> emailList = new list<string>{'meha.mathur@kcloudtechnologies.com'};
        for(contract c: contractlist) {   
            Boolean attachmentSent = false;
            system.debug('>>>>>Owner.Name'+c.Account.Owner.name);
            mail.setToAddresses(emailList);
            string subject = 'New Account Set-Up - '+ c.Account.name +'  '+ c.ContractCountry__c;
            List<Messaging.EmailFileAttachment> emlAttList = new List<Messaging.EmailFileAttachment>();
            system.debug('email list--'+emailList);
            string link = URL.getSalesforceBaseUrl().toExternalForm()+'/'+c.Id;
            //messageBody = 'Hi, <br/><br/>Attachment has been added to <a href = '+link+'>contract#'+c.ContractNumber+' :</a> <br/><br/>';
            messageBody = '<br/>Here is a new account set-up request for your review.<br/></br><a href = '+link+'>contract#'+c.ContractNumber+' :</a><br/>';
            messageBody += '<br/></br> Account Owner : '+c.Account.Owner.name +'<br/>Account Name : '+c.Account.name+'<br/>Contract Country : '+c.ContractCountry__c+'<br/>Contract Start Date : '+c.StartDate+'<br/> Legal Entity : '+c.LegalEntity__c+'<br/>Contract Type : '+c.ContractType__c+'<br/>Contract Territory : '+c.ContractTerritory__c+'<br/>Contract Description : '+c.Description+'<br/> <br/> Please contact the account manager if you have any questions.' ;
            mail.setHtmlBody(messageBody);
	 for (ContentDocumentLink cd : [SELECT ContentDocumentId,SystemModstamp,ContentDocument.ContentSize,ContentDocument.title,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: c.id ])
            {
                ContentIdlist.add(cd.ContentDocumentId);
                if(!contentIdMAP.containsKey(c.id))
                contentIdMAP.put(c.id, new List<id>());
                contentIdMAP.get(c.id).add(cd.ContentDocumentId);
            }
        	system.debug('>>>>contentIdMAP-->>'+contentIdMAP+'>>CASE>>'+c.ID);
         	
            for(ContentVersion cv: [SELECT id, VersionData,Attachment_sent__c,ContentSize ,Title, FileExtension FROM ContentVersion WHERE ContentDocumentId IN:contentIdMAP.get(c.id) AND IsLatest = true AND Attachment_sent__c =False order by createddate desc])
            {   Messaging.EmailFileAttachment emlAtt = new Messaging.EmailFileAttachment();
                contentSizeAtt += cv.ContentSize;
             	
                system.debug('>>contentSizeAtt>>>'+contentSizeAtt);
             	system.debug('>>>>>CON>>'+cv.ContentSize);
                if(cv.ContentSize < 5000000 && contentSizeAtt < 25000000 ){
                
               		 //messageBody += '<html><body>File Name: ' + cv.Title + '</body></html><br/>';
                    Blob fileData = cv.VersionData;
                    emlAtt.setFilename( cv.Title+ '.' + cv.FileExtension);
                    emlAtt.setBody(fileData);
                    emlAttList.add(emlAtt);
                    attachmentSent = True;
                    system.debug('>>>>ctv>>'+cv.Attachment_sent__c);
                    cv.Attachment_sent__c = True;
                   	ContentVersion ctv = new ContentVersion(id=cv.id,Attachment_sent__c =true);
                  	cvList.add(ctv);
                    system.debug('>>>>cvList>>'+cvList);
                    system.debug('>>>>'+emlAtt);
                    system.debug('emailSt>>>>'+ emlAttList);
                 }
              else{
                  
                  if(cv.ContentSize > 5000000)
                  {
                      ContentVersion ctv = new ContentVersion(id=cv.id,Attachment_sent__c =true);
                  	cvList.add(ctv);
                  }
                 attachmentSent = False;
            	 
              }
              }
         	mail.setFileAttachments(emlAttList );
            //messageBody += '<br/> Thank You,<br/><br/>'+c.contact.Name +' '+c.contact.email ;  
            system.debug('>>>attachemnt'+messageBody);
            mail.setHtmlBody(messageBody);
            mail.setSubject(subject);
            if(emlAttList.size() > 0){
            try{	
                 Messaging.sendEmailResult[] sendEmailResults =   Messaging.sendEmail(new Messaging.Email[] { mail });
                    for(Messaging.SendEmailResult sendEmailResult: sendEmailResults){
                        if(sendEmailResult.isSuccess()){
                            if(attachmentSent){
                                contract contr = new contract(id=c.id,New_Attachment__c = false);
                               	updateContractlst.add(contr);
                            }
                            system.debug('>>>>>email sent succesfully');
                        }
                        else {
                            for (Messaging.Sendemailerror sendEmailError : 
                                 sendEmailResult.getErrors()){
                                     system.debug('error msg '+ sendEmailError.Message);                                                   
                                 }
                        }
                    }
                } 
        		catch(System.EmailException ex){
                    // Exceptions are passed to here.
                }
            
        }
        }
    	//set<ContentVersion> contversSet = new set<ContentVersion>();
       // contversSet.addAll(cvList);
        List<ContentVersion> contversList = new List<ContentVersion>();
        contversList.addAll(cvList);
        if(contversList.size()>0)
        database.update (contversList,false);
		if(updateContractlst.size()>0)
        database.update (updateContractlst,false);
        
    }
    
    
    global void finish(Database.BatchableContext BC){
        Datetime dt = system.now().addMinutes(15);
        String day = string.valueOf(dt.day());
        String month = string.valueOf(dt.month());
        String hour = string.valueOf(dt.hour());
        String minute = string.valueOf(dt.minute());
        String second = '00';
        String year = string.valueOf(system.now().year());
        String strJobName = 'BatchScheduleCaseContract  -' + year + '-' + month + '-' + day+ ' ' + hour + ':' + minute + ':' + second;
        String strSchedule = '00 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        if(!Test.isRunningTest())
        System.schedule(strJobName, strSchedule, new BatchScheduleCaseContract());
    }
   
}