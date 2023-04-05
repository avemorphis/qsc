global class LMSAutomatedEmailScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      LMSAutomatedEmailBatch b = new LMSAutomatedEmailBatch(); 
      database.executebatch(b);
   }
}