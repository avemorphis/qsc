/*
*******************************************************************************************
# FILE...BatchScheduleCaseContract
# CREATED BY...Meha Mathur
# CREATED DATE....8th Feb 2022
# LAST MODIFIED BY....Meha Mathur
# LAST MODIFIED DATE....8th Feb 2022
*******************************************************************************************
# AUTHOR...Meha Mathur
# DESCRIPTION...Batch schedule class for scheduling batches that will run after every 15 minutes for 
sending email with new multiple attachments on case and contract.
******************************************************************************************
*/
global class BatchScheduleCaseContract implements Schedulable {
     global void execute(SchedulableContext sc)

     {

    Database.executeBatch(new BatchSendEmailforContractwithAttachment(), 5);
         //Database.executeBatch(new BatchToSendEmailforCasewithAttachment(), 100);

     }

}