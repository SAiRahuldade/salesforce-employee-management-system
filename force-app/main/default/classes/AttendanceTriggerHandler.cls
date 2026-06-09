public class AttendanceTriggerHandler {

    public static void populateDate(List<Attendance__c> attendances) {
        for(Attendance__c a : attendances) {
            if(a.Check_In_Time__c != null) {
                a.Date__c = a.Check_In_Time__c.date();
            }
        }
    }

    public static void validateCheckInOut(
        List<Attendance__c> attendances
    ) {

        for(Attendance__c a : attendances) {

            if(
                a.Check_In_Time__c != null &&
                a.Check_Out_Time__c != null &&
                a.Check_Out_Time__c <= a.Check_In_Time__c
            ) {
                a.addError(
                    'Check Out Time must be after Check In Time.'
                );
            }
        }
    }
    public static void validateDuplicateAttendance(
    List<Attendance__c> attendances
) {

    Set<Id> employeeIds = new Set<Id>();
    Set<Date> dates = new Set<Date>();

    for(Attendance__c a : attendances) {

        if(a.Employee__c != null && a.Date__c != null) {

            employeeIds.add(a.Employee__c);
            dates.add(a.Date__c);
        }
    }

    List<Attendance__c> existingRecords = [
        SELECT Id,
               Employee__c,
               Date__c
        FROM Attendance__c
        WHERE Employee__c IN :employeeIds
        AND Date__c IN :dates
    ];

    for(Attendance__c newRecord : attendances) {

        for(Attendance__c existing : existingRecords) {

            if(
                newRecord.Employee__c == existing.Employee__c &&
                newRecord.Date__c == existing.Date__c
            ) {

                newRecord.addError(
                    'Attendance already exists for this employee on this date.'
                );
            }
        }
    }
}
}