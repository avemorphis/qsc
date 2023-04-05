/**
 * @File Name          : DatatableController.cls
 * @Description        : 
 * @Author             : Sasank Subrahmanyam V..github
 * @Group              : 
 * @Last Modified By   : Uday Kumar k
**/
public with sharing class DatatableController {

    @AuraEnabled
    public static Map<String, Object> fetchDataMapCached(Map<String, Object> params) {
        return fetchDataMap(params);
    }

    @AuraEnabled
    public static Map<String, Object> fetchDataMap(Map<String, Object> params) {

        String objectName = params.containsKey('objectName') ? (String)params.get('objectName') : null;
        String fields = params.containsKey('fields') ? (String)params.get('fields') : null;
        String queryFilters = params.containsKey('queryFilters') ? (String)params.get('queryFilters') : null;
        String queryFilterswithQuery = params.containsKey('queryFilterswithQuery') ? (String)params.get('queryFilterswithQuery') : null;
        String sortBy = params.containsKey('sortBy') ? (String)params.get('sortBy') : null;
        String queryType = params.containsKey('queryType') ? (String)params.get('queryType') : null;
        String soslSearchTerm = params.containsKey('soslSearchTerm') ? (String)params.get('soslSearchTerm') : null;
        Boolean sortAsc = params.containsKey('sortAsc') ? (Boolean)params.get('sortAsc') : false;
        Integer limitRecords = params.containsKey('limitRecords') ? Integer.valueOf(params.get('limitRecords')) : null;
        
        try{
            //Initial checks
            //
            system.debug('queryFilters' + queryFilters);
            system.debug('queryFiltersque' + queryFilterswithQuery);    
            
            
            String limitRecordsStr = String.valueOf(Integer.valueOf(limitRecords));
            List<sObject> queryresultevalues = new List<sObject>();
            SET<String> queryresult = new SET<String>();
            //Declare query string
            String query;
            
            //Query initialization for Soql and Sosl
            if(queryType == 'SOQL'){
                query = 'SELECT Id, ' + fields + ' FROM ' + objectName;
            }
            else if(queryType == 'SOSL') {
                query = 'Id, ' + fields;
            }
            
            //Adding filters
            if(String.isNotBlank(queryFilters)){
                query += ' WHERE ' + queryFilters;
            }
            
            system.debug('query' + queryFilterswithQuery);
            
            if(String.isNotBlank(queryFilterswithQuery)){
                for(SObject so:Database.query(queryFilterswithQuery)){
                    queryresultevalues.add(so);
                    system.debug(so);
                }
            }
            
             if(String.isNotBlank(queryFilterswithQuery) && !queryresultevalues.isEmpty() ){
                query += String.valueOf(queryresultevalues[0].Id) ;
            }

            system.debug('query' + query);
            //Adding order by and limit records
            if(String.isNotBlank(sortBy) && queryType == 'SOQL'){
                query += ' ORDER BY ' + sortBy + (sortAsc?' ASC ':' DESC ');
            }
            
           if(String.isNotBlank(limitRecordsStr)) {
                query += ' LIMIT ' + limitRecordsStr;
     //              query += ' LIMIT ' + 1000;
            }
            
            //Log the query before getting query results from database
            Map<String, Object> returnMap = new Map<String, Object>();
            List<sObject> sObjectsList = new List<sObject>();
            if(queryType == 'SOQL'){
                system.debug('query => '+query);
                try{
                sObjectsList = Database.query(query);
                }catch(exception e){
                    system.debug('e' + e.getMessage());
                }
            }
            else if(queryType == 'SOSL') {
                query = 'FIND \'' + String.escapeSingleQuotes(soslSearchTerm) + '\' IN ALL FIELDS RETURNING ' + objectName + '(' + query + ')';
                system.debug('query => '+query);
                sObjectsList = Search.query(query)[0];
            }

            returnMap.put('records', sObjectsList);
            
            //Log the result
            system.debug('returnMap => '+returnMap);
            
            return returnMap;     
        }
        catch(Exception ex) {
            system.debug('Error => '+ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }   
    }

}