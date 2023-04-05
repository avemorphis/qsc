// Scheduler for the Rep account update 
global class RepAccountUpdateScheduler implements Schedulable{
    
    global void execute(SchedulableContext SC){
        RepAccountUpdateBatch batch = new RepAccountUpdateBatch();
        database.executebatch(batch);
    }
}