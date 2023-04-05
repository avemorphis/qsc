global class scheduleBatchIdeaComment implements Schedulable {
   global void execute(SchedulableContext sc) {
      BatchScheduleIdeaComments b = new BatchScheduleIdeaComments(); 
      database.executebatch(b);
   }
}