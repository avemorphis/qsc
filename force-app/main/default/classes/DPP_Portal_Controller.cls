/**************************************************************************************************************
* @File Name          : DPP_Portal_Controller.cls
* @description        : This class is calling from dppManageAccount.js in lwc component which is used in community.
* @Author             : naman.gupta@qsc.com
* @Group              : 
* @Last Modified By   : naman.gupta@qsc.com
* @Last Modified On   : 17/01/2023
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    27/12/2022   	naman.gupta
**************************************************************************************************************/
public Without sharing class DPP_Portal_Controller 
{
    
    /**************************************************************************************************************
* @Method Name        : getDPPAccessIsAdminOrUser
* @description        : This method is called from dPP_UserSideBar.js in lwc component, which is used in the 
community using this method, we are getting the logged-in user record and check their 
contact record DPP Access is admin or user.
* @Last Modified By   : naman.gupta@qsc.com
* @param			  : No parameter.
**************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    Public static dppWrapper getDPPAccessIsAdminOrUser()
    {
        //Getting community logged in user id. 
        String userId = userinfo.getUserId();
        
        dppWrapper objDppWrapper = new dppWrapper();
        
        //Check userId is not empty.
        If(String.isNotEmpty(userId))
        {
            //Getting user record for getting ContactId and Contact.DPP_Access__c using userId.
            List<User> listUsers = [SELECT Id, ContactId, Contact.DPP_Access__c, Contact.accountId
                                    FROM User
                                    WHERE Id =: userId
                                   ];
            //Check listUsers is not empty.
            If(!listUsers.isEmpty())
            {
                //Check user ContactId and Contact.DPP_Access__c is not null.
                If(listUsers[0].ContactId != null && listUsers[0].Contact.DPP_Access__c != null && listUsers[0].Contact.accountId != null && listUsers[0].Contact.DPP_Access__c != 'Inactive')
                {
                    objDppWrapper.dppAccess = listUsers[0].Contact.DPP_Access__c;
                    objDppWrapper.accountId = listUsers[0].Contact.accountId;
                    objDppWrapper.contactId = listUsers[0].ContactId;
                }
            }
        }
        
        return objDppWrapper;
    }
    
    //assetWrapper class.
    public class dppWrapper
    {
        @AuraEnabled public String dppAccess;
        @AuraEnabled public String accountId;
        @AuraEnabled public String contactId;
        
        public dppWrapper()
        {
            
        }
    }
    
    /**************************************************************************************************************
* @Method Name        : getUserAndContactInformation
* @description        : This method is called from dppManageAccount.js in lwc component, which is used in the 
community using this method, we are getting the logged-in user record and their 
contact-related account-related active contact records and add them into the wrapper class.
* @Last Modified By   : naman.gupta@qsc.com
* @param			  : No parameter.
**************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    Public static List<Wrapper> getUserAndContactInformation()
    {
        //Getting community logged in user id. 
        String userId = userinfo.getUserId();
        
        List<Wrapper> listWrappers = new List<Wrapper>();
        
        //Check userId is not empty.
        If(String.isNotEmpty(userId))
        {
            //Call the apex methode using userId parameter.
            listWrappers = DPP_Portal_Controller.getUserAndContactInfo(userId);
        }
        return listWrappers;
    }
    
    /**************************************************************************************************************
* @Method Name        : getUserAndContactInfo
* @description        : This method is calling from getUserAndContactInformation method	and using this method, we are getting the logged in user record and there contact related account 
related active contact records and add into the wrapper class.
* @Last Modified By   : naman.gupta@qsc.com
* @param			  : userId.
**************************************************************************************************************/
    Private static List<Wrapper> getUserAndContactInfo(String userId)
    {
        //Getting user record for getting ContactId and Contact.AccountId using userId.
        List<User> listUsers = [SELECT Id, ContactId, Contact.AccountId
                                FROM User
                                WHERE Id =: userId
                               ];
        
        List<Wrapper> listWrappers = new List<Wrapper>();        
        
        //Check listUsers is not empty.
        If(!listUsers.isEmpty())
        {
            //Check user ContactId and Contact.AccountId is not null.
            If(listUsers[0].ContactId != null && listUsers[0].Contact.AccountId != null)
            {
                //Getting contact records using listUsers[0].Contact.AccountId.
                List<Contact> listContacts = [SELECT Id, Name, AccountId, Account.DPP_Agreement_Signed_Date__c, Account.Account_Category__c,
                                              DPP_Access__c
                                              FROM Contact
                                              WHERE AccountId =: listUsers[0].Contact.AccountId
                                              AND Account.Account_Category__c = 'Developer Partner'
                                             ];
                
                
                system.debug('Record Size : ' + listContacts.size()); 
                
                //Check listContacts is not empty.
                If(!listContacts.isEmpty())
                {
                    Set<Id> setContactIds = new Set<Id>();
                    Map<Id, User> mapContactIdAndUsers = new Map<Id, User>();
                    
                    //Iterating listContacts records.
                    For(Contact objContact : listContacts)
                    {
                        //Filling the set.
                        setContactIds.add(objContact.Id);
                    }
                    
                    //Check setContactIds is not empty.
                    If(!setContactIds.isEmpty())
                    {
                        //Getting all the user records, which is related to ContactId using mapContacts.keySet().
                        List<User> listContactUsers = [SELECT Id, Name, Email, ContactId, isActive, SmallPhotoUrl
                                                       FROM User
                                                       WHERE ContactId IN : setContactIds
                                                      ];
                        
                        //Check listContactUsers is not empty.
                        If(!listContactUsers.isEmpty())
                        {
                            //Iterating listContactUsers records.
                            For(User objUser : listContactUsers)
                            {
                                mapContactIdAndUsers.put(objUser.ContactId, objUser);
                            }
                        }
                    }
                    
                    system.debug('List of contact records : ' + listContacts);
                    
                    //Iterating listContacts records.
                    For(Contact objContact : listContacts)
                    {
                        //Adding record value into wrapper.
                        Wrapper objWrapper = new Wrapper();
                        objWrapper.objContact = objContact;
                        
                        If(objContact.DPP_Access__c != null && objContact.DPP_Access__c == 'Admin')
                        {
                            objWrapper.isUserAdmin = true;
                            objWrapper.isContactInActive = false;
                        }
                        Else If(objContact.DPP_Access__c != null && objContact.DPP_Access__c == 'User')
                        {
                            objWrapper.isUserAdmin = false;
                            objWrapper.isContactInActive = false;
                        }
                        Else
                        {
                            objWrapper.isContactInActive = true;
                        }
                        
                        //Checking contact related user is exist or not.
                        If(mapContactIdAndUsers.containsKey(objContact.Id))
                        {
                            objWrapper.isUserAvailable = true;
                            objWrapper.userImageUrl = mapContactIdAndUsers.get(objContact.Id).SmallPhotoUrl;
                        }
                        Else
                        {
                            objWrapper.userImageUrl = '';
                            objWrapper.isUserAvailable = false;
                            objWrapper.isContactInActive = false;
                        }
                        listWrappers.add(objWrapper);
                    }
                }
            }
        }
        return listWrappers;
    }
    
    //Wrapper class.
    public class Wrapper
    {
        @AuraEnabled public Contact objContact;
        @AuraEnabled public Boolean isUserAdmin;
        @AuraEnabled public Boolean isUserAvailable;
        @AuraEnabled public Boolean isContactInActive;
        @AuraEnabled public String userImageUrl;
        
        public Wrapper()
        {
            
        }
    }
    
    /**************************************************************************************************************
* @Method Name        : updateContactDPPAccess
* @description        : This method is called from dppManageAccount.js in lwc component, which is used in the 
community. Using this method, we are updating the user related contact dpp access field value.
* @Last Modified By   : naman.gupta@qsc.com
* @param			  : isDPPAccessAdmin, contactId and isContactUserActive.
**************************************************************************************************************/
    @AuraEnabled
    Public static List<Wrapper> updateContactDPPAccess(Boolean isDPPAccessAdmin, String contactId, Boolean isContactUserActive)
    {
        system.debug('Checked : ' + isDPPAccessAdmin);
        system.debug('contactId : ' + contactId);
        
        //Getting community logged in user id. 
        String userId = userinfo.getUserId();
        
        List<Wrapper> listWrappers = new List<Wrapper>();
        
        //Check contactId is not empty.
        If(String.isNotEmpty(contactId))
        {
            //Getting the contact record.
            List<Contact> listContacts = [SELECT Id, DPP_Access__c
                                          FROM Contact
                                          WHERE Id =: contactId
                                         ];
            system.debug('listContacts : ' + listContacts);
            //Check listContacts is not empty.
            If(!listContacts.isEmpty())
            {
                If(isDPPAccessAdmin != null && isDPPAccessAdmin == true)
                {
                    listContacts[0].DPP_Access__c = 'Admin';
                }
                Else If(isDPPAccessAdmin != null && isDPPAccessAdmin == false)
                {
                    listContacts[0].DPP_Access__c = 'User';
                }
                Else If(isContactUserActive != null && isContactUserActive == true)
                {
                    listContacts[0].DPP_Access__c = 'User';
                }
                Else If(isContactUserActive != null && isContactUserActive == false)
                {
                    listContacts[0].DPP_Access__c = 'Inactive';
                }
                
                UPDATE listContacts;
                
                //Check userId is not empty.
                If(String.isNotEmpty(userId))
                {
                    //Call the apex methode using userId parameter.
                    listWrappers = DPP_Portal_Controller.getUserAndContactInfo(userId);
                }
            }
        }
        return listWrappers;
    }
    
    /**************************************************************************************************************
* @Method Name        : getAssetInformation
* @description        : This method is called from DPP_Portal_Home_AuraHelper.js in aura component, which is used in the 
community. Using this method, we are getting the asset record and their 
contact-related records and add them into the assetWrapper class.
* @Last Modified By   : naman.gupta@qsc.com
* @param			  : No parameter.
**************************************************************************************************************/
    @AuraEnabled
    Public static List<assetWrapper> getAssetInformation()
    {
        //Getting community logged in user id. 
        String userId = userinfo.getUserId();
        
        List<assetWrapper> listAssetWrappers = new List<assetWrapper>();
        
        //Check userId is not empty.
        If(String.isNotEmpty(userId))
        {
            //Getting user record for getting ContactId and Contact.AccountId using userId.
            List<User> listUsers = [SELECT Id, ContactId, Contact.AccountId, Contact.Account.Name, Contact.DPP_Certification_Status__c
                                    FROM User
                                    WHERE Id =: userId
                                   ];
            
            //Check listUsers is not empty.
            If(!listUsers.isEmpty())
            {
                //Check user ContactId and Contact.AccountId is not null.
                If(listUsers[0].ContactId != null && listUsers[0].Contact.AccountId != null)
                {
                    List<Asset> listAssets = [SELECT Id, Name, Description, AssociatedQSYSDeveloper__c, Web_Name_of_Integration__c, AccountId, Account.Name, Asset_Stage__c, X3rd_Party_Developer_Contact__c, DPP_Asset_Stage__c, DPP_Notification_Dismissed__c 
                                              FROM Asset
                                              WHERE AssociatedQSYSDeveloper__c =: listUsers[0].Contact.AccountId
                                             ];
                    String accountId = listUsers[0].Contact.AccountId;
                    system.debug('Account id ------> ' + accountId);
                    //Getting Portal Logo from account record related notes and attachment.
                    List<ContentDocumentLink> listContentDocumentLinks = [SELECT Id, LinkedEntityId, ContentDocumentId 
                                                                          FROM ContentDocumentLink
                                                                          WHERE LinkedEntityId =: listUsers[0].Contact.AccountId
                                                                         ];
                    system.debug('listContentDocumentLinks ------> ' + listContentDocumentLinks);
                    String portalLogoUrl = '';
                    //Check listContentDocumentLinks is not empty.
                    If(!listContentDocumentLinks.isEmpty())
                    {
                        Set<Id> setContentDocumentIds = new Set<Id>();
                        
                        //Iterating listContentDocumentLinks records.
                        For(ContentDocumentLink objContentDocumentLink : listContentDocumentLinks)
                        {
                            //Check ContentDocumentId is not null.
                            If(objContentDocumentLink.ContentDocumentId != null)
                            {
                                setContentDocumentIds.add(objContentDocumentLink.ContentDocumentId);
                            }
                        }
                        system.debug('setContentDocumentIds ------> ' + setContentDocumentIds);
                        //Check setContentDocumentIds is not empty.
                        If(!setContentDocumentIds.isEmpty())
                        {
                            List<ContentVersion> listContentVersions = [SELECT Id, ContentDocumentId, FileType, VersionDataUrl, Title 
                                                                        FROM ContentVersion
                                                                        WHERE ContentDocumentId IN : setContentDocumentIds
                                                                        AND FileType != 'SNOTE'
                                                                        AND FileType = 'PNG'
                                                                        LIMIT 1
                                                                       ];
                            //Check listContentVersions is not empty.
                            If(!listContentVersions.isEmpty())
                            {
                                portalLogoUrl = listContentVersions[0].VersionDataUrl;
                            }
                        }
                    }
                    
                    Integer count = 0;
                    Boolean isLoggedInUserCertificationActive = (listUsers[0].Contact.DPP_Certification_Status__c != null && listUsers[0].Contact.DPP_Certification_Status__c == 'Active') ? true : false;
                    Boolean isLoggedInUserCertificationInActive = (listUsers[0].Contact.DPP_Certification_Status__c != null && listUsers[0].Contact.DPP_Certification_Status__c == 'Inactive') ? true : false;
                    String loggedInUserContactAccountName = listUsers[0].Contact.Account.Name != null ? listUsers[0].Contact.Account.Name : '';
                    
                    //Check listAssets is not empty.
                    If(!listAssets.isEmpty())
                    {
                        Set<Id> setContactIds = new Set<Id>();
                        Map<Id, User> mapContactIdAndUsers = new Map<Id, User>();
                        
                        //Iterating listAssets records.
                        For(Asset objAsset : listAssets)
                        {
                            If(objAsset.X3rd_Party_Developer_Contact__c != null)
                            {
                                //Filling the set.
                                setContactIds.add(objAsset.X3rd_Party_Developer_Contact__c);
                            }
                            If(objAsset.X3rd_Party_Developer_Contact__c != null && objAsset.X3rd_Party_Developer_Contact__c == listUsers[0].ContactId && objAsset.Asset_Stage__c != null && objAsset.Asset_Stage__c == 'Development')
                            {
                                count = count + 1;
                            }
                        }
                        
                        //Check setContactIds is not empty.
                        If(!setContactIds.isEmpty())
                        {
                            //Getting all the user records, which is related to ContactId using setContactIds.
                            List<User> listContactUsers = [SELECT Id, ContactId, SmallPhotoUrl
                                                           FROM User
                                                           WHERE ContactId IN : setContactIds
                                                          ];
                            
                            //Check listContactUsers is not empty.
                            If(!listContactUsers.isEmpty())
                            {
                                //Iterating listContactUsers records.
                                For(User objUser : listContactUsers)
                                {
                                    mapContactIdAndUsers.put(objUser.ContactId, objUser);
                                }
                            }
                        }
                        
                        //Iterating listAssets records.
                        For(Asset objAsset : listAssets)
                        {
                            //Adding record value into assetWrapper.
                            assetWrapper objAssetWrapper = new assetWrapper();
                            objAssetWrapper.objAsset = objAsset;
                            
                            If(objAsset.DPP_Notification_Dismissed__c == false && objAsset.Asset_Stage__c != null && (objAsset.DPP_Asset_Stage__c != null || String.isBlank(objAsset.DPP_Asset_Stage__c)) && objAsset.Asset_Stage__c != objAsset.DPP_Asset_Stage__c && (objAsset.Asset_Stage__c == 'Development' || objAsset.Asset_Stage__c == 'Staged' || objAsset.Asset_Stage__c == 'Released'))
                            {
                                objAssetWrapper.objAssetStage = objAsset;
                            }
                            
                            objAssetWrapper.userAssetInDevelopment = count;
                            objAssetWrapper.isLoggedInUserCertificationActive = isLoggedInUserCertificationActive;
                            objAssetWrapper.isLoggedInUserCertificationInActive = isLoggedInUserCertificationInActive;
                            objAssetWrapper.loggedInUserContactAccountName = loggedInUserContactAccountName;
                            objAssetWrapper.portalLogoUrl = portalLogoUrl;
                            
                            //Checking contact related user is exist or not.
                            If(objAsset.X3rd_Party_Developer_Contact__c != null && mapContactIdAndUsers.containsKey(objAsset.X3rd_Party_Developer_Contact__c) && mapContactIdAndUsers.get(objAsset.X3rd_Party_Developer_Contact__c).SmallPhotoUrl != null)
                            {
                                objAssetWrapper.userImageUrl = mapContactIdAndUsers.get(objAsset.X3rd_Party_Developer_Contact__c).SmallPhotoUrl;
                            }
                            
                            listAssetWrappers.add(objAssetWrapper);
                        }
                    }
                    Else If(listAssets.isEmpty())
                    {
                        //Adding record value into assetWrapper.
                        assetWrapper objAssetWrapper = new assetWrapper();
                        objAssetWrapper.userAssetInDevelopment = count;
                        objAssetWrapper.isLoggedInUserCertificationActive = isLoggedInUserCertificationActive;
                        objAssetWrapper.isLoggedInUserCertificationInActive = isLoggedInUserCertificationInActive;
                        objAssetWrapper.loggedInUserContactAccountName = loggedInUserContactAccountName;
                        objAssetWrapper.portalLogoUrl = portalLogoUrl;
                        listAssetWrappers.add(objAssetWrapper);
                    }
                }
            }
        }
        return listAssetWrappers;
    }
    
    //assetWrapper class.
    public class assetWrapper
    {
        @AuraEnabled public Asset objAsset;
        @AuraEnabled public Asset objAssetStage;//It is used for asset stages, shown to the DPP admin only on the notification section.
        @AuraEnabled public String userImageUrl;
        @AuraEnabled public Integer userAssetInDevelopment;
        @AuraEnabled public Boolean isLoggedInUserCertificationActive;
        @AuraEnabled public Boolean isLoggedInUserCertificationInActive;
        @AuraEnabled public String loggedInUserContactAccountName;
        @AuraEnabled public String portalLogoUrl;
        
        public assetWrapper()
        {
            
        }
    }
    
    /**************************************************************************************************************
* @Method Name        : getDPPAccessIsAdminOrUser
* @description        : This method is called from dppNewAsset.js in lwc component, which is used in the 
community. Using this method, we are getting the logged-in user account record.
* @Last Modified By   : naman.gupta@qsc.com
* @param			  : No parameter.
**************************************************************************************************************/
    @AuraEnabled(cacheable=true)
    Public static User getAccountDetails()
    {
        User userRecord = [SELECT Id, Contact.AccountId, Contact.Account.Name, ContactId, Contact.Name, Contact.Email, Contact.DPP_Access__c 
                           FROM User 
                           WHERE ID =: UserInfo.getUserId() 
                           LIMIT 1
                          ];
        return userRecord;
    }
    
    /**************************************************************************************************************
* @Method Name        : createOpportunity
* @description        : This method is called from dppNewAsset.js in lwc component, which is used in the 
community. Using this method, we are creating opportunity and contentdocument records.
* @Last Modified By   : naman.gupta@qsc.com
* @param			  : qysReq.
**************************************************************************************************************/
    
    @AuraEnabled
    public static string createOpportunity(Object qysReq) 
    {
        system.debug('Wrapper : ' + qysReq);
        QYSFormRequestWrapper qysRequest = (QYSFormRequestWrapper)JSON.deserialize(JSON.serialize(qysReq), QYSFormRequestWrapper.class);
        system.debug('qysRequest : ' + qysRequest);
        Opportunity oppRecord = new Opportunity();
        
        If(qysRequest != null)
        {
            Try
            {
                Id allianceOppRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Alliance_Opportunity').getRecordTypeId();
                
                OppRecord.StageName = 'Candidate';
                OppRecord.CloseDate = System.Today().addDays(3);
                oppRecord.Send_Email_To_Account_Owner__c = true;
                
                If(qysRequest.integrationApplicability != null)
                {
                    oppRecord.Name = qysRequest.integrationApplicability;
                }
                
                If(allianceOppRT != null)
                {
                    oppRecord.RecordTypeId = allianceOppRT;
                }
                
                oppRecord.Request_Integration_Category__c = 'Utility';
                
                If(qysRequest.accountId != null)
                {
                    oppRecord.accountId = qysRequest.accountId;
                    oppRecord.AssociatedQSYSDeveloper__c = qysRequest.accountId;
                }
                
                If(qysRequest.primaryContactId != null)
                {
                    oppRecord.Primary_Contact__c = qysRequest.primaryContactId;
                }
                
                If(qysRequest.integrationObjective != null)
                {
                    oppRecord.Request_Integration_Objective__c = qysRequest.integrationObjective;
                }
                
                If(qysRequest.desiredInstallationDate != null)
                {
                    oppRecord.Request_Desired_Installation_Date__C = qysRequest.desiredInstallationDate;
                }
                
                If(qysRequest.integrationDeveloperName != null)
                {
                    oppRecord.Request_Integration_Developer_Name__c = qysRequest.integrationDeveloperName;
                }
                
                If(qysRequest.integrationDeveloperEmail != null)
                {
                    oppRecord.Request_Integration_Developer_Email__c = qysRequest.integrationDeveloperEmail;
                }
                
                If(qysRequest.contactEmail != null)
                {
                    oppRecord.Request_Contact_Email__c = qysRequest.contactEmail;
                }
                
                If(qysRequest.phone != null)
                {
                    oppRecord.Request_Phone__c = qysRequest.phone;
                }
                
                If(qysRequest.apiLink != null)
                {
                    oppRecord.Request_API_Link__c = qysRequest.apiLink;
                }
                
                List<string> verticalsServedList = qysRequest.verticalsServed;
                
                If(verticalsServedList != null)
                {
                    String verticalsValues = '';
                    
                    For(String str : verticalsServedList)
                    {
                        verticalsValues = str + ';' + verticalsValues; 
                    }
                    
                    oppRecord.Request_Verticals_Served__c = verticalsValues.removeEnd(';');
                }
                
                database.insert(oppRecord);
                
                System.debug('===============oppRecord : ' + oppRecord);
                
                // Get file Ids and link them to opportunity Id 
                If(oppRecord.Id != null)
                {
                    //Email goes to tammy.
                    String newOpportunityEmailTemplateName = System.Label.New_Opportunity_Email_Template;
                    system.debug('New_Opportunity_Email_Template : ' + newOpportunityEmailTemplateName);
                    
                    If(String.isNotBlank(newOpportunityEmailTemplateName))
                    {
                        String emailAddress = System.Label.New_Opportunity_Email_Address;
                        
                        //Call the apex method for sending email.
                        DPP_Portal_Controller.emailSendNotification(newOpportunityEmailTemplateName, emailAddress, oppRecord.Primary_Contact__c, oppRecord.Id);
                    }
                    
                    system.debug('Files..............');
                    If(qysRequest.apiFileUploaderFileName != null && qysRequest.apiFileUploaderFileBase64 != null)
                    {
                        ContentVersion cv = createContentVersion(qysRequest.apiFileUploaderFileBase64, qysRequest.apiFileUploaderFileName);
                        If(cv.Id != null)
                        {
                            system.debug('CV ID : ' + cv.Id);
                            ContentDocumentLink cdl = createContentLink(cv.Id, oppRecord.Id);
                        }
                    }
                    
                    If(qysRequest.logosFileUploaderFileName != null && qysRequest.logosFileUploaderFileBase64 != null)
                    {
                        ContentVersion cv = createContentVersion(qysRequest.logosFileUploaderFileBase64, qysRequest.logosFileUploaderFileName);
                        If(cv.Id != null)
                        {
                            ContentDocumentLink cdl = createContentLink(cv.Id, oppRecord.Id);
                        }
                    }
                    
                    If(qysRequest.prodImgFileUploaderFileName != null && qysRequest.prodImgFileUploaderFileBase64 != null)
                    {
                        ContentVersion cv = createContentVersion(qysRequest.prodImgFileUploaderFileBase64, qysRequest.prodImgFileUploaderFileName);
                        If(cv.Id != null)
                        {
                            ContentDocumentLink cdl = createContentLink(cv.Id, oppRecord.Id);
                        }
                    }
                }
                system.debug('File inserted.....');
                
                return '';
            }
            catch(exception ex)
            {
                system.debug('Exception caught: ' + ex + ' Line No: ' + ex.getLineNumber());
                String errorMsg = ex.getMessage();
                throw new AuraHandledException(errorMsg);
            }
        }
        else
        {
            String errorMsg = 'Please input data to create an opportunity.';
            throw new AuraHandledException(errorMsg);
        }
    }
    
    public static ContentVersion createContentVersion(String base64, String filename)
    {
        system.debug('CV Base 64 : ' + base64);
        system.debug('CV filename : ' + filename);
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        If(Test.isRunningTest())
        {
            Id networkId = [SELECT Id, Name FROM Network WHERE Name = 'QSC Communities for Developers'].Id;
            cv.networkId =  networkId;
        }
        try 
        {
            INSERT cv;
            return cv;
        } 
        catch(DMLException e) 
        {
            System.debug('CV Error : ' + e.getMessage());
            return null;
        }
    }
    
    @TestVisible 
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) 
    {
        If (contentVersionId == null || recordId == null) 
        { 
            return null; 
        }
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        
        cdl.ContentDocumentId = [SELECT ContentDocumentId 
                                 FROM ContentVersion 
                                 WHERE Id =: contentVersionId
                                ].ContentDocumentId;
        
        cdl.LinkedEntityId = recordId;
        
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        try 
        {
            INSERT cdl;
            return cdl;
        } 
        catch(DMLException e) 
        {
            System.debug(e);
            return null;
        }
    }
    
    public class QYSFormRequestWrapper
    {
        @AuraEnabled
        public string  accountId; //AssociatedQSYSDeveloper__c
        @AuraEnabled
        public String  primaryContactId; //Primary_Contact__c
        @AuraEnabled
        public string  contactEmail; //Request_Contact_Email__c
        @AuraEnabled
        public string  phone; //Request_Phone__c
        @AuraEnabled
        public list<String>  verticalsServed; //Request_Verticals_Served__c
        @AuraEnabled
        public string  integrationApplicability; //Name
        @AuraEnabled
        public string  integrationObjective; //Request_Integration_Objective__c
        @AuraEnabled
        public string  integrationDeveloperName; //Request_Integration_Developer_Name__c
        @AuraEnabled
        public string integrationDeveloperEmail; //Request_Integration_Developer_Email__c
        @AuraEnabled
        public date  desiredInstallationDate; //Request_Desired_Installation_Date__C
        @AuraEnabled
        public String apiLink; //Request_API_Link__c
        @AuraEnabled
        public fileUpload  apiFileUploader;
        @AuraEnabled
        public String  apiFileUploaderFileName;
        @AuraEnabled
        public String  apiFileUploaderFileBase64;
        @AuraEnabled
        public fileUpload  logosFileUploader;
        @AuraEnabled
        public String  logosFileUploaderFileName;
        @AuraEnabled
        public String  logosFileUploaderFileBase64;
        @AuraEnabled
        public fileUpload  prodImgFileUploader;
        @AuraEnabled
        public String  prodImgFileUploaderFileName;
        @AuraEnabled
        public String  prodImgFileUploaderFileBase64;
        
        public QYSFormRequestWrapper()
        {
        }
    }
    
    public class fileUpload
    {
        public string base64;
        public string fileName;
    }
    
    /**************************************************************************************************************
* @Method Name        : assetStagePickListValueDynamically
* @description        : This method is called from dppAllAssets.js in lwc component, which is used in the 
community. Using this method, Fetching asset stage field (picklist) values from Asset object.
* @Last Modified By   : naman.gupta@qsc.com
* @param			  : 
**************************************************************************************************************/
    
    @AuraEnabled
    public static Map<String, String> assetStagePickListValueDynamically() 
    {
        Map<String, String> mapAssetStageFieldValues = new Map<String, String>();
        
        Schema.DescribeSObjectResult objDescribe = Asset.getSObjectType().getDescribe();     
        Map<String, Schema.SObjectField> customFieldMap = objDescribe.fields.getMap();      
        List<Schema.PicklistEntry> custPickValues = customFieldMap.get('Asset_Stage__c').getDescribe().getPickListValues();
        
        For(Schema.PicklistEntry myCustPick: custPickValues) 
        {
            mapAssetStageFieldValues.put(myCustPick.getValue(), myCustPick.getLabel());
        }
        return mapAssetStageFieldValues;
    }
    
    
    /**************************************************************************************************************
* @Method Name        : getActiveAdminAndUserContact
* @description        : This method is called from dppBetaAccess.js in lwc component, which is used in the 
community. Using this method, Fetching active user and admin records using accountId.
* @Last Modified By   : naman.gupta@qsc.com
* @param			  : accountId.
**************************************************************************************************************/
    
    @AuraEnabled
    public static List<Contact> getActiveAdminAndUserContact(String activeAccountId) 
    {
        List<Contact> listContacts = new List<Contact>();
        
        If(String.isNotBlank(activeAccountId))
        {
            listContacts = [SELECT Id, Name, AccountId, DPP_Access__c 
                            FROM Contact
                            WHERE AccountId =: activeAccountId
                            AND DPP_Access__c = 'Admin'
                            AND Status__c = 'Active'
                           ];
        }
        return listContacts;
    }
    
    /**************************************************************************************************************
* @Method Name        : sendEmailForBetaAccess
* @description        : This method is called from dppBetaAccess.js in lwc component, which is used in the 
community. Using this method, sending the email notification.
* @Last Modified By   : naman.gupta@qsc.com
* @param			  : selectedContactId.
**************************************************************************************************************/
    
    @AuraEnabled
    public static String sendEmailForBetaAccess(String selectedContactId) 
    {
        String emailMsg = '';
        
        If(String.isNotBlank(selectedContactId))
        {
            String betaAccessEmailTemplateName = System.Label.Beta_Access_Email_Template;
            system.debug('beta Access Email Template Name : ' + betaAccessEmailTemplateName);
            
            If(String.isNotBlank(betaAccessEmailTemplateName))
            {
                String emailAddress = System.Label.Beta_Access_Email_Address;
                
                //Call the apex method.
                emailMsg = DPP_Portal_Controller.emailSendNotification(betaAccessEmailTemplateName, emailAddress, selectedContactId, '');
            }
        }
        Else
        {
            emailMsg = 'error';
        }
        return emailMsg;
    }
    
    private static String emailSendNotification(String emailTemplateName, String emailAddress, String recordId, String relatedRecordId)
    {
        String emailMsg = '';
        
        If(String.isNotBlank(emailTemplateName))
        {
            //Getting email template details using SOQL.
            List<EmailTemplate> listEmailTemplates = [SELECT Id, Name, DeveloperName, Subject 
                                                      FROM EmailTemplate 
                                                      WHERE DeveloperName =: emailTemplateName.trim()
                                                     ];
            
            If(!listEmailTemplates.isEmpty())
            {
                List<String> listEmails = new List<String>();
                
                //String emailAddress = System.Label.Beta_Access_Email_Address;
                
                If(String.isNotBlank(emailAddress) && emailAddress.contains(','))
                {
                    listEmails.addAll(emailAddress.split(','));                       
                }
                Else If(String.isNotBlank(emailAddress))
                {
                    listEmails.add(emailAddress.trim());
                }
                
                //New instance of a single email message
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                // Who you are sending the email to
                If(String.isNotBlank(recordId))
                {
                    system.debug('Record Id : ' + recordId);
                    mail.setTargetObjectId(recordId);
                }
                If(String.isNotBlank(relatedRecordId))
                {
                    system.debug('Related Record Id : ' + relatedRecordId);
                    mail.setWhatId(relatedRecordId);
                }
                // The email template ID used for the email
                mail.setTemplateId(listEmailTemplates[0].Id);
                
                If(!listEmails.isEmpty())
                {
                    mail.setToAddresses(listEmails);
                }
                mail.setBccSender(false);
                mail.setUseSignature(false);
                mail.setSaveAsActivity(false);  
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {mail};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                
                If(results != null)
                {
                    If(results[0].success) 
                    {
                        System.debug('The email was sent successfully.');
                        emailMsg = 'success';
                    } 
                    Else 
                    {
                        System.debug('The email failed to send : ' + results[0].errors[0].message);
                        emailMsg = 'The email failed to send : ' + results[0].errors[0].message;
                    }
                }
                
            }
        }
        return emailMsg;
    }
    
    /**************************************************************************************************************
* @Method Name        : closeNotification
* @description        : This method is called from DppAllAssets.js, DppManageAccount in lwc component and DPP_Portal_Home_AuraHelper.js in aura component, which is used in the 
community. Using this method, we are remove the notification from notification section.
* @Last Modified By   : naman.gupta@qsc.com
* @param			  : recordId.
**************************************************************************************************************/
    @AuraEnabled
    Public static Boolean closeNotification(String recordId)
    {
        Boolean isSuccess = false;
        
        //Check recordId is not blank.
        If(String.isNotBlank(recordId))
        {
            List<Asset> listAssets = [SELECT Id, DPP_Notification_Dismissed__c
                                      FROM Asset
                                      WHERE Id =: recordId
                                     ];
            //Check listAssets is not empty.
            If(!listAssets.isEmpty())
            {
                listAssets[0].DPP_Notification_Dismissed__c = true;
                UPDATE listAssets;
                
               isSuccess = true;
            }
        }
        
        return isSuccess;
    }
}