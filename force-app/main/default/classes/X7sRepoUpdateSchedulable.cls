global class X7sRepoUpdateSchedulable implements Schedulable {
   
    global void execute(SchedulableContext sc) {

        X7sUpdateForkWatchCountBatch b = new X7sUpdateForkWatchCountBatch();
        Database.executeBatch(b, 2);

    } 

}