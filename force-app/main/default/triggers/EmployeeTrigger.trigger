trigger EmployeeTrigger on Employee__c (
    before insert,
    before update
) {

    EmployeeTriggerHandler.validateSalary(
        Trigger.new
    );

    EmployeeTriggerHandler.validateDuplicateEmail(
        Trigger.new
    );

}