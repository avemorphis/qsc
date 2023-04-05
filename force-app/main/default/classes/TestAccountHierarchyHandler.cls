@istest
public class TestAccountHierarchyHandler {
    @testSetup
    public static void accountDataSetup(){
        FieloPLT__Program__c program=new FieloPLT__Program__c();
        program.Name='QSC Rewards higher education';
        insert program;
       
         FieloPLT__Program__c program2=new FieloPLT__Program__c();
        program2.Name='QSC Rewards higher education2';
        insert program2;
       
        Contact c=new Contact();
        c.LastName='Test Contact';
        c.Phone='12456';
        c.CurrencyIsoCode='USD';
        c.Email='test.contact@gmail.com';
        insert c;
        
        FieloPLT__Member__c memeber=new FieloPLT__Member__c();
        memeber.Name='Demo test Member';
        memeber.FieloPLT__Type__c='Individual Account';
        memeber.FieloPLT__Points__c=13;
        memeber.Prospectivepoints__c=21;
        memeber.FieloPLT__Program__c=program.Id;
        memeber.FieloPLT__Email__c='demo@gmail.com';
        memeber.FieloPLT__Contact__c=c.Id;
        insert memeber;
       
         FieloPLT__Member__c memeber2=new FieloPLT__Member__c();
        memeber2.Name='Demo test2 Member';
        memeber2.FieloPLT__Type__c='Individual Account';
        memeber2.FieloPLT__Points__c=15;
        memeber2.Prospectivepoints__c=21;
        memeber2.FieloPLT__Program__c=program2.Id;
        memeber2.FieloPLT__Email__c='demo@gmail2.com';
        memeber2.FieloPLT__Contact__c=c.Id;
        insert memeber2;
       
        AccountHierarchyHandler.isRunOnce=false;
        //Inserting Parent Account
        Account ac=new Account();
        ac.Name='Test Account';
        ac.CurrencyIsoCode='USD';
        //ac.F_Loyalty_Member__c=memeber.Id;
        insert ac;
    }
    
    @istest
    public static void testforInsert(){
        
        FieloPLT__Member__c memeber=[SELECT id from FieloPLT__Member__c Where Name='Demo test Member'];
        
        
        AccountHierarchyHandler.isRunOnce=false;
        // Retrieveing parent Account
        Account parentActID=[SELECT Id from Account Where Name='Test Account'];
        
        AccountHierarchyHandler.isRunOnce=true;
        //Inserting child account
        Account ac_child1=new Account();
        ac_child1.Name='Test Account Child';
        ac_child1.CurrencyIsoCode='USD';
        ac_child1.F_Loyalty_Member__c=memeber.Id;
        ac_child1.ParentId=parentActID.Id;
        insert ac_child1;
        
        AccountHierarchyHandler.isRunOnce=true;
        Account ac_child2=new Account();
        ac_child2.Name='Test Account Child2';
        ac_child2.CurrencyIsoCode='USD';
        ac_child2.F_Loyalty_Member__c=memeber.Id;
        //ac_child2.ParentId=parentActID.Id;
        insert ac_child2;
        
        memeber.FieloPLT__Account__c = ac_child1.Id;
        update memeber;
    }
    
    
    
    @istest
    public static void testforUpdate(){
        
        FieloPLT__Member__c memeber=[SELECT id from FieloPLT__Member__c Where Name='Demo test Member'];
        FieloPLT__Member__c memeber2=[SELECT id from FieloPLT__Member__c Where Name='Demo test2 Member'];
        
        Account parentActID=[SELECT Id from Account Where Name='Test Account'];
        
        AccountHierarchyHandler.isRunOnce=false;
        //Inserting Second Parent Account
        Account accfirstParent=new Account();
        accfirstParent.Name='Test Account demo';
        accfirstParent.CurrencyIsoCode='USD';
        //ac1.F_Loyalty_Member__c=memeber2.Id;
        insert accfirstParent;
        
        
        AccountHierarchyHandler.isRunOnce=false;
        Account ac_child1=new Account();
        ac_child1.Name='Test Account Child';
        ac_child1.CurrencyIsoCode='USD';
        ac_child1.F_Loyalty_Member__c=memeber.Id;
        ac_child1.ParentId=accfirstParent.Id;
        insert ac_child1;
        
        //AccountHierarchyHandler.isRunOnce=false;
        // Insert child account without parent
        Account ac_child2=new Account();
        ac_child2.Name='Test Account Child2';
        ac_child2.CurrencyIsoCode='USD';
        ac_child2.F_Loyalty_Member__c=memeber.Id;
        ac_child2.ParentId=accfirstParent.Id;
        insert ac_child2;
      
        Account ac_child3=new Account();
        ac_child3.Name='Test Account Child3';
        ac_child3.CurrencyIsoCode='USD';
        ac_child3.F_Loyalty_Member__c=memeber2.Id;
        ac_child3.ParentId=parentActID.Id;
        insert ac_child3;
      
        AccountHierarchyHandler.isRunOnce=true;
        ac_child1.ParentId=parentActID.ID;
        update ac_child1;
        
        AccountHierarchyHandler.isRunOnce=true;
        ac_child2.ParentId=parentActID.ID;
        update ac_child2;
        
         AccountHierarchyHandler.isRunOnce=true;
         ac_child3.F_Loyalty_Member__c=memeber2.Id;
        update ac_child3;
    }
    
    @istest
    public static void testforDelete(){
        
        FieloPLT__Member__c memeber=[SELECT id from FieloPLT__Member__c Where Name='Demo test Member'];
        
        Account parentActID=[SELECT Id from Account Where Name='Test Account'];
        
        AccountHierarchyHandler.isRunOnce=false;
        Account ac_child1=new Account();
        ac_child1.Name='Test Account Child';
        ac_child1.CurrencyIsoCode='USD';
        ac_child1.F_Loyalty_Member__c=memeber.Id;
        ac_child1.ParentId=parentActID.Id;
        insert ac_child1;
        
        AccountHierarchyHandler.isRunOnce=true;
        delete ac_child1;
    }
}