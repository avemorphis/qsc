/**

* @description        : ContributorEmailNotificationBatch for sending email notification to developer repo contributon every friday.
* @Last Modified By   : prakhar.jain@qsc.con
* @Last Modified On   : 20/03/2023
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    20/03/2023     prakhar.jain@qsc.com       Initial Version
**/
public class ContributorEmailNotificationBatch implements Database.Batchable<sObject>
{
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        Date todayDate = Date.today();
        Date sixDayBeforeDate = todayDate.addDays(-6);
        
        //Getting the FeedComment data from createddate <= TODAY AND createddate >: sixDayBeforeDate.
        List<FeedComment> listFeedComments = [SELECT Id, FeedItemId, ParentId, CommentBody 
                                              FROM FeedComment 
                                              WHERE createddate <= TODAY
                                              AND createddate >: sixDayBeforeDate
                                              AND FeedItemId != null
                                              AND ParentId != null
                                             ];
        
        Set<Id> setDeveloperRepoIds = new Set<Id>();
        
        //Checking listFeedComments is not empty.
        If(!listFeedComments.isEmpty())
        {
            //Iterating FeedComment records for getting ParentId.
            For(FeedComment objFeedComment : listFeedComments)
            {
                setDeveloperRepoIds.add(objFeedComment.ParentId);
            }
        }
        
        //Query on Developer_Repo_Contributor__c object for getting the records using setDeveloperRepoIds.
        String query = 'SELECT Id, Name, Developer_Repo__c, Developer_Repo__r.Name, Contributor__c, Contributor__r.Name, Contributor__r.Email FROM Developer_Repo_Contributor__c';
        query += ' WHERE Developer_Repo__c IN : setDeveloperRepoIds AND Contributor__c != null AND Developer_Repo__c != null';
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Developer_Repo_Contributor__c> listRecords)
    {
        //Checking listRecords is not empty.
        If(!listRecords.isEmpty())
        {
            //Getting email template developer name from custom label.
            String emailTemplateName = System.Label.Contributor_Email_Notification_email_developer_name;
            List<EmailTemplate> listEmailTemplates = new List<EmailTemplate>();
            
            If(String.isNotBlank(emailTemplateName))
            {
                //Getting email template record using emailTemplateName.
                listEmailTemplates = [SELECT Id, Name, DeveloperName, Subject, HtmlValue, Body 
                                      FROM EmailTemplate 
                                      WHERE DeveloperName =: emailTemplateName
                                     ];
                
                //Checking listEmailTemplates is not empty.
                If(!listEmailTemplates.isEmpty())
                {
                    List<Messaging.SingleEmailMessage> listMessages = new List<Messaging.SingleEmailMessage>();
                    
                    // Get the base URL.
					String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
                        
                    For(Developer_Repo_Contributor__c objDeveloperRepoContributor : listRecords)
                    {
                        String emailSubject = '';
                        String emailBody = '';
                        
                        If(listEmailTemplates[0].Subject != null && listEmailTemplates[0].Subject.contains('[REPO_NAME]'))
                        {
                            emailSubject = listEmailTemplates[0].Subject.replace('[REPO_NAME]', objDeveloperRepoContributor.Developer_Repo__r.Name);
                        }
                        
                        If(listEmailTemplates[0].HtmlValue != null && listEmailTemplates[0].HtmlValue.contains('[CONTRIBUTOR_NAME]'))
                        {
                            String contributorName = objDeveloperRepoContributor.Contributor__r.Name;
                            emailBody = listEmailTemplates[0].HtmlValue.replace('[CONTRIBUTOR_NAME]', contributorName);
                        }
                        
                        If(String.isNotBlank(emailBody) && emailBody.contains('recordUrl'))
                        {
                            emailBody = emailBody.replace('recordUrl', sfdcBaseURL + '/' + objDeveloperRepoContributor.Developer_Repo__c);
                        }
                        
                        //Email Sending Process.
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.subject = emailSubject;
                        message.setHtmlBody(emailBody);
                        message.setSaveAsActivity(false);
                        message.setTargetObjectId(objDeveloperRepoContributor.Contributor__c);
                        listMessages.add(message);
                    }
                    
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(listMessages);
                    
                    If(!results.isEmpty())
                    {
                        For(Messaging.SendEmailResult objEmail : results)
                        {
                            If(objEmail.success) 
                            {
                                System.debug('The email was sent successfully.');
                            } 
                            Else 
                            {
                                System.debug('The email failed to send: ' + results[0].errors[0].message);
                            }
                        }
                    }
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext BC)
    {
    }
}