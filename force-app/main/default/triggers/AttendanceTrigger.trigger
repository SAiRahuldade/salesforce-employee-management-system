trigger AttendanceTrigger on Attendance__c (
    before insert,
    before update
) {

    AttendanceTriggerHandler.populateDate(
        Trigger.new
    );

    AttendanceTriggerHandler.validateCheckInOut(
        Trigger.new
    );

    AttendanceTriggerHandler.validateDuplicateAttendance(
        Trigger.new
    );
}