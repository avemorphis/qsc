@istest
private class OpportunityReport2WeekPrior_Test {
    @testsetup
    private static void doSetup(){
        List<opportunity> opList = new List<opportunity>();
        Date startDate = date.parse(System.today().format());
        for(integer i=1; i<31; i++){
            Opportunity o = new Opportunity();
            o.name = 'Test OP'+ i;
            if(math.mod(i, 5) == 0){
                o.StageName = 'Closed';
            }else{
                o.StageName = 'Investigation';
            }
            o.CloseDate = startDate;
            startDate = startDate.addDays(1);
            oplist.add(o);
        }
        insert oplist;
    }
    
    @isTest
    private static void doTesting(){
        List<opportunity> opList = new List<opportunity>();
        Date dt = date.parse(System.today().format());
        System.debug(dt);
        Date dtLast = date.parse(dt.addDays(14).format());
        System.debug(dtLast);
        Test.startTest();
        String sch = '0 0 23 * * ?';
		system.schedule('Schedule Test', sch, new scheduleBatchClassOpportunityExpires());
        opList = [Select id, CloseDate, Name, Partner_Account__r.Name, End_User_Account__c, Amount, StageName, Owner.Name,OwnerId from Opportunity where closedate >=:dt and CloseDate <=:dtLast and (not stagename like '%Closed%') order by closedate, ownerid];
        for(Opportunity o: oplist)
            system.debug('DT: ' + o.closedate);
        Test.stopTest();
        System.assertEquals(12, opList.size());
        System.assertEquals(dt, opList[0].CloseDate);
        System.assertEquals(dtLast.addDays(-1), opList[opList.size()-1].CloseDate); //Every 5th record is marked as Closed; So 
        
    }
}