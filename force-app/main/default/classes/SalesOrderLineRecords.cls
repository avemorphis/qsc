/**************************************************************************************************************
* @File Name          : SalesOrderLineRecords.cls
* @description        : This class is calling from SalesOrderLineRecords.js in lwc component which is used in community.
* @Author             : naman.gupta@qsc.com
* @Group              : 
* @Last Modified By   : naman.gupta@qsc.com
* @Last Modified On   : 28/02/2023
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    28/02/2023   	naman.gupta
**************************************************************************************************************/
public class SalesOrderLineRecords 
{
    /**************************************************************************************************************
* @Method Name        : getSalesOrderLineRecords
* @description        : This method is called from SalesOrderLineRecords.js in lwc component, which is used in the 
community using this method, we are getting the Sales Order Line Records.
* @Last Modified By   : naman.gupta@qsc.com
* @param			  : limitSize and offset.
**************************************************************************************************************/
    @AuraEnabled
    Public Static List<SalesOrderLineWrapper> getSalesOrderLineRecords(String recordId, Integer limitSize, Integer offset)
    {
        List<SalesOrderLineWrapper> listSalesOrderLineWrappers = new List<SalesOrderLineWrapper>();
        Map<String, String> mapSalesOrderLineFields = new Map<String, String>();
        system.debug('Record Id : ' + recordId);
        If(String.isNotBlank(recordId))
        {
            
            //Getting Fields from field set using SalesOrderlines__x external object.
            For(Schema.FieldSetMember fldSet : SObjectType.SalesOrderlines__x.FieldSets.Sales_Order_Line.getFields()) 
            {
                If(fldSet.getLabel() != null && fldSet.getFieldPath() != null)
                {
                    mapSalesOrderLineFields.put(fldSet.getFieldPath(), fldSet.getLabel());
                }
            }
            
            //Check mapSalesOrderLineFields is not empty.
            If(!mapSalesOrderLineFields.isEmpty())
            {
                List<String> listFields = new List<String>();
                listFields.addAll(mapSalesOrderLineFields.keySet());
                
                If(limitSize != NULL && offset != NULL)
                {
                    String query = 'SELECT ' + String.join(listFields, ', ') + ' FROM SalesOrderlines__x WHERE Order_Number__r.Id =: recordId LIMIT : limitSize OFFSET : offset';
                    system.debug('query : ' + query);
                    
                    //Getting SalesOrderlines__x records.
                    List<sObject> listSalesOrderLines = Database.query(query);
                    system.debug('Records : ' + listSalesOrderLines);
                    
                    String query1 = 'SELECT ' + String.join(listFields, ', ') + ' FROM SalesOrderlines__x WHERE Order_Number__r.Id =: recordId';
                    //Getting SalesOrderlines__x records.
                    List<sObject> listSalesOrderLineRecords = Database.query(query1);
                    system.debug('Records : ' + listSalesOrderLineRecords.size());
                    
                    //Create SalesOrderLineWrapper Record.
                    SalesOrderLineWrapper objSalesOrderLineWrapper = new SalesOrderLineWrapper();
                    objSalesOrderLineWrapper.mapSalesOrderLineField = mapSalesOrderLineFields;
                    objSalesOrderLineWrapper.listSalesOrderLines = listSalesOrderLines;
                    objSalesOrderLineWrapper.recordSize = listSalesOrderLineRecords.size();
                    
                    //Add SalesOrderLineWrapper Record into the listSalesOrderLineWrappers.
                    listSalesOrderLineWrappers.add(objSalesOrderLineWrapper);
                }
            }
            system.debug('Wrapper : ' + listSalesOrderLineWrappers);
        }
        return listSalesOrderLineWrappers;
    }
    
    Public class SalesOrderLineWrapper
    {
        @AuraEnabled
        Public Map<String, String> mapSalesOrderLineField;
        @AuraEnabled
        Public List<sObject> listSalesOrderLines;
        @AuraEnabled
        Public Integer recordSize;
        
        Public SalesOrderLineWrapper()
        {
            
        }
    }
}