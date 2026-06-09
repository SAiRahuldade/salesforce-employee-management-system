public with sharing class LeaveController {

    @AuraEnabled(cacheable=true)
    public static List<Leave_Request__c> getLeaveRequests() {
        return [
            SELECT Id, Name, Leave_Type__c, Start_Date__c,
                   End_Date__c, Reason__c, Status__c,
                   Employee__c, Employee__r.Name
            FROM Leave_Request__c
            ORDER BY CreatedDate DESC
        ];
    }

    @AuraEnabled
    public static void saveLeaveRequest(Leave_Request__c l) {
        upsert l;
    }

    @AuraEnabled
    public static void deleteLeaveRequest(Id leaveId) {
        delete [SELECT Id FROM Leave_Request__c WHERE Id = :leaveId];
    }
}