public with sharing class OpportunityTriggerHelper {
    
    public static void checkDeleteAllowed(Map<Id, Opportunity> opportunitiesMap) {
        List<Opportunity> opportunityList = opportunitiesMap.values();
        Set<Id> opportunityIds = opportunitiesMap.keySet();
        if(!Schema.sObjectType.Opportunity.isDeletable()){
            throw new CustomException('You don\'t have access to delete Opportunity records');
        }
        
        List<Opportunity> queriedOpportunity = queryOpportunityWithLineItems(opportunityIds);
        checkDeleteCriteria(queriedOpportunity, opportunitiesMap);
    }
	
    private static List<Opportunity> queryOpportunityWithLineItems (Set<Id> opportunityIds) {
       	if(!(Schema.sObjectType.Opportunity.isAccessible() && Schema.sObjectType.Opportunity.fields.StageName.isAccessible())){
        	throw new CustomException('You don\'t have access to read Opportunity record or stage field');
        } else if (! Schema.sObjectType.OpportunityLineItem.isAccessible()) {
            throw new CustomException('You don\'t have access to read OpportunityLineItems records');
        }
        List<Opportunity> queriedOpportunity = [select id, StageName, (select id from OpportunityLineItems) 
                                                from opportunity 
                                                where Id =: opportunityIds];
        return queriedOpportunity;
    }
    
    private static void checkDeleteCriteria(List<Opportunity> queriedOpportunity, Map<Id, Opportunity> opportunitiesMap){
        List<Opportunity> errorRecords = new List<Opportunity>();
        List<Opportunity> oppLineItemErrorRecords = new List<Opportunity>();
        List<String> opportunityErrorStages = CustomMetadataHelper.getOpportunityErrorStages();
        if(opportunityErrorStages.size() < 1){
            return;
        }
        for(Opportunity opp : queriedOpportunity){
            if(opportunityErrorStages.contains(opp.StageName) && opp.OpportunityLineItems.size() > 0) {
                Opportunity errorOpp = opportunitiesMap.get(opp.Id);
                errorRecords.add(errorOpp);
            }
        }
        if(errorRecords.size() > 0) {
            updateErrorOnRecords(errorRecords, String.format('Opportunity with stage values {0} and opportunity line items are not allowed to be deleted', new List<String>{String.join(opportunityErrorStages, ',')}));
        }
    }
    
    public static void updateErrorOnRecords(List<Opportunity> opportunityRecords, String message) {
        for(Opportunity opp :opportunityRecords){
            opp.addError(message);
        }
        return;
    }
}