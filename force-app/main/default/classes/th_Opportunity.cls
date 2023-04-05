//==================================================================================================
//  Object: th_cls
// Company: Young Technology Group
//  Author: Barney Young Jr.
// Comment: Opportunity Trigger Handler Class
//==================================================================================================
//          Date            Purpose
// Changes: 08/09/2019      Initial Version
//			12/10/2019		Commenting out due to request of QSC
//==================================================================================================

public class th_Opportunity  {

    //TH Variables
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    /*************NEW Varible AUTHOR-CHIRAG RATHI *****************/
    Public Id OppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Professional Services Opportunity').getRecordTypeId();
    Public Id AssetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Pro Services').getRecordTypeId();
    List<Asset> lstAssetInsert = new List<Asset>(); 
    /*********************NEW Varible END************************************************/
    //Constructor
    public th_Opportunity(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size; 
    }

	/**************************************************************************************************************
	OnAfterUpdate

	Order:
	1.  Checks if Opportunity status has been updated to 'Reflect Trail Success'

	Booleans:
	reflectTrialSuccess - Set of OpportunityIds that have been updated to 'Reflect Trial Success'

	Methods:
    sendReflectmail:  Emails Subscription Contacts Reflect Trial Success email template 
    **************************************************************************************************************/
    public void OnAfterUpdate(Opportunity[] oldContacts, Opportunity[] newContacts, map<Id, Opportunity> oldMap, map<Id, Opportunity> newMap){
        
		//Booleans
		Boolean reflectTrialSuccess = false;  //Opportunity Status = 'Reflect Trial Success'
		
		//reflect Opportunity Update Sets
		Set<Id> reflectOpportunityIds = new Set<Id>();                   

        for(Opportunity opp : newMap.values()){
		
			//1.  Checks if Opportunity status has been updated to 'Reflect Trail Success'
			if(opp.Status__c == 'Reflect Trial Success' && (opp.Status__c != oldMap.get(opp.Id).Status__c) ) {
				
				//Update Boolean
				//reflectTrialSuccess = true;

				//Populate reflectOpportunityIds
				//reflectOpportunityIds.add(opp.Id);
			}

        } 
        /*********************NEW CODE START,AUTHOR-CHIRAG RATHI ************************************************/
         for(Opportunity opi : [select id,name,Accountid,stagename, 
                                        Partner_Account__c,Status__c,User_Preference_1__c,User_Preference_2__c,PSID__c,Warranty_End_Date__c,Warranty_Start_Date__c,QSC_File_Deployment_Engineer__c	,QSC_Technical_Sponsor__c,QSC_Project_Manager__c,QSC_Programmer__c,File_Deployment_Sub_Contractor__c,Programming_Sub_Contractor__c, RecordTypeid from Opportunity
                                        where Id IN :newMap.keyset() and RecordTypeid=:OppRecordTypeId  ])
        {
           
            if(opi.stagename == 'Quote Accepted SOW signed' && (opi.stagename != oldMap.get(opi.Id).stagename) ){
            if(opi.Accountid != null){
            Asset Ast = new Asset();  
            Ast.name = opi.name;
            Ast.AccountId = opi.Accountid;
           // Ast.Product2Id = opi.Product2Id;
            Ast.Opportunity__c = opi.Id;
            Ast.Partner_Account__c = opi.Partner_Account__c;
            Ast.PSID__c = opi.PSID__c;
            Ast.Programming_Sub_Contractor__c = opi.Programming_Sub_Contractor__c;
            Ast.File_Deployment_Sub_Contractor__c = opi.File_Deployment_Sub_Contractor__c;
            Ast.QSC_Programmer__c = opi.QSC_Programmer__c;
            Ast.QSC_Project_Manager__c = opi.QSC_Project_Manager__c;
            Ast.QSC_Technical_Sponsor__c = opi.QSC_Technical_Sponsor__c;
            Ast.QSC_File_Deployment_Engineer__c	= opi.QSC_File_Deployment_Engineer__c;
            Ast.Warranty_Start_Date__c = opi.Warranty_Start_Date__c;
            Ast.Warranty_End_Date__c = opi.Warranty_End_Date__c;
            Ast.Status = opi.Status__c;
            Ast.User_Preference_2__c = opi.User_Preference_2__c;
            Ast.User_Preference_1__c = opi.User_Preference_1__c;
            Ast.RecordTypeId = AssetRecordTypeId ;
            lstAssetInsert.add(Ast);
            }
 		 }
        }
        if(lstAssetInsert.size() > 0){
            //database.insert (lstAssetInsert,false);
            insert lstAssetInsert;
        }
    /*********************NEW CODE END************************************************/
		//1.  Process Boolean -  reflect Opportunity Update Sets
		if(reflectTrialSuccess){			
			
			//sendTrialSuccessEmail
			//methods_sendReflectmail(reflectOpportunityIds);
        }
    }
}