public with sharing class QYSPluginFormController {
    @AuraEnabled
    public static user getAccountDetails() {
        User userRecord = [SELECT Id, AccountId, Account.Name, ContactId, Contact.Name, Contact.Email FROM User WHERE ID =: UserInfo.getUserId() LIMIT 1 ];
        return userRecord;
    }
    @AuraEnabled
    public static string createOpportunity(QYSFormRequestWrapper qysRequest) {
        Opportunity oppRecord = new Opportunity();
      
        if(qysRequest!=null){
            try{
                list<string> verticalsServedList = qysRequest.verticalsServed;
                Id allianceOppRT =  Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Alliance Opportunity').getRecordTypeId();
                OppRecord.Name = 'A&E Request'+System.Now();
                OppRecord.StageName = 'Candidate';
                OppRecord.CloseDate = System.Today().addDays(3);
                oppRecord.RecordTypeId = allianceOppRT;
                if(qysRequest.accountId!=null){
                    oppRecord.AccountId = qysRequest.accountId;
                }
                if(qysRequest.compDivBusinessUnit!=null){
                    oppRecord.Request_Company_Division_Business_Unit__c = qysRequest.compDivBusinessUnit;
                }
                
                if(qysRequest.primaryContactId!=null){
                    oppRecord.Primary_Contact__c = qysRequest.primaryContactId;
                }
                if(qysRequest.integrationCateg!=null){
                    oppRecord.Request_Integration_Category__c = qysRequest.integrationCateg;
                }
                if(qysRequest.integrationApplicability!=null){
                    oppRecord.Request_Integration_Applicability__c = qysRequest.integrationApplicability;
                }
                if(qysRequest.integrationObjective!=null){
                    oppRecord.Request_Integration_Objective__c = qysRequest.integrationObjective;
                }
                if(qysRequest.desiredInstallationDate!=null){
                    oppRecord.Request_Desired_Installation_Date__c = qysRequest.desiredInstallationDate;
                }
                if(qysRequest.integrationDeveloperName!=null){
                    oppRecord.Request_Integration_Developer_Name__c = qysRequest.integrationDeveloperName;
                }
                if(qysRequest.integrationDeveloperEmail!=null){
                     oppRecord.Request_Integration_Developer_Email__c = qysRequest.integrationDeveloperEmail;
                }
                if(qysRequest.contactEmail!=null){
                     oppRecord.Request_Contact_Email__c = qysRequest.contactEmail;
                }
                if(qysRequest.phone!=null){
                     oppRecord.Request_Phone__c = qysRequest.phone;
                }
                if(qysRequest.apiLink!=null){
                     oppRecord.Request_API_Link__c = qysRequest.apiLink;
                }
                if(verticalsServedList != null)
                {
                    String verticalsValues = '';
                    for(String str : verticalsServedList){
                        verticalsValues = str+';'+verticalsValues; 
                        
                    }
                    oppRecord.Request_Verticals_Served__c = verticalsValues.removeEnd(';');
                }
                
                database.insert(oppRecord);
                 System.debug('===============oppRecord'+oppRecord);
                // Get file Ids and link them to opportunity Id 
                if(oppRecord.Id!=null){
                    system.debug('Files..............');
                    if(qysRequest.apiFilesDataFileName != null && qysRequest.apiFilesDataFileBase64 != null){
                        ContentVersion cv = CreateFilesDynamically.createContentVersion(qysRequest.apiFilesDataFileBase64, qysRequest.apiFilesDataFileName);
                        ContentDocumentLink cdl = CreateFilesDynamically.createContentLink(cv.Id, oppRecord.Id);
                    }
                    if(string.isNotBlank(qysRequest.lstlogosFilesData)){
                        CreateFilesDynamically.createFilesinBulk(oppRecord.Id,qysRequest.lstlogosFilesData);
                    }
                    if(string.isNotBlank(qysRequest.lstprodImgFilesData)){
                        CreateFilesDynamically.createFilesinBulk(oppRecord.Id,qysRequest.lstprodImgFilesData);
                    }
                }
                system.debug('File inserted.....');
                Opportunity c = [select id,Name from Opportunity where Id=: oppRecord.Id];
                Network myNetwork = [SELECT Id FROM Network WHERE Name ='tpp' ];
                string networkOppUrl = Network.getLoginUrl(myNetwork.id).removeEnd('login');
                networkOppUrl += 'opportunity/'+oppRecord.Id;
                system.debug('networkOppUrl>>>>>>>'+networkOppUrl);
				return networkOppUrl;
            }
            catch(exception ex){
                system.debug('Exception caught: '+ex+' Line No: '+ex.getLineNumber());
                String errorMsg = ex.getMessage();
                throw new AuraHandledException(errorMsg);
            }
        }
        else{
            String errorMsg = 'Please input data to create an opportunity.';
            throw new AuraHandledException(errorMsg);
        }
    }
    public class QYSFormRequestWrapper{
        @AuraEnabled
        public string  company{get;set;} //AccountId
        @AuraEnabled
        public string  accountId{get;set;} //AccountId
        @AuraEnabled
        public string  compDivBusinessUnit{get;set;} //Notes__c
        @AuraEnabled
        public String  primaryContactId{get;set;} //Primary_Contact__c
        @AuraEnabled
        public string  contactEmail{get;set;}
        @AuraEnabled
        public string  phone{get;set;}
        @AuraEnabled
        public list<String>  verticalsServed{get;set;}
        @AuraEnabled
        public string  integrationCateg{get;set;} //Asset_Manager_Categorization__c
        @AuraEnabled
        public string  integrationApplicability{get;set;} //Partner_Links_and_Resources__c
        @AuraEnabled
        public string  integrationObjective{get;set;} //Web_Description_of_Integration__c
        @AuraEnabled
        public boolean  integrationDeveloper{get;set;}
        @AuraEnabled
        public string  integrationDeveloperName{get;set;} //AssociatedQSYSDeveloper__c
        @AuraEnabled
        public string integrationDeveloperEmail{get;set;}
        @AuraEnabled
        public date  desiredInstallationDate{get;set;} //Est_Installation_Date__c
        @AuraEnabled
        public FileDataWrap  apiFilesData{get;set;}
        @AuraEnabled
        public String  apiFilesDataFileName{get;set;}
        @AuraEnabled
        public String  apiFilesDataFileBase64{get;set;}
        @AuraEnabled
        public List<FileDataWrap>  logosFilesData{get;set;}
        @AuraEnabled
        public String  lstlogosFilesData{get;set;}
        @AuraEnabled
        public List<FileDataWrap>  prodImgFilesData{get;set;}
        @AuraEnabled
        public String  lstprodImgFilesData{get;set;}
        @AuraEnabled
        public String apiLink{get;set;}
    }
    public class FileDataWrap {
        public String fileName;
        public String fileContent;
    }
}