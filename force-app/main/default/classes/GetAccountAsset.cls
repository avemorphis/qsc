/** 
* @File Name          : GetAccountAsset.cls 
* @description        : This class is being Called on the Quick Action Button which is present on the Asset Object 
* @Author             : prakhar.jain@qsc.com
* @Group              :  
* @Last Modified By   : prakhar.jain@qsc.com
* @Last Modified On   : 18/01/2023 
* @Modification Log   :  
* Ver       Date            Author                 Modification 
* 1.0   18/01/2023   prakhar.jain@qsc.com        Initial Version 
**/ 
public class GetAccountAsset {      
    /** 
* @description : getAsset method for doing a tour search based on a search string 
* @author : prakhar.jain@qsc.com | 18/01/2023   
* @param :  assetId
* @return : Contract Record  
**///This method is called from a doInit method of a createOrderQuickaction component and accepting an asset id as a parameter and returning the Activated Contract which is 
    // associated with the same account .
    @AuraEnabled(cacheable=true)
    public static Contract getContractRecord(Id assetId)
    {
        List<Asset> assetRecords = new List<Asset>();
        Id assetAccountId;
        Contract ContractRecord = new Contract();
        List<Contract> ContractList = new List<Contract>();
        
        system.debug('Asset Record Id' + assetId);
        If(assetId != null)
        {
            
            assetRecords = [SELECT Id, AccountId FROM Asset WHERE Id =: assetId AND AccountId != null  LIMIT 1];
        }
        If(assetRecords.size() > 0 && assetRecords[0] != null)
        {
            assetAccountId = assetRecords[0].AccountId;
        }              
        system.debug('Asset AccountId' + assetAccountId);
        If(assetAccountId != null)
        {
            ContractList = [SELECT Id,accountid,Status,Program_Idf__c,Certification__c,Verification__c,Scoping__c
                            FROM Contract WHERE AccountId =: assetAccountId  AND Status='Activated'
                            LIMIT 1];
        }
        system.debug('returned List ' + ContractList.size());
        
        If(ContractList.size() > 0)
        {
            ContractRecord = ContractList[0];
        }                    
        return ContractRecord;   
    }
    
    /** 
* @description :  createOpportunityOnSave method for creating an opportunity by accepting parameters 
* @author : prakhar.jain@qsc.com | 18/01/2023   
* @param :   creditvalue,accId,contractId,label
* @return : Contract Record  
**/   
    //This method updates the Contract Record if any value in Certifcation , Verification and Scoping fields changes.
    @AuraEnabled
    public static void updateContractRecordfinal(string certificationValue, string verificationValue , string scopingValue , contract contractRec)
    {
        string conid;
        Integer cervalue;
        Integer Verval; 
        Integer scopval;
        
        system.debug('Certification Value  : ' + certificationValue);
        system.debug('Verification Value : ' + verificationValue);
        system.debug('Scoping Value : ' + scopingValue);
        system.debug('ContractRec '+ contractRec);
        
        If(contractRec.Id != null)
        {
            conid = contractRec.Id;
        }
        If(certificationValue != null && certificationValue != '')
        {
            
            cervalue = integer.valueOf(certificationValue);
        }
        Else
        {
            cervalue = 0;
        }
        system.debug('cerval : '+ cervalue );
        
        If(verificationValue != null && verificationValue != '')
        {
            
            Verval = integer.valueOf(verificationValue);
        }
        Else
        {
            Verval = 0;
        }
        system.debug('Verval : '+ Verval );
        
        
        If(scopingValue != null && scopingValue != '')
        {
            
            scopval = integer.valueOf(scopingValue);
        }
        Else
        {
            scopval = 0;
        }
        system.debug('scopval : '+ scopval );
        
        List<Contract> ContRecList = [SELECT id,Certification__c,Verification__c,Scoping__c
                                      FROM Contract WHERE id =:conid LIMIT 1];
        ContRecList[0].Certification__c = cervalue;
        ContRecList[0].Verification__c = Verval;
        ContRecList[0].Scoping__c = scopval;
        ContRecList[0].Id = contractRec.Id;
        try{
        update ContRecList;
        }
        catch(Exception em){
               
              createCase(contractRec);
       
                
            }
        system.debug(' Updated Contract Record : ' + ContRecList[0].Verification__c + ContRecList[0].Certification__c + ContRecList[0].Scoping__c );
        
        
    }
    
    /** 
* @description :  createOpportunityOnSave method for creating an opportunity by accepting parameters 
* @author : prakhar.jain@qsc.com | 18/01/2023   
* @param :   creditvalue,contractRec,selectedMod
* @return : Contract Record  
**/
    // This method creates an opportunity based on credits and selected mode which are Certification, Verification and Scoping.
    @AuraEnabled
    public static Contract createOpportunityOnSave(Id assetId,string creditvalue,contract contractRec, string selectedMod)
    {        
        Integer credits = 0;
        
        Opportunity opp = new Opportunity();
        system.debug('selectedMod' + selectedMod + '  assetId :' + assetId);
        system.debug('value' + creditvalue);
    
        If( creditvalue != null || string.isNotBlank(creditvalue)){
            credits = integer.valueof(creditvalue);
        }
        
        //fetching recordTypeId Of opportunity object
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Program_Opportunity').getRecordTypeId();
        system.debug('rt' + recordTypeId);     
        system.debug('rt null' + recordTypeId != null);
        // Opportunity opp = new Opportunity();
        If(credits != null && credits > 0 )
        {
            //Creating Opportunity
            system.debug('value' + creditvalue);
            If(contractRec.AccountId != null)
            {
                opp.AccountId = contractRec.AccountId;
            }
            
            
            opp.Name = 'TPP OPP 0$';  
          //  opp.StageName ='Pending';
            If(selectedMod != null && selectedMod =='Certification')
            {
                Opp.Subscription_Type__c = 'TPP Certification';
            }
            Else If(selectedMod != null && selectedMod == 'Verification')
            {
                Opp.Subscription_Type__c = 'TPP Verification';
            } 
            Else If(selectedMod != null && selectedMod == 'Scoping')
            {
                Opp.Subscription_Type__c = 'TPP Scoping';
            }
             Else If(selectedMod != null && selectedMod == 'Re-Certification')
            {
                Opp.Subscription_Type__c = 'TPP Re-Certification';
            } 
            Else If(selectedMod != null && selectedMod == 'Re-Verification')
            {
                Opp.Subscription_Type__c = 'TPP Re-Verification';
            } 
           // opp.CloseDate =system.today().addMonths(5);
            opp.Type__c = 'Paid';
            opp.Free__c = true; //true
            If(recordTypeId != null)
            {
                opp.RecordTypeId = recordTypeId;
            }
            If(assetId != null)
            {
                opp.Asset__c = assetId;
            }
            If(contractRec.Program_Idf__c	!= null){
                opp.Program_ID__c = contractRec.Program_Idf__c;
            }
          
            
        }
        If(credits != null && credits == 0)
        {
            system.debug('value' + creditvalue);
            
            If(contractRec.AccountId != null)
            {
                opp.AccountId = contractRec.AccountId;
            }
            opp.Name = 'TPP Opp 1000$';  
            opp.StageName = 'Pending';
            If(selectedMod != null && selectedMod == 'Certification')
            {
                Opp.Subscription_Type__c = 'TPP Certification';
            } 
            Else If(selectedMod != null && selectedMod == 'Verification')
            {
                Opp.Subscription_Type__c = 'TPP Verification';
            }  
            Else If(selectedMod != null && selectedMod == 'Scoping')
            {
                Opp.Subscription_Type__c = 'TPP Scoping';
            }
            Else If(selectedMod != null && selectedMod == 'Re-Certification')
            {
                Opp.Subscription_Type__c = 'TPP Re-Certification';
            } 
            Else If(selectedMod != null && selectedMod == 'Re-Verification')
            {
                Opp.Subscription_Type__c = 'TPP Re-Verification';
            } 
            
            opp.CloseDate = system.today().addMonths(5);
            opp.Type__c = 'Paid';
            opp.Free__c = false;// false
            If(recordTypeId != null)
            {
                opp.RecordTypeId = recordTypeId;
            }
            If(assetId != null)
            {
                opp.Asset__c = assetId;
            }
            If(contractRec.Program_Idf__c	!= null){
                opp.Program_ID__c = contractRec.Program_Idf__c;
            }
            
        }
        system.debug('print');
        
        If(!Test.isRunningTest())
        {
            try
            {
            insert opp; 
            system.debug('recordId '+ opp.Id);
                 
            }
            catch(Exception em){
               
              createCase(contractRec);
       
                
            }
            
            system.debug('Calling Flow from apex');
            
            Map<String, Object> Params = new Map<String, Object>();
            Params.put('recordId', opp.Id);
            Id oppId = opp.Id;
            Flow.Interview.Call_from_Apex flowcall = new Flow.Interview.Call_from_Apex(Params);
            flowcall.start();
        }
        
        system.debug('Called Flow finishes');
        
        
        
        //Querying Contract record based on ContractId which is accepted in a method arguement
        If(contractRec.Verification__c != null && selectedMod == 'Verification' && contractRec.Verification__c != 0 )
        {      
            contractRec.Verification__c = contractRec.Verification__c - 1;
        }
        Else If(contractRec.Certification__c != null && selectedMod == 'Certification' && contractRec.Certification__c != 0)
        {
            contractRec.Certification__c = contractRec.Certification__c - 1;
        }
        Else If(contractRec.Scoping__c != null && selectedMod == 'Scoping' && contractRec.Scoping__c != 0)
        {
            contractRec.Scoping__c = contractRec.Scoping__c - 1;
        } 
        Else If(contractRec.Certification__c != null && selectedMod == 'Re-Certification' && contractRec.Certification__c != 0)
        {
            contractRec.Certification__c = contractRec.Certification__c - 1;
        } 
        Else If(contractRec.Verification__c != null && selectedMod == 'Re-Verification' && contractRec.Verification__c != 0 )
        {      
            contractRec.Verification__c = contractRec.Verification__c - 1;
        }
        try
        {
        update contractRec;
        }
        catch(Exception em)
        {
              createCase(contractRec);                
            }
        system.debug('contract Rec + ' + contractRec);
        return contractRec;
    }
    
    
    public static  void createCase(Contract conRec) {
        system.debug('conRec : '+ conRec.AccountId );
        Case CaseRecord = New Case();
        If(conRec.AccountId != null)
        {
            CaseRecord.AccountId = conRec.AccountId;
        }
       // CaseRecord.ContactId = '0037i000016PNkrAAG';
        caserecord.Subject = 'Console Application Exception';
            caseRecord.Country_of_use_pl__c= 'United States';
            CaseRecord.Status = 'Open'; 
            CaseRecord.SoftwareFirmwareVersion_p__c = 'Not Accessible' ;
            CaseRecord.Reason = 'Exception creating Subscription' ;
            CaseRecord.Priority= 'Expedite';
            CaseRecord.Type = 'Software Subscription';
            CaseRecord.Description = 'CurrentProcessStep.Error';
            CaseRecord.Origin = 'System';
        
           insert CaseRecord;
           //Database.insert(CaseRecord);
        system.debug('Caserecord : '+ CaseRecord );
    }
}