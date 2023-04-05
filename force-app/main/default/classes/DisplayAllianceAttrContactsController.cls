public with sharing class DisplayAllianceAttrContactsController {
    public static string TPP_Primary_Contact ='TPP Primary Contact';
    public static string TPP_Technical_Contact ='TPP Technical Contact';
    public static string TPP_Marketing_Contact ='TPP Marketing Contact';
    public static string TPP_Billing_Contact ='TPP Billing Contact';
    public static string TPP_Admin_Contact ='TPP Admin Contact';
    public static string TPP_Legal_Contact ='TPP Legal Contact';
    public static string TPPPrimaryContact ='TPPPrimaryContact';
    public static string TPPTechnicalContact ='TPPTechnicalContact';
    public static string TPPMarketingContact ='TPPMarketingContact';
    public static string TPPBillingContact ='TPPBillingContact';
    public static string TPPAdminContact ='TPPAdminContact';
    public static string TPPLegalContact ='TPPLegalContact';
    @AuraEnabled(cacheable = true)
    public static Map<String,List<contact>> getAllianceAttrContactData(string accId) {
        Map<String,List<contact>> attrContactMap = new Map<String,List<contact>>();
        for(Contact c :[select id,Name,Email,Phone,Alliance_Attributes__c from Contact where accountId=:accId and Alliance_Attributes__c!=null]){
            if(c.Alliance_Attributes__c.contains(TPP_Primary_Contact)){
                if(attrContactMap.containskey(TPPPrimaryContact)){
                    attrContactMap.get(TPPPrimaryContact).add(c);
                }
                else{
                    attrContactMap.put(TPPPrimaryContact, new List<contact>{c});
                }
            }
            if(c.Alliance_Attributes__c.contains(TPP_Technical_Contact)){
                if(attrContactMap.containskey(TPPTechnicalContact)){
                    attrContactMap.get(TPPTechnicalContact).add(c);
                }
                else{
                    attrContactMap.put(TPPTechnicalContact, new List<contact>{c});
                }
            }
            if(c.Alliance_Attributes__c.contains(TPP_Marketing_Contact)){
                if(attrContactMap.containskey(TPPMarketingContact)){
                    attrContactMap.get(TPPMarketingContact).add(c);
                }
                else{
                    attrContactMap.put(TPPMarketingContact, new List<contact>{c});
                }
            }
            if(c.Alliance_Attributes__c.contains(TPP_Billing_Contact)){
                if(attrContactMap.containskey(TPPBillingContact)){
                    attrContactMap.get(TPPBillingContact).add(c);
                }
                else{
                    attrContactMap.put(TPPBillingContact, new List<contact>{c});
                }
            }
            if(c.Alliance_Attributes__c.contains(TPP_Admin_Contact)){
                if(attrContactMap.containskey(TPPAdminContact)){
                    attrContactMap.get(TPPAdminContact).add(c);
                }
                else{
                    attrContactMap.put(TPPAdminContact, new List<contact>{c});
                }
            }
            if(c.Alliance_Attributes__c.contains(TPP_Legal_Contact)){
                if(attrContactMap.containskey(TPPLegalContact)){
                    attrContactMap.get(TPPLegalContact).add(c);
                }
                else{
                    attrContactMap.put(TPPLegalContact, new List<contact>{c});
                }
            }
        }
        if(!attrContactMap.isEmpty()){
            return attrContactMap;
        }
        else{
            return null;
        }
       
    }
}