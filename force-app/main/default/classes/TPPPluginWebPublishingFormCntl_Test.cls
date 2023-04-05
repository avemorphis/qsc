@isTest
public class TPPPluginWebPublishingFormCntl_Test{
    @testsetup
    public static void testsetupdata() {
        UserRole r = [select id from UserRole where developername ='CEO'];
        Id ap = [select id from profile where name='System Administrator'].id;
        User auser = new User(alias = 'test1234', email='test1234@noemail1.com',UserRoleId= r.Id,
        emailencodingkey='UTF-8', lastname='Testing4', languagelocalekey='en_US',
        localesidkey='en_US', profileid = ap, country='United States',IsActive =true,
        timezonesidkey='America/Los_Angeles', username='testerGenius@testCon1434.com');
        insert auser;
        system.runAs(auser) {
            NFR_API__c apiCS=caseDataFactory.customApisSetting();
            apiCS.Name = 'Case Trigger';
            insert apiCS;
            Account ac = new Account(name ='testAccount') ;
            insert ac; 
            Contact con = new Contact(LastName ='testCon143',email = 'testCon143@testCon1432.com',AccountId = ac.Id);
            insert con;  
                  
            Id p = [select id from profile where name='External User CCP Member'].id;
            User usr = new User(alias = 'test123', email='test123@noemail2.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p, country='United States',IsActive =true,
            contactid = con.id,
            timezonesidkey='America/Los_Angeles', username='testerTejabrilliant@testCon143.quiz');
            insert usr;
             
        }
    }
    public static testMethod void SaveFormDetailsinAsset() {
        
        test.startTest();
        Account acc = [select id from account limit 1];
        Asset a = new Asset();
        a.Accountid = acc.Id;
        a.name = 'asset test';
        insert a;
        CreateFilesDynamically.FileDataWrap files = new CreateFilesDynamically.FileDataWrap();
        files.fileName = 'test';
        files.fileContent = 'test';
        List<CreateFilesDynamically.FileDataWrap> fileslst = new List<CreateFilesDynamically.FileDataWrap>();
        fileslst.add(files);
        string flst = JSON.serialize(fileslst);
        TPPPluginWebPublishingFormCntl.SaveFormDetailsinAsset(string.valueOf(a.id),'Test','test','testfile','test',flst);
        
        test.stopTest();
    }
}