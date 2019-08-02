trigger OpportunityTrigger on Opportunity (before delete) {
    try{
        if(Trigger.isDelete && Trigger.isBefore){
        	OpportunityTriggerHelper.checkDeleteAllowed(Trigger.oldMap);  
        }
    } catch (exception e){
        OpportunityTriggerHelper.updateErrorOnRecords(Trigger.old, e.getMessage());
    }
}