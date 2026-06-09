trigger AssignmentTrigger on Assignment__c (
    before insert,
    before update
) {

    AssignmentTriggerHandler.validateDuplicateAssignment(
        Trigger.new
    );

    AssignmentTriggerHandler.validateAllocationLimit(
        Trigger.new
    );

}