public with sharing class AttendanceController {

    @AuraEnabled(cacheable=true)
    public static List<Attendance__c> getAttendances() {
        return [
            SELECT Id, Name, Date__c, Check_In_Time__c,
                   Check_Out_Time__c, Status__c,
                   Employee__c, Employee__r.Name
            FROM Attendance__c
            ORDER BY Date__c DESC
        ];
    }

    @AuraEnabled
    public static void saveAttendance(Attendance__c a) {
        upsert a;
    }

    @AuraEnabled
    public static void deleteAttendance(Id attendanceId) {
        delete [SELECT Id FROM Attendance__c WHERE Id = :attendanceId];
    }

    @AuraEnabled(cacheable=true)
    public static List<Attendance__c> getAttendanceByEmployee(Id employeeId) {
        return [
            SELECT Id, Name, Date__c, Check_In_Time__c,
                   Check_Out_Time__c, Status__c
            FROM Attendance__c
            WHERE Employee__c = :employeeId
            ORDER BY Date__c DESC
        ];
    }
}