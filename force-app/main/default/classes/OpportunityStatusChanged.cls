//=================================================================================================================
//  Object: methods_Contact.cls
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: opportunity method Clas
//=================================================================================================================
//          Date            Purpose
// Changes: 09/08/2018      Initial Version
//=================================================================================================================
public class OpportunityStatusChanged {
    
    /**************************************************************************************************************
SendEmail
Method When the opportunity status = Reflect Trial Success. This method takes  Opportunity Associated to Assets And Assets Associated to Subscription Contact  
and send an email to Subscription contact email.
---------------------------------------------------------------------------------------------------------------
@param    SetopportunityIds    ids of Status__c field from Opportunity
@return   void
**************************************************************************************************************/
    Public Static Void SendEmail(Set<Id> SetopportunityId){
        
         //Get Opportunity id and Status
        if(SetopportunityId.size()>0){
            Map<Id,string> opportunityIdList=new Map<Id,string>();
            Map<Id,Opportunity> Opportunitymap=new Map<Id,Opportunity>([select id,Name,Status__c from Opportunity Where Id IN: SetopportunityId]);
            for(Id key:Opportunitymap.keyset()){
                opportunityIdList.put(Key,Opportunitymap.get(key).Status__c);
            }
            
            //Get Opportunity --> Asset --> Subscription Contacts-->contact Email
             List<String> emails= new List<String>();
            for(Asset assets:[select id,name,Opportunity__c,(select name,Contact__r.Email from Subscription_Contacts__r) from Asset where Opportunity__c in:SetopportunityId]){
                for(Subscription_Contact__c cons: assets.Subscription_Contacts__r)
                {
                    if(cons!=null){
                        emails.add(cons.Contact__r.Email);
                    }
                }
            }
            
            //Get Email template to send email to SubscriptionContact to contact Email 
            List<Messaging.SingleEmailMessage> lstemail = new list<Messaging.SingleEmailMessage>();
            EmailTemplate et = [SELECT id,Name,subject,HTMLValue,body FROM EmailTemplate WHERE Name = 'Reflect Trial Success'];
			OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'communications@qsc.com'];

            for(String email : emails) {

                Messaging.SingleEmailMessage Emailmsg=new Messaging.SingleEmailMessage();
                Emailmsg.setToAddresses(new list<String>{email});
                Emailmsg.setTemplateId(et.Id);

				if ( owea.size() > 0 ) {
					Emailmsg.setOrgWideEmailAddressId(owea.get(0).id);
				} 
				   
                string sub=et.subject;
                String emailBody = et.HTMLValue;
                Emailmsg.setSubject(sub);
                Emailmsg.setHTMLBody(emailBody);
                lstemail.add(Emailmsg);
            }

			//Send Message
            Messaging.SendEmailResult[] results = Messaging.sendEmail(lstemail);
        }
    }
}