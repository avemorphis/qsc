public class TPPDataUpdateHelper {
    public static void companyInformationUpdate(List<TPP_Data_Update__e> tduList){
        List<account> acclist = new List<account>();
        account acc;
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emt = [Select id,Name from EmailTemplate where name = 'TPPCompanyInfoUpdate'];
        List<string> emailAddrLst = system.label.TPPCompanyInfoUpdateEmailAddr.split(';');
        for(TPP_Data_Update__e tdu : tduList){
            acc = new account();
            acc.Id = tdu.AccountId__c;
            acc.Company_Description__c = tdu.Account_Description__c;
            acclist.add(acc);
            //Set email
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setUseSignature(false);
            message.setBccSender(false);
            message.setSaveAsActivity(false);
            message.setTemplateID(emt.Id);
            message.setWhatId(tdu.AccountId__c); 
            message.setTargetObjectId(tdu.ContactId_for_Email__c);
            message.toAddresses = emailAddrLst;
            //message.bccAddresses = new String[] {'Tejasri.Arikat@qsc.com'};
            messages.add(message);
        }
        if(!acclist.isEmpty()){
            update acclist;
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            system.debug('results:::::::'+results);
        }
    }
    public static void assetInformationUpdate(List<TPP_Data_Update__e> tduList){
        List<asset> astlist = new List<asset>();
        asset ast;
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emt = [Select id,Name from EmailTemplate where name = 'TPPWebPublishingFormEmail'];
        List<string> emailAddrLst = system.label.TPPWebPublishingEmailAddr.split(';');
        for(TPP_Data_Update__e tdu : tduList){
            ast= new asset();
            ast.Id = tdu.AssetId__c;
            ast.Web_Name_of_Integration__c = tdu.Web_Name_of_Intg__c;
            ast.Web_Description_of_Integration__c = tdu.Web_Descr_of_Integ__c;
            astlist.add(ast);
            //Set email
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setUseSignature(false);
            message.setBccSender(false);
            message.setSaveAsActivity(false);
            message.setTemplateID(emt.Id);
            message.setWhatId(tdu.AssetId__c); 
            message.setTargetObjectId(tdu.ContactId_for_Email__c);
            message.toAddresses = emailAddrLst;
            message.bccAddresses = new String[] {'Tejasri.Arikat@qsc.com'};
            messages.add(message);
        }
        if(!astlist.isEmpty()){
            update astlist;
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            system.debug('results:::::::'+results);
        }
    }
}