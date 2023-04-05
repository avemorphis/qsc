/**

* @description        : BatchClass for making Active_in_Pricebook = true, for Product Whose atleast 1 PriceBookEntry is true and PriceBook isStandard= false 
* @Author             : prakhar.jain@qsc.com
* @Last Modified By   : prakhar.jain@qsc.con
* @Last Modified On   : 21/12/2022
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    21/12/2022     prakhar.jain@qsc.com       Initial Version
**/

public class priceBookEntryBatch implements Database.Batchable<sObject> 
{
    Public Database.QueryLocator start(Database.BatchableContext BC)
    {
        Set<Id> prodIdSet = new Set<Id>();
        
        
        //Querying ProductId from PriceBookEntry whose priceBook's isStandard is false and price is Active
        FOR (PriceBookEntry pbeList: [SELECT Id, Product2Id FROM PricebookEntry where Pricebook2.isStandard= false and Pricebook2.isActive=true and LastModifiedDate = today])
        {
            prodIdSet.add(pbeList.Product2Id);
            system.debug('Product Id: '+prodIdSet);
        }
        //Returning the list of Product whose id is in above query to execute
        RETURN database.getQueryLocator([SELECT Id FROM Product2 where id in: prodIdSet]);
    }
    
    Public void execute(Database.BatchableContext BC, List<Product2> prodList)
    {
        IF(!prodList.isEmpty()){
            system.debug('Product List: '+prodList);
            Map<id,List<PriceBookEntry>> prodMap = new Map<id, List<PriceBookEntry>>();
            
            //Iterating the Product list using ProductId from start method
            
            List<Product2> allProd= [SELECT id, Active_In_PriceBook__c, (SELECT id, Product2Id, isActive from PriceBookEntries) from Product2 where id in : prodList];
            FOR(Product2 prodObj:allProd)
            {
                prodMap.put(prodObj.id, prodObj.PriceBookEntries);
            }
            List<Product2> updateProd = new List<Product2>();
            FOR(Product2 prodObj1:allProd)
            {
                integer count =0;
                List<PriceBookEntry> newPbe = prodMap.get(prodObj1.id);
                For(PriceBookEntry pbe: newPbe){
                    if(pbe.isActive==true){
                        count++;
                    }
                }
                IF(count==0)
                {
                    prodObj1.Active_In_PriceBook__c=false;
                    updateProd.add(prodObj1);
                }
                ELSE
                {
                    prodObj1.Active_In_PriceBook__c=true;
                    updateProd.add(prodObj1);
                }
            }
            system.debug('Size of list: '+updateProd.size());
            UPDATE updateProd;
        }
     }
    
    Public void finish(Database.BatchableContext BC)
    {
        
    }
}