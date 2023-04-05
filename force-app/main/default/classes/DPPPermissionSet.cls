/**************************************************************************************************************
* @File Name          : DPPPermissionSet.cls
* @description        : This class is calling from th_Account.cls and th_Contact.cls.
* @Author             : naman.gupta@qsc.com
* @Group              : 
* @Last Modified By   : naman.gupta@qsc.com
* @Last Modified On   : 19/12/2022
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    19/12/2022   	naman.gupta
**************************************************************************************************************/
public class DPPPermissionSet 
{
    /**************************************************************************************************************
* @File Name          : DPPPermissionSet.cls
* @method Name		  : assignPermissionSetToUser.
* @description        : We insert the PermissionSetAssignment Records from the active contact users using future methode.
* @Author             : naman.gupta@qsc.com
* @Group              : 
* @Last Modified By   : naman.gupta@qsc.com
* @Last Modified On   : 19/12/2022
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    19/12/2022   	naman.gupta
**************************************************************************************************************/
    @future(callout = true)
    public static void assignPermissionSetToUser(Set<Id> setAccountIds, Set<Id> setDeveloperPartnerParentAccountIds)
    {
        //Check setDeveloperPartnerParentAccountIds is not empty.
        If(!setDeveloperPartnerParentAccountIds.isEmpty())
        {
            setAccountIds.addAll(setDeveloperPartnerParentAccountIds);
        }
        
        //Check setAccountIds is not empty.
        If(!setAccountIds.isEmpty())
        {
            List<Contact> listActiveContacts = [SELECT Id, Status__c, DPP_Access__c, Email, FirstName
                                                FROM Contact
                                                WHERE Status__c = 'Active'
                                                AND DPP_Access__c != NULL
                                                AND AccountId IN : setAccountIds
                                               ];
            
            //Check listActiveContacts is not empty.
            If(!listActiveContacts.isEmpty())
            {
                Map<Id, Contact> mapContacts = new Map<Id, Contact>();
                
                //Iterate list of active contact records.
                For(Contact objContact : listActiveContacts)
                {
                    If(String.isNotEmpty(objContact.DPP_Access__c))
                    {
                        mapContacts.put(objContact.Id, objContact);
                    }
                }
                //Getting DPP_Permission_Set__mdt records.
                List<DPP_Permission_Set__mdt> listDPPPermissionSets = [SELECT Id, MasterLabel, DeveloperName, category__c
                                                                       FROM DPP_Permission_Set__mdt
                                                                      ];
                //Check listDPPPermissionSets is not empty.
                If(!listDPPPermissionSets.isEmpty())
                {
                    Set<String> setAdminPermissionSets = new Set<String>();
                    Set<String> setUserPermissionSets = new Set<String>();
                    
                    //Iterate list of DPP_Permission_Set__mdt metadata records.
                    for(DPP_Permission_Set__mdt objMTD : listDPPPermissionSets)
                    {
                        If(String.isNotEmpty(objMTD.category__c) && objMTD.category__c == 'Admin')
                        {
                            setAdminPermissionSets.add(objMTD.DeveloperName);
                        }
                        Else If(String.isNotEmpty(objMTD.category__c) && objMTD.category__c == 'User')
                        {
                            setUserPermissionSets.add(objMTD.DeveloperName);
                        }
                    }
                    
                    List<PermissionSet> psDPPAdmins = [SELECT Id, Label, Name 
                                                       FROM PermissionSet 
                                                       WHERE Name IN : setAdminPermissionSets 
                                                       LIMIT 1
                                                      ];
                    List<PermissionSet> psDPPUsers = [SELECT Id, Label, Name 
                                                      FROM PermissionSet 
                                                      WHERE Name IN : setUserPermissionSets 
                                                      LIMIT 1
                                                     ];
                    List<User> listUsers = [SELECT Id, Name, ContactId 
                                            FROM User
                                            WHERE ContactId IN : mapContacts.keySet()
                                            AND IsActive = true
                                           ];
                    
                    //Check listUsers is not empty.
                    If(!listUsers.isEmpty())
                    {
                        Set<Id> setUserIds = new Set<Id>();
                        
                        For(User usr : listUsers)
                        {
                            setUserIds.add(usr.Id);
                        }
                        
                        List<PermissionSetAssignment> psInsert = new List<PermissionSetAssignment>();
                        
                        List<PermissionSetAssignment> listPermissionSetAssignments = [SELECT Id, PermissionSetId
                                                                                      FROM PermissionSetAssignment
                                                                                      WHERE AssigneeId IN : setUserIds
                                                                                     ];
                        
                        Map<Id, PermissionSetAssignment> mapPermissionSetAssignments = new Map<Id, PermissionSetAssignment>();
                        
                        For(PermissionSetAssignment objPSA : listPermissionSetAssignments)
                        {
                            If(String.isNotEmpty(objPSA.PermissionSetId))
                            {
                                mapPermissionSetAssignments.put(objPSA.PermissionSetId, objPSA);
                            }
                        }
                        
                        //Getting DPP User email template developer name from custom label.
                        /*String dppUserEmailTemplateName = System.Label.DPP_User_Email_Template;
                        system.debug('DPP User Email Template Result : ' + dppUserEmailTemplateName);
                        
                        //Getting DPP Admin email template developer name from custom label.
                        String dppAdminEmailTemplateName = System.Label.DPP_Admin_Email_Template;
                        system.debug('DPP Admin Email Template Result : ' + dppUserEmailTemplateName);
                        
                        
                        List<EmailTemplate> listUserEmailTemplates = new List<EmailTemplate>();
                        List<EmailTemplate> listAdminEmailTemplates = new List<EmailTemplate>();
                        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                        
                        If(String.isNotEmpty(dppUserEmailTemplateName))
                        {
                            //Getting DPP User email template detals using SOQL.
                            listUserEmailTemplates = [SELECT Id, Name, DeveloperName, Subject 
                                                      FROM EmailTemplate 
                                                      WHERE DeveloperName =: dppUserEmailTemplateName.trim()
                                                     ];
                        }
                        
                        If(String.isNotEmpty(dppAdminEmailTemplateName))
                        {
                            //Getting DPP Admin email template detals using SOQL.
                            listAdminEmailTemplates = [SELECT Id, Name, DeveloperName, Subject 
                                                       FROM EmailTemplate 
                                                       WHERE DeveloperName =: dppAdminEmailTemplateName.trim()
                                                      ];
                        }
                        
                        System.debug('Email template : ' + listAdminEmailTemplates); */
                        For(User usr : listUsers)
                        {
                            If(String.isNotEmpty(usr.ContactId) && mapContacts.containsKey(usr.ContactId) && mapContacts.get(usr.ContactId).DPP_Access__c == 'Admin' && !psDPPAdmins.isEmpty() && !mapPermissionSetAssignments.containsKey(psDPPAdmins[0].Id))
                            {
                                PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = psDPPAdmins[0].Id, AssigneeId = usr.Id);
                                psInsert.Add(psa);
                                
                                //Email sendding process for DPP Admin.
                                /*If(!listAdminEmailTemplates.isEmpty() && mapContacts.get(usr.ContactId).Email != null)
                                {
                                    //New instance of a single email message
                                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                    
                                    // Who you are sending the email to
                                    mail.setTargetObjectId(usr.ContactId);
                                    
                                    // The email template ID used for the email
                                    mail.setTemplateId(listAdminEmailTemplates[0].Id);
                                    mail.setBccSender(false);
                                    mail.setUseSignature(false);
                                    mail.setSaveAsActivity(false);  
                                    mails.add(mail);
                                }*/
                            }
                            Else If(String.isNotEmpty(usr.ContactId) && mapContacts.containsKey(usr.ContactId) && mapContacts.get(usr.ContactId).DPP_Access__c == 'User' && !psDPPUsers.isEmpty() && !mapPermissionSetAssignments.containsKey(psDPPUsers[0].Id))
                            {
                                PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = psDPPUsers[0].Id, AssigneeId = usr.Id);
                                psInsert.Add(psa);
                                
                                //Email sendding process for DPP Admin.
                                /*If(!listUserEmailTemplates.isEmpty() && mapContacts.get(usr.ContactId).Email != null)
                                {
                                    //New instance of a single email message
                                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                    
                                    // Who you are sending the email to
                                    mail.setTargetObjectId(usr.ContactId);
                                    
                                    // The email template ID used for the email
                                    mail.setTemplateId(listUserEmailTemplates[0].Id);
                                    mail.setBccSender(false);
                                    mail.setUseSignature(false);
                                    mail.setSaveAsActivity(false);  
                                    mails.add(mail);
                                }*/
                            }
                        }
                        
                        //Check psInsert is not empty.
                        If(!psInsert.isEmpty())
                        {
                            INSERT psInsert;
                            //Check mails is not empty.
                            /*If(!mails.isEmpty())
                            {
                                Messaging.sendEmail(mails);
                            }*/
                        }
                    }
                }
            }
        }
    }
    
    /**************************************************************************************************************
* @File Name          : DPPPermissionSet.cls
* @method Name		  : removePermissionSetToUser.
* @description        : We delete an existing PermissionSetAssignment Records from the active contact users using future methode.
* @Author             : naman.gupta@qsc.com
* @Group              : 
* @Last Modified By   : naman.gupta@qsc.com
* @Last Modified On   : 19/12/2022
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    19/12/2022   	naman.gupta
**************************************************************************************************************/
    @future(callout = true)
    public static void removePermissionSetToUser(Set<Id> setAccountIds, Set<Id> setDeveloperPartnerParentAccountIds)
    {
        //Check setAccountIds is not empty.
        If(!setAccountIds.isEmpty())
        {
            //Check setDeveloperPartnerParentAccountIds is not empty.
            If(!setDeveloperPartnerParentAccountIds.isEmpty())
            {
                setAccountIds.addAll(setDeveloperPartnerParentAccountIds);
            }
            
            List<Contact> listActiveContacts = [SELECT Id, Status__c, DPP_Access__c
                                                FROM Contact
                                                WHERE Status__c = 'Active'
                                                AND DPP_Access__c != NULL
                                                AND AccountId IN : setAccountIds
                                               ];
            
            //Check listActiveContacts is not empty.
            If(!listActiveContacts.isEmpty())
            {
                Map<Id, Contact> mapContacts = new Map<Id, Contact>();
                
                //Iterate list of active contact records.
                For(Contact objContact : listActiveContacts)
                {
                    If(String.isNotEmpty(objContact.DPP_Access__c))
                    {
                        mapContacts.put(objContact.Id, objContact);
                    }
                }
                
                List<User> listUsers = [SELECT Id, Name, ContactId 
                                        FROM User
                                        WHERE ContactId IN : mapContacts.keySet()
                                        AND IsActive = true
                                       ];
                
                //Check listUsers is not empty.
                If(!listUsers.isEmpty())
                {
                    Set<Id> setUserIds = new Set<Id>();
                    For(User usr : listUsers)
                    {
                        If(String.isNotEmpty(usr.ContactId) && mapContacts.containsKey(usr.ContactId) && (mapContacts.get(usr.ContactId).DPP_Access__c == 'Admin' || mapContacts.get(usr.ContactId).DPP_Access__c == 'User'))
                        {
                            setUserIds.add(usr.Id);
                        }
                    }
                    
                    //Getting DPP_Permission_Set__mdt records.
                    List<DPP_Permission_Set__mdt> listDPPPermissionSets = [SELECT Id, MasterLabel, DeveloperName, category__c
                                                                           FROM DPP_Permission_Set__mdt
                                                                          ];
                    //Check listDPPPermissionSets is not empty.
                    If(!listDPPPermissionSets.isEmpty())
                    {
                        Set<String> setAdminUserPermissionSets = new Set<String>();
                        
                        //Iterate list of DPP_Permission_Set__mdt metadata records.
                        for(DPP_Permission_Set__mdt objMTD : listDPPPermissionSets)
                        {
                            If(String.isNotEmpty(objMTD.category__c) && objMTD.category__c == 'Admin')
                            {
                                setAdminUserPermissionSets.add(objMTD.DeveloperName);
                            }
                            Else If(String.isNotEmpty(objMTD.category__c) && objMTD.category__c == 'User')
                            {
                                setAdminUserPermissionSets.add(objMTD.DeveloperName);
                            }
                        }
                        
                        List<PermissionSet> psDPPAdmins = [SELECT Id, Label, Name 
                                                           FROM PermissionSet 
                                                           WHERE Name IN : setAdminUserPermissionSets
                                                          ];
                        //Check psDPPAdmins is not empty.
                        If(!psDPPAdmins.isEmpty())
                        {
                            Set<Id> setPermissionSetIds = new Set<Id>();
                            
                            //Iterate list of PermissionSet records.
                            For(PermissionSet objPermissionSet : psDPPAdmins)
                            {
                                setPermissionSetIds.add(objPermissionSet.Id);
                            }
                            
                            If(!setPermissionSetIds.isEmpty())
                            {
                                List<PermissionSetAssignment> listPermissionSetAssignments = [SELECT Id 
                                                                                              FROM PermissionSetAssignment 
                                                                                              WHERE AssigneeId IN : setUserIds 
                                                                                              AND PermissionSet.id IN : setPermissionSetIds
                                                                                             ];
                                DELETE listPermissionSetAssignments;
                            }
                        }
                    }
                }
            }
        }
    }
    
    //We insert the new PermissionSetAssignment records and delete an existing PermissionSetAssignment Records from the active contact users using future methode.
    @future(callout = true)
    public static void assignAndRemovePermissionSetFromUser(Set<Id> setNewContactIds)
    {
        Map<Id, Contact> mapContacts = new Map<Id, Contact>();
        
        List<Contact> listContacts = [SELECT Id, DPP_Access__c, AccountId, Account.Account_Category__c, Email, FirstName 
                                      FROM Contact 
                                      WHERE Id IN : setNewContactIds
                                     ];
        
        //Iterate list of Contact records.
        For(Contact objContact : listContacts)
        {
            mapContacts.put(objContact.Id, objContact);
        }
        
        //Check map is not empty.
        If(!mapContacts.isEmpty())
        {
            List<User> listUsers = [SELECT Id, Name, ContactId 
                                    FROM User
                                    WHERE ContactId IN : mapContacts.keySet()
                                    AND IsActive = true
                                   ];
            
            //Check list is not empty.
            If(!listUsers.isEmpty())
            {
                //Getting DPP_Permission_Set__mdt records.
                List<DPP_Permission_Set__mdt> listDPPPermissionSets = [SELECT Id, MasterLabel, DeveloperName, category__c
                                                                       FROM DPP_Permission_Set__mdt
                                                                      ];
                //Check listDPPPermissionSets is not empty.
                If(!listDPPPermissionSets.isEmpty())
                {
                    Set<String> setAdminPermissionSets = new Set<String>();
                    Set<String> setUserPermissionSets = new Set<String>();
                    Set<Id> setUserIds = new Set<Id>();
                    
                    //Iterate list of DPP_Permission_Set__mdt metadata records.
                    for(DPP_Permission_Set__mdt objMTD : listDPPPermissionSets)
                    {
                        If(String.isNotEmpty(objMTD.category__c) && objMTD.category__c == 'Admin')
                        {
                            setAdminPermissionSets.add(objMTD.DeveloperName);
                        }
                        Else If(String.isNotEmpty(objMTD.category__c) && objMTD.category__c == 'User')
                        {
                            setUserPermissionSets.add(objMTD.DeveloperName);
                        }
                    }
                    
                    List<PermissionSet> psDPPAdmins = [SELECT Id, Label, Name 
                                                       FROM PermissionSet 
                                                       WHERE Name IN : setAdminPermissionSets 
                                                       LIMIT 1
                                                      ];
                    List<PermissionSet> psDPPUsers = [SELECT Id, Label, Name 
                                                      FROM PermissionSet 
                                                      WHERE Name IN : setUserPermissionSets 
                                                      LIMIT 1
                                                     ];
                    
                    List<PermissionSetAssignment> psInsert = new List<PermissionSetAssignment>();
                    
                    //Getting DPP User email template developer name from custom label.
                    /*String dppUserEmailTemplateName = System.Label.DPP_User_Email_Template;
                    system.debug('DPP User Email Template Result : ' + dppUserEmailTemplateName);
                    
                    //Getting DPP Admin email template developer name from custom label.
                    String dppAdminEmailTemplateName = System.Label.DPP_Admin_Email_Template;
                    system.debug('DPP Admin Email Template Result : ' + dppAdminEmailTemplateName);
                    
                    
                    List<EmailTemplate> listUserEmailTemplates = new List<EmailTemplate>();
                    List<EmailTemplate> listAdminEmailTemplates = new List<EmailTemplate>();
                    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                    
                    If(String.isNotEmpty(dppUserEmailTemplateName))
                    {
                        //Getting DPP User email template detals using SOQL.
                        listUserEmailTemplates = [SELECT Id, Name, DeveloperName, Subject 
                                                  FROM EmailTemplate 
                                                  WHERE DeveloperName =: dppUserEmailTemplateName.trim()
                                                 ];
                    }
                    
                    If(String.isNotEmpty(dppAdminEmailTemplateName))
                    {
                        //Getting DPP Admin email template detals using SOQL.
                        listAdminEmailTemplates = [SELECT Id, Name, DeveloperName, Subject 
                                                   FROM EmailTemplate 
                                                   WHERE DeveloperName =: dppAdminEmailTemplateName.trim()
                                                  ];
                    }
                    
                    System.debug('Email template : ' + listAdminEmailTemplates); */
                    
                    For(User usr : listUsers)
                    {
                        If(String.isNotEmpty(usr.ContactId) && mapContacts.containsKey(usr.ContactId) && mapContacts.get(usr.ContactId).DPP_Access__c == 'Admin' && !psDPPAdmins.isEmpty() && mapContacts.get(usr.ContactId).Account.Account_Category__c == 'Developer Partner')
                        {
                            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = psDPPAdmins[0].Id, AssigneeId = usr.Id);
                            psInsert.Add(psa);
                            setUserIds.add(usr.Id);
                            
                            //Email sendding process for DPP Admin.
                            /*If(!listAdminEmailTemplates.isEmpty() && mapContacts.get(usr.ContactId).Email != null)
                            {
                                //New instance of a single email message
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                
                                // Who you are sending the email to
                                mail.setTargetObjectId(usr.ContactId);
                                
                                // The email template ID used for the email
                                mail.setTemplateId(listAdminEmailTemplates[0].Id);
                                mail.setBccSender(false);
                                mail.setUseSignature(false);
                                mail.setSaveAsActivity(false);  
                                mails.add(mail);
                            }*/
                        }
                        Else If(String.isNotEmpty(usr.ContactId) && mapContacts.containsKey(usr.ContactId) && mapContacts.get(usr.ContactId).DPP_Access__c == 'User' && !psDPPUsers.isEmpty()  && mapContacts.get(usr.ContactId).Account.Account_Category__c == 'Developer Partner')
                        {
                            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = psDPPUsers[0].Id, AssigneeId = usr.Id);
                            psInsert.Add(psa);
                            setUserIds.add(usr.Id);
                            
                            //Email sendding process for DPP Admin.
                            /*If(!listUserEmailTemplates.isEmpty() && mapContacts.get(usr.ContactId).Email != null)
                            {
                                //New instance of a single email message
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                
                                // Who you are sending the email to
                                mail.setTargetObjectId(usr.ContactId);
                                
                                // The email template ID used for the email
                                mail.setTemplateId(listUserEmailTemplates[0].Id);
                                mail.setBccSender(false);
                                mail.setUseSignature(false);
                                mail.setSaveAsActivity(false);  
                                mails.add(mail);
                            }*/
                        }
                        Else If(String.isNotEmpty(usr.ContactId) && mapContacts.containsKey(usr.ContactId) && (String.isBlank(mapContacts.get(usr.ContactId).DPP_Access__c) || mapContacts.get(usr.ContactId).DPP_Access__c == 'Inactive'))
                        {
                            setUserIds.add(usr.Id);
                        }
                    }
                    //Check setUserIds is not empty.
                    If(!setUserIds.isEmpty())
                    {
                        List<PermissionSetAssignment> psaDelete = [SELECT Id 
                                                                   FROM PermissionSetAssignment 
                                                                   WHERE AssigneeId IN : setUserIds 
                                                                   AND (PermissionSet.Id =: psDPPAdmins[0].Id
                                                                        OR PermissionSet.Id =: psDPPUsers[0].Id)
                                                                  ];
                        DELETE psaDelete;
                    }
                    
                    //Check psInsert is not empty.
                    If(!psInsert.isEmpty())
                    {
                        INSERT psInsert;
                        /*system.debug('mails =======> ' + mails);
                        //Check mails is not empty.
                        If(!mails.isEmpty())
                        {
                            Messaging.sendEmail(mails);
                        }*/
                    }
                }
            }
        }
    }
}