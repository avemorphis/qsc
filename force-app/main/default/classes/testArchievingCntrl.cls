/**

* @description        : ArchievingCntrl Testclass for fetching Chatter group and archieve and unarchieve group
* @Author             : aniruddha.vashishthe@qsc.com
* @Last Modified By   : prakhar.jain@qsc.com
* @Last Modified On   : 18/01/2023
* @Modification Log   : 
* Ver       Date            Author      		    		Modification
* 1.0    18/01/2023     aniruddha.vashishthe@qsc.com       Initial Version
**/
@isTest
public class testArchievingCntrl {
	@isTest
    public static void setTest()
    {
        List<String> unArchData = new List<String>();
        List<String> archData = new List<String>();
        List<String> archData2 = new List<String>();
         
        
        CollaborationGroup cg = new CollaborationGroup();
        cg.Name = 'Scripting controller';
        cg.IsArchived = true;
        cg.CollaborationType = 'public';
        cg.NetworkId = '0DB4X000000wkLpWAI';//Changed by prakhar.jain@qsc.com
        insert cg;
        
		CollaborationGroup cg1 = new CollaborationGroup();
        cg1.Name = 'Advanced controller';
        cg1.IsArchived = true;   
        cg1.CollaborationType = 'public';
        cg1.NetworkId = '0DB4X000000wkLpWAI';//Changed by prakhar.jain@qsc.com
		insert cg1;		
        
        CollaborationGroup cg2 = new CollaborationGroup();
        cg2.Name = 'Cloud Controller';
        cg2.IsArchived = false; 
        cg2.CollaborationType = 'public';
        cg2.NetworkId = '0DB4X000000wkLpWAI';//Changed by prakhar.jain@qsc.com
        insert cg2;
        
        CollaborationGroup cg3 = new CollaborationGroup();
        cg3.Name = 'Service controller';
        cg3.IsArchived = false;
        cg3.CollaborationType = 'public';
        cg3.NetworkId = '0DB4X000000wkLpWAI';//Changed by prakhar.jain@qsc.com
        insert cg3;
        
		unArchData.add(cg2.Id);
        unArchData.add(cg3.Id);
        
        archData.add(cg.Id);
        archData.add(cg1.Id);
        
        test.startTest();
        ArchievingCntrl.fetchGroupData();
        ArchievingCntrl.setGroupData(archData, unArchData);
        ArchievingCntrl.setGroupData(archData2, unArchData);
        test.stopTest();
        
    }
}