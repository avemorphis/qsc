public with sharing class emailToSalesDirector {

    public static String body(List<Opportunity> report) {
    String tableStyleheader = '<html><body>Hi '+report[0].Owner.Name+',<br/> The following Opportunities are set to expire in next two weeks,'+
    'please review and update your pipeline.<br/>'+
    '<table style="border-collapse: collapse;width: 100%;">';
    String tableStyleend = '</table></body></html>';
    String header ='<tr style="border: 1px solid #dddddd;padding: 8px;background-color: #dddddd"> <th style="border: 1px solid #000000;padding: 8px;">Estimated Closed Date </th> <th style="border: 1px solid #000000;padding: 8px;">Opportunity Name</th> <th style="border: 1px solid #000000;padding: 8px;">Partner Account</th>'+
    '<th style="border: 1px solid #000000;padding: 8px;">End User Account</th> <th style="border: 1px solid #000000;padding: 8px;">Amount</th> <th style="border: 1px solid #000000;padding: 8px;">Stage</th> <th style="border: 1px solid #000000;padding: 8px;">Sales Director</th></tr>';
    String columData ='';
    list<String> a = new List<String>();
    for (Opportunity op : report) {
        System.debug('test1 '+ op.name);
        String opID = op.Id;
        string link = URL.getSalesforceBaseUrl().toExternalForm()+'/'+opID;
        String col = '<tr style="border: 1px solid #000000;padding: 8px;"> <th style="border: 1px solid #000000;padding: 8px;">'+op.CloseDate.format()+'</th> <th>'+'<a href ='+link+'>'+op.Name+'</a></th> <th style="border: 1px solid #000000;padding: 8px;">'+op.Partner_Account__r.Name+'</th>'+
        '<th style="border: 1px solid #000000;padding: 8px;">'+op.End_User_Account__c+'</th> <th style="border: 1px solid #000000;padding: 8px;">'+op.Amount+'</th> <th style="border: 1px solid #000000;padding: 8px;">'+op.StageName+'</th> <th style="border: 1px solid #000000;padding: 8px;">'+op.Owner.Name+'</th></tr>';
        columData+=col;
    }
    String body = tableStyleheader+header+columData+tableStyleend;
    return body;
    }

    public static void sendEmail( Map<String,List<Opportunity>> report ) {
    string subject = 'Opportunites Expiring Soon';
    messaging.SingleEmailMessage email1=new messaging.SingleEmailMessage();
    OrgWideEmailAddress owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='QSC Communications' limit 1];
    
    Map<String,User> userEmail = new Map<String,User>();
    for (User u : [select id, Name, email from user where id In:report.keySet()]) {
        userEmail.put(u.Id, u);
    }
        List<messaging.SingleEmailMessage> mailToSend = new List<messaging.SingleEmailMessage>();
    for (String opp : report.keySet() ){
        email1=new messaging.SingleEmailMessage();
        email1.setSubject(subject);
    string[]toAdd=new string[]{userEmail.get(opp).email};
    //string[]toAdd=new string[]{'dysem@kcloudtechnologies.com', 'Erica.Richmond@qsc.com'};//atul.menon@kcloudtechnologies.com
    email1.setOrgWideEmailAddressId(owea.Id); 
    // email1.setReplyTo(userEmail.get(opp).email);
    email1.setToAddresses(toAdd);
    System.debug(userEmail.get(opp).Name+' '+userEmail.get(opp).email);
    email1.setHtmlBody(body(report.get(opp)));
    // email1.setSenderDisplayName(userEmail.get(opp).Name);
    mailToSend.add(email1);
    
    }
        if(mailToSend.size()>0){
            messaging.sendEmail(mailToSend);
        }
    }
    }