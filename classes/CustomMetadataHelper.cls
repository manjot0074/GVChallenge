public with sharing class CustomMetadataHelper {
    private static List<String> opportunityErrorStages;
    
    public static List<String> getOpportunityErrorStages() {
        if(opportunityErrorStages != null){
            return opportunityErrorStages;
        }
        opportunityErrorStages = new List<String>();
        List<Opportunity_Delete_Error_Stage__mdt> opportunityErrorStageRecords = [select id, Picklist_Name__c  from Opportunity_Delete_Error_Stage__mdt];
        for(Opportunity_Delete_Error_Stage__mdt opportunityErrorStage: opportunityErrorStageRecords){
            opportunityErrorStages.add(opportunityErrorStage.Picklist_Name__c);
        }
        return opportunityErrorStages;
    } 

}